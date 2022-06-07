Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6886AC433EF
	for <linux-nfs@archiver.kernel.org>; Tue,  7 Jun 2022 01:08:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235573AbiFGBIq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 6 Jun 2022 21:08:46 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58836 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235568AbiFGBIq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2022 21:08:46 -0400
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.220.28])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 851D825C64
        for <linux-nfs@vger.kernel.org>; Mon,  6 Jun 2022 18:08:45 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id 3370D21ADC;
        Tue,  7 Jun 2022 01:08:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1654564124; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=ZElVVkgHksgGuqvuIsmW0D+X73I4fIGresCAvxrT3mk=;
        b=S+EPEkFfKRKoShlzNq28kgU93/xqFat/XT2KdUw0O1ZQQIdsyiS8GvPeDkcl53N8tZt2C6
        oq9wDQIbQ64zdUM9B6hR3m8jODKoLtC3sdOmk4gLK1bck8L0GxJwUB3SBJAx+GlXLcvPxc
        o2iz9tr1DMN8l382kE/B7UXuPP6R3HI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1654564124;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=ZElVVkgHksgGuqvuIsmW0D+X73I4fIGresCAvxrT3mk=;
        b=29wpzc8Pc7gI+fkDeXotbGzaowYyDCejX3Pdt4Z8ap7zsUDHVYKoFSHH59kFmLPCGb5Rc1
        ZNqTltdyWsHUbsDA==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 6460513A5F;
        Tue,  7 Jun 2022 01:08:43 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id xfsgCRulnmJOFgAAMHmgww
        (envelope-from <neilb@suse.de>); Tue, 07 Jun 2022 01:08:43 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Chuck Lever" <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 5/5] SUNRPC: Remove pointer type casts from
 xdr_get_next_encode_buffer()
In-reply-to: <165445913079.1664.5467024491080755855.stgit@bazille.1015granger.net>
References: <165445865736.1664.4497130284832282034.stgit@bazille.1015granger.net>,
 <165445913079.1664.5467024491080755855.stgit@bazille.1015granger.net>
Date:   Tue, 07 Jun 2022 11:08:39 +1000
Message-id: <165456411905.22243.16914535455796677784@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 06 Jun 2022, Chuck Lever wrote:
> To make the code easier to read, remove visual clutter by changing
> the declared type of @p.

Oh yes - that's much nicer!

Reviewed-by: NeilBrown <neilb@suse.de>

Thanks,
NeilBrown

>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xdr.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index 89cb48931a1f..4e4cad7aeec2 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -955,9 +955,9 @@ EXPORT_SYMBOL_GPL(xdr_commit_encode);
>  static noinline __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
>  						   size_t nbytes)
>  {
> -	__be32 *p;
>  	int space_left;
>  	int frag1bytes, frag2bytes;
> +	void *p;
> =20
>  	if (nbytes > PAGE_SIZE)
>  		goto out_overflow; /* Bigger buffers require special handling */
> @@ -986,12 +986,12 @@ static noinline __be32 *xdr_get_next_encode_buffer(st=
ruct xdr_stream *xdr,
>  	 * xdr_commit_encode() has shifted this one back:
>  	 */
>  	p =3D page_address(*xdr->page_ptr);
> -	xdr->p =3D (void *)p + frag2bytes;
> +	xdr->p =3D p + frag2bytes;
>  	space_left =3D xdr->buf->buflen - xdr->buf->len;
>  	if (space_left - nbytes >=3D PAGE_SIZE)
> -		xdr->end =3D (void *)p + PAGE_SIZE;
> +		xdr->end =3D p + PAGE_SIZE;
>  	else
> -		xdr->end =3D (void *)p + space_left - frag1bytes;
> +		xdr->end =3D p + space_left - frag1bytes;
> =20
>  	xdr->buf->page_len +=3D frag2bytes;
>  	xdr->buf->len +=3D nbytes;
>=20
>=20
>=20
