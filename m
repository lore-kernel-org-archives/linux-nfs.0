Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54942 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752783AbdIGHAr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Sep 2017 03:00:47 -0400
From: "Jianhong.Yin" <yin-jianhong@163.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH] nfs-utils: nfsman: document minorversion
Date: Thu,  7 Sep 2017 15:00:40 +0800
Message-Id: <20170907070040.4882-1-yin-jianhong@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 utils/mount/nfs.man | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index cc6e992..7d42f19 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -779,6 +779,23 @@ so if this mount option is not specified, the NFS version 4 client
 uses the TCP protocol.
 Refer to the TRANSPORT METHODS section for more details.
 .TP 1.5i
+.BI minorversion= n
+Specifies the protocol minor version number.
+NFSv4 introduces "minor versioning," where NFS protocol enhancements can
+be introduced without bumping the NFS protocol version number.
+Before kernel 2.6.38, the minor version is always zero, and this
+option is not recognized.
+After this kernel, specifying "minorversion=1" enables a number of
+advanced features, such as NFSv4 sessions.
+.IP
+Recent kernels allow the minor version to be specified using the
+.B vers=
+option.
+For example, specifying
+.B vers=4.1
+is the same as specifying
+.BR vers=4,minorversion=1 .
+.TP 1.5i
 .BI port= n
 The numeric value of the server's NFS service port.
 If the server's NFS service is not available on the specified port,
-- 
2.13.5

