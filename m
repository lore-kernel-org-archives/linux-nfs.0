Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42074 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751626AbdBAWoW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Feb 2017 17:44:22 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs: add support for the umask attribute
Date: Wed,  1 Feb 2017 23:44:19 +0100
Message-Id: <1485989059-28706-1-git-send-email-agruenba@redhat.com>
In-Reply-To: <CAN-5tyER30ZQk9f0j1DDOYAsmk6XDnbay2my68R6gVDp+0paNQ@mail.gmail.com>
References: <CAN-5tyER30ZQk9f0j1DDOYAsmk6XDnbay2my68R6gVDp+0paNQ@mail.gmail.com> <1479933700-5743-1-git-send-email-bfields@redhat.com> <1479933700-5743-2-git-send-email-bfields@redhat.com> <20161201220716.GB1589@fieldses.org> <CAHc6FU721nR8QmcpJsDWtvg9EqzK-krYH7GTGw0Y=s7nSEy-vg@mail.gmail.com> <20161202164705.GB20384@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@fieldses.org>

On Wed, Feb 1, 2017 at 10:31 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Any plans to add wireshark support for this?

We did, yes.  Bruce had posted that together with the very first version.  I
couldn't find the wireshark patch for the current version of the proposal in
the mailing list archive, so here's that.

Andreas

--

NFSv4.2 umask support

---
 epan/dissectors/packet-nfs.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/epan/dissectors/packet-nfs.c b/epan/dissectors/packet-nfs.c
index 6d1dd3b..5f2ce42 100644
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
@@ -6133,6 +6134,8 @@ static const value_string fattr4_names[] = {
 	{	FATTR4_CHANGE_ATTR_TYPE,   "Change_Attr_Type"		},
 #define FATTR4_SECURITY_LABEL      80
 	{	FATTR4_SECURITY_LABEL,     "Security_Label"		},
+#define FATTR4_MODE_UMASK          81
+	{	FATTR4_MODE_UMASK,         "Mode_Umask"			},
 	{	0,	NULL	}
 };
 static value_string_ext fattr4_names_ext = VALUE_STRING_EXT_INIT(fattr4_names);
@@ -6717,6 +6720,14 @@ dissect_nfs4_security_label(tvbuff_t *tvb, proto_tree *tree, int offset)
 	return offset;
 }
 
+static int
+dissect_nfs4_mode_umask(tvbuff_t *tvb, proto_tree *tree, int offset)
+{
+	offset = dissect_nfs4_mode(tvb, offset, tree);
+	offset = dissect_rpc_uint32(tvb, tree, hf_nfs4_fattr_umask_mask, offset);
+	return offset;
+}
+
 #define FATTR4_BITMAP_ONLY 0
 #define FATTR4_DISSECT_VALUES 1
 
@@ -7119,6 +7130,10 @@ dissect_nfs4_fattrs(tvbuff_t *tvb, int offset, packet_info *pinfo, proto_tree *t
 						offset = dissect_nfs4_security_label(tvb, attr_tree, offset);
 						break;
 
+					case FATTR4_MODE_UMASK:
+						offset = dissect_nfs4_mode_umask(tvb, attr_tree, offset);
+						break;
+
 					default:
 						break;
 					}
@@ -12509,6 +12524,10 @@ proto_register_nfs(void)
 			"label_format", "nfs.fattr4.security_label.lfs", FT_UINT32, BASE_DEC,
 			NULL, 0, NULL, HFILL }},
 
+		{ &hf_nfs4_fattr_umask_mask, {
+			"umask", "nfs.fattr4.umask", FT_UINT32, BASE_OCT,
+			NULL, 0, NULL, HFILL }},
+
 		{ &hf_nfs4_fattr_security_label_pi, {
 			"policy_id", "nfs.fattr4.security_label.pi", FT_UINT32, BASE_DEC,
 			NULL, 0, NULL, HFILL }},
-- 
2.7.4
