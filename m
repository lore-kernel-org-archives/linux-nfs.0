Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6837 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932414AbaIWOz4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 10:55:56 -0400
Message-ID: <542189F6.1050406@RedHat.com>
Date: Tue, 23 Sep 2014 10:55:50 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-server: Replace rpc.svcgssd with gssproxy in
 systemd script
References: <1411146621-18797-1-git-send-email-steved@redhat.com>	<1411146621-18797-2-git-send-email-steved@redhat.com>	<541C892D.7020401@RedHat.com> <20140923112352.28917775@notabene.brown>
In-Reply-To: <20140923112352.28917775@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 09/22/2014 09:23 PM, NeilBrown wrote:
> 
> Hi Steve,
>  as gssproxy is part of a separate package, I don't think it is appropriate
>  for and nfs-utils service file to 'want' it.  I don't know that there are
>  any "rules" about this so I make it up as I go along, but that seems right
>  to me.
I was wondering about this... From a distro its easy... Just add a 
requirement in the spec file and you'll know the package will exist...
But upstream it may not so straightforward...   
 
> 
>  Instead, the .service file which the gssproxy package installs
>  should/could/might declare
> 
>     WantedBy=nfs-server.service
> 
>  so if that is enabled, the linkage gets created.
> 
>  Either way, my idea is that starting nfs-server should try to start both
>  svcgssd and gssproxy.
Right... this is the general consensuses...  

>  rpc-svcgssd.service already declares itself as being *after* gssproxy so if
>  both are available, gssproxy will be run first.
Ah.. I did miss this fact... That is very important! 

>  If gssproxy starts and finds the kernel supports it, then it will be running
>  when rpc-svcgssd.service starts up and the Conditions in there will cause it
>  to not start the actual daemon.
Those ConditionPathExists do indeed work... I think both of them need to stay... 

> 
>  So the nfs-utils .service files should not need changing.  All that should
>  be needed for gssproxy to be used is:
>  - gssproxy needs to be installed (of course)
>  - gssproxy.service needs to declare "WantedBy=nfs-server.service" in the
>    [Install] section
Right now gssproxy.service has:

[Unit]
Before=nfs-secure.service nfs-secure-server.service
Requires=proc-fs-nfsd.mount
^^^^ this Requires actually loads sunrpc, nfsd, auth_rpcgss
     another important fact!

 
[Install]
WantedBy=multi-user.target

So I went ahead and added "WantedBy=nfs-server.service" to the 
gssproxy.service file and re-installed the package... I didn't
see it make much difference.... both packages have to be enabled
for them to be started. 

>  - 'systemctl enable gssproxy' needs to have been run somehow.  There are
>    various ways to get this to happen at install time.
When gssproxy is enabled, it will be *always* started, whether the server 
is running or not... I was working toward only starting gssproxy when its
needed, like rpc.svcgssd is today. 

> 
> 
>  However I haven't really tested this much.  I know I said I would do some
>  testing of these unit files and I really do want to, but it just hasn't
>  happened yet because ... you know, "life". 
No problem... ;-) thanks for the help! 

> 
>  I had a look at the gssproxy.service file and it already has
>  'WantedBy=multi-user.target' the same as nfs-server.service.
>  So if they are both enabled, they should both be started at the same time,
>  and if should all *just*work*.
They do... I enable them both... everything comes up just fine... 

> 
>  I assume it doesn't *just*work* at present.  What is actually happening?  Do
>  you have gssproxy.service 'enabled'??
This is the problem... gssproxy has to be enabled... I don't think that's is
good... and not necessary... What (I think) is necessary is we create a 
dependency on gssproxy (like we do for rpcbind, keyutils, libevent, etc) and 
have the server bring up gssproxy when it comes up. That is achieved by
simply adding gssproxy.service to the nfs-server.service files:

diff -up f21/systemd/nfs-server.service.orig f21/systemd/nfs-server.service
--- f21/systemd/nfs-server.service.orig 2014-09-23 10:38:39.572726403 -0400
+++ f21/systemd/nfs-server.service  2014-09-23 10:39:17.604412641 -0400
@@ -2,12 +2,13 @@
 Description=NFS server and services
 Requires= network.target proc-fs-nfsd.mount rpcbind.target
 Requires= nfs-mountd.service
-Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
+Wants=rpc-statd.service nfs-idmapd.service 
+Wants=rpc-gssd.service gssproxy.service rpc-svcgssd.service
 Wants=rpc-statd-notify.service

 After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
 After= nfs-idmapd.service rpc-statd.service
-After= rpc-gssd.service rpc-svcgssd.service
+After= rpc-gssd.service gssproxy.service rpc-svcgssd.service
 Before= rpc-statd-notify.service

 Wants=nfs-config.service


The patch does not require gssproxy to be enabled so gssproxy will be started
only when the server is started. Now if an admin what to enable gssproxy for
some other reason so be it... Things will still work. 

Through this discussion both of my concerns about this patch have been address:

1) Having both gssproxy and rpc.gssd started/running at the same time because 
   systemd starts everything at once... but that can't happen because of 
   the 'After=gssproxy.service' in rpc-svcgssd.service. That's something I 
   missed... thank you for pointing  that out! That is very good foresight 
   on your part! IMHO...

2) This whole business about how auth_rpcgss gets loaded... It is crystal
   to me that the "Requires=proc-fs-nfsd.mount" in gssproxy.service is 
   loading the modules. You disable the server, disable the client and 
   enable gssproxy then reboot... lsmod | grep rpc show sunrpc, nfsd, and 
   auth_rpcgss are loaded. So nothing has to change in gssproxy.service and
   another unit file to load the modules is not needed. 

So I guess at the end of the day... I want to break the 'Unknown' Wants rule... ;-) 
By adding a dependency to gssproxy and by having nfs-server 'want' the gssproxy
service...  Its the cleanest way... IMHO... 

steved.
 
