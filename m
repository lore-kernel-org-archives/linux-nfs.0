Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51133 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765AbaC1VTV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2014 17:19:21 -0400
Date: Fri, 28 Mar 2014 17:19:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFSD: Re-initialize fh_post/pre_saved between two
 operations
Message-ID: <20140328211920.GD6041@fieldses.org>
References: <533299E9.6010806@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <533299E9.6010806@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 26, 2014 at 05:12:09PM +0800, Kinglong Mee wrote:
> Testing NFS4.0 by pynfs, I got some messeages as,
> "nfsd: inode locked twice during operation."

Thanks for looking into this.  I agree that we should clear fh_pre_saved
and fh_post_saved between compound ops.

This is kind of non-obvious, though, so I think it would be worth moving
these two assignments to a little helper function (how about
"fh_clear_wcc_data()" for a name?) and adding a comment with the
definition of the function, explaining why we need it.

> When one compound RPC contains two or more SETATTR operation
> for one filehandle,the second SETATTR will cause the message.

Also worth noting that this affects any op that locks the filehandle
(e.g. a compound with two LINK ops would probably trigger the same
warning.)

--b.

> 
> Because after the first SETATTR, nfsd will not call fh_put()
> to release current filehandle, it means filehandle have unlocked
> with fh_post_saved = 1.
> The second SETATTR find fh_post_saved = 1, and printk the message.
> 
> This patch re-initialize fh_post/pre_saved between two operations.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4proc.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 550faf2..103d1ac 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1356,6 +1356,9 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  			  !(opdesc->op_flags & ALLOWED_ON_ABSENT_FS)) {
>  			op->status = nfserr_moved;
>  			goto encode_op;
> +		} else {
> +			current_fh->fh_post_saved = 0;
> +			current_fh->fh_pre_saved = 0;
>  		}
> 
>  		/* If op is non-idempotent */
> -- 
> 1.8.5.3
> 
