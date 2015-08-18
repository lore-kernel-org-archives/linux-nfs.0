Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34114 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbbHRHZF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2015 03:25:05 -0400
Subject: [PATCH 2/6 v9] fs_pin: Export functions for specific filesystem
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
References: <55D2DBF6.3010406@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55D2DDC4.2010805@gmail.com>
Date: Tue, 18 Aug 2015 15:24:52 +0800
MIME-Version: 1.0
In-Reply-To: <55D2DBF6.3010406@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Exports functions for others who want pin to vfsmount,
eg, nfsd's export cache.

These are needed for any module to participate in pinning.

mnt_pin_kill() and group_pin_kill() are just helper-functions for
unmount etc (and are in fs/internal.h) so don't need to be exported.

v9, same as v4
add exporting of pin_kill.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/fs_pin.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/fs_pin.c b/fs/fs_pin.c
index b7954a9..b1a9654 100644
--- a/fs/fs_pin.c
+++ b/fs/fs_pin.c
@@ -33,6 +33,7 @@ int pin_remove(struct fs_pin *pin)
 	spin_unlock_irq(&pin->wait.lock);
 	return ret;
 }
+EXPORT_SYMBOL(pin_remove);
 
 void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hlist_head *p)
 {
@@ -42,11 +43,13 @@ void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hlist_head
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
@@ -88,6 +91,7 @@ void pin_kill(struct fs_pin *p)
 	}
 	rcu_read_unlock();
 }
+EXPORT_SYMBOL(pin_kill);
 
 void mnt_pin_kill(struct mount *m)
 {
-- 
2.4.3

