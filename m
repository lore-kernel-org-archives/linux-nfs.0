Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:23893 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754315Ab3CLGJB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Mar 2013 02:09:01 -0400
Message-ID: <513EC692.4090907@cn.fujitsu.com>
Date: Tue, 12 Mar 2013 14:09:22 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] pnfs-block: may be return NULL when find a extent
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

maybe return NULL when find a extent, if we use it later,
it will cause oops.

 Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>
---
 fs/nfs/blocklayout/extents.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 9c3e117..131ea59 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -762,6 +762,11 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)

        spin_lock(&bl->bl_ext_lock);
        be = bl_find_get_extent_locked(bl, offset);
+       if (!be) {
+               spin_unlock(&bl->bl_ext_lock);
+               goto out_nosplit;
+       }
+
        rv = be->be_f_offset + be->be_length;
        if (be->be_state != PNFS_BLOCK_INVALID_DATA) {
                spin_unlock(&bl->bl_ext_lock);
--
1.7.1

