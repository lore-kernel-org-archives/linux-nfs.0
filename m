Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34607 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbbFQHuX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2015 03:50:23 -0400
Message-ID: <558126B7.8050700@gmail.com>
Date: Wed, 17 Jun 2015 15:50:15 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 2/6 v5] fs_pin: Export functions for specific filesystem
References: <5581266C.9080404@gmail.com>
In-Reply-To: <5581266C.9080404@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Exports functions for others who want pin to vfsmount,
eg, nfsd's export cache.

v4, v5,
add exporting of pin_kill.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/fs_pin.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/fs_pin.c b/fs/fs_pin.c
index 611b540..a1a4eb2 100644
--- a/fs/fs_pin.c
+++ b/fs/fs_pin.c
@@ -17,6 +17,7 @@ void pin_remove(struct fs_pin *pin)
 	wake_up_locked(&pin->wait);
 	spin_unlock_irq(&pin->wait.lock);
 }
+EXPORT_SYMBOL(pin_remove);
 
 void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hlist_head *p)
 {
@@ -26,11 +27,13 @@ void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hlist_head
 	hlist_add_head(&pin->m_list, &real_mount(m)->mnt_pins);
 	spin_unlock(&pin_lock);
 }
+EXPORT_SYMBOL(pin_insert_group);
 
 void pin_insert(struct fs_pin *pin, struct vfsmount *m)
 {
 	pin_insert_group(pin, m, &m->mnt_sb->s_pins);
 }
+EXPORT_SYMBOL(pin_insert);
 
 void pin_kill(struct fs_pin *p)
 {
@@ -72,6 +75,7 @@ void pin_kill(struct fs_pin *p)
 	}
 	rcu_read_unlock();
 }
+EXPORT_SYMBOL(pin_kill);
 
 void mnt_pin_kill(struct mount *m)
 {
-- 
2.4.3

