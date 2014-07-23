Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32805 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933270AbaGWUsc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jul 2014 16:48:32 -0400
Date: Wed, 23 Jul 2014 16:48:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH] nfsd: ensure that st_access_bmap and st_deny_bmap are
 initialized to 0
Message-ID: <20140723204824.GJ9118@fieldses.org>
References: <1406137609-24466-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406137609-24466-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 23, 2014 at 01:46:49PM -0400, Jeff Layton wrote:
> Open stateids must be initialized with the st_access_bmap and
> st_deny_bmap set to 0, so that nfs4_get_vfs_file can properly record
> their state in old_access_bmap and old_deny_bmap.
> 
> This bug was introduced in commit baeb4ff0e502 (nfsd: make deny mode
> enforcement more efficient and close races in it) and was causing the
> refcounts to end up incorrect when nfs4_get_vfs_file returned an error
> after bumping the refcounts. This made it impossible to unmount the
> underlying filesystem after running pynfs tests that involve deny modes.

Thanks, applied.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 72da0d44e66b..ce07e9517a80 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2968,8 +2968,6 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
>  	stp->st_file = fp;
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = 0;
> -	set_access(open->op_share_access, stp);
> -	set_deny(open->op_share_deny, stp);
>  	stp->st_openstp = NULL;
>  	spin_lock(&fp->fi_lock);
>  	list_add(&stp->st_perfile, &fp->fi_stateids);
> -- 
> 1.9.3
> 
