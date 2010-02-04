Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:55681 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932346Ab0BDPT1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2010 10:19:27 -0500
Date: Thu, 4 Feb 2010 10:19:26 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Ben Myers <bpm@sgi.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 4/4] If 'wsync' pass datasync=1 to vfs_fsync().
Message-ID: <20100204151926.GA22014@infradead.org>
References: <20100203233755.17677.96582.stgit@case> <20100203234444.17677.32390.stgit@case>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100203234444.17677.32390.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 03, 2010 at 05:44:44PM -0600, Ben Myers wrote:
> 
> ---
>  fs/nfsd/vfs.c |   39 +++++++++++++++++++++++++--------------
>  1 files changed, 25 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 89eb1b2..4b1973b 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -418,7 +418,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  	if (!err) {
>  		if (EX_ISSYNC(fhp->fh_export)) {
>  			if (EX_ISWSYNC(fhp->fh_export)) {
> -				vfs_fsync(NULL, dentry, 0);
> +				vfs_fsync(NULL, dentry, 1);

I think this is incorrect.  datasync = 1 means to only write out
metadata that is required to access the file data.  The write_inode code
makes sure all metadata goes out, which AFAIK is what the NFS protocol
requires from us anyway for all these metadata operations.

Note that this does not invalidate your XFS numbers as right now XFS
doesn't actually implement the datasync == 1 optimization, although I'm
about to send a patch to do that.  The updsize is that this will
make your patchset quite a bit simpler :)

