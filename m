Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB1AFC4320A
	for <linux-nfs@archiver.kernel.org>; Mon,  9 Aug 2021 18:11:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id ABDAE61004
	for <linux-nfs@archiver.kernel.org>; Mon,  9 Aug 2021 18:11:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234930AbhHISMT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 9 Aug 2021 14:12:19 -0400
Received: from mail.kernel.org ([198.145.29.99]:52852 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231357AbhHISMS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Aug 2021 14:12:18 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id D650E60F6F
        for <linux-nfs@vger.kernel.org>; Mon,  9 Aug 2021 18:11:57 +0000 (UTC)
Subject: [PATCH] SUNRPC: Add RPC_AUTH_TLS protocol numbers
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 09 Aug 2021 14:11:57 -0400
Message-ID: <162853266949.4997.17269324922537839389.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Shared by client and server. See:

https://www.iana.org/assignments/rpc-authentication-numbers/rpc-authentication-numbers.xhtml

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/msg_prot.h |    1 +
 include/linux/sunrpc/xdr.h      |    1 +
 2 files changed, 2 insertions(+)

Adding this now means I can introduce support for RPC-with-TLS on
either the client or server in any order.

diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index 938c2bf29db8..02117ed0fa2e 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -20,6 +20,7 @@ enum rpc_auth_flavors {
 	RPC_AUTH_DES   = 3,
 	RPC_AUTH_KRB   = 4,
 	RPC_AUTH_GSS   = 6,
+	RPC_AUTH_TLS   = 7,
 	RPC_AUTH_MAXFLAVOR = 8,
 	/* pseudoflavors: */
 	RPC_AUTH_GSS_KRB5  = 390003,
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index a965cbc136ad..b519609af1d0 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -95,6 +95,7 @@ xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
 #define	rpc_auth_unix	cpu_to_be32(RPC_AUTH_UNIX)
 #define	rpc_auth_short	cpu_to_be32(RPC_AUTH_SHORT)
 #define	rpc_auth_gss	cpu_to_be32(RPC_AUTH_GSS)
+#define	rpc_auth_tls	cpu_to_be32(RPC_AUTH_TLS)
 
 #define	rpc_call	cpu_to_be32(RPC_CALL)
 #define	rpc_reply	cpu_to_be32(RPC_REPLY)


