Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29555 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755167Ab3KTVUW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 16:20:22 -0500
Message-ID: <528D27D5.4010608@RedHat.com>
Date: Wed, 20 Nov 2013 16:21:25 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs(5): Document the "migration" mount option
References: <20130910192730.2394.8803.stgit@seurat.1015granger.net>
In-Reply-To: <20130910192730.2394.8803.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/09/13 15:28, Chuck Lever wrote:
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> This has been floating around for a while in my nfs-utils repo.
> Now that migration support is getting merged upstream, I propose
> this minor change to nfs(5).
> 
> Note that my pending migration patches currently allow migration
> even if the "migration" option is not specified.  In this case,
> standard state recovery will occur on the destination server (aka a
> non-TSM migration) since the destination server can't match up a
> client using the traditional clientid string with incoming migrated
> state.
> 
> If we think this is dangerous to allow, then the client can be
> changed to require the "migration" option to enable migration
> support on NFSv4.0 mount points.
> 
> Non-TSM migration can still occur if the servers for some reason
> fail to transfer open and lock state during a migration.
> 
> Comments...?
Committed (tag: nfs-utils-1-2-10-rc1)

steved.
> 
>  utils/mount/nfs.man |   20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index 2a42b93..e93bd16 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -855,6 +855,26 @@ In the presence of multiple client network interfaces,
>  special routing policies,
>  or atypical network topologies,
>  the exact address to use for callbacks may be nontrivial to determine.
> +.TP 1.5i
> +.BR migration " / " nomigration
> +Selects whether the client uses an identification string that is compatible
> +with NFSv4 Transparent State Migration (TSM).
> +If the mounted server supports NFSv4 migration with TSM, specify the
> +.B migration
> +option.
> +.IP
> +Some server features misbehave in the face of a migration-compatible
> +identification string.
> +The
> +.B nomigration
> +option retains the use of a traditional client indentification string
> +which is compatible with legacy NFS servers.
> +This is also the behavior if neither option is specified.
> +A client's open and lock state cannot be migrated transparently
> +when it identifies itself via a traditional identification string.
> +.IP
> +This mount option has no effect with NFSv4 minor versions greater than zero,
> +as these versions always use TSM-compatible client identification strings.
>  .SH nfs4 FILE SYSTEM TYPE
>  The
>  .BR nfs4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
