Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49273 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753165AbbLDPpu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2015 10:45:50 -0500
Date: Fri, 4 Dec 2015 10:45:49 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        hch@infradead.org
Subject: Re: [PATCH v1 2/3] NFSD: Implement the COPY call
Message-ID: <20151204154549.GD26898@fieldses.org>
References: <1449176137-4940-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1449176137-4940-3-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1449176137-4940-3-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 03, 2015 at 03:55:35PM -0500, Anna Schumaker wrote:
> @@ -498,6 +499,22 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  }
>  #endif
>  
> +ssize_t nfsd_copy_range(struct file *src, u64 src_pos,
> +		       struct file *dst, u64 dst_pos,
> +		       u64 count)
> +{
> +	ssize_t bytes;
> +	u64 limit = 0x10000000;

Why that value?  Could I get a comment here?

> +
> +	if (count > limit)
> +		count = limit;
> +
> +	bytes = vfs_copy_file_range(src, src_pos, dst, dst_pos, count, 0);

Sorry, I lost track of the copy discussions: does this only work on
filesystems with special support, or does it fall back on doing the copy
by hand?  Which filesystems (of the exportable filesystems) support
this?

--b.

> +	if (bytes > 0)
> +		vfs_fsync_range(dst, dst_pos, dst_pos + bytes, 0);
> +	return bytes;
> +}
> +
>  __be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  			   struct file *file, loff_t offset, loff_t len,
>  			   int flags)
