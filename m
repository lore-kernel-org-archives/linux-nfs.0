Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2975C6379F
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Nov 2020 20:05:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4A3432071E
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Nov 2020 20:05:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UG9rmZmP"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728996AbgKWUF5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 23 Nov 2020 15:05:57 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41724 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728023AbgKWUF5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2020 15:05:57 -0500
Received: from mail-qk1-x744.google.com (mail-qk1-x744.google.com [IPv6:2607:f8b0:4864:20::744])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 726DAC0613CF
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2020 12:05:57 -0800 (PST)
Received: by mail-qk1-x744.google.com with SMTP id b144so3719517qkc.13
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2020 12:05:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=dA7k7olRk4kkAkR4xkyhBYkPn9T2qeHnB5GxQHiwkqI=;
        b=UG9rmZmPEKnONLbYfaZDnTxz9+a5HOJWxJoeq6OGUZ2alzBZ6noQbouRSv+qiakIUr
         /nESr+sNI1yU8P/f+JmbgS6eVe8eMtoHmnZXFr++Gx8Vfbfharkw4E/kZkVBfIDXrQ/m
         uL6V5Lvmj4KvOgR9zSetb3SOLYQDjc8qLxmhwwJ4H2lRlFCiYUt2Cd0gNAOTVIU8S5JE
         TfnTgxBACo1B3zLaD36aKXVd6z3adiL3KMKxGj6Rw5dmZ8iyOIcr53V+gQhku/ylYkO0
         fdH/wlk14pCas4e4xtaoy8jc86mFhpAr9T0iVx6mL4zmkOtQ6TU46zZY3/th3CxZD/Gt
         YBAg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=dA7k7olRk4kkAkR4xkyhBYkPn9T2qeHnB5GxQHiwkqI=;
        b=VgdBDiAM7oh+vUxjEVp9DWhlWIjy8fo+8fgL5/npUmcVb3v+BoSGK8d7vHBLTribYV
         TPglwgmCLbaBC6DGG2c2jh9NlHspPiQnhFWuG/udEOr7R5PN9rw1xdd1OUo5ELdGbifk
         VqMKbXfZcLmkOCoXW+hQM4qA/wVT6tbdX+5QmXcCWnDo6PMtiul4GxTO4Ftue3txwom9
         GFenUke0fErYnHk8H1eHlw3D7GMGYbKv3Xy0tgAP7ZhF66e+vE/miySsL7qnmbfhNWT7
         h3i/npbIUUME+6TfdkONmlhqk4NADssI2k9jF1ugn6Gh//ZLj3L+XPgMsPb2cnpY8Axf
         K8UA==
X-Gm-Message-State: AOAM530TyVfYRCryLTIlHkfvBWlbrC1kYWLztUBag2+PsSE/cPB3qCaJ
        wg2SkumcMSm9GoDCnuW29wnJ5O9vPqs=
X-Google-Smtp-Source: ABdhPJzEoE8wtnSUpbY1dMbkcIqo0OygbJwtRH+lArGCY50hcRtYX4iJtBAW4TRhqW28OMdu+bm3qA==
X-Received: by 2002:a37:9d16:: with SMTP id g22mr1281950qke.62.1606161956439;
        Mon, 23 Nov 2020 12:05:56 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id j17sm10104317qtn.2.2020.11.23.12.05.55
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2020 12:05:55 -0800 (PST)
Sender: Chuck Lever <chucklever@gmail.com>
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id 0ANK5s1j010334
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2020 20:05:54 GMT
Subject: [PATCH v3 22/85] NFSD: Replace READ* macros in nfsd4_decode_getattr()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 23 Nov 2020 15:05:54 -0500
Message-ID: <160616195482.51996.18437989779703151829.stgit@klimt.1015granger.net>
In-Reply-To: <160616177104.51996.14915419165992024951.stgit@klimt.1015granger.net>
References: <160616177104.51996.14915419165992024951.stgit@klimt.1015granger.net>
User-Agent: StGit/0.23-29-ga622f1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index cdddc62a8fb4..52e461969f09 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -772,7 +772,8 @@ nfsd4_decode_delegreturn(struct nfsd4_compoundargs *argp, struct nfsd4_delegretu
 static inline __be32
 nfsd4_decode_getattr(struct nfsd4_compoundargs *argp, struct nfsd4_getattr *getattr)
 {
-	return nfsd4_decode_bitmap(argp, getattr->ga_bmval);
+	return nfsd4_decode_bitmap4(argp, getattr->ga_bmval,
+				    ARRAY_SIZE(getattr->ga_bmval));
 }
 
 static __be32


