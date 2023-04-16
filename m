Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D49F7C77B61
	for <linux-nfs@archiver.kernel.org>; Sun, 16 Apr 2023 17:05:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229500AbjDPRFM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 16 Apr 2023 13:05:12 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36884 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229458AbjDPRFL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Apr 2023 13:05:11 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 746B11FFE
        for <linux-nfs@vger.kernel.org>; Sun, 16 Apr 2023 10:05:09 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 0383461048
        for <linux-nfs@vger.kernel.org>; Sun, 16 Apr 2023 17:05:09 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F826C433EF;
        Sun, 16 Apr 2023 17:05:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1681664708;
        bh=2DzESkY33vxidAP8HjU+6SI3H5lgeCf1rQfQS8biPpM=;
        h=Subject:From:To:Cc:Date:From;
        b=FgetmNBbECdyLuilX6KYAeRVCg0sIB0GkpKNvkB4x9O3VWmA9ESGLlF2Cpzu5U6ho
         B5Sg95i6A1yCQa/l3CAWdc4ln7TpSxMZGI34ro4hHXdqi7yUgDO3V898sQvpPTCKu9
         QDQtYKCjISnWN4K1gpgpkRhQDk9g8RLjtIK8ddPLajV/2HKQuzFK7RgSeABK2VcOJN
         qiqm/XvHj1uDdkYRdME+IJl0I/eHMr5Wj5+87kXt6mACFHmgsxvmjkCl5B/dCHB+AB
         /FKKrUCgYdGviCsb1kyFv64qg7tuAJzvUxRbnYevR3CcW2nWPmNypc4ZYgrgzYu8F3
         lkPWo0EmfHOaw==
Subject: [PATCH] SUNRPC: Fix failures of checksum Kunit tests
From:   Chuck Lever <cel@kernel.org>
To:     smayhew@redhat.com
Cc:     linux-nfs@vger.kernel.org
Date:   Sun, 16 Apr 2023 13:05:06 -0400
Message-ID: <168166470652.2679.10078886564885712799.stgit@bazille.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

Scott reports that when the new GSS krb5 Kunit tests are built as
a separate module and loaded, the RFC 6803 and RFC 8009 checksum
tests all fail, even though they pass when run under kunit.py.

It appears that passing a buffer backed by static const memory to
gss_krb5_checksum() is a problem. A printk in checksum_case() shows
the correct plaintext, but by the time the buffer has been converted
to a scatterlist and arrives at checksummer(), it contains all
zeroes.

Replacing this buffer with one that is dynamically allocated fixes
the issue.

Reported-by: Scott Mayhew <smayhew@redhat.com>
Fixes: 02142b2ca8fc ("SUNRPC: Add checksum KUnit tests for the RFC 6803 encryption types")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/auth_gss/gss_krb5_test.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_test.c b/net/sunrpc/auth_gss/gss_krb5_test.c
index aa6ec4e858aa..95ca783795c5 100644
--- a/net/sunrpc/auth_gss/gss_krb5_test.c
+++ b/net/sunrpc/auth_gss/gss_krb5_test.c
@@ -73,7 +73,6 @@ static void checksum_case(struct kunit *test)
 {
 	const struct gss_krb5_test_param *param = test->param_value;
 	struct xdr_buf buf = {
-		.head[0].iov_base	= param->plaintext->data,
 		.head[0].iov_len	= param->plaintext->len,
 		.len			= param->plaintext->len,
 	};
@@ -99,6 +98,10 @@ static void checksum_case(struct kunit *test)
 	err = crypto_ahash_setkey(tfm, Kc.data, Kc.len);
 	KUNIT_ASSERT_EQ(test, err, 0);
 
+	buf.head[0].iov_base = kunit_kzalloc(test, buf.head[0].iov_len, GFP_KERNEL);
+	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, buf.head[0].iov_base);
+	memcpy(buf.head[0].iov_base, param->plaintext->data, buf.head[0].iov_len);
+
 	checksum.len = gk5e->cksumlength;
 	checksum.data = kunit_kzalloc(test, checksum.len, GFP_KERNEL);
 	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, checksum.data);


