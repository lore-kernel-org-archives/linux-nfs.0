Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38854 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041AbaDPETa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2014 00:19:30 -0400
From: NeilBrown <neilb@suse.de>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 16 Apr 2014 14:03:36 +1000
Subject: [PATCH 14/19] driver core: set PF_FSTRANS while holding gdp_mutex
Cc: xfs@oss.sgi.com
Message-ID: <20140416040336.10604.223.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lockdep reports a locking chain:

  sk_lock-AF_INET --> rtnl_mutex --> gdp_mutex

As sk_lock can be needed for memory reclaim (when loop-back NFS is in
use at least), any memory allocation under gdp_mutex needs to
be protected by PF_FSTRANS.

The path frome rtnl_mutex to gdp_mutex is

    [<ffffffff81841ecc>] get_device_parent+0x4c/0x1f0
    [<ffffffff81842496>] device_add+0xe6/0x610
    [<ffffffff81ac5f2a>] netdev_register_kobject+0x7a/0x130
    [<ffffffff81aaf5d4>] register_netdevice+0x354/0x550
    [<ffffffff81aaf7e5>] register_netdev+0x15/0x30

Signed-off-by: NeilBrown <neilb@suse.de>
---
 drivers/base/core.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 2b567177ef78..1a2735237650 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -750,6 +750,7 @@ static struct kobject *get_device_parent(struct device *dev,
 		struct kobject *kobj = NULL;
 		struct kobject *parent_kobj;
 		struct kobject *k;
+		unsigned int pflags;
 
 #ifdef CONFIG_BLOCK
 		/* block disks show up in /sys/block */
@@ -788,7 +789,9 @@ static struct kobject *get_device_parent(struct device *dev,
 		}
 
 		/* or create a new class-directory at the parent device */
+		current_set_flags_nested(&pflags, PF_FSTRANS);
 		k = class_dir_create_and_add(dev->class, parent_kobj);
+		current_restore_flags_nested(&pflags, PF_FSTRANS);
 		/* do not emit an uevent for this simple "glue" directory */
 		mutex_unlock(&gdp_mutex);
 		return k;


