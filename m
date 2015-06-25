Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33092 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbbFYOTL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 10:19:11 -0400
Message-ID: <558C0DC3.4020807@gmail.com>
Date: Thu, 25 Jun 2015 22:18:43 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 01/10 v6] fs_pin: Initialize value for fs_pin explicitly
References: <558C0D6A.9050104@gmail.com>
In-Reply-To: <558C0D6A.9050104@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without initialized, done in fs_pin at stack space may
contains strange value.

v3, v4, v5, v6
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
2.4.3

