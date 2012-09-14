Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60924 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932366Ab2INAZj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Sep 2012 20:25:39 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TCJj0-000686-BY
	for linux-nfs@vger.kernel.org; Thu, 13 Sep 2012 20:25:38 -0400
Date: Thu, 13 Sep 2012 20:25:32 -0400
To: linux-nfs@vger.kernel.org
Subject: wireshark status flag parsing
Message-ID: <20120914002532.GB9649@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For what it's worth, I submitted the following to wireshark as I was
annoyed at having to look up the sequence status flags by hand....

--b.

commit af62feaed900e68e7525c431905dcead1566cefb
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Sep 13 18:36:29 2012 -0400

    nfs: remove unused hf_nfs_exch_id_flags4

diff --git a/epan/dissectors/packet-nfs.c b/epan/dissectors/packet-nfs.c
index e73a306..a9e6e0b 100644
--- a/epan/dissectors/packet-nfs.c
+++ b/epan/dissectors/packet-nfs.c
@@ -447,7 +447,6 @@ static int hf_nfs_uid4 = -1;
 static int hf_nfs_gid4 = -1;
 static int hf_nfs_service4 = -1;
 static int hf_nfs_sessionid4 = -1;
-static int hf_nfs_exch_id_flags4 = -1;
 static int hf_nfs_exchid_flags_moved_refer = -1;
 static int hf_nfs_exchid_flags_moved_migr = -1;
 static int hf_nfs_exchid_flags_bind_princ = -1;
@@ -12120,9 +12119,6 @@ proto_register_nfs(void)
 		{ &hf_nfs_sessionid4, {
 			"sessionid", "nfs.session_id4", FT_BYTES, BASE_NONE,
 			NULL, 0, NULL, HFILL }},
-		{ &hf_nfs_exch_id_flags4, {
-			"eia_flags", "nfs.exch_id_flags", FT_UINT32, BASE_HEX,
-			NULL, 0, NULL, HFILL }},
 		{ &hf_nfs_exchid_flags_moved_refer, {
 			"EXCHGID4_FLAG_SUPP_MOVED_REFER", "nfs.exchange_id.flags.moved_refer", FT_BOOLEAN, 32,
 			TFS(&tfs_set_notset), EXCHGID4_FLAG_SUPP_MOVED_REFER, NULL, HFILL}},

commit 20b49645ddf54226def9c1c7dfbb4ebf15260ae2
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Sep 13 18:17:41 2012 -0400

    nfs: parse sequence status flags

diff --git a/epan/dissectors/packet-nfs.c b/epan/dissectors/packet-nfs.c
index 13fc917..e73a306 100644
--- a/epan/dissectors/packet-nfs.c
+++ b/epan/dissectors/packet-nfs.c
@@ -427,7 +427,6 @@ static int hf_nfs_return_on_close4 = -1;
 static int hf_nfs_slotid4 = -1;
 static int hf_nfs_high_slotid4 = -1;
 static int hf_nfs_target_high_slotid4 = -1;
-static int hf_nfs_sr_status4 = -1;
 static int hf_nfs_serverscope4 = -1;
 static int hf_nfs_minorid4 = -1;
 static int hf_nfs_majorid4 = -1;
@@ -484,6 +483,19 @@ static int hf_nfs_bctsa_dir = -1;
 static int hf_nfs_bctsa_use_conn_in_rdma_mode = -1;
 static int hf_nfs_bctsr_dir = -1;
 static int hf_nfs_bctsr_use_conn_in_rdma_mode = -1;
+static int hf_nfs_sequence_status_flags_cb_path_down = -1;
+static int hf_nfs_sequence_status_flags_cb_gss_contexts_expiring = -1;
+static int hf_nfs_sequence_status_flags_cb_gss_contexts_expired = -1;
+static int hf_nfs_sequence_status_flags_expired_all_state_revoked = -1;
+static int hf_nfs_sequence_status_flags_expired_some_state_revoked = -1;
+static int hf_nfs_sequence_status_flags_admin_state_revoked = -1;
+static int hf_nfs_sequence_status_flags_recallable_state_revoked = -1;
+static int hf_nfs_sequence_status_flags_lease_moved = -1;
+static int hf_nfs_sequence_status_flags_restart_reclaim_needed = -1;
+static int hf_nfs_sequence_status_flags_cb_path_down_session = -1;
+static int hf_nfs_sequence_status_flags_backchannel_fault = -1;
+static int hf_nfs_sequence_status_flags_devid_changed = -1;
+static int hf_nfs_sequence_status_flags_devid_deleted = -1;
 
 /* Hidden field for v2, v3, and v4 status */
 int hf_nfs_nfsstat = -1;
@@ -616,6 +628,7 @@ static gint ett_nfs_clientaddr4 = -1;
 static gint ett_nfs_aceflag4 = -1;
 static gint ett_nfs_acemask4 = -1;
 static gint ett_create_session_flags = -1;
+static gint ett_sequence_status_flags = -1;
 
 static gint ett_nfs_layoutget4 = -1;
 static gint ett_nfs_layoutcommit4 = -1;
@@ -9948,14 +9961,46 @@ dissect_nfs_resop4(tvbuff_t *tvb, int offset, packet_info *pinfo,
 			offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_eof, offset);
 			break;
 
-		case NFS4_OP_SEQUENCE:
-			offset = dissect_nfs_sessionid4(tvb, offset, newftree);
-			offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_seqid4, offset);
-			offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_slotid4, offset);
-			offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_high_slotid4, offset);
-			offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_target_high_slotid4, offset);
-			offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_sr_status4,
-										offset);
+		case NFS4_OP_SEQUENCE: {
+#define SEQ4_STATUS_CB_PATH_DOWN                  0x00000001
+#define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING      0x00000002
+#define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED       0x00000004
+#define SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED     0x00000008
+#define SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED    0x00000010
+#define SEQ4_STATUS_ADMIN_STATE_REVOKED           0x00000020
+#define SEQ4_STATUS_RECALLABLE_STATE_REVOKED      0x00000040
+#define SEQ4_STATUS_LEASE_MOVED                   0x00000080
+#define SEQ4_STATUS_RESTART_RECLAIM_NEEDED        0x00000100
+#define SEQ4_STATUS_CB_PATH_DOWN_SESSION          0x00000200
+#define SEQ4_STATUS_BACKCHANNEL_FAULT             0x00000400
+#define SEQ4_STATUS_DEVID_CHANGED                 0x00000800
+#define SEQ4_STATUS_DEVID_DELETED                 0x00001000
+				proto_tree *status_flags_tree = NULL;
+				guint32 status_flags = 0;
+
+				offset = dissect_nfs_sessionid4(tvb, offset, newftree);
+				offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_seqid4, offset);
+				offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_slotid4, offset);
+				offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_high_slotid4, offset);
+				offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_target_high_slotid4, offset);
+				status_flags = tvb_get_ntohl(tvb, offset);
+				fitem = proto_tree_add_text(newftree, tvb, offset, 4, "status flags:0x%08x", status_flags);
+				status_flags_tree = proto_item_add_subtree(fitem, ett_sequence_status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_cb_path_down, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_cb_gss_contexts_expiring, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_cb_gss_contexts_expired, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_expired_all_state_revoked, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_expired_some_state_revoked, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_admin_state_revoked, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_recallable_state_revoked, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_lease_moved, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_restart_reclaim_needed, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_cb_path_down_session, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_backchannel_fault, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_devid_changed, tvb, offset, 1, status_flags);
+				proto_tree_add_boolean(status_flags_tree, hf_nfs_sequence_status_flags_devid_deleted, tvb, offset, 1, status_flags);
+				offset += 4;
+			}
 			break;
 
 		default:
@@ -11900,10 +11945,6 @@ proto_register_nfs(void)
 			"target high slot id", "nfs.target.high.slotid4", FT_UINT32, BASE_DEC,
 			NULL, 0, NULL, HFILL }},
 
-		{ &hf_nfs_sr_status4, {
-			"status", "nfs.status", FT_UINT32, BASE_DEC,
-			NULL, 0, NULL, HFILL }},
-
 		{ &hf_nfs_serverscope4, {
 			"server scope", "nfs.scope", FT_BYTES, BASE_NONE,
 			NULL, 0, NULL, HFILL }},
@@ -12236,6 +12277,46 @@ proto_register_nfs(void)
 			"op_mask", "nfs.op_mask", FT_UINT32, BASE_DEC,
 			VALS(names_nfsv4_operation), 0, "Operation Mask", HFILL }},
 
+		{ &hf_nfs_sequence_status_flags_cb_path_down, {
+			"SEQ4_STATUS_CB_PATH_DOWN", "nfs.sequence.flags.cb_path_down", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_CB_PATH_DOWN, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_cb_gss_contexts_expiring, {
+			"SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING", "nfs.sequence.flags.cb_gss_contexts_expiring", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_cb_gss_contexts_expired, {
+			"SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED", "nfs.sequence.flags.cb_gss_contexts_expired", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_expired_all_state_revoked, {
+			"SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED", "nfs.sequence.flags.expired_all_state_revoked", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_expired_some_state_revoked, {
+			"SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED", "nfs.sequence.flags.expired_some_state_revoked", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_admin_state_revoked, {
+			"SEQ4_STATUS_ADMIN_STATE_REVOKED", "nfs.sequence.flags.admin_state_revoked", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_ADMIN_STATE_REVOKED, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_recallable_state_revoked, {
+			"SEQ4_STATUS_RECALLABLE_STATE_REVOKED", "nfs.sequence.flags.recallable_state_revoked", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_RECALLABLE_STATE_REVOKED, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_lease_moved, {
+			"SEQ4_STATUS_LEASE_MOVED", "nfs.sequence.flags.lease_moved", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_LEASE_MOVED, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_restart_reclaim_needed, {
+			"SEQ4_STATUS_RESTART_RECLAIM_NEEDED", "nfs.sequence.flags.restart_reclaim_needed", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_RESTART_RECLAIM_NEEDED, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_cb_path_down_session, {
+			"SEQ4_STATUS_CB_PATH_DOWN_SESSION", "nfs.sequence.flags.cb_path_down_session", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_CB_PATH_DOWN_SESSION, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_backchannel_fault, {
+			"SEQ4_STATUS_BACKCHANNEL_FAULT", "nfs.sequence.flags.backchannel_fault", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_BACKCHANNEL_FAULT, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_devid_changed, {
+			"SEQ4_STATUS_DEVID_CHANGED", "nfs.sequence.flags.devid_changed", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_DEVID_CHANGED, NULL, HFILL}},
+		{ &hf_nfs_sequence_status_flags_devid_deleted, {
+			"SEQ4_STATUS_DEVID_DELETED", "nfs.sequence.flags.devid_deleted", FT_BOOLEAN, 32,
+			TFS(&tfs_set_notset), SEQ4_STATUS_DEVID_DELETED, NULL, HFILL}},
+
 	/* Hidden field for v2, v3, and v4 status */
 		{ &hf_nfs_nfsstat, {
 			"Status", "nfs.status", FT_UINT32, BASE_DEC,
@@ -12428,6 +12509,7 @@ proto_register_nfs(void)
 		&ett_nfs_cb_illegal,
 		&ett_nfs_chan_attrs,
 		&ett_create_session_flags,
+		&ett_sequence_status_flags,
 	};
 	module_t *nfs_module;
 
