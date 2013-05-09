Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56014 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753905Ab3EIOpd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 May 2013 10:45:33 -0400
Date: Thu, 9 May 2013 10:45:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, skinsbursky@parallels.com,
        toralf.foerster@gmx.de
Subject: Re: [PATCH] nfsd: fix oops when legacy_recdir_name_error is passed a
 -ENOENT error
Message-ID: <20130509144532.GC9316@fieldses.org>
References: <1368102983-5264-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1368102983-5264-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying, should get sent along soon.  Very minor nit:

On Thu, May 09, 2013 at 08:36:23AM -0400, Jeff Layton wrote:
> The problem appears to be a regression that was introduced in commit
> 9a9c6478.

Linus asks that people include the subject line when referencing a
commit:

	https://lkml.org/lkml/2007/10/23/241

	"... while it's great to use [commit names] in the body of the
	explanation, even there you don't want to assume that people
	read it from within git. People see patches and commit
	changelogs on the web or the commit mailing lists, so when
	specifying an exact version, also specify the human-readable
	name of that version."

So:

	The problem appears to be a regression that was introduced in
	commit 9a9c6478 "nfsd: make NFSv4 recovery client tracking
	options per net"....

--b.

> Prior to that commit, it was safe to pass a NULL net pointer
> to nfsd4_client_tracking_exit in the legacy recdir case, and
> legacy_recdir_name_error did so. After that comit, the net pointer must
> be valid.
> 
> This patch just fixes legacy_recdir_name_error to pass in a valid net
> pointer to that function.
> 
> Cc: <stable@vger.kernel.org> # v3.8+
> Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
> Reported-by: Toralf Förster <toralf.foerster@gmx.de>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4recover.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 899ca26..4e9a21d 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -146,7 +146,7 @@ out_no_tfm:
>   * then disable recovery tracking.
>   */
>  static void
> -legacy_recdir_name_error(int error)
> +legacy_recdir_name_error(struct nfs4_client *clp, int error)
>  {
>  	printk(KERN_ERR "NFSD: unable to generate recoverydir "
>  			"name (%d).\n", error);
> @@ -159,9 +159,7 @@ legacy_recdir_name_error(int error)
>  	if (error == -ENOENT) {
>  		printk(KERN_ERR "NFSD: disabling legacy clientid tracking. "
>  			"Reboot recovery will not function correctly!\n");
> -
> -		/* the argument is ignored by the legacy exit function */
> -		nfsd4_client_tracking_exit(NULL);
> +		nfsd4_client_tracking_exit(clp->net);
>  	}
>  }
>  
> @@ -184,7 +182,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
>  
>  	status = nfs4_make_rec_clidname(dname, &clp->cl_name);
>  	if (status)
> -		return legacy_recdir_name_error(status);
> +		return legacy_recdir_name_error(clp, status);
>  
>  	status = nfs4_save_creds(&original_cred);
>  	if (status < 0)
> @@ -341,7 +339,7 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
>  
>  	status = nfs4_make_rec_clidname(dname, &clp->cl_name);
>  	if (status)
> -		return legacy_recdir_name_error(status);
> +		return legacy_recdir_name_error(clp, status);
>  
>  	status = mnt_want_write_file(nn->rec_file);
>  	if (status)
> @@ -601,7 +599,7 @@ nfsd4_check_legacy_client(struct nfs4_client *clp)
>  
>  	status = nfs4_make_rec_clidname(dname, &clp->cl_name);
>  	if (status) {
> -		legacy_recdir_name_error(status);
> +		legacy_recdir_name_error(clp, status);
>  		return status;
>  	}
>  
> -- 
> 1.8.1.4
> 
