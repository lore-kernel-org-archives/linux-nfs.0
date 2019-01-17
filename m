Return-Path: <SRS0=+NMN=PZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 379BCC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Jan 2019 22:02:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EC62A20859
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Jan 2019 22:02:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fW7ACo1r"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727444AbfAQWCh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Jan 2019 17:02:37 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:50243 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726348AbfAQWCh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2019 17:02:37 -0500
Received: by mail-it1-f194.google.com with SMTP id z7so3949969iti.0
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jan 2019 14:02:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=jX16A0Jqac7HO/FNCWNKnYQTXLnVzrcc6cMyf9KuLU0=;
        b=fW7ACo1rkMs+KX70sbhVE3O3o/QsoSU87fimj+neN/OaZ+c+yeb1LenH0mN6I4qhjM
         PgVUq3PLeK7XH0y15wiqHzG5bD7F2g7cfS4xGV2NBhSX4jqvT/w6TmZm5tiKvwbz8wNj
         cByP32xmllg/nhIcuNfGFZfnhwOnBpOz3zyZbmjAaKqfrlMAoZz6QFBT5dF/JSVkKW+c
         7sT3XUn/Ct1pSenTcIuq1fxHmJCPue0iQs+P/uJDIHBXlcs08WiXNwin6ZV30PA4EZ1N
         TWhUDW7tmsbvE64/o+YxenKhd704W6jfsPOMrzG7Ie0yR7zOsOOb3jM5mhht6wNtreG0
         aHUw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=jX16A0Jqac7HO/FNCWNKnYQTXLnVzrcc6cMyf9KuLU0=;
        b=VLq2NEzqRx+kFRlAssNZ8f3RH8BSwCTdVckx5LRX4RfH9eWxiz4jwfhbbPavl3Ltza
         PQI998vkBdLe8Vs1I92Ann3oqHdHy+c0c+k4S8n0f1qUzjedlE224jPNdciOKb+wKnUk
         ANu5gLsPt3cFLfeLFPdx9gThYOCsnKSJnTXMUXkip1KxyIZKeA9r5vMMDWqcMmZMtGNH
         IaqTkSRKfEsh1gJs2rlJa2JNTTzGY4ILPCesXs7IdVCM7gCSSG7AnnrrVvV1c2YTcARq
         M/XfwFJoivar1wdploDhz0i+pv5iNsqBEcUt/WmahhL7yY/ukQgM4XZcEoeVYBe77zuI
         lgIQ==
X-Gm-Message-State: AJcUukcFQSvhVnQg+R4eWpiu1rkqlmiYF7KxPjlbzhNvFJRM/z8f5YOo
        nhR8EVLHCXlF7b4kw/Jcj0hVHwKd
X-Google-Smtp-Source: ALg8bN5VmRmpOLf+CzPBrAocIPuurvpMEOhHyuVfXVr/gYtzDN1nKJMvMXNGAHfYARXcT2xfbe942w==
X-Received: by 2002:a24:b8c6:: with SMTP id m189mr9028447ite.72.1547762556003;
        Thu, 17 Jan 2019 14:02:36 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id v4sm1454871itv.20.2019.01.17.14.02.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 14:02:35 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x0HM2XFW016948;
        Thu, 17 Jan 2019 22:02:33 GMT
Subject: [PATCH RFC] SUNRPC: Add SPDX IDs to some net/sunrpc/auth_gss/ files
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     kstewart@linuxfoundation.org, simo@redhat.com
Date:   Thu, 17 Jan 2019 17:02:33 -0500
Message-ID: <20190117220233.13961.53423.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Files under net/sunrpc/auth_gss/ do not yet have SPDX ID tags.
This directory is somewhat complicated because most of these files
have license boilerplate that is not strictly GPL 2.0.

In this patch I add ID tags where there is an obvious match. The
less recognizable licenses are still under research.

For reference, SPDX IDs added in this patch correspond to the
following license text:

GPL-2.0         https://spdx.org/licenses/GPL-2.0.html
GPL-2.0+        https://spdx.org/licenses/GPL-2.0+.html
BSD-3-Clause    https://spdx.org/licenses/BSD-3-Clause.html

Cc: Simo Sorce <simo@redhat.com>
Cc: Kate Stewart <kstewart@linuxfoundation.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/auth_gss/auth_gss.c        |    1 +
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    1 +
 net/sunrpc/auth_gss/gss_mech_switch.c |    1 +
 net/sunrpc/auth_gss/gss_rpc_upcall.c  |    1 +
 net/sunrpc/auth_gss/gss_rpc_upcall.h  |    1 +
 net/sunrpc/auth_gss/gss_rpc_xdr.c     |    1 +
 net/sunrpc/auth_gss/gss_rpc_xdr.h     |    1 +
 net/sunrpc/auth_gss/svcauth_gss.c     |    1 +
 8 files changed, 8 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3bf7cb0..0513891 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: BSD-3-Clause
 /*
  * linux/net/sunrpc/auth_gss/auth_gss.c
  *
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index be31a58..1286fe9 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: BSD-3-Clause
 /*
  *  linux/net/sunrpc/gss_krb5_mech.c
  *
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 379318d..cd32c12 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: BSD-3-Clause
 /*
  *  linux/net/sunrpc/gss_mech_switch.c
  *
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index 73dcda0..21ff372 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0+
 /*
  *  linux/net/sunrpc/gss_rpc_upcall.c
  *
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.h b/net/sunrpc/auth_gss/gss_rpc_upcall.h
index 1e542ad..7adeeb9 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.h
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0+ */
 /*
  *  linux/net/sunrpc/gss_rpc_upcall.h
  *
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index 006062a..caf2428 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0+
 /*
  * GSS Proxy upcall module
  *
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.h b/net/sunrpc/auth_gss/gss_rpc_xdr.h
index 146c310..3877fa0 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.h
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0+ */
 /*
  * GSS Proxy upcall module
  *
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index f1aabab..0c5d789 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0
 /*
  * Neil Brown <neilb@cse.unsw.edu.au>
  * J. Bruce Fields <bfields@umich.edu>

