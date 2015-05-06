Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36556 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbbEFNUB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 09:20:01 -0400
Message-ID: <554A14FA.50407@gmail.com>
Date: Wed, 06 May 2015 21:19:54 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 2/4] fs_pin: Export functions for specific filesystem
References: <554A149B.5060102@gmail.com>
In-Reply-To: <554A149B.5060102@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Exports functions for others who want pin to vfsmount,
eg, nfsd's export cache.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/fs_pin.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/fs_pin.c b/fs/fs_pin.c
index 611b540..553e8b1 100644
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
-- 
2.4.0

