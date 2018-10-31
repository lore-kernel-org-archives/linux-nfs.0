Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B371C0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 14:03:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E08DF20664
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 14:03:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E08DF20664
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728938AbeJaXBV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 19:01:21 -0400
Received: from fieldses.org ([173.255.197.46]:54504 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728918AbeJaXBV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Oct 2018 19:01:21 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 8FC2D2430; Wed, 31 Oct 2018 10:03:11 -0400 (EDT)
Date:   Wed, 31 Oct 2018 10:03:11 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Frank Sorenson <sorenson@redhat.com>
Cc:     linux-nfs@vger.kernel.org, jlayton@kernel.org
Subject: Re: [PATCH] sunrpc: correct the computation for page_ptr when
 truncating
Message-ID: <20181031140311.GA2451@fieldses.org>
References: <20181030201040.2024882-1-sorenson@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181030201040.2024882-1-sorenson@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 30, 2018 at 03:10:40PM -0500, Frank Sorenson wrote:
> When truncating the encode buffer, the page_ptr is getting
> advanced, causing the next page to be skipped while encoding.
> The page is still included in the response, so the response
> contains a page of bogus data.
> 
> We need to adjust the page_ptr backwards to ensure we encode
> the next page into the correct place.

Thanks!  Queuing this up for 4.20 and stable.

Also added one more note to the changelog in case it's useful to someone
else who runs across this bug:

	We saw this triggered when concurrent directory modifications
	caused nfsd4_encode_direct_fattr() to return nfserr_noent, and
	the resulting call to xdr_truncate_encode() corrupted the
	READDIR reply.

--b.

> 
> Signed-off-by: Frank Sorenson <sorenson@redhat.com>
> ---
>  net/sunrpc/xdr.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index 2bbb8d38d2bf..5cfb9e0a18dc 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -673,11 +673,10 @@ void xdr_truncate_encode(struct xdr_stream *xdr, size_t len)
>  		WARN_ON_ONCE(xdr->iov);
>  		return;
>  	}
> -	if (fraglen) {
> +	if (fraglen)
>  		xdr->end = head->iov_base + head->iov_len;
> -		xdr->page_ptr--;
> -	}
>  	/* (otherwise assume xdr->end is already set) */
> +	xdr->page_ptr--;
>  	head->iov_len = len;
>  	buf->len = len;
>  	xdr->p = head->iov_base + head->iov_len;
> -- 
> 2.14.5
