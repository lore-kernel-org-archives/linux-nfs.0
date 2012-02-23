Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:49322 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777Ab2BWDOl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Feb 2012 22:14:41 -0500
Received: by yenm8 with SMTP id m8so408959yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 22 Feb 2012 19:14:41 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix dissection of NFSv4.1 OPEN4_DELEGATE_NONE_EXT
Date: Wed, 22 Feb 2012 19:14:34 -0800
Message-Id: <1329966874-9002-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 epan/dissectors/packet-nfs.c |   79 ++++++++++++++++++++++++++++++++++++++++++
 svnversion.h                 |    4 +-
 2 files changed, 81 insertions(+), 2 deletions(-)

diff --git a/epan/dissectors/packet-nfs.c b/epan/dissectors/packet-nfs.c
index 7da7fc2..f7c1a22 100644
--- a/epan/dissectors/packet-nfs.c
+++ b/epan/dissectors/packet-nfs.c
@@ -483,6 +483,9 @@ static int hf_nfs_bctsa_dir = -1;
 static int hf_nfs_bctsa_use_conn_in_rdma_mode = -1;
 static int hf_nfs_bctsr_dir = -1;
 static int hf_nfs_bctsr_use_conn_in_rdma_mode = -1;
+static int hf_nfs_why_no_delegation4 = -1;
+static int hf_nfs_will_push_deleg4 = -1;
+static int hf_nfs_will_signal_avail4 = -1;
 
 /* Hidden field for v2, v3, and v4 status */
 int hf_nfs_nfsstat = -1;
@@ -658,6 +661,7 @@ static gint ett_nfs_fh_ex = -1;
 static gint ett_nfs_layoutseg_fh = -1;
 static gint ett_nfs_reclaim_complete4 = -1;
 static gint ett_nfs_chan_attrs = -1;
+static gint ett_nfs_why_no_delegation4 = -1;
 
 /* what type of fhandles should we dissect as */
 static dissector_table_t nfs_fhandle_table;
@@ -8525,6 +8529,65 @@ dissect_nfs_open_write_delegation4(tvbuff_t *tvb, int offset,
 	return offset;
 }
 
+enum why_no_delegaiton4 {
+	WND4_NOT_WANTED         = 0,
+	WND4_CONTENTION         = 1,
+	WND4_RESOURCE           = 2,
+	WND4_NOT_SUPP_FTYPE     = 3,
+	WND4_WRITE_DELEG_NOT_SUPP_FTYPE = 4,
+	WND4_NOT_SUPP_UPGRADE   = 5,
+	WND4_NOT_SUPP_DOWNGRADE = 6,
+	WND4_CANCELLED          = 7,
+	WND4_IS_DIR             = 8
+};
+
+static const value_string names_why_no_delegation4[] = {
+	{	WND4_NOT_WANTED,	"WND4_NOT_WANTED" },
+	{	WND4_CONTENTION,	"WND4_CONTENTION" },
+	{	WND4_RESOURCE,		"WND4_RESOURCE" },
+	{	WND4_NOT_SUPP_FTYPE,	"WND4_NOT_SUPP_FTYPE" },
+	{	WND4_WRITE_DELEG_NOT_SUPP_FTYPE, "WND4_WRITE_DELEG_NOT_SUPP_FTYPE" },
+	{	WND4_NOT_SUPP_UPGRADE,	"WND4_NOT_SUPP_UPGRADE" },
+	{	WND4_NOT_SUPP_DOWNGRADE,"WND4_NOT_SUPP_DOWNGRADE" },
+	{	WND4_CANCELLED,		"WND4_CANCELLED" },
+	{	WND4_IS_DIR,		"WND4_IS_DIR" },
+	{	0,	NULL }
+};
+
+static int
+dissect_nfs_open_none_delegation4(tvbuff_t *tvb, int offset,
+	proto_tree *tree)
+{
+	proto_item *fitem = NULL;
+	guint why_no_delegation = tvb_get_ntohl(tvb, offset);
+
+	fitem = proto_tree_add_uint(tree, hf_nfs_why_no_delegation4, tvb,
+				    offset, 4, why_no_delegation);
+	offset += 4;
+
+	if (fitem) {
+		switch (why_no_delegation) {
+		case WND4_CONTENTION:
+			offset = dissect_rpc_bool(tvb, tree, hf_nfs_will_push_deleg4, offset);
+			break;
+		case WND4_RESOURCE:
+			offset = dissect_rpc_bool(tvb, tree, hf_nfs_will_signal_avail4, offset);
+			break;
+
+		case WND4_NOT_WANTED:
+		case WND4_NOT_SUPP_FTYPE:
+		case WND4_WRITE_DELEG_NOT_SUPP_FTYPE:
+		case WND4_NOT_SUPP_UPGRADE:
+		case WND4_NOT_SUPP_DOWNGRADE:
+		case WND4_CANCELLED:
+		case WND4_IS_DIR:
+			break;
+		}
+	}
+
+	return offset;
+}
+
 #define OPEN_DELEGATE_NONE 0
 #define OPEN_DELEGATE_READ 1
 #define OPEN_DELEGATE_WRITE 2
@@ -8568,6 +8631,10 @@ dissect_nfs_open_delegation4(tvbuff_t *tvb, int offset, packet_info *pinfo,
 				newftree);
 			break;
 
+		case OPEN_DELEGATE_NONE_EXT:
+			offset = dissect_nfs_open_none_delegation4(tvb, offset, newftree);
+			break;
+
 		default:
 			break;
 		}
@@ -11233,6 +11300,10 @@ proto_register_nfs(void)
 			"Delegation Type", "nfs.open.delegation_type", FT_UINT32, BASE_DEC,
 			VALS(names_open_delegation_type4), 0, NULL, HFILL }},
 
+		{ &hf_nfs_why_no_delegation4, {
+			"Why No Delegation Type", "nfs.open.why_no_delegation", FT_UINT32, BASE_DEC,
+			VALS(names_why_no_delegation4), 0, NULL, HFILL }},
+
 		{ &hf_nfs_ftype4, {
 			"nfs_ftype4", "nfs.nfs_ftype4", FT_UINT32, BASE_DEC,
 			VALS(names_ftype4), 0, NULL, HFILL }},
@@ -12181,6 +12252,13 @@ proto_register_nfs(void)
 		{ &hf_nfs_reclaim_one_fs4, {
 			"reclaim one fs?", "nfs.reclaim_one_fs4", FT_BOOLEAN,
 			BASE_NONE, TFS(&tfs_yes_no), 0x0, NULL, HFILL }},
+		{ &hf_nfs_will_push_deleg4, {
+			"Will push deleg", "nfs.will_push_deleg4", FT_BOOLEAN,
+			BASE_NONE, TFS(&tfs_yes_no), 0x0, NULL, HFILL }},
+		{ &hf_nfs_will_signal_avail4, {
+			"Will signal avail", "nfs.will_signal_avail4", FT_BOOLEAN,
+			BASE_NONE, TFS(&tfs_yes_no), 0x0, NULL, HFILL }},
+
 		{ &hf_nfs_cb_procedure, {
 		   "CB Procedure", "nfs.cb_procedure", FT_UINT32, BASE_DEC,
 			VALS(nfs_cb_proc_vals), 0, NULL, HFILL }},
@@ -12382,6 +12460,7 @@ proto_register_nfs(void)
 		&ett_nfs_pathname4,
 		&ett_nfs_change_info4,
 		&ett_nfs_open_delegation4,
+		&ett_nfs_why_no_delegation4,
 		&ett_nfs_open_claim4,
 		&ett_nfs_opentype4,
 		&ett_nfs_lock_owner4,
diff --git a/svnversion.h b/svnversion.h
index cb1c019..70bc17d 100644
--- a/svnversion.h
+++ b/svnversion.h
@@ -1,2 +1,2 @@
-#define SVNVERSION "SVN Rev 41145"
-#define SVNPATH "/trunk"
+#define SVNVERSION "SVN Rev Unknown"
+#define SVNPATH "unknown"
-- 
1.7.6.5

