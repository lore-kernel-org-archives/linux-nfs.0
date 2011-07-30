From: Jim Rees <rees@umich.edu>
Subject: [PATCH v6 18/26] pnfsblock: bl_find_get_extent
Date: Sat, 30 Jul 2011 13:08:41 -0400
Message-ID: <1312045729-27554-19-git-send-email-rees@umich.edu>
References: <1312045729-27554-1-git-send-email-rees@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:56532 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab1G3RJV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 13:09:21 -0400
In-Reply-To: <1312045729-27554-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

=46rom: Fred Isaman <iisaman@citi.umich.edu>

Implement bl_find_get_extent(), one of the core extent manipulation
routines.

[pnfsblock: Lookup list entry of layouts and tags in reverse order]
Signed-off-by: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

pnfsblock: fix print format warnings for sector_t and size_t

gcc spews warnings about these on x86_64, e.g.:
fs/nfs/blocklayout/blocklayout.c:74: warning: format =E2=80=98%Lu=E2=80=
=99 expects type =E2=80=98long long unsigned int=E2=80=99, but argument=
 2 has type =E2=80=98sector_t=E2=80=99
fs/nfs/blocklayout/blocklayout.c:388: warning: format =E2=80=98%d=E2=80=
=99 expects type =E2=80=98int=E2=80=99, but argument 5 has type =E2=80=98=
size_t=E2=80=99

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.h |    3 ++
 fs/nfs/blocklayout/extents.c     |   47 ++++++++++++++++++++++++++++++=
++++++++
 2 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/bloc=
klayout.h
index d645880..3e1b5fc 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -153,6 +153,9 @@ int nfs4_blk_process_layoutget(struct pnfs_layout_h=
dr *lo,
 void bl_free_block_dev(struct pnfs_block_dev *bdev);
=20
 /* extents.c */
+struct pnfs_block_extent *
+bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
+		struct pnfs_block_extent **cow_read);
 void bl_put_extent(struct pnfs_block_extent *be);
 struct pnfs_block_extent *bl_alloc_extent(void);
 int bl_add_merge_extent(struct pnfs_block_layout *bl,
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.=
c
index ee4891f..8fa93e2 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -193,3 +193,50 @@ bl_add_merge_extent(struct pnfs_block_layout *bl,
 	bl_put_extent(new);
 	return -EIO;
 }
+
+/* Returns extent, or NULL.  If a second READ extent exists, it is ret=
urned
+ * in cow_read, if given.
+ *
+ * The extents are kept in two seperate ordered lists, one for READ an=
d NONE,
+ * one for READWRITE and INVALID.  Within each list, we assume:
+ * 1. Extents are ordered by file offset.
+ * 2. For any given isect, there is at most one extents that matches.
+ */
+struct pnfs_block_extent *
+bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
+	    struct pnfs_block_extent **cow_read)
+{
+	struct pnfs_block_extent *be, *cow, *ret;
+	int i;
+
+	dprintk("%s enter with isect %llu\n", __func__, (u64)isect);
+	cow =3D ret =3D NULL;
+	spin_lock(&bl->bl_ext_lock);
+	for (i =3D 0; i < EXTENT_LISTS; i++) {
+		list_for_each_entry_reverse(be, &bl->bl_extents[i], be_node) {
+			if (isect >=3D be->be_f_offset + be->be_length)
+				break;
+			if (isect >=3D be->be_f_offset) {
+				/* We have found an extent */
+				dprintk("%s Get %p (%i)\n", __func__, be,
+					atomic_read(&be->be_refcnt.refcount));
+				kref_get(&be->be_refcnt);
+				if (!ret)
+					ret =3D be;
+				else if (be->be_state !=3D PNFS_BLOCK_READ_DATA)
+					bl_put_extent(be);
+				else
+					cow =3D be;
+				break;
+			}
+		}
+		if (ret &&
+		    (!cow_read || ret->be_state !=3D PNFS_BLOCK_INVALID_DATA))
+			break;
+	}
+	spin_unlock(&bl->bl_ext_lock);
+	if (cow_read)
+		*cow_read =3D cow;
+	print_bl_extent(ret);
+	return ret;
+}
--=20
1.7.4.1

