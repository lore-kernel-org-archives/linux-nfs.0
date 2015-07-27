Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35850 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755269AbbG0DHE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 23:07:04 -0400
Message-ID: <55B5A04D.8090905@gmail.com>
Date: Mon, 27 Jul 2015 11:06:53 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 1/9 v8] fs_pin: Initialize value for fs_pin explicitly
References: <55B5A012.1030006@gmail.com>
In-Reply-To: <55B5A012.1030006@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without initialized, done in fs_pin at stack space may
contains strange value.

v8, same as v3
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

