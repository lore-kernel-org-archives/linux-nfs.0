Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37062 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753769AbdBAWha (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Feb 2017 17:37:30 -0500
Date: Wed, 1 Feb 2017 17:37:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs: add support for the umask attribute
Message-ID: <20170201223726.GB2014@fieldses.org>
References: <1479933700-5743-1-git-send-email-bfields@redhat.com>
 <1479933700-5743-2-git-send-email-bfields@redhat.com>
 <20161201220716.GB1589@fieldses.org>
 <CAHc6FU721nR8QmcpJsDWtvg9EqzK-krYH7GTGw0Y=s7nSEy-vg@mail.gmail.com>
 <20161202164705.GB20384@parsley.fieldses.org>
 <CAN-5tyER30ZQk9f0j1DDOYAsmk6XDnbay2my68R6gVDp+0paNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyER30ZQk9f0j1DDOYAsmk6XDnbay2my68R6gVDp+0paNQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 01, 2017 at 04:31:25PM -0500, Olga Kornievskaia wrote:
> Any plans to add wireshark support for this?

Digging around, all I can find is this, which is outdated (it's for the
umask not the umask+mode attribute), and never went upstream.

I'll try to get back to this soon.  (But if somebody else can fist,
great.)

--b.

commit ed7c3053a99e
Author: Andreas Gruenbacher <agruenba@redhat.com>
Date:   Thu Jan 14 21:20:38 2016 +0100

    NFS: Add support for the proposed umask attribute
    
    Clients can set the umask attribute when creating files to cause the
    server to apply it always except when inheriting permissions from the
    parent directory.
    
    Change-Id: Id2a23c6839021107fdb32252be4a689b6125222c
    Signed-off-by: J. Bruce Fields <bfields@fieldses.org>

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
