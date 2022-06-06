Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D5E9C433EF
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jun 2022 22:09:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231557AbiFFWJm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 6 Jun 2022 18:09:42 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59800 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231521AbiFFWJl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2022 18:09:41 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 93DADBE1A
        for <linux-nfs@vger.kernel.org>; Mon,  6 Jun 2022 15:09:40 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 08AF86C90; Mon,  6 Jun 2022 18:09:39 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 08AF86C90
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1654553379;
        bh=ktiBAQ/wgvwptzNAOn9nPvZvQrzjysCqUMdBc8mNzTw=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=WPUOboAf6TuslUvsZHx8Fe20biVnFhZPoQr9fjcmru+oPU5/A3Ke3T1UGsfIj/UpR
         KI9vYL3/hFiwY8GE3CMgAP6LSyjy8q9LqbJamTXBQffffcAy0Z3MpHrV5uCwjqLm20
         EmZ16rPjUjHD9bWB68CxZlmSIm9TcPMyNvZljiL4=
Date:   Mon, 6 Jun 2022 18:09:38 -0400
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 1/5] SUNRPC: Fix the calculation of xdr->end in
 xdr_get_next_encode_buffer()
Message-ID: <20220606220938.GE15057@fieldses.org>
References: <165445865736.1664.4497130284832282034.stgit@bazille.1015granger.net>
 <165445910560.1664.5852151724543272982.stgit@bazille.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <165445910560.1664.5852151724543272982.stgit@bazille.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Jun 05, 2022 at 03:58:25PM -0400, Chuck Lever wrote:
> I found that NFSD's new NFSv3 READDIRPLUS XDR encoder was screwing up
> right at the end of the page array. xdr_get_next_encode_buffer() does
> not compute the value of xdr->end correctly:
> 
>  * The check to see if we're on the final available page in xdr->buf
>    needs to account for the space consumed by @nbytes.
> 
>  * The new xdr->end value needs to account for the portion of @nbytes
>    that is to be encoded into the previous buffer.
> 
> Fixes: 2825a7f90753 ("nfsd4: allow encoding across page boundaries")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xdr.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index df194cc07035..b57cf9df4de8 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -979,7 +979,11 @@ static __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
>  	 */
>  	xdr->p = (void *)p + frag2bytes;
>  	space_left = xdr->buf->buflen - xdr->buf->len;
> -	xdr->end = (void *)p + min_t(int, space_left, PAGE_SIZE);
> +	if (space_left - nbytes >= PAGE_SIZE)
> +		xdr->end = (void *)p + PAGE_SIZE;
> +	else
> +		xdr->end = (void *)p + space_left - frag1bytes;
> +

I think that's right.

Couldn't you just make that


-	xdr->end = (void *)p + min_t(int, space_left, PAGE_SIZE);
+	xdr->end = (void *)p + min_t(int, space_left - nbytes, PAGE_SIZE);

?

(Note we know space_left >= nbytes from the second "if" of this
function.)

No strong opinion either way, really, I just wonder if I'm missing
something.

--b.

>  	xdr->buf->page_len += frag2bytes;
>  	xdr->buf->len += nbytes;
>  	return p;
> 
