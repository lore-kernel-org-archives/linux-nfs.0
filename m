Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38843 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279Ab1EVQuW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 12:50:22 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 09/23] pnfs-obj: pnfs_osd XDR client implementation
Date: Sun, 22 May 2011 19:49:57 +0300
Message-Id: <1306082997-10869-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD93D3E.9010909@panasas.com>
References: <4DD93D3E.9010909@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

* Add the fs/nfs/objlayout/pnfs_osd_xdr_cli.c file, which will
  include the XDR encode/decode implementations for the pNFS
  client objlayout driver.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/Kbuild             |    2 +-
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |  412 +++++++++++++++++++++++++++++++++++
 2 files changed, 413 insertions(+), 1 deletions(-)
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
index 0000000..dd3052c
--- /dev/null
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -0,0 +1,412 @@
+/*
+ *  Object-Based pNFS Layout XDR layer
+ *
+ *  Copyright (C) 2007 Panasas Inc. [year of first publication]
+ *  All rights reserved.
+ *
+ *  Benny Halevy <bhalevy@panasas.com>
+ *  Boaz Harrosh <bharrosh@panasas.com>
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
+ *	struct pnfs_deviceid	oid_device_id;
+ *	u64			oid_partition_id;
+ *	u64			oid_object_id;
+ * }; // xdr size 32 bytes
+ */
+static __be32 *
+_osd_xdr_decode_objid(__be32 *p, struct pnfs_osd_objid *objid)
+{
+	p = xdr_decode_opaque_fixed(p, objid->oid_device_id.data,
+				    sizeof(objid->oid_device_id.data));
+
+	p = xdr_decode_hyper(p, &objid->oid_partition_id);
+	p = xdr_decode_hyper(p, &objid->oid_object_id);
+	return p;
+}
+/*
+ * struct pnfs_osd_opaque_cred {
+ *	u32 cred_len;
+ *	void *cred;
+ * }; // xdr size [variable]
+ * The return pointers are from the xdr buffer
+ */
+static int
+_osd_xdr_decode_opaque_cred(struct pnfs_osd_opaque_cred *opaque_cred,
+			    struct xdr_stream *xdr)
+{
+	__be32 *p = xdr_inline_decode(xdr, 1);
+
+	if (!p)
+		return -EINVAL;
+
+	opaque_cred->cred_len = be32_to_cpu(*p++);
+
+	p = xdr_inline_decode(xdr, opaque_cred->cred_len);
+	if (!p)
+		return -EINVAL;
+
+	opaque_cred->cred = p;
+	return 0;
+}
+
+/*
+ * struct pnfs_osd_object_cred {
+ *	struct pnfs_osd_objid		oc_object_id;
+ *	u32				oc_osd_version;
+ *	u32				oc_cap_key_sec;
+ *	struct pnfs_osd_opaque_cred	oc_cap_key
+ *	struct pnfs_osd_opaque_cred	oc_cap;
+ * }; // xdr size 32 + 4 + 4 + [variable] + [variable]
+ */
+static int
+_osd_xdr_decode_object_cred(struct pnfs_osd_object_cred *comp,
+			    struct xdr_stream *xdr)
+{
+	__be32 *p = xdr_inline_decode(xdr, 32 + 4 + 4);
+	int ret;
+
+	if (!p)
+		return -EIO;
+
+	p = _osd_xdr_decode_objid(p, &comp->oc_object_id);
+	comp->oc_osd_version = be32_to_cpup(p++);
+	comp->oc_cap_key_sec = be32_to_cpup(p);
+
+	ret = _osd_xdr_decode_opaque_cred(&comp->oc_cap_key, xdr);
+	if (unlikely(ret))
+		return ret;
+
+	ret = _osd_xdr_decode_opaque_cred(&comp->oc_cap, xdr);
+	return ret;
+}
+
+/*
+ * struct pnfs_osd_data_map {
+ *	u32	odm_num_comps;
+ *	u64	odm_stripe_unit;
+ *	u32	odm_group_width;
+ *	u32	odm_group_depth;
+ *	u32	odm_mirror_cnt;
+ *	u32	odm_raid_algorithm;
+ * }; // xdr size 4 + 8 + 4 + 4 + 4 + 4
+ */
+static inline int
+_osd_data_map_xdr_sz(void)
+{
+	return 4 + 8 + 4 + 4 + 4 + 4;
+}
+
+static __be32 *
+_osd_xdr_decode_data_map(__be32 *p, struct pnfs_osd_data_map *data_map)
+{
+	data_map->odm_num_comps = be32_to_cpup(p++);
+	p = xdr_decode_hyper(p, &data_map->odm_stripe_unit);
+	data_map->odm_group_width = be32_to_cpup(p++);
+	data_map->odm_group_depth = be32_to_cpup(p++);
+	data_map->odm_mirror_cnt = be32_to_cpup(p++);
+	data_map->odm_raid_algorithm = be32_to_cpup(p++);
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
+
+int pnfs_osd_xdr_decode_layout_map(struct pnfs_osd_layout *layout,
+	struct pnfs_osd_xdr_decode_layout_iter *iter, struct xdr_stream *xdr)
+{
+	__be32 *p;
+
+	memset(iter, 0, sizeof(*iter));
+
+	p = xdr_inline_decode(xdr, _osd_data_map_xdr_sz() + 4 + 4);
+	if (unlikely(!p))
+		return -EINVAL;
+
+	p = _osd_xdr_decode_data_map(p, &layout->olo_map);
+	layout->olo_comps_index = be32_to_cpup(p++);
+	layout->olo_num_comps = be32_to_cpup(p++);
+	iter->total_comps = layout->olo_num_comps;
+	return 0;
+}
+
+bool pnfs_osd_xdr_decode_layout_comp(struct pnfs_osd_object_cred *comp,
+	struct pnfs_osd_xdr_decode_layout_iter *iter, struct xdr_stream *xdr,
+	int *err)
+{
+	BUG_ON(iter->decoded_comps > iter->total_comps);
+	if (iter->decoded_comps == iter->total_comps)
+		return false;
+
+	*err = _osd_xdr_decode_object_cred(comp, xdr);
+	if (unlikely(*err)) {
+		dprintk("%s: _osd_xdr_decode_object_cred=>%d decoded_comps=%d "
+			"total_comps=%d\n", __func__, *err,
+			iter->decoded_comps, iter->total_comps);
+		return false; /* stop the loop */
+	}
+	dprintk("%s: dev(%llx:%llx) par=0x%llx obj=0x%llx "
+		"key_len=%u cap_len=%u\n",
+		__func__,
+		_DEVID_LO(&comp->oc_object_id.oid_device_id),
+		_DEVID_HI(&comp->oc_object_id.oid_device_id),
+		comp->oc_object_id.oid_partition_id,
+		comp->oc_object_id.oid_object_id,
+		comp->oc_cap_key.cred_len, comp->oc_cap.cred_len);
+
+	iter->decoded_comps++;
+	return true;
+}
+
+/*
+ * Get Device Information Decoding
+ *
+ * Note: since Device Information is currently done synchronously, all
+ *       variable strings fields are left inside the rpc buffer and are only
+ *       pointed to by the pnfs_osd_deviceaddr members. So the read buffer
+ *       should not be freed while the returned information is in use.
+ */
+/*
+ *struct nfs4_string {
+ *	unsigned int len;
+ *	char *data;
+ *}; // size [variable]
+ * NOTE: Returned string points to inside the XDR buffer
+ */
+static __be32 *
+__read_u8_opaque(__be32 *p, struct nfs4_string *str)
+{
+	str->len = be32_to_cpup(p++);
+	str->data = (char *)p;
+
+	p += XDR_QUADLEN(str->len);
+	return p;
+}
+
+/*
+ * struct pnfs_osd_targetid {
+ *	u32			oti_type;
+ *	struct nfs4_string	oti_scsi_device_id;
+ * };// size 4 + [variable]
+ */
+static __be32 *
+__read_targetid(__be32 *p, struct pnfs_osd_targetid* targetid)
+{
+	u32 oti_type;
+
+	oti_type = be32_to_cpup(p++);
+	targetid->oti_type = oti_type;
+
+	switch (oti_type) {
+	case OBJ_TARGET_SCSI_NAME:
+	case OBJ_TARGET_SCSI_DEVICE_ID:
+		p = __read_u8_opaque(p, &targetid->oti_scsi_device_id);
+	}
+
+	return p;
+}
+
+/*
+ * struct pnfs_osd_net_addr {
+ *	struct nfs4_string	r_netid;
+ *	struct nfs4_string	r_addr;
+ * };
+ */
+static __be32 *
+__read_net_addr(__be32 *p, struct pnfs_osd_net_addr* netaddr)
+{
+	p = __read_u8_opaque(p, &netaddr->r_netid);
+	p = __read_u8_opaque(p, &netaddr->r_addr);
+
+	return p;
+}
+
+/*
+ * struct pnfs_osd_targetaddr {
+ *	u32				ota_available;
+ *	struct pnfs_osd_net_addr	ota_netaddr;
+ * };
+ */
+static __be32 *
+__read_targetaddr(__be32 *p, struct pnfs_osd_targetaddr *targetaddr)
+{
+	u32 ota_available;
+
+	ota_available = be32_to_cpup(p++);
+	targetaddr->ota_available = ota_available;
+
+	if (ota_available)
+		p = __read_net_addr(p, &targetaddr->ota_netaddr);
+
+
+	return p;
+}
+
+/*
+ * struct pnfs_osd_deviceaddr {
+ *	struct pnfs_osd_targetid	oda_targetid;
+ *	struct pnfs_osd_targetaddr	oda_targetaddr;
+ *	u8				oda_lun[8];
+ *	struct nfs4_string		oda_systemid;
+ *	struct pnfs_osd_object_cred	oda_root_obj_cred;
+ *	struct nfs4_string		oda_osdname;
+ * };
+ */
+
+/* We need this version for the pnfs_osd_xdr_decode_deviceaddr which does
+ * not have an xdr_stream
+ */
+static __be32 *
+__read_opaque_cred(__be32 *p,
+			      struct pnfs_osd_opaque_cred *opaque_cred)
+{
+	opaque_cred->cred_len = be32_to_cpu(*p++);
+	opaque_cred->cred = p;
+	return p + XDR_QUADLEN(opaque_cred->cred_len);
+}
+
+static __be32 *
+__read_object_cred(__be32 *p, struct pnfs_osd_object_cred *comp)
+{
+	p = _osd_xdr_decode_objid(p, &comp->oc_object_id);
+	comp->oc_osd_version = be32_to_cpup(p++);
+	comp->oc_cap_key_sec = be32_to_cpup(p++);
+
+	p = __read_opaque_cred(p, &comp->oc_cap_key);
+	p = __read_opaque_cred(p, &comp->oc_cap);
+	return p;
+}
+
+void pnfs_osd_xdr_decode_deviceaddr(
+	struct pnfs_osd_deviceaddr *deviceaddr, __be32 *p)
+{
+	p = __read_targetid(p, &deviceaddr->oda_targetid);
+
+	p = __read_targetaddr(p, &deviceaddr->oda_targetaddr);
+
+	p = xdr_decode_opaque_fixed(p, deviceaddr->oda_lun,
+				    sizeof(deviceaddr->oda_lun));
+
+	p = __read_u8_opaque(p, &deviceaddr->oda_systemid);
+
+	p = __read_object_cred(p, &deviceaddr->oda_root_obj_cred);
+
+	p = __read_u8_opaque(p, &deviceaddr->oda_osdname);
+
+	/* libosd likes this terminated in dbg. It's last, so no problems */
+	deviceaddr->oda_osdname.data[deviceaddr->oda_osdname.len] = 0;
+}
+
+/*
+ * struct pnfs_osd_layoutupdate {
+ *	u32	dsu_valid;
+ *	s64	dsu_delta;
+ *	u32	olu_ioerr_flag;
+ * }; xdr size 4 + 8 + 4
+ */
+int
+pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
+				 struct pnfs_osd_layoutupdate *lou)
+{
+	__be32 *p = xdr_reserve_space(xdr,  4 + 8 + 4);
+
+	if (!p)
+		return -E2BIG;
+
+	*p++ = cpu_to_be32(lou->dsu_valid);
+	if (lou->dsu_valid)
+		p = xdr_encode_hyper(p, lou->dsu_delta);
+	*p++ = cpu_to_be32(lou->olu_ioerr_flag);
+	return 0;
+}
+
+/*
+ * struct pnfs_osd_objid {
+ *	struct pnfs_deviceid	oid_device_id;
+ *	u64			oid_partition_id;
+ *	u64			oid_object_id;
+ * }; // xdr size 32 bytes
+ */
+static inline __be32 *
+pnfs_osd_xdr_encode_objid(__be32 *p, struct pnfs_osd_objid *object_id)
+{
+	p = xdr_encode_opaque_fixed(p, &object_id->oid_device_id.data,
+				    sizeof(object_id->oid_device_id.data));
+	p = xdr_encode_hyper(p, object_id->oid_partition_id);
+	p = xdr_encode_hyper(p, object_id->oid_object_id);
+
+	return p;
+}
+
+/*
+ * struct pnfs_osd_ioerr {
+ *	struct pnfs_osd_objid	oer_component;
+ *	u64			oer_comp_offset;
+ *	u64			oer_comp_length;
+ *	u32			oer_iswrite;
+ *	u32			oer_errno;
+ * }; // xdr size 32 + 24 bytes
+ */
+void pnfs_osd_xdr_encode_ioerr(__be32 *p, struct pnfs_osd_ioerr *ioerr)
+{
+	p = pnfs_osd_xdr_encode_objid(p, &ioerr->oer_component);
+	p = xdr_encode_hyper(p, ioerr->oer_comp_offset);
+	p = xdr_encode_hyper(p, ioerr->oer_comp_length);
+	*p++ = cpu_to_be32(ioerr->oer_iswrite);
+	*p   = cpu_to_be32(ioerr->oer_errno);
+}
+
+__be32 *pnfs_osd_xdr_ioerr_reserve_space(struct xdr_stream *xdr)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 32 + 24);
+	if (unlikely(!p))
+		dprintk("%s: out of xdr space\n", __func__);
+
+	return p;
+}
-- 
1.7.2.3

