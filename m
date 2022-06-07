Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C445C43334
	for <linux-nfs@archiver.kernel.org>; Tue,  7 Jun 2022 01:05:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232766AbiFGBFz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 6 Jun 2022 21:05:55 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51552 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232513AbiFGBFy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2022 21:05:54 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.220.29])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 77BC06AA4D
        for <linux-nfs@vger.kernel.org>; Mon,  6 Jun 2022 18:05:53 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id 364B61FAE3;
        Tue,  7 Jun 2022 01:05:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1654563952; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=n3TuOM+703DKMqP6jLJL2VhZSBSLY8652zR/b4ZaytM=;
        b=DMOtuOGeqileWBbj6OMWiKQzaW2xsWVbH48o7iq+HtqINVolBGzdaTOv86EWAnL256JK1I
        hvn9Kf6nZ1/DqIDWluTLvSrlsJDNZmASzxOxqppTJhYLdwUceZjfXfcyMxG+LPI9tC6lx/
        c0SroRcvPvX+yyloqSHwSb2pPNp9LFc=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1654563952;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=n3TuOM+703DKMqP6jLJL2VhZSBSLY8652zR/b4ZaytM=;
        b=dL763/Z7yZOF0z0M6/XpTrReTYg12gzQXEp4jOGyM1ieuLbHW9CjFvRvWwwpn2QLdn/1k1
        xdtOqfTHbNrkPWAA==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 5D68A13A5F;
        Tue,  7 Jun 2022 01:05:51 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id 3I+LBm+knmKEFQAAMHmgww
        (envelope-from <neilb@suse.de>); Tue, 07 Jun 2022 01:05:51 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Chuck Lever" <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 3/5] SUNRPC: Clean up xdr_commit_encode()
In-reply-to: <165445911819.1664.8436212544546306528.stgit@bazille.1015granger.net>
References: <165445865736.1664.4497130284832282034.stgit@bazille.1015granger.net>,
 <165445911819.1664.8436212544546306528.stgit@bazille.1015granger.net>
Date:   Tue, 07 Jun 2022 11:05:48 +1000
Message-id: <165456394819.22243.15333379326870400835@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 06 Jun 2022, Chuck Lever wrote:
> Both the ::iov_len field and the third parameter of memcpy() and
> memmove() are size_t. There's no reason for the implicit conversion
> from size_t to int and back. Change the type of @shift to make the
> code easier to read and understand.

I wouldn't object to "shift" being renamed "frag1bytes" to make the
connection with xdr_get_next_encode_buffer() more blatant..

Reviewed-by: NeilBrown <neilb@suse.de>

Thanks,
NeilBrown


> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xdr.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index 08a85375b311..de8f71468637 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -933,14 +933,16 @@ EXPORT_SYMBOL_GPL(xdr_init_encode);
>   */
>  inline void xdr_commit_encode(struct xdr_stream *xdr)
>  {
> -	int shift = xdr->scratch.iov_len;
> +	size_t shift = xdr->scratch.iov_len;
>  	void *page;
>  
>  	if (shift == 0)
>  		return;
> +
>  	page = page_address(*xdr->page_ptr);
>  	memcpy(xdr->scratch.iov_base, page, shift);
>  	memmove(page, page + shift, (void *)xdr->p - page);
> +
>  	xdr_reset_scratch_buffer(xdr);
>  }
>  EXPORT_SYMBOL_GPL(xdr_commit_encode);
> 
> 
> 
