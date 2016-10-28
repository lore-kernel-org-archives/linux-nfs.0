Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51784 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753955AbcJ1U20 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Oct 2016 16:28:26 -0400
Date: Fri, 28 Oct 2016 16:28:25 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: Re: [PATCH 0/2] NFSv4.2 umask support
Message-ID: <20161028202825.GA12210@fieldses.org>
References: <1477686228-12158-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1477686228-12158-1-git-send-email-bfields@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way, the code is as noted Andreas's work--I just did a minor
update to reflect a protocol change suggested by Trond and already
incorporated in the ietf drafts.

We also have a wireshark patch, below.

--b.

diff --git a/epan/dissectors/packet-nfs.c b/epan/dissectors/packet-nfs.c
index 010db6e96761..bf458d4bccf4 100644
--- a/epan/dissectors/packet-nfs.c
+++ b/epan/dissectors/packet-nfs.c
@@ -420,6 +420,7 @@ static int hf_nfs4_fattr_layout_blksize = -1;
 static int hf_nfs4_fattr_security_label_lfs = -1;
 static int hf_nfs4_fattr_security_label_pi = -1;
 static int hf_nfs4_fattr_security_label_context = -1;
+static int hf_nfs4_fattr_umask_mask = -1;
 static int hf_nfs4_who = -1;
 static int hf_nfs4_server = -1;
 static int hf_nfs4_fslocation = -1;
@@ -6134,6 +6135,8 @@ static const value_string fattr4_names[] = {
 	{	FATTR4_CHANGE_ATTR_TYPE,   "Change_Attr_Type"		},
 #define FATTR4_SECURITY_LABEL      80
 	{	FATTR4_SECURITY_LABEL,     "Security_Label"		},
+#define FATTR4_UMASK               81
+	{	FATTR4_UMASK,              "Umask"			},
 	{	0,	NULL	}
 };
 static value_string_ext fattr4_names_ext = VALUE_STRING_EXT_INIT(fattr4_names);
@@ -6718,6 +6721,14 @@ dissect_nfs4_security_label(tvbuff_t *tvb, proto_tree *tree, int offset)
 	return offset;
 }
 
+static int
+dissect_nfs4_umask(tvbuff_t *tvb, proto_tree *tree, int offset)
+{
+	offset = dissect_nfs4_mode(tvb, offset, tree);
+	offset = dissect_rpc_uint32(tvb, tree, hf_nfs4_fattr_umask_mask, offset);
+	return offset;
+}
+
 #define FATTR4_BITMAP_ONLY 0
 #define FATTR4_DISSECT_VALUES 1
 
@@ -7120,6 +7131,10 @@ dissect_nfs4_fattrs(tvbuff_t *tvb, int offset, packet_info *pinfo, proto_tree *t
 						offset = dissect_nfs4_security_label(tvb, attr_tree, offset);
 						break;
 
+					case FATTR4_UMASK:
+						offset = dissect_nfs4_umask(tvb, attr_tree, offset);
+						break;
+
 					default:
 						break;
 					}
@@ -12510,6 +12525,10 @@ proto_register_nfs(void)
 			"label_format", "nfs.fattr4.security_label.lfs", FT_UINT32, BASE_DEC,
 			NULL, 0, NULL, HFILL }},
 
+		{ &hf_nfs4_fattr_umask, {
+			"umask", "nfs.fattr4.umask", FT_UINT32, BASE_OCT,
+			NULL, 0, NULL, HFILL }},
+
 		{ &hf_nfs4_fattr_security_label_pi, {
 			"policy_id", "nfs.fattr4.security_label.pi", FT_UINT32, BASE_DEC,
 			NULL, 0, NULL, HFILL }},
