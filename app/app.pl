use strict;
use warnings;
use Data::Dumper qw{Dumper};
use Future::AsyncAwait; #await
use PAGI::Request;
use PAGI::Response;
use PAGI::App::File;
use File::Basename qw();

print "PID: $$\n";
local $Data::Dumper::Terse = 1;
local $Data::Dumper::Varname = 0;

my $PUBLIC_DIR = File::Basename::dirname(__FILE__);
die(qq{Error: PAGI::App::File Directory: "$PUBLIC_DIR" not readable}) unless -r $PUBLIC_DIR;
print qq{PAGI::App::File Directory: "$PUBLIC_DIR"\n};
my $static_app = PAGI::App::File->new(root => $PUBLIC_DIR)->to_app; #Caution: opens all files in path to web server

my $app = async sub  {
                      my @srs                      = @_;
                      my ($scope, $receive, $send) = @srs;
                      my $scope_type = $scope->{'type'};  # http, lifespan, websocket, etc.

                      if ($scope_type eq 'http') {
                        my $req          = PAGI::Request->new($scope, $receive);
                        my $host         = $req->host;          # example.com
                        my $method       = $req->method;        # GET, POST, etc.
                        my $path         = $req->path;          # /user/42
                        my $query_string = $req->query_string;  # ?query_string
                        print "Scope: $scope_type, Host: $host, Method: $method, Path: $path, Query String: $query_string\n";

                        my $res    = PAGI::Response->new($scope, $send);
                        if ($method eq 'GET') { #TODO: Port to PAGI::App::Router
                          if ($path eq '/') {
                            return await $res->html(root_html());
                          } elsif ($path eq '/json') {
                            return await $res->json({example=>'json'});
                          } elsif ($path eq '/diag') {
                            return await $res->text(Dumper($scope));
                          } elsif ($path eq '/text') {
                            return await $res->text('example text');
                          } elsif ($path eq '/html') {
                            return await $res->html('<p>example html</p>');
                          } elsif ($path eq '/redirect') {
                            return await $res->redirect('/');
                          } elsif ($path =~ m{\A/public/}) { #default: index.html
                            #TODO: change path to remove "/public" and then point static_app to sub folder for more security
                            return await $static_app->(@srs);
                          } else {
                            return await $res->status(404)->text('Not Found');
                          }
                        } elsif ($method eq 'POST') {
                          my $form = await $req->form;
                          if ($path eq '/submit') {
                            my $name = $form->get('name') || 'n/a'; #zero?
                            return await $res->html("<p>Name: $name</p>");
                          } else {
                            return await $res->status(404)->text('Not Found');
                          }
                        } else {
                          return await $res->status(405)->text('Method Not Allowed');
                        }
                      } elsif ($scope_type eq 'lifespan') {
                        return await lifespan_handler(@srs);
                      } else {
                        die qq{Error: Unsupported scope type: "$scope_type"};
                      }
                     };

async sub lifespan_handler {
  my ($scope, $receive, $send) = @_;
  while (1) {
    my $event = await $receive->();
    my $event_type = $event->{'type'};
    if ($event_type eq 'lifespan.startup') {
      print STDERR "[lifespan] Startup, PID $$\n";
      await $send->({ type => 'lifespan.startup.complete' });
    } elsif ($event_type eq 'lifespan.shutdown') {
      print STDERR "[lifespan] Shutdown, PID $$\n";
      await $send->({ type => 'lifespan.shutdown.complete' });
      last; #exit while on shutdown
    }
  }
}

my $return = $app;

sub root_html {
  return q{
           <p>Index</p>
           <ul>
             <li><a href="/json">GET: /json</a></li>
             <li><a href="/text">GET: /text</a></li>
             <li><a href="/html">GET: /html</a></li>
             <li><a href="/redirect">GET: /redirect</a></li>
             <li><a href="/public/file.txt">GET: /public/file.txt</a></li>
             <li><a href="/public/file.html">GET: /public/file.html</a></li>
             <li><a href="/public/file.png">GET: /public/file.png</a></li>
             <li>
               <form method="POST" action="/submit" enctype="multipart/form-data">
                 <input type="text" name="name"></input>
                 <input type="submit"></input>
               </form>
             </li>
           </ul>
  };
}
