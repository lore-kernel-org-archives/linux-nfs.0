Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50180 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751408AbeCNUwu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Mar 2018 16:52:50 -0400
Date: Wed, 14 Mar 2018 16:52:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 11/15] nfsd: Record request byte count, not count of
 vectors
Message-ID: <20180314205250.GC7241@fieldses.org>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
 <20180313154437.21531.89300.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180313154437.21531.89300.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 13, 2018 at 11:44:37AM -0400, Chuck Lever wrote:
>  	TP_fast_assign(
>  		__entry->xid = be32_to_cpu(rqstp->rq_xid);
> -		do {
> -			struct knfsd_fh fh;
> -
> -			fh_copy_shallow(&fh, &fhp->fh_handle);
> -			__entry->fh_hash = knfsd_fh_hash(&fh);
> -		} while (0);
> +		__entry->fh_hash = knfsd_fh_hash(&fhp->fh_handle);
>  		__entry->offset = offset;
>  		__entry->len = len;
>  	),

What's that about?  Why did someone originally think we needed to copy
before hashing?

--b.
