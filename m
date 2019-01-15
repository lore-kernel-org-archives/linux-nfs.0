Return-Path: <SRS0=7zHz=PX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE4BBC43387
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 20:18:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 94ADB20657
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 20:18:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nYQPzHjB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730205AbfAOUSj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Jan 2019 15:18:39 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:36562 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728612AbfAOUSj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2019 15:18:39 -0500
Received: by mail-it1-f194.google.com with SMTP id c9so6256720itj.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jan 2019 12:18:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=YE/M2qZNbXV6WBT0oXXw5mWN5NhT36Izavo7SFo70YM=;
        b=nYQPzHjBd6UM29wjh2cIRtFOOTIbbeusjbCPZLm5xhtfNywfccK5hXqIRKkR4Qnx3p
         jf2g5rWSYTpcvqXxlIkpJawoNjUS7khfKRmfZOdzvG42ArMk7PBLDb8dPciNvFVdKsMr
         1+Z/b8rY+JlSKBQzszSKKLdXvx/6BUrJkvmxr5gT64Xyrp9dgqoDxIxa7ODELNoadSVW
         kNsNvfJMIK6QOwYWFuQaY8symM9Q6ao9etwEnxk/bRgt5ovSIMNgx27DT+8Scs/Tdufx
         s5Er3MgvmPLSmfhcv7hRWa0wU/oLJY67qcXU46dhol5E496xEBm+3Gdqf13s6rJWc4Jt
         wTEg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=YE/M2qZNbXV6WBT0oXXw5mWN5NhT36Izavo7SFo70YM=;
        b=ayaqZ2CKYgCIUWpgBFYWEclNbbu7M+uQyq0r6EViCUQJ594WtEJr7jUcbLJzB2H4b9
         JL3sscvz/PN2WZnHPZivkRwTh3G2dLB0iB+JCPpMq6tdz6TFh4hCWp4f4JudA4fWRCRQ
         YEpm+TERlCGalXw56Tn5TTs2nM4D0/w7jscXsXy/U8+F0YnQe099xENep7UiO7+k5QMG
         0tlJCGoKQN+HR92biGoZ3D9P5YfHBKrGyed+ZUmnJCqT43sJjgI1+NY5tGdBal45kbUi
         X2fodgMRXycbawPcvwkXg7qElGMrUlyXp/z7Ic4vGkFOUds2ch4GQ4qk27Cod3OmBsla
         ES9g==
X-Gm-Message-State: AJcUukfwF+T6c820BjO3DNV0PXP0CgR1M9LtZ/TuDFjL8gBMbNPjhZEQ
        z17+976XDeYqvKXQRHf/zF0=
X-Google-Smtp-Source: ALg8bN6fsq+ZSc0i+FtAeBWj2UHoY4mCZWEta6yglA+32oyhVJdLk4ZRLXKwuHEH602N2TR2TbNuwg==
X-Received: by 2002:a05:660c:34f:: with SMTP id b15mr3728708itl.146.1547583518350;
        Tue, 15 Jan 2019 12:18:38 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id q14sm2065047itb.36.2019.01.15.12.18.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 12:18:37 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x0FKIZ0c011123;
        Tue, 15 Jan 2019 20:18:35 GMT
Subject: [PATCH RFC] SUNRPC: Add build option to disable support for
 insecure enctypes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     simo@redhat.com
Date:   Tue, 15 Jan 2019 15:18:35 -0500
Message-ID: <20190115201835.6381.19527.stgit@manet.1015granger.net>
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
---
 include/linux/sunrpc/gss_krb5_enctypes.h |   42 +++++++++++++++++++++++++++++-
 net/sunrpc/Kconfig                       |   16 +++++++++++
 net/sunrpc/auth_gss/gss_krb5_mech.c      |    2 +
 3 files changed, 59 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/gss_krb5_enctypes.h b/include/linux/sunrpc/gss_krb5_enctypes.h
index ec6234e..788742d 100644
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
+ * by RFC 6649 and RFC 8429 (DES3_CBC_SHA1 and ARCFOUR_HMAC).
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

