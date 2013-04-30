Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45728 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933978Ab3D3Xmu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Apr 2013 19:42:50 -0400
Date: Tue, 30 Apr 2013 19:42:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] NFSD: Kill some mixed sign comparisons in
 fs/nfsd/nfs4xdr.c
Message-ID: <20130430234242.GA32031@fieldses.org>
References: <20130430224730.21406.27294.stgit@seurat.1015granger.net>
 <20130430224903.21406.2877.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130430224903.21406.2877.stgit@seurat.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 30, 2013 at 06:49:03PM -0400, Chuck Lever wrote:
> Clean up.

I don't want to describe something as cleanup unless it's obvious it
won't change behavior.  But:

> @@ -3033,7 +3032,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
>  static __be32
>  nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_readdir *readdir)
>  {
> -	int maxcount;
> +	unsigned int maxcount;
>  	loff_t offset;
>  	__be32 *page, *savep, *tailbase;
>  	__be32 *p;

This one, at least, is an actual behavior change.  (Note we've got an
"if (maxcount < 0) ..." later on.)  Maybe not a real problem, I haven't
checked.

And I haven't checked the others carefully.

--b.
