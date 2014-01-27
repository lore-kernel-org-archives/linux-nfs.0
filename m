Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54832 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405AbaA0TYJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jan 2014 14:24:09 -0500
Date: Mon, 27 Jan 2014 14:24:06 -0500
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd4: fix delegation-unlink/rename race
Message-ID: <20140127192406.GD17165@fieldses.org>
References: <1390769961-30898-1-git-send-email-bfields@redhat.com>
 <1390769961-30898-4-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1390769961-30898-4-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 26, 2014 at 03:59:21PM -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> If a file is unlinked or renamed between the time when we do the local
> open and the time when we get the delegation, then we will return to the
> client indicating that it holds a delegation even though the file no
> longer exists under the name it was open under.
> 
> But a client performing an open-by-name, when it is returned a
> delegation, must be able to assume that the file is still linked at the
> name it was opened under.
> 
> So, hold the parent i_mutex for longer to prevent concurrent renames or
> unlinks.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4proc.c |   10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 844813a..ef76ba6 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -279,11 +279,15 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
>  		if (open->op_createmode == NFS4_CREATE_EXCLUSIVE && status == 0)
>  			open->op_bmval[1] = (FATTR4_WORD1_TIME_ACCESS |
>  							FATTR4_WORD1_TIME_MODIFY);
> -	} else {
> +	} else
> +		/*
> +		 * Note this may exit with the parent still locked.
> +		 * We will hold the lock until nfsd4_open's final
> +		 * lookup, to prevent renames or unlinks until we've had
> +		 * a chance to an acquire a delegation if appropriate.
> +		 */
>  		status = nfsd_lookup(rqstp, current_fh,
>  				     open->op_fname.data, open->op_fname.len, *resfh);
> -		fh_unlock(current_fh);
> -	}
>  	if (status)
>  		goto out;
>  	status = nfsd_check_obj_isreg(*resfh);

One last-minute fix: we can now end up taking two i_mutexes.  The
locking's still correct but we need the following annotation on the
parent directory.

(I haven't actually seen any lockdep warning trigger here.)

--b.

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index e85b463..a41302a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -207,7 +207,12 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				goto out_nfserr;
 		}
 	} else {
-		fh_lock(fhp);
+		/*
+		 * In the nfsd4_open() case, this may be held across
+		 * subsequent open and delegation acquisition which may
+		 * need to take the child's i_mutex:
+		 */
+		fh_lock_nested(fhp, I_MUTEX_PARENT);
 		dentry = lookup_one_len(name, dparent, len);
 		host_err = PTR_ERR(dentry);
 		if (IS_ERR(dentry))
