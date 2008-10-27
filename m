From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: fs/nfs_common/Makefile: fix the C file name
Date: Mon, 27 Oct 2008 17:07:37 +0000
Message-ID: <20081027170737.GA1027@hack.voiplan.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:36689 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbYJ0RIC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Oct 2008 13:08:02 -0400
Received: by ug-out-1314.google.com with SMTP id 39so300827ugf.37
        for <linux-nfs@vger.kernel.org>; Mon, 27 Oct 2008 10:08:00 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


There's no file named 'nfs_acl.c' in that directory, it is 'nfsacl.c'.

Signed-off-by: WANG Cong <wangcong-va7F5g4oNmbYtjvyW6yDsg@public.gmane.org>
Cc: J. Bruce Fields <bfields@fieldses.org>

---
diff --git a/fs/nfs_common/Makefile b/fs/nfs_common/Makefile
index f689ed8..5cb60c5 100644
--- a/fs/nfs_common/Makefile
+++ b/fs/nfs_common/Makefile
@@ -2,6 +2,6 @@
 # Makefile for Linux filesystem routines that are shared by client and server.
 #
 
-obj-$(CONFIG_NFS_ACL_SUPPORT) += nfs_acl.o
+obj-$(CONFIG_NFS_ACL_SUPPORT) += nfsacl.o
 
 nfs_acl-objs := nfsacl.o

