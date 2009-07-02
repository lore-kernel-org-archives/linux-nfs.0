From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFSD: Don't hold unrefcounted creds over call to
	nfsd_setuser()
Date: Thu, 2 Jul 2009 16:39:37 -0400
Message-ID: <20090702203937.GA10504@fieldses.org>
References: <20090702133532.28297.89635.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 174-143-236-118.static.slicehost.net ([174.143.236.118]:36521
	"EHLO fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbZGBUji (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2009 16:39:38 -0400
In-Reply-To: <20090702133532.28297.89635.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 02, 2009 at 02:35:32PM +0100, David Howells wrote:
> nfsd_open() gets an unrefcounted pointer to the current process's effective
> credentials at the top of the function, then calls nfsd_setuser() via
> fh_verify() - which may replace and destroy the current process's effective
> credentials - and then passes the unrefcounted pointer to dentry_open() - but
> the credentials may have been destroyed by this point.
> 
> Instead, the value from current_cred() should be passed directly to
> dentry_open() as one of its arguments, rather than being cached in a variable.

Got it, thanks.  How easy is it to hit this case?  (Just wondering
whether to submit for stable.)

--b.

> 
> Possibly fh_verify() should return the creds to use.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  fs/nfsd/vfs.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 4145083..23341c1 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -678,7 +678,6 @@ __be32
>  nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
>  			int access, struct file **filp)
>  {
> -	const struct cred *cred = current_cred();
>  	struct dentry	*dentry;
>  	struct inode	*inode;
>  	int		flags = O_RDONLY|O_LARGEFILE;
> @@ -733,7 +732,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
>  		vfs_dq_init(inode);
>  	}
>  	*filp = dentry_open(dget(dentry), mntget(fhp->fh_export->ex_path.mnt),
> -			    flags, cred);
> +			    flags, current_cred());
>  	if (IS_ERR(*filp))
>  		host_err = PTR_ERR(*filp);
>  	else
> 
