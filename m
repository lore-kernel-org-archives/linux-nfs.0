Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AF65C169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 52A3E218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZFq/aT3d"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727260AbfBKQYp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:24:45 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:40551 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728484AbfBKQYp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:24:45 -0500
Received: by mail-it1-f193.google.com with SMTP id i2so3606006ite.5;
        Mon, 11 Feb 2019 08:24:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Z66nf1oMqx7yZleiBce97GTP+EwJaeegxHi7p538Oug=;
        b=ZFq/aT3dI7+gYGqZ+Xe5xhkT1EHLZe0L/NcxZHf7PB67jg7mccUpwT+s7gsobUosnA
         wnVuEEYUwoOEmWmZ48cg5AjBD515e18r9izbqHtEKLTCsS+HnvDqYTYkG8JwONOAv1aD
         jWbknV3Vb6iEMlKtmUwwkH+G9RleC3+k4XuPEQt8TJGCO6it/eAQuQZ3K7XlVNH/FTSU
         IGqBt/suBY0LcTubw2KJZr557f6jVgialnbax5Jt1V4cvuVkbO3LbX+PJ7QGcHeNz4b/
         Gi2eVtGn239SeTk/A3BUZ9zUwJG41d7a/c7PAqZj/Fw2YzceT1rTZWiqC5hCJ8cJNyEn
         e3AQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Z66nf1oMqx7yZleiBce97GTP+EwJaeegxHi7p538Oug=;
        b=M2w2htBAqAT48pgFLQWJz0tD6X8WRaC3Mbox80djG2VP3aOnHtBUPewGoY1+/5GCOm
         fUK9LkQtt6CxWK4OWXUbwrp1KMLXsTVBTOJi0yK/wMvi3VJWRRZdKFNhdaoSqG3PEJas
         BqtfSAIUFGDwgZAoMS0t8GTvKzIK1VetbF1eTzVRuRDXzMQCKsQytCQTMvpYSmng3sI+
         IVFvHkxpC6qq9shhoKZSD7Pm0L6EQzU4qjblW2+07PEgh0ctmfiK76n45qBiWTSR5mrK
         zrhiUT0wUzZfrhynt79PCqyFYRm/xgedQ831TzAoKz6EL/jTQz0u3zNB7cVxKJK2v0ah
         49hw==
X-Gm-Message-State: AHQUAuYEPHXrXm56r8H1iwGWTEhGG3th/r1Hj+ksSFfGuL6P84ckxNgb
        7KaOlTqFO9v3tsUQ7AogZfHZB+kv
X-Google-Smtp-Source: AHgI3Iaqsh6FQmHgBjgSRZRB7JBrVjhXWRWMyOvRguR5/tyxE4/ANJHoAQT7+pZM2LJyoTc2e/UB6Q==
X-Received: by 2002:a02:9951:: with SMTP id d17mr18657688jak.134.1549902284130;
        Mon, 11 Feb 2019 08:24:44 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id s81sm2641832itb.8.2019.02.11.08.24.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:24:43 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGOhIf029988;
        Mon, 11 Feb 2019 16:24:43 GMT
Subject: [PATCH v1 12/23] SUNRPC: Add build option to disable support for
 insecure enctypes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:24:43 -0500
Message-ID: <20190211162442.2817.45497.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Enable distributions to enforce the rejection of ancient and
insecure Kerberos enctypes in the kernel's RPCSEC_GSS
implementation. These are the single-DES encryption types that
were deprecated in 2012 by RFC 6649.

Enctypes that were deprecated more recently (by RFC 8429) remain
fully supported for now because they are still likely to be widely
used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Simo Sorce <simo@redhat.com>
---
 include/linux/sunrpc/gss_krb5_enctypes.h |   42 +++++++++++++++++++++++++++++-
 net/sunrpc/Kconfig                       |   16 +++++++++++
 net/sunrpc/auth_gss/gss_krb5_mech.c      |    2 +
 3 files changed, 59 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/gss_krb5_enctypes.h b/include/linux/sunrpc/gss_krb5_enctypes.h
index ec6234e..981c89c 100644
--- a/include/linux/sunrpc/gss_krb5_enctypes.h
+++ b/include/linux/sunrpc/gss_krb5_enctypes.h
@@ -1,4 +1,44 @@
+/* SPDX-License-Identifier: GPL-2.0 */
 /*
- * Dumb way to share this static piece of information with nfsd
+ * Define the string that exports the set of kernel-supported
+ * Kerberos enctypes. This list is sent via upcall to gssd, and
+ * is also exposed via the nfsd /proc API. The consumers generally
+ * treat this as an ordered list, where the first item in the list
+ * is the most preferred.
+ */
+
+#ifndef _LINUX_SUNRPC_GSS_KRB5_ENCTYPES_H
+#define _LINUX_SUNRPC_GSS_KRB5_ENCTYPES_H
+
+#ifdef CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES
+
+/*
+ * NB: This list includes encryption types that were deprecated
+ * by RFC 8429 (DES3_CBC_SHA1 and ARCFOUR_HMAC).
+ *
+ * ENCTYPE_AES256_CTS_HMAC_SHA1_96
+ * ENCTYPE_AES128_CTS_HMAC_SHA1_96
+ * ENCTYPE_DES3_CBC_SHA1
+ * ENCTYPE_ARCFOUR_HMAC
+ */
+#define KRB5_SUPPORTED_ENCTYPES "18,17,16,23"
+
+#else	/* CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES */
+
+/*
+ * NB: This list includes encryption types that were deprecated
+ * by RFC 8429 and RFC 6649.
+ *
+ * ENCTYPE_AES256_CTS_HMAC_SHA1_96
+ * ENCTYPE_AES128_CTS_HMAC_SHA1_96
+ * ENCTYPE_DES3_CBC_SHA1
+ * ENCTYPE_ARCFOUR_HMAC
+ * ENCTYPE_DES_CBC_MD5
+ * ENCTYPE_DES_CBC_CRC
+ * ENCTYPE_DES_CBC_MD4
  */
 #define KRB5_SUPPORTED_ENCTYPES "18,17,16,23,3,1,2"
+
+#endif	/* CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES */
+
+#endif	/* _LINUX_SUNRPC_GSS_KRB5_ENCTYPES_H */
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index ac09ca8..83f5617 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -34,6 +34,22 @@ config RPCSEC_GSS_KRB5
 
 	  If unsure, say Y.
 
+config CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES
+	bool "Secure RPC: Disable insecure Kerberos encryption types"
+	depends on RPCSEC_GSS_KRB5
+	default n
+	help
+	  Choose Y here to disable the use of deprecated encryption types
+	  with the Kerberos version 5 GSS-API mechanism (RFC 1964). The
+	  deprecated encryption types include DES-CBC-MD5, DES-CBC-CRC,
+	  and DES-CBC-MD4. These types were deprecated by RFC 6649 because
+	  they were found to be insecure.
+
+	  N is the default because many sites have deployed KDCs and
+	  keytabs that contain only these deprecated encryption types.
+	  Choosing Y prevents the use of known-insecure encryption types
+	  but might result in compatibility problems.
+
 config SUNRPC_DEBUG
 	bool "RPC: Enable dprintk debugging"
 	depends on SUNRPC && SYSCTL
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index eab71fc..be31a58 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -53,6 +53,7 @@
 static struct gss_api_mech gss_kerberos_mech;	/* forward declaration */
 
 static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
+#ifndef CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES
 	/*
 	 * DES (All DES enctypes are mapped to the same gss functionality)
 	 */
@@ -74,6 +75,7 @@
 	  .cksumlength = 8,
 	  .keyed_cksum = 0,
 	},
+#endif	/* CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES */
 	/*
 	 * RC4-HMAC
 	 */

