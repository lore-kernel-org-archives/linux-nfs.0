Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32967 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932612AbcCKDkH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Mar 2016 22:40:07 -0500
From: Yongcheng Yang <yoyang@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com, Yongcheng Yang <yongcheng.yang@gmail.com>
Subject: [PATCH] mountd.man: Update to change -P option as an alias for -p
Date: Fri, 11 Mar 2016 11:39:59 +0800
Message-Id: <1457667599-6880-1-git-send-email-yoyang@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yongcheng Yang <yongcheng.yang@gmail.com>

Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
---
 utils/mountd/mountd.man | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index 7c5bfbe..66e3bba 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -115,10 +115,7 @@ must be invoked with the option
 .B \-n " or " \-\-no-tcp
 Don't advertise TCP for mount.
 .TP
-.B \-P
-Ignored (compatibility with unfsd??).
-.TP
-.B \-p num " or " \-\-port num
+.B \-p num " or " \-P num " or " \-\-port num
 Specifies the port number used for RPC listener sockets.
 If this option is not specified,
 .B rpc.mountd
-- 
2.4.3

