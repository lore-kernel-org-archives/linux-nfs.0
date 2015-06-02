Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33736 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbbFBB0W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jun 2015 21:26:22 -0400
Message-ID: <556D0637.4060901@gmail.com>
Date: Tue, 02 Jun 2015 09:26:15 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 1/5 v3] fs_pin: Fix uninitialized value in fs_pin
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid using kmalloc for memory allocationg without initialized,
done in fs_pin at stack space may contains strange value.

v1 --> v3,
Adds macro for header file

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/fs_pin.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/fs_pin.h b/include/linux/fs_pin.h
index 3886b3b..0dde7b7 100644
--- a/include/linux/fs_pin.h
+++ b/include/linux/fs_pin.h
@@ -1,3 +1,6 @@
+#ifndef _LINUX_FS_PIN_H
+#define _LINUX_FS_PIN_H
+
 #include <linux/wait.h>
 
 struct fs_pin {
@@ -16,9 +19,12 @@ static inline void init_fs_pin(struct fs_pin *p, void (*kill)(struct fs_pin *))
 	INIT_HLIST_NODE(&p->s_list);
 	INIT_HLIST_NODE(&p->m_list);
 	p->kill = kill;
+	p->done = 0;
 }
 
 void pin_remove(struct fs_pin *);
 void pin_insert_group(struct fs_pin *, struct vfsmount *, struct hlist_head *);
 void pin_insert(struct fs_pin *, struct vfsmount *);
 void pin_kill(struct fs_pin *);
+
+#endif
-- 
2.4.2

