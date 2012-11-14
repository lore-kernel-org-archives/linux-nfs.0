Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34228 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933163Ab2KNWjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2012 17:39:17 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so1402953iea.19
        for <linux-nfs@vger.kernel.org>; Wed, 14 Nov 2012 14:39:17 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] nfs(5): Document the minorversion= mount option
To: linux-nfs@vger.kernel.org
Date: Wed, 14 Nov 2012 17:39:15 -0500
Message-ID: <20121114223600.48062.5680.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Our pals on the Solaris team recently noticed that the minorversion=
option is not documented in nfs(5).  This is a first take, just to
start the conversation.  I'm pretty sure I got the kernel version
information wrong, for instance.

Any other comments?

 utils/mount/nfs.man |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index c15de98..66198cc 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -777,6 +777,23 @@ so if this mount option is not specified, the NFS version 4 client
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

