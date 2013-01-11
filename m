Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:22390 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753570Ab3AKJnt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jan 2013 04:43:49 -0500
Message-ID: <50EFDEEA.4040201@cn.fujitsu.com>
Date: Fri, 11 Jan 2013 17:44:10 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        wireshark-dev@wireshark.org
Subject: [PATCH] wireshark: can't decode callback if didn't caught CREATE_SESSION
 and SETCLIENTID packets before
Content-Type: multipart/mixed;
 boundary="------------060006050406040401020606"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--------------060006050406040401020606
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP

now i found that nfs kernel use 0x40000000 as callback program number.
the CREATE_SESSION and SETCLIENTID use 0x40000000 as callback program number,
and they didn't change it.

but i found that i use wireshark to decode nfsv4 callback procedures, it didn't
decode them if the wireshark or tcpdump didn't caught CREATE_SESSION and SETCLIENTID
packets before.

Signed-off-by: Fan Chaoting <fanchaoting@cn.fujitsu.com>

---
 epan/dissectors/packet-nfs.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/epan/dissectors/packet-nfs.c b/epan/dissectors/packet-nfs.c
index 63d1019..7b5ec88 100644
--- a/epan/dissectors/packet-nfs.c
+++ b/epan/dissectors/packet-nfs.c
@@ -7979,10 +7979,7 @@ dissect_nfs_cb_client4(tvbuff_t *tvb, int offset, proto_tree *tree)
 {
 	proto_tree *cb_location = NULL;
 	proto_item *fitem = NULL;
-	int cbprog;
 
-	cbprog = tvb_get_ntohl(tvb, offset);
-	reg_callback(cbprog);
 	offset = dissect_rpc_uint32(tvb, tree, hf_nfs_cb_program, offset);
 	fitem = proto_tree_add_text(tree, tvb, offset, 0, "cb_location");
 
@@ -8991,7 +8988,6 @@ dissect_nfs_argop4(tvbuff_t *tvb, int offset, packet_info *pinfo,
 	proto_tree *ftree = NULL;
 	proto_tree *newftree = NULL;
 	guint32 string_length;
-	int cbprog;
 	const char *name = NULL, *source_name = NULL, *dest_name=NULL;
 	const char *opname=NULL;
 	guint32 last_fh_hash=0;
@@ -9012,6 +9008,10 @@ dissect_nfs_argop4(tvbuff_t *tvb, int offset, packet_info *pinfo,
 		"Operations (count: %u)", ops);
 	offset += 4;
 
+	 /*Now the nfs use '0x40000000' as callback's program number.*/
+#define CB_PROG 0x40000000
+	reg_callback(CB_PROG);
+
 #define MAX_NFSV4_OPS 128
 
 	if (ops > MAX_NFSV4_OPS) {
@@ -9469,8 +9469,6 @@ dissect_nfs_argop4(tvbuff_t *tvb, int offset, packet_info *pinfo,
 			offset = dissect_nfs_create_session_flags(tvb, offset, newftree, hf_nfs_create_session_flags_csa);
 			offset = dissect_rpc_chanattrs4(tvb, offset, newftree, "csa_fore_chan_attrs");
 			offset = dissect_rpc_chanattrs4(tvb, offset, newftree, "csa_back_chan_attrs");
-			cbprog = tvb_get_ntohl(tvb, offset);
-			reg_callback(cbprog);
 			offset = dissect_rpc_uint32(tvb, newftree, hf_nfs_cb_program, offset);
 			offset = dissect_rpc_secparms4(tvb, offset, newftree);
 			break;
-- 
1.7.10.1

--------------060006050406040401020606
Content-Type: application/octet-stream;
 name="callback.pcap"
Content-Disposition: attachment;
 filename="callback.pcap"
Content-Transfer-Encoding: base64

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


--------------060006050406040401020606--

