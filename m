Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10BD4C677F1
	for <linux-nfs@archiver.kernel.org>; Sun, 15 Jan 2023 17:23:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231504AbjAORX1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 15 Jan 2023 12:23:27 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:55540 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231497AbjAORX0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2023 12:23:26 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 43CDA10AA8;
        Sun, 15 Jan 2023 09:23:25 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id E984CB80B44;
        Sun, 15 Jan 2023 17:23:23 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 58903C433EF;
        Sun, 15 Jan 2023 17:23:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1673803402;
        bh=KueGC4DU52yRbFQ3R4YQVv279GpKxK3k5dNVxnL4kLQ=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=oGUxzmvWOSJF9OUHwkqL4JmbWUVBpupw5NaiIvYrtBOMxZNz9Iu9D4/ubLQNzpaiL
         kfB9kBe+F9173++rw5XPlegXV0C625EyynWhoS5xvUQ1Dr94EF/99PtvnyzRp6TMgY
         FuKl+YMQ03iMx5Xck5FK5pKuyX4EnZZOIZEWOibdZWkO1/64wkUnwMmxoFGwL7f4k+
         Pno0P/ocweeHilPhm7lDS5WIOBMINTXq7rIBtbvJLCNszqf52Kdp5gs5rpus2FwZyy
         mjS8pZFK9yIsYMOY5aCdsKnyvDlKyuve8FFDf/APu8MgPRCvTWky4HhaFhpFWksMzh
         V8rmCF+Ej+zHw==
Subject: [PATCH v2 29/41] SUNRPC: Advertise support for the Camellia
 encryption types
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     dhowells@redhat.com, simo@redhat.com,
        linux-kselftest@vger.kernel.org
Date:   Sun, 15 Jan 2023 12:23:21 -0500
Message-ID: <167380340151.10651.7949882607083067516.stgit@bazille.1015granger.net>
In-Reply-To: <167380196429.10651.4103075913257868035.stgit@bazille.1015granger.net>
References: <167380196429.10651.4103075913257868035.stgit@bazille.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

Add the RFC 6803 encryption types to the string of integers that is
reported to gssd during upcalls. This enables gssd to utilize keys
with these encryption types when support for them is built into the
kernel.

Tested-by: Scott Mayhew <smayhew@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/auth_gss/gss_krb5_mech.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index e616ec536265..5909fef97d27 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -275,6 +275,10 @@ static void gss_krb5_prepare_enctype_priority_list(void)
 		ENCTYPE_AES256_CTS_HMAC_SHA384_192,
 		ENCTYPE_AES128_CTS_HMAC_SHA256_128,
 #endif
+#if defined(CONFIG_RPCSEC_GSS_KRB5_ENCTYPES_CAMELLIA)
+		ENCTYPE_CAMELLIA256_CTS_CMAC,
+		ENCTYPE_CAMELLIA128_CTS_CMAC,
+#endif
 #if defined(CONFIG_RPCSEC_GSS_KRB5_ENCTYPES_AES_SHA1)
 		ENCTYPE_AES256_CTS_HMAC_SHA1_96,
 		ENCTYPE_AES128_CTS_HMAC_SHA1_96,


