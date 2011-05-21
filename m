Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19767 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab1EUKbv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:31:51 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/13] SQUASHME: pnfs-obj: Change API of objlayout_io_set_result
Date: Sat, 21 May 2011 13:31:40 +0300
Message-Id: <1305973900-17388-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Remove the dependency of objlayout_io_set_result() on the existence of
a pnfs_osd_layout at the generic level, by passing the needed pnfs_osd_objid
in question directly. The io-driver has it at hand more readily. It also
decouples the error to be at the index of the original device and enables
a shorter io_err array with only the error devices.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    5 ++++-
 fs/nfs/objlayout/objlayout.c |    7 +++----
 fs/nfs/objlayout/objlayout.h |    4 ++--
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 1e80f82..f3f7640 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -429,6 +429,7 @@ static int _io_check(struct objio_state *ios, bool is_write)
 	for (i = 0; i <  ios->numdevs; i++) {
 		struct osd_sense_info osi;
 		struct osd_request *or = ios->per_dev[i].or;
+		unsigned dev;
 		int ret;
 
 		if (!or)
@@ -449,7 +450,9 @@ static int _io_check(struct objio_state *ios, bool is_write)
 
 			continue; /* we recovered */
 		}
-		objlayout_io_set_result(&ios->ol_state, ios->per_dev[i].dev,
+		dev = ios->per_dev[i].dev;
+		objlayout_io_set_result(&ios->ol_state, dev,
+					&ios->layout->comps[dev].oc_object_id,
 					osd_pri_2_pnfs_err(osi.osd_err_pri),
 					ios->per_dev[i].offset,
 					ios->per_dev[i].length,
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 1ab9bdc..c80f06c 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -292,15 +292,14 @@ objlayout_iodone(struct objlayout_io_state *state)
  */
 void
 objlayout_io_set_result(struct objlayout_io_state *state, unsigned index,
-			int osd_error, u64 offset, u64 length, bool is_write)
+			struct pnfs_osd_objid *pooid, int osd_error,
+			u64 offset, u64 length, bool is_write)
 {
 	struct pnfs_osd_ioerr *ioerr = &state->ioerrs[index];
 
 	BUG_ON(index >= state->num_comps);
 	if (osd_error) {
-		struct pnfs_osd_layout *layout = &state->objlseg->layout;
-
-		ioerr->oer_component = layout->olo_comps[index].oc_object_id;
+		ioerr->oer_component = *pooid;
 		ioerr->oer_comp_offset = offset;
 		ioerr->oer_comp_length = length;
 		ioerr->oer_iswrite = is_write;
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 6ea54f6..01a3e4f 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -132,8 +132,8 @@ extern ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state,
  * callback API
  */
 extern void objlayout_io_set_result(struct objlayout_io_state *state,
-				    unsigned index, int osd_error,
-				    u64 offset, u64 length, bool is_write);
+			unsigned index, struct pnfs_osd_objid *pooid,
+			int osd_error, u64 offset, u64 length, bool is_write);
 
 static inline void
 objlayout_add_delta_space_used(struct objlayout_io_state *state, s64 space_used)
-- 
1.7.2.3

