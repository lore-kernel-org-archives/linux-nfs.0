Return-Path: <SRS0=c+aj=QI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5F11C282D8
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:57:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A5260218AF
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:57:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tkcx1Rk0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730164AbfBAT5p (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Feb 2019 14:57:45 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:38279 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729876AbfBAT5p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Feb 2019 14:57:45 -0500
Received: by mail-it1-f194.google.com with SMTP id z20so11604473itc.3
        for <linux-nfs@vger.kernel.org>; Fri, 01 Feb 2019 11:57:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Z66nf1oMqx7yZleiBce97GTP+EwJaeegxHi7p538Oug=;
        b=tkcx1Rk0LX6QzL2fDcN3PiuMe1QFL5Aw4uSkfvCyNIigd381Cejp0fVo3isEwI8xvM
         rt/fCgjtCKDKI/oYy49Zf2giNO2iRYQ9uDL0j7M/WHGtTfJss2h9KSffgcfruUaikjwM
         U7HWyhk5TjNFVqKtJL1zvLYenpDsD6B14WehCLr5qerxbCdAy/51DIhSxCGD2dPXUl57
         53ipVZTQQIekCoe64nXPh0XK60VJuzikKd7S9kjt6uPugA0BxAu96xb9F+t/Aganvkhk
         QB7IS58g1hipBEIyOn3p/zSJk331ln5UZVZrGvJ/Z7KhI5HXnaLhJh3Xhv0DYxTpwfBQ
         YDpA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Z66nf1oMqx7yZleiBce97GTP+EwJaeegxHi7p538Oug=;
        b=okGup36it1XlHd5qcsTGhgNPpplpGNhRn0sXG8fomSVP9yW4gHZEkBPxWViMhYRYcA
         Ny2WHJgaWAMotMfnoSSHItwQIJOj8AH7llSuIvXVN7dxos7KVBYkSkvdwPH9lPK2hySB
         f8Y96t1EzqFuhg1iLM6K1PUHbJHEt+LUp7d4c7SbO5U6Z7mrDJjT8KMnxBhNQM3YIkFP
         j7FQq/dPMCa5v3Xryc/pnA+Gco4Rwb8Efl/XAwfLBUQF3ezd5IpTHXQbYZ4kKjkxj2fT
         6uxKauAER0+03CPrtibwISC1cyRelwAjP9njHTgDQxjVlh9cejVHHeXV7uGDT9tOL03I
         QwlQ==
X-Gm-Message-State: AHQUAuZCW/KkmHYZOMJwBk/gDUpBcs9v0rwlVYDitZbBR2YhbvMXPSnG
        VOrAU8keocFDp8cHZRWgwqk=
X-Google-Smtp-Source: AHgI3Ib8gx/+F3sg+xB1piqoPhjzoX29NJ9c4FrqDG709PILxlwQgzkmVunHsKOkhBafJ3NPb1BL9A==
X-Received: by 2002:a24:6fc4:: with SMTP id x187mr2831697itb.93.1549051063872;
        Fri, 01 Feb 2019 11:57:43 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id c31sm1822474itd.25.2019.02.01.11.57.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 11:57:43 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x11Jvgkk008702;
        Fri, 1 Feb 2019 19:57:42 GMT
Subject: [PATCH RFC 03/10] SUNRPC: Add build option to disable support for
 insecure enctypes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     simo@redhat.com
Date:   Fri, 01 Feb 2019 14:57:42 -0500
Message-ID: <20190201195742.11389.27742.stgit@manet.1015granger.net>
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

