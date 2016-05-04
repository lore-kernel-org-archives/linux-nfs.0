Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbcEDGMP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 May 2016 02:12:15 -0400
From: yongcheng.yang@gmail.com
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com, yoyang@redhat.com,
        Yongcheng Yang <yongcheng.yang@gmail.com>
Subject: [PATCH] blkmapd: Add the -h flag on the man page
Date: Wed,  4 May 2016 14:11:59 +0800
Message-Id: <1462342319-7355-1-git-send-email-yongcheng.yang@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yongcheng Yang <yongcheng.yang@gmail.com>

Update SYNOPSIS and OPTIONS for the -h flag.

Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
---
 utils/blkmapd/blkmapd.man | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/utils/blkmapd/blkmapd.man b/utils/blkmapd/blkmapd.man
index fd38122..914b80f 100644
--- a/utils/blkmapd/blkmapd.man
+++ b/utils/blkmapd/blkmapd.man
@@ -9,7 +9,7 @@
 .SH NAME
 blkmapd \- pNFS block layout mapping daemon
 .SH SYNOPSIS
-.B "blkmapd [-d] [-f]"
+.B "blkmapd [-h] [-d] [-f]"
 .SH DESCRIPTION
 The
 .B blkmapd
@@ -33,6 +33,9 @@ reflect the server topology, and passes these devices to the kernel for use
 by the pNFS block layout client.
 .SH OPTIONS
 .TP
+.B -h
+Display usage message.
+.TP
 .B -d
 Performs device discovery only then exits.
 .TP
-- 
2.4.3

