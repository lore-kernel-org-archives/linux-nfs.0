Return-Path: <SRS0=c+aj=QI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB298C282DA
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:57:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BB5F3218AF
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:57:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LsUCWFRM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730275AbfBAT5u (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Feb 2019 14:57:50 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:35785 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730259AbfBAT5u (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Feb 2019 14:57:50 -0500
Received: by mail-it1-f196.google.com with SMTP id p197so11646347itp.0
        for <linux-nfs@vger.kernel.org>; Fri, 01 Feb 2019 11:57:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=jF0p18C3njZaaq9uN+q6IYdqIemjJ13MVyPC5Kr/7A8=;
        b=LsUCWFRMHw7KjCBNQ9NRNhktz4Oxt9oladYHDAlV5E1gJrmL0hgZcp+7zy/Jf3uwTS
         LfHPp4QtWtch5F0t1ANZr9ppyQeGfHI0Nr0YCuo+M+l5rxQRhYJ5ftfgfjLrVrPhe7f6
         PN/57MBU0dWKWhkUnkEFOrbQkYoHs3p0dghdZpxDUPv9VP34IEMWsQ+06Evj/Eke7rRi
         NdsRsprmM725SStuOtkwBYah0ynPwjt/sF9jU+2ApnmOv+hJmtcq8W8aXi88HWX4vCpf
         pDdDYrMmNjQ8ONEQpm1xXfTNsHqtcXOaTMR4lxV0dbMMBWoXwHZFUzwOtaXEIVgNhYd7
         WAFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=jF0p18C3njZaaq9uN+q6IYdqIemjJ13MVyPC5Kr/7A8=;
        b=g1Y+/qtsw5eNysLBizDJ65d5+RSPfyj31bnz0s/ay8JwzKOkRtFZpR1rtatTGbN/eE
         bhmFr72JVoTTdZfCgI0Dvonej9Z5c8SF9XZ5S8QVF1CjX7b81pUdAZcbTsmbBFy81t4+
         LbspAVnRYNnfozP631BNifPaQs7eV6P/7DB0pWNdx1QMhmDqjogXYt4wyenjQFy8gXeH
         QJL9JI8wT/BzTOWppKGDaWPcXSTIxnNJlcXdRlmLnIGkgjfOCdqq/F+9U6Et5T54SP/a
         u2LVdAtA2dPIxqxOkNAtZC8bdGP8hoq3RvBlW6Uk0oLcZQG7Ex4kL9KFPWpCw30rxT3I
         iYng==
X-Gm-Message-State: AHQUAuaZs3xn6Ar7UfLMkUxVl5WPgmRYD4DWS/AwylRQmmU/1ZWM0ZUU
        CxjhAqja//5MTYOOb5sQVVbX813J
X-Google-Smtp-Source: AHgI3Iahz1penbga3SfbUxEHfO2Y/twSZZ9u5xx/RllQyw6oJg2uzxJxZUrfsxb197rTCYU79g76gw==
X-Received: by 2002:a05:660c:fd2:: with SMTP id m18mr2487502itn.1.1549051069017;
        Fri, 01 Feb 2019 11:57:49 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l3sm1729665itb.43.2019.02.01.11.57.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 11:57:48 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x11Jvlwh008705;
        Fri, 1 Feb 2019 19:57:47 GMT
Subject: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     simo@redhat.com
Date:   Fri, 01 Feb 2019 14:57:47 -0500
Message-ID: <20190201195747.11389.75164.stgit@manet.1015granger.net>
In-Reply-To: <20190201195538.11389.96106.stgit@manet.1015granger.net>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Byte-swapping causes a CPU pipeline bubble on some processors. When
a decoder is comparing an on-the-wire value for equality, byte-
swapping can be avoided by comparing it directly to a pre-byte-
swapped constant value.

The current set of pre-xdr'd constants is missing some common values
used in the RPC header. Fill those out.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/auth_gss.h |    5 ++-
 include/linux/sunrpc/xdr.h      |   66 ++++++++++++++++++++++++---------------
 2 files changed, 45 insertions(+), 26 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 30427b7..adc4be2 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -19,7 +19,10 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/gss_api.h>
 
-#define RPC_GSS_VERSION		1
+enum {
+	RPC_GSS_VERSION = 1,
+	rpc_gss_version = cpu_to_be32(RPC_GSS_VERSION)
+};
 
 #define MAXSEQ 0x80000000 /* maximum legal sequence number, from rfc 2203 */
 
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 787939d..69161cb 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -17,6 +17,7 @@
 #include <asm/byteorder.h>
 #include <asm/unaligned.h>
 #include <linux/scatterlist.h>
+#include <linux/sunrpc/msg_prot.h>
 
 struct bio_vec;
 struct rpc_rqst;
@@ -79,31 +80,46 @@ struct xdr_buf {
 	buf->buflen = len;
 }
 
-/*
- * pre-xdr'ed macros.
- */
-
-#define	xdr_zero	cpu_to_be32(0)
-#define	xdr_one		cpu_to_be32(1)
-#define	xdr_two		cpu_to_be32(2)
-
-#define	rpc_success		cpu_to_be32(RPC_SUCCESS)
-#define	rpc_prog_unavail	cpu_to_be32(RPC_PROG_UNAVAIL)
-#define	rpc_prog_mismatch	cpu_to_be32(RPC_PROG_MISMATCH)
-#define	rpc_proc_unavail	cpu_to_be32(RPC_PROC_UNAVAIL)
-#define	rpc_garbage_args	cpu_to_be32(RPC_GARBAGE_ARGS)
-#define	rpc_system_err		cpu_to_be32(RPC_SYSTEM_ERR)
-#define	rpc_drop_reply		cpu_to_be32(RPC_DROP_REPLY)
-
-#define	rpc_auth_ok		cpu_to_be32(RPC_AUTH_OK)
-#define	rpc_autherr_badcred	cpu_to_be32(RPC_AUTH_BADCRED)
-#define	rpc_autherr_rejectedcred cpu_to_be32(RPC_AUTH_REJECTEDCRED)
-#define	rpc_autherr_badverf	cpu_to_be32(RPC_AUTH_BADVERF)
-#define	rpc_autherr_rejectedverf cpu_to_be32(RPC_AUTH_REJECTEDVERF)
-#define	rpc_autherr_tooweak	cpu_to_be32(RPC_AUTH_TOOWEAK)
-#define	rpcsec_gsserr_credproblem	cpu_to_be32(RPCSEC_GSS_CREDPROBLEM)
-#define	rpcsec_gsserr_ctxproblem	cpu_to_be32(RPCSEC_GSS_CTXPROBLEM)
-#define	rpc_autherr_oldseqnum	cpu_to_be32(101)
+enum xdr_be32_equivalents {
+	xdr_zero		= cpu_to_be32(0),
+	xdr_one			= cpu_to_be32(1),
+	xdr_two			= cpu_to_be32(2),
+
+	rpc_version		= cpu_to_be32(RPC_VERSION),
+
+	rpc_auth_null		= cpu_to_be32(RPC_AUTH_NULL),
+	rpc_auth_unix		= cpu_to_be32(RPC_AUTH_UNIX),
+	rpc_auth_short		= cpu_to_be32(RPC_AUTH_SHORT),
+	rpc_auth_des		= cpu_to_be32(RPC_AUTH_DES),
+	rpc_auth_krb		= cpu_to_be32(RPC_AUTH_KRB),
+	rpc_auth_gss		= cpu_to_be32(RPC_AUTH_GSS),
+
+	rpc_call		= cpu_to_be32(RPC_CALL),
+	rpc_reply		= cpu_to_be32(RPC_REPLY),
+
+	rpc_msg_accepted	= cpu_to_be32(RPC_MSG_ACCEPTED),
+	rpc_msg_denied		= cpu_to_be32(RPC_MSG_DENIED),
+
+	rpc_success		= cpu_to_be32(RPC_SUCCESS),
+	rpc_prog_unavail	= cpu_to_be32(RPC_PROG_UNAVAIL),
+	rpc_prog_mismatch	= cpu_to_be32(RPC_PROG_MISMATCH),
+	rpc_proc_unavail	= cpu_to_be32(RPC_PROC_UNAVAIL),
+	rpc_garbage_args	= cpu_to_be32(RPC_GARBAGE_ARGS),
+	rpc_system_err		= cpu_to_be32(RPC_SYSTEM_ERR),
+	rpc_drop_reply		= cpu_to_be32(RPC_DROP_REPLY),
+
+	rpc_mismatch		= cpu_to_be32(RPC_MISMATCH),
+	rpc_auth_error		= cpu_to_be32(RPC_AUTH_ERROR),
+
+	rpc_auth_ok		= cpu_to_be32(RPC_AUTH_OK),
+	rpc_autherr_badcred	= cpu_to_be32(RPC_AUTH_BADCRED),
+	rpc_autherr_rejectedcred = cpu_to_be32(RPC_AUTH_REJECTEDCRED),
+	rpc_autherr_badverf	= cpu_to_be32(RPC_AUTH_BADVERF),
+	rpc_autherr_rejectedverf = cpu_to_be32(RPC_AUTH_REJECTEDVERF),
+	rpc_autherr_tooweak	= cpu_to_be32(RPC_AUTH_TOOWEAK),
+	rpcsec_gsserr_credproblem = cpu_to_be32(RPCSEC_GSS_CREDPROBLEM),
+	rpcsec_gsserr_ctxproblem = cpu_to_be32(RPCSEC_GSS_CTXPROBLEM),
+};
 
 /*
  * Miscellaneous XDR helper functions

