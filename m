Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045AbcEBOzR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2016 10:55:17 -0400
Subject: Re: [PATCH nfs-utils] systemd unit files: fix up dependencies on
 rpcbind.
To: NeilBrown <neilb@suse.com>
References: <8760v1unlw.fsf@notabene.neil.brown.name>
Cc: NFS List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <57276A54.1070304@RedHat.com>
Date: Mon, 2 May 2016 10:55:16 -0400
MIME-Version: 1.0
In-Reply-To: <8760v1unlw.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 28/04/16 22:59, NeilBrown wrote:
> 
> The dependencies on rpcbind have been changed a few times and I think
> they are still wrong.  So I'll go into some detail to justify this change.
> 
> Firstly: rpcbind.target rpcbind.socket or rpcbind.service?
> 
> The systemd documentation talks about targets as "synchronization
> points" and likens them to SysV init run levels.  Run levels are about
> ordering but not dependencies.
> 
> The systemd.special man page describes rpcbind.target as intended
> explicitly for ordering sysvinit scripts, with "After=" dependencies.
> 
> So while I think it is valid to use rpcbind.target for ordering
> (before/after) it shouldn't be used for dependencies (Wants/Requires).
> The rpcbind.target file included in systemd does not "Require" the
> actual service, so requiring rpcbind.target itself is pointless.
> 
> I think we shouldn't use rpcbind.target at all.  Leave it for sysvinit
> synchronization.
> 
> So: .socket or .service?
> 
> I think nfs only needs the socket to be active.  On first connection
> the service will be started.  But nfs does not need to wait for the
> service to start, only the socket.  So I think we should exclusively
> use rpcbind.socket.
> 
> Next: Wants or Requires.
> 
> rpc.statd definitely Requires rpcbind.  It needs to register to be
> useful, and without rpcbind it cannot register.
> 
> nfs-server does not necesarily require rpcbind.  Specifically if
> configured for NFSv4 only, nfs-server will work quite happily without
> rpcbind.
> 
> Someone with an NFSv4 only setup who wants rpcbind to not run can use
>   systemctl mask rpcbind.socket
> to ensure it never runs.
> So nfs-server should only "Wants: rpcbind.socket".
> I think
>  Commit: 4fabfcd08206 ("systemd: Decouple the starting and stopping of rpcbind/nfs-server")
> should have changed "Requires" to "Wants" rather than "server" to "target"
> to fix the dependency problem.
> 
> Finally: After?
> 
> It only makes sense to declare an ordering relation as "After:"
> something that will actually be started.  If "foo.service" is not part
> of the systemd transaction, then "After: foo.service" has no effect.
> So having:
>   Requires: rpcbind.target
>   After: rpcbind.socket
> 
> doesn't make much sense unless there is some relationship between
> rpcbind.target and rpcbind.socket, and there is no general guarantee
> of that (though what individual distros do, I don't know).
> So the "After" should match the "Wants" or "Requires".
> 
> It might make sense to
>   Requires: rpcbind.socket
>   After: rpcbind.target
> 
> as it is reasonable to assume that rpcbind.target will be ordered with
> rpcbind.socket, but as we can use rpcbind.socket explictly, that is
> clearer.
> 
> So my conclusion is that nfs-server should:
>   Wants: rpcbind.socket
>   After: rpcbind.socket
> 
> and rpc-statd should
>   Requires: rpcbind.socket
>   After: rpcbind.socket
> 
> which is what this patch puts into effect.
Thanks for making sense of this.... Committed... 

steved.

> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> 
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 317e5d689767..2ccdc6344cd5 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -1,13 +1,14 @@
>  [Unit]
>  Description=NFS server and services
>  DefaultDependencies=no
> -Requires= network.target proc-fs-nfsd.mount rpcbind.target
> +Requires= network.target proc-fs-nfsd.mount
>  Requires= nfs-mountd.service
> +Wants=rpcbind.socket
>  Wants=rpc-statd.service nfs-idmapd.service
>  Wants=rpc-statd-notify.service
>  
>  After= local-fs.target
> -After= network.target proc-fs-nfsd.mount rpcbind.service nfs-mountd.service
> +After= network.target proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
>  After= nfs-idmapd.service rpc-statd.service
>  Before= rpc-statd-notify.service
>  
> diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
> index f16ea425dc77..a02f5c41a424 100644
> --- a/systemd/rpc-statd.service
> +++ b/systemd/rpc-statd.service
> @@ -2,8 +2,8 @@
>  Description=NFS status monitor for NFSv2/3 locking.
>  DefaultDependencies=no
>  Conflicts=umount.target
> -Requires=nss-lookup.target rpcbind.target
> -After=network.target nss-lookup.target rpcbind.service
> +Requires=nss-lookup.target rpcbind.socket
> +After=network.target nss-lookup.target rpcbind.socket
>  
>  PartOf=nfs-utils.service
>  
> 
