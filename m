Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41544 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751775AbbG2D7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2015 23:59:24 -0400
Date: Wed, 29 Jul 2015 13:59:14 +1000
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH] fs-pin: allow pin_remove() to be called other than from
 ->kill()
Message-ID: <20150729135914.13cb0f86@noble>
In-Reply-To: <55B5A186.7040004@gmail.com>
References: <55B5A012.1030006@gmail.com>
	<55B5A186.7040004@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



fs-pin currently assumes when either the vfsmount or the fs_pin wants
to unpin, pin_kill() will be called.
This requires that the ->kill() function can wait for any transient
references to the fs_pin to be released.  If the structure containing
the fs_pin doesn't already have the ability to wait for references,
this can be a burden.

As the fs_pin already has infrastructure for waiting, that can be
leveraged to remove the burden.

In this alternate scenario, only the vfsmount calls pin_kill() when it
wants to unpin.  The owner of the fs_pin() instead calls pin_remove().

The ->kill() function removes any long-term references, and then calls
pin_kill() (recursively).
When the last reference on (the structure containing) the fs_pin is
dropped, pin_remove() will be called and the (recursive) pin_kill()
call will complete.

For this to be safe, the final "put" must *not* free the structure if
pin_kill() has already been called, as that could leave ->kill()
accessing freed data.

So we provide a return value for pin_remove() which reports the old
->done value.

When final put calls pin_remove() it checks that value.
If it was 0, then pin_kill() has not called ->kill and will not,
so final put can free the data structure.
If it was -1, then pin_kill() has called ->kill, and ->kill will
free the data structure - final put must not touch it.

This makes the 'wait' infrastructure of fs_pin available to any
pinning client which wants to use it.

Signed-Off-By: NeilBrown <neilb@suse.com>

---
Hi Al,
 do you see this as a workable solution?  I think it will improve the nfsd pining patch
a lot.

Thanks,
NeilBrown


diff --git a/fs/fs_pin.c b/fs/fs_pin.c
index 611b5408f6ec..b7954a9d17da 100644
--- a/fs/fs_pin.c
+++ b/fs/fs_pin.c
@@ -6,16 +6,32 @@
 
 static DEFINE_SPINLOCK(pin_lock);
 
-void pin_remove(struct fs_pin *pin)
+/**
+ * pin_remove - disconnect an fs_pin from the pinned structure.
+ * @pin:	The struct fs_pin which is pinning something.
+ *
+ * Detach a 'pin' which was added by pin_insert().  A return value
+ * of -1 implies that pin_kill() has already been called and that the
+ * ->kill() function now owns the data structure containing @pin.
+ * The function which called pin_remove() must not touch the data structure
+ * again (unless it is the ->kill() function itself).
+ * A return value of 0 implies an uneventful disconnect: pin_kill() has not called,
+ * and will not call, the ->kill() function on this @pin.
+ * Any other return value is a usage error - e.g. repeated call to pin_remove().
+ */
+int pin_remove(struct fs_pin *pin)
 {
+	int ret;
 	spin_lock(&pin_lock);
 	hlist_del_init(&pin->m_list);
 	hlist_del_init(&pin->s_list);
 	spin_unlock(&pin_lock);
 	spin_lock_irq(&pin->wait.lock);
+	ret = pin->done;
 	pin->done = 1;
 	wake_up_locked(&pin->wait);
 	spin_unlock_irq(&pin->wait.lock);
+	return ret;
 }
 
 void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hlist_head *p)
diff --git a/include/linux/fs_pin.h b/include/linux/fs_pin.h
index 3886b3bffd7f..2fe9d3ba09e8 100644
--- a/include/linux/fs_pin.h
+++ b/include/linux/fs_pin.h
@@ -18,7 +18,7 @@ static inline void init_fs_pin(struct fs_pin *p, void (*kill)(struct fs_pin *))
 	p->kill = kill;
 }
 
-void pin_remove(struct fs_pin *);
+int pin_remove(struct fs_pin *);
 void pin_insert_group(struct fs_pin *, struct vfsmount *, struct hlist_head *);
 void pin_insert(struct fs_pin *, struct vfsmount *);
 void pin_kill(struct fs_pin *);
