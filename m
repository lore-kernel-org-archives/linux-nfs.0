Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:47012 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755774Ab1JYABc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2011 20:01:32 -0400
Message-ID: <4EA5FAD7.4020806@panasas.com>
Date: Mon, 24 Oct 2011 16:55:03 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Michal Marek <mmarek@suse.cz>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH] fs/Makefile: Always inspect exofs/
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


fs/exofs directory has multiple targets now, of which the
ore.ko will be needed by the pnfs-objects-layout-driver
(fs/nfs/objlayout).

As suggested by: Michal Marek <mmarek@suse.cz>  convert
inclusion of exofs/ from obj-$(CONFIG_EXOFS_FS) => obj-$(y).
So ORE can be selected also from fs/nfs/Kconfig

CC: Michal Marek <mmarek@suse.cz>
CC: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/Makefile b/fs/Makefile
index afc1096..5c30a13 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -120,6 +120,6 @@ obj-$(CONFIG_DEBUG_FS)		+= debugfs/
 obj-$(CONFIG_OCFS2_FS)		+= ocfs2/
 obj-$(CONFIG_BTRFS_FS)		+= btrfs/
 obj-$(CONFIG_GFS2_FS)           += gfs2/
-obj-$(CONFIG_EXOFS_FS)          += exofs/
+obj-$(y)          		+= exofs/ # Multiple mods, used by nfs/objlayout
 obj-$(CONFIG_CEPH_FS)		+= ceph/
 obj-$(CONFIG_PSTORE)		+= pstore/
-- 
1.7.6.4

