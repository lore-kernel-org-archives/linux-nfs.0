Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E0ACC77B61
	for <linux-nfs@archiver.kernel.org>; Fri, 28 Apr 2023 09:44:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1345379AbjD1Joj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 28 Apr 2023 05:44:39 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56402 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1345739AbjD1Joh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Apr 2023 05:44:37 -0400
Received: from 167-179-156-38.a7b39c.syd.nbn.aussiebb.net (167-179-156-38.a7b39c.syd.nbn.aussiebb.net [167.179.156.38])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 610994497;
        Fri, 28 Apr 2023 02:44:35 -0700 (PDT)
Received: from loth.rohan.me.apana.org.au ([192.168.167.2])
        by formenos.hmeau.com with smtp (Exim 4.94.2 #2 (Debian))
        id 1psKeH-003DRd-E7; Fri, 28 Apr 2023 17:44:19 +0800
Received: by loth.rohan.me.apana.org.au (sSMTP sendmail emulation); Fri, 28 Apr 2023 17:44:18 +0800
Date:   Fri, 28 Apr 2023 17:44:18 +0800
From:   Herbert Xu <herbert@gondor.apana.org.au>
To:     Scott Mayhew <smayhew@redhat.com>, Ard Biesheuvel <ardb@kernel.org>
Cc:     linux-crypto@vger.kernel.org, chuck.lever@oracle.com,
        linux-nfs@vger.kernel.org
Subject: Re: RPCSEC GSS krb5 KUnit test fails on arm64 with h/w accelerated
 ciphers enabled
Message-ID: <ZEuVcizjPtG96/ST@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ZEBi8ReG9LKLcmW3@aion.usersys.redhat.com>
X-Newsgroups: apana.lists.os.linux.cryptoapi
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Scott Mayhew <smayhew@redhat.com> wrote:
>
> diff --git a/arch/arm64/crypto/aes-modes.S b/arch/arm64/crypto/aes-modes.S
> index 0e834a2c062c..477605fad76b 100644
> --- a/arch/arm64/crypto/aes-modes.S
> +++ b/arch/arm64/crypto/aes-modes.S
> @@ -268,6 +268,7 @@ AES_FUNC_START(aes_cbc_cts_encrypt)
>        add             x4, x0, x4
>        st1             {v0.16b}, [x4]                  /* overlapping stores */
>        st1             {v1.16b}, [x0]
> +       st1             {v1.16b}, [x5]
>        ret
> AES_FUNC_END(aes_cbc_cts_encrypt)
> 
> But I don't know if that change is at all correct! (I've never even
> looked at arm64 asm before).  If someone who's knowledgeable about this
> code could chime in, I'd appreciate it.

Ard, could you please take a look at this?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
