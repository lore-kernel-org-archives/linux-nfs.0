Return-Path: <SRS0=c+aj=QI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53C06C282DA
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:58:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0CF18218AF
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:58:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p9sEYxZk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730401AbfBAT6W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Feb 2019 14:58:22 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:39307 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730292AbfBAT6W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Feb 2019 14:58:22 -0500
Received: by mail-io1-f67.google.com with SMTP id k7so6704540iob.6
        for <linux-nfs@vger.kernel.org>; Fri, 01 Feb 2019 11:58:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=KYhZBUhVt7L/FI3FzgYHVapqgCpL9eCj2NXeHs+aPNY=;
        b=p9sEYxZka8iqSQ2otwLY+5W2Q3UubcriJcVqGm29KgySuVm5SG71PcT2hVxfwce7D5
         TGwhVGY/xMeqY65mpxy1mfE3+B6RJPegK5Auzz6dWsKpFsAOCRhES/YpxU3sZHUmqiN2
         Ggeb1QUmFxu/xfaaEtEvPmlbGDZH/i46TWGtH+KrJbM4Sof4I/VUGvzjGIWdwdYJCsxh
         D0M95q3Aj6Fewv2Dq6bgPVGGXiZbWcJLTFt5Dxv/5qvzDNQchrwtXmkA9lS0sksfGjT1
         d7VjJRPYLHJ+nu31tObOEA2aiU0uczLFJwruSgWUu2BKw1rF4E0OZ2pWV5bsfuZ2/GbY
         Y5nQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=KYhZBUhVt7L/FI3FzgYHVapqgCpL9eCj2NXeHs+aPNY=;
        b=q9Ub56KRqYfTDi9TuUxtzjjHos82eFmh8qLzIg6uJWrJ/yhpnhEstXJ6NybjF7YMSb
         zocFsO1BrKp3/Owo5XRIKBbdQbKNr0+hMCVotIVnU4hrzd6l0cA9+mPtExgba68qVnLM
         gXLDCqsh/u420I02WGu/zVLiSbyRz/EUJnN5/QLZRWorKdh0TAjw/AsJ9aAH+lGNMQrI
         hStDiZWeB3Nv8sJfCfvbzlDPRQxiY9bga624MTaJERNrVOnDnc9AJ7aQiZeRpSyDrORs
         v9rp7QrrNIPIQqa4B5Z38T6ROsOnScbp4Z0lpxjR+kT0EwzogMQUvnN8xh399hxeY9dZ
         qjuw==
X-Gm-Message-State: AHQUAubo84KHP2sKBnCX0tUf0ZzWgUwIyKIIv3ar4bAqGOocEKG9fAtT
        116bfv/gKg3NDZFjRD9p/No=
X-Google-Smtp-Source: AHgI3IZSp8S4B1iSvEDctP09eV3FhwdQkM7aZEXYptevGWmJGbUWxO35H9rXqjzq5Zw5/FXJ35m8sg==
X-Received: by 2002:a6b:dc18:: with SMTP id s24mr18847012ioc.139.1549051100817;
        Fri, 01 Feb 2019 11:58:20 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id s15sm3511281ioe.52.2019.02.01.11.58.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 11:58:20 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x11JwJRw008723;
        Fri, 1 Feb 2019 19:58:19 GMT
Subject: [PATCH RFC 10/10] SUNRPC: Add SPDX IDs to some net/sunrpc/auth_gss/
 files
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     simo@redhat.com
Date:   Fri, 01 Feb 2019 14:58:19 -0500
Message-ID: <20190201195819.11389.74240.stgit@manet.1015granger.net>
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
 net/sunrpc/auth_gss/auth_gss.c        |   27 +--------------------------
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   27 +--------------------------
 net/sunrpc/auth_gss/gss_mech_switch.c |   27 +--------------------------
 net/sunrpc/auth_gss/gss_rpc_upcall.c  |   15 +--------------
 net/sunrpc/auth_gss/gss_rpc_upcall.h  |   16 ++--------------
 net/sunrpc/auth_gss/gss_rpc_xdr.c     |   15 +--------------
 net/sunrpc/auth_gss/gss_rpc_xdr.h     |   17 +----------------
 net/sunrpc/auth_gss/svcauth_gss.c     |    1 +
 8 files changed, 9 insertions(+), 136 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3d1fbd6..fda454c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: BSD-3-Clause
 /*
  * linux/net/sunrpc/auth_gss/auth_gss.c
  *
@@ -8,34 +9,8 @@
  *
  *  Dug Song       <dugsong@monkey.org>
  *  Andy Adamson   <andros@umich.edu>
- *
- *  Redistribution and use in source and binary forms, with or without
- *  modification, are permitted provided that the following conditions
- *  are met:
- *
- *  1. Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *  2. Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in the
- *     documentation and/or other materials provided with the distribution.
- *  3. Neither the name of the University nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
- *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
- *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
- *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
- *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
- *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
- *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
-
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/types.h>
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index be31a58..56cc85c 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: BSD-3-Clause
 /*
  *  linux/net/sunrpc/gss_krb5_mech.c
  *
@@ -6,32 +7,6 @@
  *
  *  Andy Adamson <andros@umich.edu>
  *  J. Bruce Fields <bfields@umich.edu>
- *
- *  Redistribution and use in source and binary forms, with or without
- *  modification, are permitted provided that the following conditions
- *  are met:
- *
- *  1. Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *  2. Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in the
- *     documentation and/or other materials provided with the distribution.
- *  3. Neither the name of the University nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
- *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
- *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
- *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
- *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
- *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
- *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
  */
 
 #include <crypto/hash.h>
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 379318d..8206009 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: BSD-3-Clause
 /*
  *  linux/net/sunrpc/gss_mech_switch.c
  *
@@ -5,32 +6,6 @@
  *  All rights reserved.
  *
  *  J. Bruce Fields   <bfields@umich.edu>
- *
- *  Redistribution and use in source and binary forms, with or without
- *  modification, are permitted provided that the following conditions
- *  are met:
- *
- *  1. Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *  2. Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in the
- *     documentation and/or other materials provided with the distribution.
- *  3. Neither the name of the University nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
- *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
- *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
- *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
- *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
- *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
- *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
  */
 
 #include <linux/types.h>
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index 73dcda0..0349f45 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -1,21 +1,8 @@
+// SPDX-License-Identifier: GPL-2.0+
 /*
  *  linux/net/sunrpc/gss_rpc_upcall.c
  *
  *  Copyright (C) 2012 Simo Sorce <simo@redhat.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
 #include <linux/types.h>
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.h b/net/sunrpc/auth_gss/gss_rpc_upcall.h
index 1e542ad..31e9634 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.h
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.h
@@ -1,21 +1,8 @@
+/* SPDX-License-Identifier: GPL-2.0+ */
 /*
  *  linux/net/sunrpc/gss_rpc_upcall.h
  *
  *  Copyright (C) 2012 Simo Sorce <simo@redhat.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
 #ifndef _GSS_RPC_UPCALL_H
@@ -45,4 +32,5 @@ int gssp_accept_sec_context_upcall(struct net *net,
 void init_gssp_clnt(struct sunrpc_net *);
 int set_gssp_clnt(struct net *);
 void clear_gssp_clnt(struct sunrpc_net *);
+
 #endif /* _GSS_RPC_UPCALL_H */
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index 006062a..2ff7b70 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -1,21 +1,8 @@
+// SPDX-License-Identifier: GPL-2.0+
 /*
  * GSS Proxy upcall module
  *
  *  Copyright (C) 2012 Simo Sorce <simo@redhat.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
 #include <linux/sunrpc/svcauth.h>
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.h b/net/sunrpc/auth_gss/gss_rpc_xdr.h
index 146c310..3f17411 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.h
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.h
@@ -1,21 +1,8 @@
+/* SPDX-License-Identifier: GPL-2.0+ */
 /*
  * GSS Proxy upcall module
  *
  *  Copyright (C) 2012 Simo Sorce <simo@redhat.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
 #ifndef _LINUX_GSS_RPC_XDR_H
@@ -262,6 +249,4 @@ int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
 #define GSSX_ARG_wrap_size_limit_sz 0
 #define GSSX_RES_wrap_size_limit_sz 0
 
-
-
 #endif /* _LINUX_GSS_RPC_XDR_H */
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index f1aabab..0c5d789 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0
 /*
  * Neil Brown <neilb@cse.unsw.edu.au>
  * J. Bruce Fields <bfields@umich.edu>

