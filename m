Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44985 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756842AbbFRSET (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jun 2015 14:04:19 -0400
Date: Thu, 18 Jun 2015 14:04:19 -0400
To: Dennis Jacobfeuerborn <dennisml@conversis.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS server startup hangs for 60 seconds
Message-ID: <20150618180419.GB21212@fieldses.org>
References: <5582B009.9090901@conversis.de>
 <5582FC45.4010007@conversis.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5582FC45.4010007@conversis.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 18, 2015 at 07:13:41PM +0200, Dennis Jacobfeuerborn wrote:
> On 18.06.2015 13:48, Dennis Jacobfeuerborn wrote:
> > Hi,
> > when I start nfs-server.service on a CentOS 7 system it takes 60 seconds
> > until the nfsd finally is up. Looking at the process list I see a
> > process 'systemd-tty-ask-password-agent' running which goes away after
> > the 60 seconds the startup requires soI suspect something in the startup
> > process is trying to get a password.
> > 
> > Does anyone have an idea what the reason could be for this and how I can
> > get rid of this delay?
> 
> I've added some debug options to /etc/sysconfig/nfs and attached the
> resulting log. The interesting bit seems to be rpc.mountd:

Whoops, never mind my previous reply.

> 
> Jun 18 19:00:58 test systemd: Starting NFS Mount Daemon...
> ...
> Jun 18 19:01:58 test rpc.mountd[2021]: Failed to unregister program
> 100005, version 1
> Jun 18 19:01:58 test rpc.statd[2010]: failed to create RPC listeners,
> exiting


Maybe there's some problem with rpcbind?

--b.

> Jun 18 19:01:58 test systemd: rpc-statd.service: control process exited,
> code=exited status=1
> Jun 18 19:01:58 test systemd: Failed to start NFS status monitor for
> NFSv2/3 locking..
> Jun 18 19:01:58 test systemd: Unit rpc-statd.service entered failed state.
> Jun 18 19:01:58 test systemd: Started NFS Mount Daemon.
> 
> It seems rpc.mountd wants to do something that presumably needs a
> password on startup which then times out after 60 seconds.
> 
> Any ideas what rpc.mountd could be doing there?
> 
> Regards,
>   Dennis
> 

> Jun 18 19:00:58 test systemd: Mounting RPC Pipe File System...
> Jun 18 19:00:58 test systemd: Started Kernel Module supporting RPCSEC_GSS.
> Jun 18 19:00:58 test systemd: Starting GSSAPI Proxy Daemon...
> Jun 18 19:00:58 test systemd: Starting Network Manager Wait Online...
> Jun 18 19:00:58 test systemd: Starting Host and Network Name Lookups.
> Jun 18 19:00:58 test systemd: Reached target Host and Network Name Lookups.
> Jun 18 19:00:58 test systemd: Starting Preprocess NFS configuration...
> Jun 18 19:00:58 test systemd: Starting RPC Port Mapper.
> Jun 18 19:00:58 test systemd: Reached target RPC Port Mapper.
> Jun 18 19:00:58 test systemd: Mounting NFSD configuration filesystem...
> Jun 18 19:00:58 test systemd: Started Preprocess NFS configuration.
> Jun 18 19:00:58 test systemd: Starting NFS status monitor for NFSv2/3 locking....
> Jun 18 19:00:58 test systemd: Starting NFSv4 ID-name mapping service...
> Jun 18 19:00:58 test systemd: Started Network Manager Wait Online.
> Jun 18 19:00:58 test systemd: Starting Network is Online.
> Jun 18 19:00:58 test systemd: Reached target Network is Online.
> Jun 18 19:00:58 test kernel: RPC: Registered named UNIX socket transport module.
> Jun 18 19:00:58 test systemd: Mounted RPC Pipe File System.
> Jun 18 19:00:58 test kernel: RPC: Registered udp transport module.
> Jun 18 19:00:58 test kernel: RPC: Registered tcp transport module.
> Jun 18 19:00:58 test kernel: RPC: Registered tcp NFSv4.1 backchannel transport module.
> Jun 18 19:00:58 test rpc.statd[2010]: Version 1.3.0 starting
> Jun 18 19:00:58 test rpc.statd[2010]: Flags: TI-RPC
> Jun 18 19:00:58 test systemd: Started GSSAPI Proxy Daemon.
> Jun 18 19:00:58 test systemd: Started RPC security service for NFS client and server.
> Jun 18 19:00:58 test systemd: Started RPC security service for NFS server.
> Jun 18 19:00:58 test kernel: Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> Jun 18 19:00:58 test systemd: Mounted NFSD configuration filesystem.
> Jun 18 19:00:58 test systemd: Starting NFS Mount Daemon...
> Jun 18 19:00:58 test systemd: Starting RPC bind service...
> Jun 18 19:00:58 test systemd: Started RPC bind service.
> Jun 18 19:00:58 test systemd: Started NFSv4 ID-name mapping service.
> Jun 18 19:01:01 test systemd: Starting Session 3 of user root.
> Jun 18 19:01:01 test systemd: Started Session 3 of user root.
> 
> Jun 18 19:01:58 test rpc.mountd[2021]: Failed to unregister program 100005, version 1
> Jun 18 19:01:58 test rpc.statd[2010]: failed to create RPC listeners, exiting
> Jun 18 19:01:58 test systemd: rpc-statd.service: control process exited, code=exited status=1
> Jun 18 19:01:58 test systemd: Failed to start NFS status monitor for NFSv2/3 locking..
> Jun 18 19:01:58 test systemd: Unit rpc-statd.service entered failed state.
> Jun 18 19:01:58 test systemd: Started NFS Mount Daemon.
> Jun 18 19:01:58 test systemd: Starting NFS server and services...
> Jun 18 19:01:58 test rpc.mountd[2046]: Version 1.3.0 starting
> Jun 18 19:01:58 test rpc.nfsd[2048]: Checking netconfig for visible protocols.
> Jun 18 19:01:58 test rpc.nfsd[2048]: Enabling inet udp.
> Jun 18 19:01:58 test rpc.nfsd[2048]: Enabling inet tcp.
> Jun 18 19:01:58 test rpc.nfsd[2048]: Enabling inet6 udp.
> Jun 18 19:01:58 test rpc.nfsd[2048]: Enabling inet6 tcp.
> Jun 18 19:01:58 test rpc.nfsd[2048]: knfsd is currently down
> Jun 18 19:01:58 test rpc.nfsd[2048]: Writing version string to kernel: -2 +3 +4
> Jun 18 19:01:58 test rpc.nfsd[2048]: Creating inet TCP socket.
> Jun 18 19:01:58 test rpc.nfsd[2048]: Creating inet UDP socket.
> Jun 18 19:01:58 test rpc.nfsd[2048]: Creating inet6 TCP socket.
> Jun 18 19:01:58 test rpc.nfsd[2048]: Creating inet6 UDP socket.
> Jun 18 19:01:58 test systemd: Started NFS server and services.
> Jun 18 19:01:58 test systemd: Starting Notify NFS peers of a restart...
> Jun 18 19:01:58 test kernel: NFSD: starting 90-second grace period (net ffffffff819e07c0)
> Jun 18 19:01:58 test sm-notify[2064]: Version 1.3.0 starting
> Jun 18 19:01:58 test systemd: Started Notify NFS peers of a restart.
> 

