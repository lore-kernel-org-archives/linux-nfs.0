Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:43483 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097AbbBLU3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2015 15:29:47 -0500
Date: Thu, 12 Feb 2015 15:29:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: Re: [patch] nfsd: fix comparison in fh_fsid_match()
Message-ID: <20150212202944.GA5370@fieldses.org>
References: <20150211130832.GA25573@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150211130832.GA25573@mwanda>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 04:08:32PM +0300, Dan Carpenter wrote:
> We're supposed to be testing that the fh_fsid's match but because the
> parenthesis are in the wrong place, then we only check the first
> byte.

Thanks, I'll pass this along!

--b.

> 
> Fixes: 9558f2500a20 ('nfsd: add fh_fsid_match helper')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
> index 84cae20..f229204 100644
> --- a/fs/nfsd/nfsfh.h
> +++ b/fs/nfsd/nfsfh.h
> @@ -200,7 +200,7 @@ static inline bool fh_fsid_match(struct knfsd_fh *fh1, struct knfsd_fh *fh2)
>  {
>  	if (fh1->fh_fsid_type != fh2->fh_fsid_type)
>  		return false;
> -	if (memcmp(fh1->fh_fsid, fh2->fh_fsid, key_len(fh1->fh_fsid_type) != 0))
> +	if (memcmp(fh1->fh_fsid, fh2->fh_fsid, key_len(fh1->fh_fsid_type)) != 0)
>  		return false;
>  	return true;
>  }
