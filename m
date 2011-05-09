Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37975 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556Ab1EIRId (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 13:08:33 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 11/29] pnfs-obj: pnfs_osd XDR client implementation
Date: Mon,  9 May 2011 20:08:26 +0300
Message-Id: <1304960906-4196-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DC81E8C.6040901@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

* Add the fs/nfs/objlayout/pnfs_osd_xdr_cli.c file, which will
  include the XDR encode/decode implementations for the pNFS
  client objlayout driver.

[Some extra debug-prints]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[use NFSDBG_PNFS_LD also in pnfs_osd_xdr_cli.c]
[use __be32]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/Kbuild             |    2 +-
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |  132 +++++++++++++++++++++++++++++++++++
 2 files changed, 133 insertions(+), 1 deletions(-)
 create mode 100644 fs/nfs/objlayout/pnfs_osd_xdr_cli.c

diff --git a/fs/nfs/objlayout/Kbuild b/fs/nfs/objlayout/Kbuild
index 2e5b9a4..7b2a5a2 100644
--- a/fs/nfs/objlayout/Kbuild
+++ b/fs/nfs/objlayout/Kbuild
@@ -1,5 +1,5 @@
 #
 # Makefile for the pNFS Objects Layout Driver kernel module
 #
-objlayoutdriver-y := objio_osd.o
+objlayoutdriver-y := objio_osd.o pnfs_osd_xdr_cli.o
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayoutdriver.o
diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
new file mode 100644
index 0000000..19228f8
--- /dev/null
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -0,0 +1,132 @@
+/*
+ *  Object-Based pNFS Layout XDR layer
+ *
+ *  Copyright (C) 2007 Panasas Inc. [year of first publication]
+ *  All rights reserved.
+ *
+ *  Benny Halevy <bhalevy@panasas.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2
+ *  See the file COPYING included with this distribution for more details.
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the Panasas company nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/pnfs_osd_xdr.h>
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+/*
+ * The following implementation is based on RFC5664
+ */
+
+/*
+ * struct pnfs_osd_objid {
+ * 	struct pnfs_deviceid	oid_device_id;
+ * 	u64			oid_partition_id;
+ * 	u64			oid_object_id;
+ * };
+ */
+static inline __be32 *
+pnfs_osd_xdr_decode_objid(__be32 *p, struct pnfs_osd_objid *objid)
+{
+	COPYMEM(objid->oid_device_id.data, sizeof(objid->oid_device_id.data));
+	READ64(objid->oid_partition_id);
+	READ64(objid->oid_object_id);
+	return p;
+}
+
+static inline __be32 *
+pnfs_osd_xdr_decode_opaque_cred(__be32 *p,
+				struct pnfs_osd_opaque_cred *opaque_cred)
+{
+	READ32(opaque_cred->cred_len);
+	COPYMEM(opaque_cred->cred, opaque_cred->cred_len);
+	return p;
+}
+
+/*
+ * struct pnfs_osd_object_cred {
+ * 	struct pnfs_osd_objid		oc_object_id;
+ * 	u32				oc_osd_version;
+ * 	u32				oc_cap_key_sec;
+ * 	struct pnfs_osd_opaque_cred	oc_cap_key
+ * 	struct pnfs_osd_opaque_cred	oc_cap;
+ * };
+ */
+static inline __be32 *
+pnfs_osd_xdr_decode_object_cred(__be32 *p, struct pnfs_osd_object_cred *comp,
+				u8 **credp)
+{
+	u8 *cred;
+
+	p = pnfs_osd_xdr_decode_objid(p, &comp->oc_object_id);
+	READ32(comp->oc_osd_version);
+	READ32(comp->oc_cap_key_sec);
+
+	cred = *credp;
+	comp->oc_cap_key.cred = cred;
+	p = pnfs_osd_xdr_decode_opaque_cred(p, &comp->oc_cap_key);
+	cred = (u8 *)((u32 *)cred + XDR_QUADLEN(comp->oc_cap_key.cred_len));
+	comp->oc_cap.cred = cred;
+	p = pnfs_osd_xdr_decode_opaque_cred(p, &comp->oc_cap);
+	cred = (u8 *)((u32 *)cred + XDR_QUADLEN(comp->oc_cap.cred_len));
+	*credp = cred;
+
+	return p;
+}
+
+/*
+ * struct pnfs_osd_data_map {
+ * 	u32	odm_num_comps;
+ * 	u64	odm_stripe_unit;
+ * 	u32	odm_group_width;
+ * 	u32	odm_group_depth;
+ * 	u32	odm_mirror_cnt;
+ * 	u32	odm_raid_algorithm;
+ * };
+ */
+static inline u32 *
+pnfs_osd_xdr_decode_data_map(__be32 *p, struct pnfs_osd_data_map *data_map)
+{
+	READ32(data_map->odm_num_comps);
+	READ64(data_map->odm_stripe_unit);
+	READ32(data_map->odm_group_width);
+	READ32(data_map->odm_group_depth);
+	READ32(data_map->odm_mirror_cnt);
+	READ32(data_map->odm_raid_algorithm);
+	dprintk("%s: odm_num_comps=%u odm_stripe_unit=%llu odm_group_width=%u "
+		"odm_group_depth=%u odm_mirror_cnt=%u odm_raid_algorithm=%u\n",
+		__func__,
+		data_map->odm_num_comps,
+		(unsigned long long)data_map->odm_stripe_unit,
+		data_map->odm_group_width,
+		data_map->odm_group_depth,
+		data_map->odm_mirror_cnt,
+		data_map->odm_raid_algorithm);
+	return p;
+}
-- 
1.7.3.4

