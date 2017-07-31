Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:24192 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751106AbdGaTPa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 31 Jul 2017 15:15:30 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <anna.schumaker@netapp.com>, <olga.kornievskaia@netapp.com>,
        <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@fc25-7.androsad.fake>,
        "Andy Adamson" <andros@netapp.com>
Subject: [PATCH Version 4 3/3] GSSD RPCSEC_GSS version 3 gssd man page additions
Date: Mon, 31 Jul 2017 15:15:26 -0400
Message-ID: <1501528526-25077-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@fc25-7.androsad.fake>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gssd/gssd.man | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 87eef02..e65ca7f 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -8,7 +8,7 @@
 rpc.gssd \- RPCSEC_GSS daemon
 .SH SYNOPSIS
 .B rpc.gssd
-.RB [ \-DfMnlvr ]
+.RB [ \-DGfMnlvr ]
 .RB [ \-k
 .IR keytab ]
 .RB [ \-p
@@ -20,8 +20,9 @@ rpc.gssd \- RPCSEC_GSS daemon
 .RB [ \-R
 .IR realm ]
 .SH INTRODUCTION
-The RPCSEC_GSS protocol, defined in RFC 5403, is used to provide
-strong security for RPC-based protocols such as NFS.
+The RPCSEC_GSS version 1 protocol defined in RFC 5403, and the RPCSEC_GSS version 3 protocol defined in RFC 7861, are used to provide strong security for RPC-based protocols such as NFS.
+.P
+RPCSEC_GSS version 3 supports all of RPCSEC_GSS version 1 features, and provides support for communicating additional authorization and authentication information to a server.
 .P
 Before exchanging RPC requests using RPCSEC_GSS, an RPC client must
 establish a GSS
@@ -218,6 +219,13 @@ can introduce a security vulnerability, so it is recommended that
 not be used, and that canonical names always be used when requesting
 services.
 .TP
+.B \-G
+For GSS context initialization, GSS version 3 is normally tried first, and if the server reports an RPC level error, then GSS version 1 is tried. The negotiated GSS version is then passed to the kernel. This happens for each GSS context initilaization request.
+
+If the kernel does not support the GSS version downcall, the mount will fail.
+
+If .B \-G is present, the GSS version will not be passed to the kernel, and GSS version 3 will not be attempted; all calls will use GSS version 1.
+.TP
 .B -f
 Runs
 .B rpc.gssd
-- 
1.8.3.1

