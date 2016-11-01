Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51314 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751723AbcKAQva (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Nov 2016 12:51:30 -0400
Subject: Re: [PATCH - rpcbind] Provide systemd unit files for rpcbind
To: NeilBrown <neilb@suse.com>
References: <87oa2q14yc.fsf@notabene.neil.brown.name>
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <8c1fa65d-9efc-462a-b6c8-7ed518f0dfe4@RedHat.com>
Date: Tue, 1 Nov 2016 12:51:29 -0400
MIME-Version: 1.0
In-Reply-To: <87oa2q14yc.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

My apologies for not getting to this sooner... 
A rough a couple of weeks... 
On 10/12/2016 02:01 AM, NeilBrown wrote:
> 
> 
> To encourage uniformity across distributions, provide
> systemd unit files.
> 
> If extra arguments are wanted for rpcbind, a drop-in should be used
> to set the Environment= or read and EnvironmentFile=
> 
> As the "run" directory could be /run or /var/run we RequiresMountsFor
> both of these.
Talking with the systemd folks they strongly sugguest we just
use /run (not /var/run) and drop the RequiresMountsFor.

> 
> rpcbind.service pulls in rpcbind.socket so that the listening sockets
> chosen there will always be used.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .gitignore                 |  1 +
>  Makefile.am                |  4 ++++
>  configure.ac               |  7 ++++++-
>  systemd/rpcbind.service.in | 17 +++++++++++++++++
>  systemd/rpcbind.socket     | 19 +++++++++++++++++++
>  5 files changed, 47 insertions(+), 1 deletion(-)
>  create mode 100644 systemd/rpcbind.service.in
>  create mode 100644 systemd/rpcbind.socket
> 
> hi,
>  these are based on the unit files in use a SUSE, though I have made a
>  few "improvements".
>  If anyone has differences in their distros that you think we should
>  have in mainline, I'd love to hear about it.
> 
> Thanks,
> NeilBrown
> 
> 
> diff --git a/.gitignore b/.gitignore
> index 321dff64a57d..a8f1fed2acb6 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -27,3 +27,4 @@ rpcbind
>  rpcinfo
>  # cscope database files
>  cscope.*
> +systemd/rpcbind.service
> diff --git a/Makefile.am b/Makefile.am
> index 5ec8cd66b689..43c27100ceae 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -50,6 +50,10 @@ if SYSTEMD
>  AM_CPPFLAGS += $(SYSTEMD_CFLAGS) -DSYSTEMD
>  
>  rpcbind_LDADD += $(SYSTEMD_LIBS)
> +
> +systemdsystemunit_DATA = \
> +	systemd/rpcbind.service \
> +	systemd/rpcbind.socket
>  endif
>  
>  rpcinfo_SOURCES =       src/rpcinfo.c
> diff --git a/configure.ac b/configure.ac
> index af4b74b31c9a..0892d8246a12 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -61,4 +61,9 @@ AC_SEARCH_LIBS([pthread_create], [pthread])
>  
>  AC_CHECK_HEADERS([nss.h rpcsvc/mount.h])
>  
> -AC_OUTPUT([Makefile])
> +# make bindir available for substitution in config file
> +# 2 "evals" needed to expand variable names
> +AC_SUBST([_bindir])
> +AC_CONFIG_COMMANDS_PRE([eval eval _bindir=$bindir])
> +
> +AC_OUTPUT([Makefile systemd/rpcbind.service])
> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
> new file mode 100644
> index 000000000000..4706b5a77abf
> --- /dev/null
> +++ b/systemd/rpcbind.service.in
> @@ -0,0 +1,17 @@
> +[Unit]
> +Description=RPC Bind
> +Documentation=man:rpcbind(8)
> +DefaultDependencies=no
> +RequiresMountsFor=/var/run /run
> +# Make sure we use the IP addresses listed for
> +# rpcbind.socket, no matter how this unit is started.
> +Wants=rpcbind.socket
> +After=rpcbind.socket
> +
> +[Service]
> +Type=notify
> +# distro can provide a drop-in adding EnvironmentFile=-/??? if needed.
> +ExecStart=@_bindir@/rpcbind $RPCBIND_OPTIONS -w -f
This macro puts rpcbind in /usr/bin, but in the Red Hat
distros rpcbind lives /usr/sbin. I could easily patch
it to do the right thing... but is this a typo or does 
rpcbind live in /usr/bin in other distros? 

steved.


> +
> +[Install]
> +WantedBy=multi-user.target
> diff --git a/systemd/rpcbind.socket b/systemd/rpcbind.socket
> new file mode 100644
> index 000000000000..7204c97efa6f
> --- /dev/null
> +++ b/systemd/rpcbind.socket
> @@ -0,0 +1,19 @@
> +[Unit]
> +Description=RPCbind Server Activation Socket
> +DefaultDependencies=no
> +RequiresMountsFor=/var/run /run
> +Wants=rpcbind.target
> +Before=rpcbind.target
> +
> +[Socket]
> +ListenStream=/var/run/rpcbind.sock
> +
> +# RPC netconfig can't handle ipv6/ipv4 dual sockets
> +BindIPv6Only=ipv6-only
> +ListenStream=0.0.0.0:111
> +ListenDatagram=0.0.0.0:111
> +ListenStream=[::]:111
> +ListenDatagram=[::]:111
> +
> +[Install]
> +WantedBy=sockets.target
> 
