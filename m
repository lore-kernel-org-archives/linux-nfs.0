From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: fix double-lock of i_mutex on nfsv4 recovery
	directory
Date: Tue, 6 Jan 2009 12:58:29 -0500
Message-ID: <20090106175828.GH2386@fieldses.org>
References: <20090106100246.GA13742@alice> <20090106172914.GG2386@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, hch@lst.de, neilb@suse.de
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42800 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308AbZAFR6d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 12:58:33 -0500
In-Reply-To: <20090106172914.GG2386@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2009 at 12:29:14PM -0500, bfields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> This mutex should be unnecessary, and as of 4c728ef583b3d "add a
> vfs_fsync helper" it triggers a lockdep warning.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4recover.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> On Tue, Jan 06, 2009 at 11:02:47AM +0100, Eric Sesterhenn wrote:
> > hi,
> > 
> > with todays -git i see the following lockdep warning, that wasnt there
> > yesterday. It occurs after booting the box.
> 
> Thanks.  The much-hated recovery code strikes again.  I think this
> should do it?

No, then we just run into a deadlocks in unlink, create, or any of the
other nfsd operations that want the parent lock to cover more than just
the sync.  So 4c728ef583b3d just doesn't work for nfsd.

--b.

> 
> --b.
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 74f7b67..9fb5a10 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -127,9 +127,7 @@ out_no_tfm:
>  static void
>  nfsd4_sync_rec_dir(void)
>  {
> -	mutex_lock(&rec_dir.dentry->d_inode->i_mutex);
>  	nfsd_sync_dir(rec_dir.dentry);
> -	mutex_unlock(&rec_dir.dentry->d_inode->i_mutex);
>  }
>  
>  int
> -- 
> 1.5.5.rc1
> 
