Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:25563 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab3KOQ5n convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 11:57:43 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] NFS: -EIO from decode_bitmap if too many bitmaps
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1384533481-2254-1-git-send-email-dros@netapp.com>
Date: Fri, 15 Nov 2013 11:57:39 -0500
Cc: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Message-Id: <98411E2E-3D5D-44F6-9254-C2248C57F741@oracle.com>
References: <1384533481-2254-1-git-send-email-dros@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 15, 2013, at 11:38 AM, Weston Andros Adamson <dros@netapp.com> wrote:

> decode_bitmap will only decode up to three bitmaps.  If the xdr buffer
> has more than three bitmaps, return -EIO here instead of bailing out in
> a later xdr decode.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> 
> This is related to my "NFSv4: fix getacl ERANGE for some ACL buffer sizes"
> patch - I noticed that even though we'll only ever parse 3 bitmaps, we don't
> error out correctly if more are sent.
> 
> This condition is probably never hit, but if it ever is, it'd be nice to
> have the code error out where the problem actually occurred.
> 
> fs/nfs/nfs4xdr.c | 3 +++
> 1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 5be2868..3866a69 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -3146,6 +3146,9 @@ static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
> 		goto out_overflow;
> 	bmlen = be32_to_cpup(p);
> 
> +	if (unlikely(bmlen > 3))
> +		goto out_overflow;
> +

Nit: Using a naked integer should be avoid, if we can.  Is there somewhere in the code that documents the "we only handle up t 3 bitmaps" constraint?


> 	bitmap[0] = bitmap[1] = bitmap[2] = 0;
> 	p = xdr_inline_decode(xdr, (bmlen << 2));
> 	if (unlikely(!p))
> -- 
> 1.8.3.1 (Apple Git-46)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




