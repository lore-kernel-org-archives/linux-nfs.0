From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Replace NFS4ERR_NOTEMPY with NFS4ERR_EXIST
Date: Thu, 19 Mar 2009 15:47:22 -0400
Message-ID: <20090319194722.GA5499@fieldses.org>
References: <49C193B1.8040608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Ni Wenjuan <niwj@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:53041 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758124AbZCSTrY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Mar 2009 15:47:24 -0400
In-Reply-To: <49C193B1.8040608@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 19, 2009 at 08:37:05AM +0800, Ni Wenjuan wrote:
> Fix a test in rename operation. rename dir1 into existing,nonempty dir2 should
> return  NFS4ERR_EXIST instead got NFS4ERR_NOTEMPTY. RFC says if the target is a
> directory but not empty, the server will return the error, NFS4ERR_EXIST.

On a second look: could you double-check the client behavior?:
Currently

	mkdir subdir
	mkdir -p todir/subdir
	touch todir/subdir/foo
	mv subdir todir/

results (as in the local case) in "Directory not empty".  What happens
after applying this patch?

--b.

>
> Signed-off-by:Ni Wenjuan  <niwj@cn.fujitsu.com>
>
> ---
>  fs/nfsd/nfs4proc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 9fa60a3..c1e2e22 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -605,7 +605,7 @@ nfsd4_rename(struct svc_rqst *rqstp, struct
> nfsd4_compound_state *cstate,
>
>  	/* the underlying filesystem returns different error's than required
>  	 * by NFSv4. both save_fh and current_fh have been verified.. */
> -	if (status == nfserr_isdir)
> +	if (status == nfserr_isdir || status == nfserr_notempty)
>  		status = nfserr_exist;
>  	else if ((status == nfserr_notdir) &&
>                    (S_ISDIR(cstate->save_fh.fh_dentry->d_inode->i_mode) &&
> -- 
>
