Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050579;
	b=OEMcbqAoIiRl+QB9LPmHUn4825WSzPRQLkhUF1XFuS06ri33JWUOsrLrbG5VQaAmT8rN
	 7lBpswLa53sQzhGqk16KOmgNSEqV77a360vLyS7PlzsZN3hOZEEBzW/k/YsKEEeShcuvs
	 05AFrzdCGrWH33SP84Tq+ZCbV823O9SoJcMdZfd+6Skr3FU7YqZPsHufmlMZ1FrPthB/d
	 Z+x8zC/rXhCtP/W7WF/6ehRkqkZZD5w6o3FxTJLRGYDP6bE8rWwGO242u28ydGwN4FZyb
	 moVeY9q/+0sQNSqcWSWmDKVAxFuhv88W35+yT2qB8FVBzImwHH7Ci+hOv7PZbvqt4Rw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050579;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=AsLO49kF1fRk2BnJVavQV41nHfJQ9nnym+Ccwt0QA+4=;
	b=mglFq75psNZnlcTFajMCIC8ZzxWC0CoVKnnI3V0ozG+ypjVUG8+ggyfh6ZjrYsx0NzCc
	 OZGNgjunhr3ptRfzPILs4icbjdDvSNU00WyJc93CHai9vRPcvM2b6A21NApa3AMx77IJL
	 VR/qHr3TVNNM9DSHLJBhjwTK7n9Cz37e5KR0N4CMHSEJUEYHZi2yL6oKU3PAPCfa8/tlB
	 WrNeod9J31lPkxiqek7HRv+e5fiwteacepf/KP6KLbVAws4BXfrUFWKs+FCl1BtgRtAM+
	 kw//2INNPztxgeyf/XfrC1cOSP+yfaJuLjvE0SaCbaU855VESKtynR5JwCj4xA/6Qjw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mx4GpDw4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A9982606A323
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mx4GpDw4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A0C931F01829;
	Mon, 26 Oct 2026 21:36:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050578;
	bh=AsLO49kF1fRk2BnJVavQV41nHfJQ9nnym+Ccwt0QA+4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mx4GpDw4TLqzVJ7JKSbeREJanManrBsqSwUyKu8SIUA1IeOxYYeexzh74WbfoG+uT
	 WC6oCNlSKkfCAqHNjqggpmQMiuIOCJJSMtxzMQXv/hftD2bvtwsxjUL7JyWIIUq2KM
	 l/97u8ZlrwbU+R8Vg+UKBTyslA9D02X4hOiesphtY2xa1UDuo8jwLIEeI8j/4E+Qvf
	 ISAU1Z4sQ2vcClLJrEFQ+40lF0etUNI2CktgB1K+vAivybajfdzg+at3CiJ0a1QKHc
	 yFy1rp+DaAoFI2uLIf4Vdll0VeM0X5fCHJ4yiuAk/MAp2yyKyT0FOn1AQlOjt09q0k
	 ilCweQ5WXd51w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 01/13] Documentation: Add the RPC language description of NFS_ACLv3
Date: Sun, 25 Oct 2026 11:16:10 -0400
Message-ID: <20261025151622.141025-2-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261025151622.141025-1-cel@kernel.org>
References: <20261025151622.141025-1-cel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Converting nfs3acl.c from hand-written XDR codecs to xdrgen-generated
code first requires a machine-readable description of the protocol for
xdrgen to process. Include a copy of the RPC language description of
NFS_ACLv3, taken from the NFS ACL protocol specification.

The description carries no pragmas. Later patches add the header,
aggregate, and endianness pragmas as the generated code that needs
each one is introduced.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs_acl3.x | 268 ++++++++++++++++++++++++++++
 1 file changed, 268 insertions(+)
 create mode 100644 Documentation/sunrpc/xdr/nfs_acl3.x

diff --git a/Documentation/sunrpc/xdr/nfs_acl3.x b/Documentation/sunrpc/xdr/nfs_acl3.x
new file mode 100644
index 000000000000..913ecf3a369f
--- /dev/null
+++ b/Documentation/sunrpc/xdr/nfs_acl3.x
@@ -0,0 +1,268 @@
+/*
+ * Copyright (c) 2024 IETF Trust and the persons
+ * identified as authors of the code.  All rights reserved.
+ *
+ * The authors of the code are:
+ * Oracle
+ *
+ * Redistribution and use in source and binary forms, with
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
+ * - Neither the name of Internet Society, IETF or IETF
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
+ */
+
+const NFS_ACL_MAX_ENTRIES = 1024;
+
+typedef unsigned int uid;
+typedef unsigned short o_mode;
+
+/*
+ * This is the format of an ACL which is passed over the network.
+ */
+struct aclent {
+    int type;
+    uid id;
+    o_mode perm;
+};
+
+/*
+ * The values for the type element of the aclent structure.
+ */
+const NA_USER_OBJ = 0x1;            /* object owner */
+const NA_USER = 0x2;                /* additional users */
+const NA_GROUP_OBJ = 0x4;           /* owning group of the object */
+const NA_GROUP = 0x8;               /* additional groups */
+const NA_CLASS_OBJ = 0x10;          /* file group class and mask entry */
+const NA_OTHER_OBJ = 0x20;          /* other entry for the object */
+const NA_ACL_DEFAULT = 0x1000;      /* default flag */
+
+/*
+ * The bit field values for the perm element of the aclent
+ * structure.  The three values can be combined to form any
+ * of the 8 combinations.
+ */
+const NA_READ = 0x4;                /* read permission */
+const NA_WRITE = 0x2;               /* write permission */
+const NA_EXEC = 0x1;                /* exec permission */
+
+/*
+ * This is the structure which contains the ACL entries for a
+ * particular entity.  It contains the ACL entries which apply
+ * to this object plus any default ACL entries which are
+ * inherited by its children.
+ *
+ * The values for the mask field are defined below.
+ */
+struct secattr {
+    unsigned int mask;
+    int aclcnt;
+    aclent aclent<NFS_ACL_MAX_ENTRIES>;
+    int dfaclcnt;
+    aclent dfaclent<NFS_ACL_MAX_ENTRIES>;
+};
+
+/*
+ * The values for the mask element of the secattr struct as well
+ * as for the mask element in the arguments in the GETACL2 and
+ * GETACL3 procedures.
+ */
+const NA_ACL = 0x1;                 /* aclent contains a valid list */
+const NA_ACLCNT = 0x2;              /* number of entries in the aclent list */
+const NA_DFACL = 0x4;               /* dfaclent contains a valid list */
+const NA_DFACLCNT = 0x8;            /* number of entries in the dfaclent list */
+
+/*
+ * Share the ports with the NFS service.
+ */
+const NFS_ACL_PORT = 2049;
+const NFS_ACL_RDMA_PORT = 20049;
+
+/*
+ * XDR data types inherited from the NFS version 3 protocol
+ */
+
+typedef unsigned hyper uint64;
+typedef unsigned long uint32;
+typedef uint64 fileid3;
+typedef uint32 uid3;
+typedef uint32 gid3;
+typedef uint64 size3;
+typedef uint32 mode3;
+
+enum ftype3 {
+    NF3REG    = 1,
+    NF3DIR    = 2,
+    NF3BLK    = 3,
+    NF3CHR    = 4,
+    NF3LNK    = 5,
+    NF3SOCK   = 6,
+    NF3FIFO   = 7
+};
+
+struct specdata3 {
+    uint32     specdata1;
+    uint32     specdata2;
+};
+
+const NFS3_FHSIZE = 64;
+
+struct nfs_fh3 {
+    opaque       data<NFS3_FHSIZE>;
+};
+
+struct nfstime3 {
+    uint32   seconds;
+    uint32   nseconds;
+};
+
+struct fattr3 {
+    ftype3     type;
+    mode3      mode;
+    uint32     nlink;
+    uid3       uid;
+    gid3       gid;
+    size3      size;
+    size3      used;
+    specdata3  rdev;
+    uint64     fsid;
+    fileid3    fileid;
+    nfstime3   atime;
+    nfstime3   mtime;
+    nfstime3   ctime;
+};
+
+union post_op_attr switch (bool attributes_follow) {
+case TRUE:
+    fattr3   attributes;
+case FALSE:
+    void;
+};
+
+/*
+ * ACL error codes; the numeric values match codes with the same
+ * name used in NFS version 3.
+ */
+enum aclstat3 {
+    ACL3_OK = 0,
+    ACL3ERR_PERM = 1,
+    ACL3ERR_NOENT = 2,
+    ACL3ERR_IO = 5,
+    ACL3ERR_ACCES = 13,
+    ACL3ERR_INVAL = 22,
+    ACL3ERR_NOSPC = 28,
+    ACL3ERR_ROFS = 30,
+    ACL3ERR_DQUOT = 69,
+    ACL3ERR_STALE = 70,
+    ACL3ERR_BADHANDLE = 10001,
+    ACL3ERR_NOTSUPP = 10004,
+    ACL3ERR_SERVERFAULT = 10006,
+    ACL3ERR_JUKEBOX = 10008
+};
+
+/*
+ * NFS_ACL version 3 procedure arguments and results
+ */
+
+struct GETACL3args {
+    nfs_fh3 fh;
+    unsigned int mask;
+};
+
+struct GETACL3resok {
+    post_op_attr attr;
+    secattr acl;
+};
+
+struct GETACL3resfail {
+    post_op_attr attr;
+};
+
+union GETACL3res switch (aclstat3 status) {
+case ACL3_OK:
+    GETACL3resok resok;
+default:
+    GETACL3resfail resfail;
+};
+
+struct SETACL3args {
+    nfs_fh3 fh;
+    secattr acl;
+};
+
+struct SETACL3resok {
+    post_op_attr attr;
+};
+
+struct SETACL3resfail {
+    post_op_attr attr;
+};
+
+union SETACL3res switch (aclstat3 status) {
+case ACL3_OK:
+    SETACL3resok resok;
+default:
+    SETACL3resfail resfail;
+};
+
+/*
+ * This is the definition for the GETXATTRDIR procedure which
+ * applies to NFS Version 3 files.
+ */
+struct GETXATTRDIR3args {
+    nfs_fh3 fh;
+    bool create;
+};
+
+struct GETXATTRDIR3resok {
+    nfs_fh3 fh;
+    post_op_attr attr;
+};
+
+union GETXATTRDIR3res switch (aclstat3 status) {
+case ACL3_OK:
+    GETXATTRDIR3resok resok;
+default:
+    void;
+};
+
+program NFS_ACL_PROGRAM {
+    version NFS_ACL_V3 {
+        void
+            ACLPROC3_NULL(void) = 0;
+        GETACL3res
+            ACLPROC3_GETACL(GETACL3args) = 1;
+        SETACL3res
+            ACLPROC3_SETACL(SETACL3args) = 2;
+        GETXATTRDIR3res
+            ACLPROC3_GETXATTRDIR(GETXATTRDIR3args) = 3;
+    } = 3;
+} = 100227;
-- 
2.56.0

