Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36118 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759038Ab2IMXhr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2012 19:37:47 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 07/10] SQUASHME: pnfsd: Something very wrong with layout_recall(RETURN_FILE)
Date: Fri, 14 Sep 2012 02:37:34 +0300
Message-ID: <1347579454-21650-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <50526B39.3000802@panasas.com>
References: <50526B39.3000802@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In patch:
	pnfsd: layout recall layout state

the cl_has_file_layout() is no longer inspecting the layout structures added per file
but is inspecting if file has layout_state.

So it is counting layout_states and not layouts

This is bad because the addition of the layout_states on the file is done before the
call to the filesystem so if the FS does a recall, the nfsd is confused thinking
it already has a layout and issues a recall. Instead of returning -ENOENT, ie list
is empty. The client then truly returns nomaching_layout and when the lo_return(s) are
emulated the system gets stuck is some reference miss-match. (UML so no crash trace)

Now lets say that the state should be set before the call to the FS. Then I don't
see where the state is removed in the case of an ERROR return from FS->layout_get.
Meaning cl_has_file_layout() will always think it has some count.

Also When a layout is returned it is the layout list that is inspected and freed,
so how is the cl_has_file_layout() emptied ?

In any way. I do not agree that it is the state that is needed to be searched
in cl_has_file_layout() but it is layouts that are needed, otherwise the all
layout <---> recall very delicate dance is totally broken.

What was the meaning of the Poet?

I reverted the cl_has_file_layout() to historical processing.

Also cl_has_file_layout() returns true for any layout on a file, but we must
inspect IO_MODE and LSEG for a partial-match, as well.

The below works for me. State also looks good. I can now safely call
cb_recall, from within a layout_get operation.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c | 29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index e8e7709..523d3d0 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1177,24 +1177,27 @@ out:
 }
 
 static bool
-cl_has_file_layout(struct nfs4_client *clp, struct nfs4_file *fp, stateid_t *lsid)
+cl_has_file_layout(struct nfs4_client *clp, struct nfs4_file *fp,
+		   stateid_t *lsid, struct nfsd4_pnfs_cb_layout *cbl)
 {
-	struct nfs4_layout_state *ls;
+	struct nfs4_layout *lo;
+	bool ret = false;
 
 	spin_lock(&layout_lock);
-	list_for_each_entry (ls, &fp->fi_layout_states, ls_perfile)
-		if (same_clid(&ls->ls_stid.sc_stateid.si_opaque.so_clid,
-			      &clp->cl_clientid)) {
+	list_for_each_entry(lo, &fp->fi_layouts, lo_perfile) {
+		if (same_clid(&lo->lo_client->cl_clientid, &clp->cl_clientid) &&
+		    lo_seg_overlapping(&cbl->cbl_seg, &lo->lo_seg) &&
+		    (cbl->cbl_seg.iomode & lo->lo_seg.iomode))
 			goto found;
-		}
-	spin_unlock(&layout_lock);
-	return false;
-
+	}
+	goto unlock;
 found:
-	update_layout_stateid_locked(ls, lsid);
+	/* Im going to send a recall on this latout update state */
+	update_layout_stateid_locked(lo->lo_state, lsid);
+	ret = true;
+unlock:
 	spin_unlock(&layout_lock);
-
-	return true;
+	return ret;
 }
 
 static int
@@ -1226,7 +1229,7 @@ cl_has_layout(struct nfs4_client *clp, struct nfsd4_pnfs_cb_layout *cbl,
 {
 	switch (cbl->cbl_recall_type) {
 	case RETURN_FILE:
-		return cl_has_file_layout(clp, lrfile, lsid);
+		return cl_has_file_layout(clp, lrfile, lsid, cbl);
 	case RETURN_FSID:
 		return cl_has_fsid_layout(clp, &cbl->cbl_fsid);
 	default:
-- 
1.7.10.2.677.gb6bc67f

