Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58390 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755103Ab3KTVWI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 16:22:08 -0500
Message-ID: <528D2841.6090600@RedHat.com>
Date: Wed, 20 Nov 2013 16:23:13 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs(5): Document the "migration" mount option
References: <20131114163552.19821.30799.stgit@manray.1015granger.net>
In-Reply-To: <20131114163552.19821.30799.stgit@manray.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 14/11/13 11:35, Chuck Lever wrote:
> Support for NFSv4 migration was merged in 3.13.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed (tag: nfs-utils-1-2-10-rc1)

steved.
> ---
>  utils/mount/nfs.man |   20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index 2a42b93..8535aec 100644
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
> +This mount option has no effect with NFSv4 minor versions newer than zero,
> +which always use TSM-compatible client identification strings.
>  .SH nfs4 FILE SYSTEM TYPE
>  The
>  .BR nfs4
> 
