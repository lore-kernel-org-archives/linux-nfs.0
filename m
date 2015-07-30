Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33130 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbbG3MNj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 08:13:39 -0400
Received: by pdbnt7 with SMTP id nt7so23795427pdb.0
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 05:13:39 -0700 (PDT)
Message-ID: <55BA14E2.60407@gmail.com>
Date: Thu, 30 Jul 2015 20:13:22 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        tigran.mkrtchyan@desy.de, kinglongmee@gmail.com
Subject: [PATCH v2] 4.1 xdrdef: Update nfs4.x to the latest dot-x-38.txt
References: <55B76B9B.4090700@gmail.com> <20150729193734.GB21949@fieldses.org> <55BA130C.1050604@gmail.com>
In-Reply-To: <55BA130C.1050604@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are some updates and bugfixes between draft-ietf-nfsv4-minorversion2-dot-x-38.txt
 and draft-ietf-nfsv4-minorversion2-dot-x-30.txt.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.1/xdrdef/README |   2 +-
 nfs4.1/xdrdef/nfs4.x | 108 +++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 92 insertions(+), 18 deletions(-)

diff --git a/nfs4.1/xdrdef/README b/nfs4.1/xdrdef/README
index 2d57ee1..c39fd43 100644
--- a/nfs4.1/xdrdef/README
+++ b/nfs4.1/xdrdef/README
@@ -1,4 +1,4 @@
 # Note nfs4.x was created using:
 
-curl http://www.ietf.org/id/draft-ietf-nfsv4-minorversion2-dot-x-30.txt|grep "^  *///" | sed 's?^  */// ??' | sed 's?^  *///$??' >nfs4.1/xdrdef/nfs4.x
+curl http://www.ietf.org/id/draft-ietf-nfsv4-minorversion2-dot-x-38.txt|grep "^  *///" | sed 's?^  */// ??' | sed 's?^  *///$??' >nfs4.1/xdrdef/nfs4.x
 patch nfs4.1/xdrdef/nfs4.x <nfs4.1/xdrdef/nfs4.x.diff 
diff --git a/nfs4.1/xdrdef/nfs4.x b/nfs4.1/xdrdef/nfs4.x
index 024e0b4..23c6d7c 100644
--- a/nfs4.1/xdrdef/nfs4.x
+++ b/nfs4.1/xdrdef/nfs4.x
@@ -1,8 +1,53 @@
 /*
- * This file was machine generated for
- *  draft-ietf-nfsv4-minorversion2-30
- * Last updated Wed Jan 21 09:59:04 PST 2015
+ * This file was machine generated for [draft-ietf-nfsv4-minorversion2-38].
+ *
+ * Last updated Tue Apr 28 09:46:23 PDT 2015
  */
+
+/*
+ * Copyright (c) 2015 IETF Trust and the persons identified
+ * as the document authors.  All rights reserved.
+ *
+ * The Redistribution and use in source and binary forms, with
+ * or without modification, are permitted provided that the
+ * following conditions are met:
+ *
+ * - Redistributions of source code must retain the above
+ *   copyright notice, this list of conditions and the
+ *   following disclaimer.
+ *
+ * - Redistributions in binary form must reproduce the above
+ *   copyright notice, this list of conditions and the
+ *   following disclaimer in the documentation and/or other
+ *   materials provided with the distribution.
+ *
+ * - Neither the name of Internet Society Society, IETF or IETF
+ *   Trust, nor the names of specific contributors, may be
+ *   used to endorse or promote products derived from this
+ *   software without specific prior written permission.
+ *
+ *   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS
+ *   AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
+ *   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ *   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
+ *   FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
+ *   EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
+ *   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ *   NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
+ *   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
+ *   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
+ *   IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
+ *   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+
+ */
+
+/*
+ * This code was derived from [draft-ietf-nfsv4-minorversion2-dot-x-38].
+ */
+
 /*
  *  Copyright (C) The IETF Trust (2007-2014)
  *  All Rights Reserved.
@@ -667,9 +712,9 @@ typedef uint32_t        fs_charset_cap4;
  */
 
 enum netloc_type4 {
-        NL4_NAME        = 0,
-        NL4_URL         = 1,
-        NL4_NETADDR     = 2
+        NL4_NAME        = 1,
+        NL4_URL         = 2,
+        NL4_NETADDR     = 3
 };
 union netloc4 switch (netloc_type4 nl_type) {
         case NL4_NAME:          utf8str_cis nl_name;
@@ -849,10 +894,11 @@ typedef change_policy4  fattr4_change_policy;
 /*
  * attributes new to NFSv4.2
  */
-typedef uint64_t        fattr_space_freed;
+typedef uint64_t        fattr4_space_freed;
 typedef change_attr_type4
                 fattr4_change_attr_type;
-typedef sec_label4      fattr_sec_label<>;
+typedef sec_label4      fattr4_sec_label<>;
+typedef uint32_t        fattr4_clone_blksize;
 
 %/*
 % * REQUIRED Attributes
@@ -931,10 +977,6 @@ const FATTR4_DIRENT_NOTIF_DELAY = 57;
 const FATTR4_DACL               = 58;
 const FATTR4_SACL               = 59;
 const FATTR4_CHANGE_POLICY      = 60;
-
-%/*
-% * new to NFSV4.2
-% */
 const FATTR4_FS_STATUS          = 61;
 const FATTR4_FS_LAYOUT_TYPES    = 62;
 const FATTR4_LAYOUT_HINT        = 63;
@@ -950,7 +992,11 @@ const FATTR4_RETENTEVT_SET      = 72;
 const FATTR4_RETENTION_HOLD     = 73;
 const FATTR4_MODE_SET_MASKED    = 74;
 const FATTR4_FS_CHARSET_CAP     = 76;
-/* 77 is currently unused */
+
+%/*
+% * new to NFSV4.2
+% */
+const FATTR4_CLONE_BLKSIZE      = 77;
 const FATTR4_SPACE_FREED        = 78;
 const FATTR4_CHANGE_ATTR_TYPE   = 79;
 const FATTR4_SEC_LABEL          = 80;
@@ -1287,6 +1333,7 @@ enum nfs_opnum4 {
  OP_READ_PLUS           = 68,
  OP_SEEK                = 69,
  OP_WRITE_SAME          = 70,
+ OP_CLONE               = 71,
  OP_ILLEGAL             = 10044
 };
 
@@ -1316,6 +1363,19 @@ union ACCESS4res switch (nfsstat4 status) {
         void;
 };
 
+struct CLONE4args {
+        /* SAVED_FH: source file */
+        /* CURRENT_FH: destination file */
+        stateid4        cl_src_stateid;
+        stateid4        cl_dst_stateid;
+        offset4         cl_src_offset;
+        offset4         cl_dst_offset;
+        length4         cl_count;
+};
+
+struct CLONE4res {
+        nfsstat4        cl_status;
+};
 struct CLOSE4args {
         /* CURRENT_FH: object */
         seqid4          seqid;
@@ -2759,13 +2819,24 @@ struct COPY4args {
 };
 
 
-struct COPY4res {
-        nfsstat4        cr_status;
-        write_response4 cr_response;
+struct copy_requirements4 {
         bool            cr_consecutive;
         bool            cr_synchronous;
 };
 
+struct COPY4resok {
+        write_response4         cr_response;
+        copy_requirements4      cr_requirements;
+};
+
+union COPY4res switch (nfsstat4 cr_status) {
+case NFS4_OK:
+        COPY4resok              cr_resok4;
+case NFS4ERR_OFFLOAD_NO_REQS:
+        copy_requirements4      cr_requirements;
+default:
+        void;
+};
 
 struct COPY_NOTIFY4args {
         /* CURRENT_FH: source file */
@@ -2775,6 +2846,7 @@ struct COPY_NOTIFY4args {
 
 struct COPY_NOTIFY4resok {
         nfstime4        cnr_lease_time;
+        stateid4        cnr_stateid;
         netloc4         cnr_source_server<>;
 };
 
@@ -2887,7 +2959,7 @@ struct LAYOUTERROR4res {
 };
 
 struct io_info4 {
-        uint32_t        ii_count;
+        uint64_t        ii_count;
         uint64_t        ii_bytes;
 };
 
@@ -3088,6 +3160,7 @@ union nfs_argop4 switch (nfs_opnum4 argop) {
  case OP_READ_PLUS:     READ_PLUS4args opread_plus;
  case OP_SEEK:          SEEK4args opseek;
  case OP_WRITE_SAME:    WRITE_SAME4args opwrite_same;
+ case OP_CLONE:         CLONE4args opclone;
 
  /* Operations not new to NFSv4.1 */
  case OP_ILLEGAL:       void;
@@ -3216,6 +3289,7 @@ union nfs_resop4 switch (nfs_opnum4 resop) {
  case OP_READ_PLUS:     READ_PLUS4res opread_plus;
  case OP_SEEK:          SEEK4res opseek;
  case OP_WRITE_SAME:    WRITE_SAME4res opwrite_same;
+ case OP_CLONE:         CLONE4res opclone;
 
  /* Operations not new to NFSv4.1 */
  case OP_ILLEGAL:       ILLEGAL4res opillegal;
-- 
2.4.3

