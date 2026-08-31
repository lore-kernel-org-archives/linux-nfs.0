Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F8413E49D0
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 11:48:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788176926; cv=none; b=VF3r3p6Q924oVmVyoBn4L3X1QT1Z222xOi0glfrJR4kuFwauAQHAgrlU+gYOrb2pmDwsq59V19Lt1n2vLu1fneWBzo6ydLY30oA+plBRr8XdJ7ChudQyf03WBA68h6tB2OKzn9oOxJkaoukr+R/n5FMfI9oD/o2d4r/bE6CnK/E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788176926; c=relaxed/simple;
	bh=+GRJWseujSBDlSn74VHzR+Ks/qrJJuNPMPYMCsYq/QY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DsOJF+UK6SpewX9dzraWrH8fWEmYLvQVFxfLh+ezQ+z6T/nbyg+gisr0nBGxUKhKWwExuk7bSdk8gKRhNtU9eG7gxG5omdrqXBcYlGCbaPkVxpzmUi2pQoPTZeb+OYiBrzBIxPuyoh7dS1ww/0GU7QTENgD3MCqzvSIS5eteNsM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=itif3GeF; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=Fo5u9ra4; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="itif3GeF";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="Fo5u9ra4"
Received: from pps.filterd (m0170394.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VBA1sv3170239
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 07:48:43 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=MFtHKTujHZ/+
	Of4bsb1lHO37s7LdAmTI5gzeAwwquTQ=; b=itif3GeFf0eG3OzD9pr0gBGGxGxG
	46LBe9acsUbNBD4bvVtT2S5nxvEuoKm7q1twRvdH4wYzoqOYRqAC4Bz82mvQHlHg
	ttKKTw1EXvri//DVuRKckz2aCCTLiEXILHNl8xobJ9p2HhBD5ktut2CrwzXvQ5Xp
	LqbY4QdsPziu+F3QlUcj4sgpU1X7bzyRYm9u2E5TlEIHVZxik454O/bEqLE9ki1k
	0IEKkxVYV5oCqvjHPrtghoz2g36wJC2zrKaQZJY2Uk13BVUirAMm3uLiJAGeFPsA
	OGHCmazlPknhV/Y1rgELhUoP0flwFmL9qdwi+SQblVFugl87tqD/9734oQ==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbt01dqpm-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 07:48:43 -0400 (EDT)
Received: from pps.filterd (m0142699.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VB9oRx3049667
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 07:48:42 -0400
Received: from esapsmtplv01.us.dell.com (esapsmtplv01.us.dell.com [143.166.203.147])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gd7wp8uqk-8
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 07:48:42 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788176922; x=1819712922;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=MFtHKTujHZ/+Of4bsb1lHO37s7LdAmTI5gzeAwwquTQ=;
  b=Fo5u9ra4EqQPIkQ0KpLgCUm9VPWS3LVY2eTwdJ0+/SLV2Zc8CqqNT9nN
   0wdqVPvciGPUujqYxC5UYA3o81mnb6E0tojEmmTggWBeK/mruZrVT1jNq
   ofR2H3Bkx6jUnHhnCFMr+6vAObh13tP8ka2aPaqC/X3N9nEiCQn/i5SrZ
   +W2uOce1QIDudu0CHFzo9PZQv/NNwC6qGD2RfHLarMrpGKy148b8WnPxB
   W6EFvOxOtnN+GHPtoGrJ+E3PD8glaCS0m7/NM9ISk3ZF/JyLW4y3G1GUE
   PBiJD0sUrE6WZDFCWNWl4myxKsO2ZmhfzDG9SnpVqtXYlcx+NGrJnRxqB
   g==;
X-CSE-ConnectionGUID: sR76fHmFQ7e2hEFICm2xeQ==
X-CSE-MsgGUID: jYK+hOfLRrOQVpfKQHp+EA==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 11:48:38 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v2 7/7] NFS: add KUnit coverage for pNFS XDR decoding
Date: Mon, 31 Aug 2026 11:48:18 +0000
Message-ID: <c3eac5239a6555b88e7d4bdb4daaa45c75c4b567.1788173789.git.prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788173789.git.prabhakar.pujeri@dell.com>
References: <cover.1788173789.git.prabhakar.pujeri@dell.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-31_04,2026-08-27_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 adultscore=0 lowpriorityscore=0 impostorscore=0 suspectscore=0
 priorityscore=1501 bulkscore=0 spamscore=0 phishscore=0 malwarescore=0
 clxscore=1015 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608310101
X-Proofpoint-ORIG-GUID: FCT8joNVaL3Q151ZDSD305BmDDPKsdPn
X-Proofpoint-GUID: FCT8joNVaL3Q151ZDSD305BmDDPKsdPn
X-Authority-Analysis: v=2.4 cv=H67rBeYi c=1 sm=1 tr=0 ts=6a956a1b cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=L/h6WUVEnF1aJ0/14Ndw0A==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=gLxAKuEMs0EQMVFiDJnH:22 a=iLNU1ar6AAAA:8
 a=SKN7k2qLuZBHEhaCik0A:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX8RexmiD17vwt
 pCYZB8f4DtH97K6W3zfmAi9rKHUIX/COjUEhhU2mMtUq7v2Di5MyVsMPG/QT9fJoFC2liqdRz+b
 aeNows1tMQk+yp7GXwM8eomKoVb7IDo=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX3BY8sMKUHcTJ
 st+bY8v/Z0JjAVseeXxHly7LoMtAuwIgz8Ggdr49UWcTsUPDc6jHPuI+EILaCrHsNLFBVmquBRy
 iuvzz7CoIAedzbGcbu1Pn9uE3IOFMg+UxhZtdxBmU4qr6oiNwCttMOhOmLyywXH346LdlkimNwX
 e47e0ZdwwMhcBWciTy/p/qBf9VzznDknnQty3xLoyfJZQDbJvpwCQGflX8G9jMZSmVNMN8ToChE
 j1R0TIWeduX3ZUjJvKsLW1Gvdzo48ahiYRiio/lMz+fzhOGORFolV4yguEFHo6jcrLqHmHF8kYC
 dUH7G4nbuVmx1uyGusNUkU0lroVTyJvWM29EbePZ57B6RQDKHR9FbzagciyX+ifyz5XDY0FnmnC
 1CZ9GqxQEsWvsquBKS2AtqTDr363SIuBXlGf+p9ewtqMgT/b3fBqPAELUhDpzOq1SDSyIVvEI53
 DKY3UcAWhY4W+S+XcPw==
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 bulkscore=0
 priorityscore=1501 spamscore=0 clxscore=1015 lowpriorityscore=0
 suspectscore=0 phishscore=0 impostorscore=0 malwarescore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310102

Add page-backed tests for nfs4_decode_mp_ds_addr(). Cover valid IPv4
and IPv6 universal addresses, boundary port values, missing fields,
non-numeric fields, out-of-range values, integer overflow, and trailing
garbage.

Exercise the flexfiles GETDEVICEINFO decoder with valid device data,
cache reuse, and zero or oversized multipath and version counts. Exercise
the LAYOUTGET decoder with an oversized filehandle-version count. The
cache-reuse and malformed-version cases also drive both temporary-address
cleanup paths.

Export the flexfiles decoder helpers only when KUnit is enabled and keep
the suites behind guideline-compliant Kconfig entries that default with
KUNIT_ALL_TESTS.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 fs/nfs/Kconfig                               |  34 +++
 fs/nfs/Makefile                              |   3 +
 fs/nfs/flexfilelayout/Makefile               |   3 +
 fs/nfs/flexfilelayout/flexfilelayout.c       |   4 +-
 fs/nfs/flexfilelayout/flexfilelayout.h       |   6 +
 fs/nfs/flexfilelayout/flexfilelayoutdev.c    |   4 +
 fs/nfs/flexfilelayout/tests/deviceid_kunit.c | 286 +++++++++++++++++++
 fs/nfs/tests/pnfs_decode_kunit.c             | 222 ++++++++++++++
 8 files changed, 561 insertions(+), 1 deletion(-)
 create mode 100644 fs/nfs/flexfilelayout/tests/deviceid_kunit.c
 create mode 100644 fs/nfs/tests/pnfs_decode_kunit.c

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 6bb30543eff0..13b5a80d8f8e 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -215,3 +215,37 @@ config NFS_V4_2_READ_PLUS
 	default y
 	help
 	 Choose Y here to enable use of the NFS v4.2 READ_PLUS operation.
+
+config NFS_PNFS_DECODE_KUNIT_TEST
+	tristate "KUnit tests for pNFS data server address decoding" if !KUNIT_ALL_TESTS
+	depends on NFS_V4 && KUNIT
+	default KUNIT_ALL_TESTS
+	help
+	  This builds KUnit tests for the pNFS data server address decoder.
+	  The tests cover valid IPv4 and IPv6 universal addresses and malformed
+	  port fields supplied by an NFS server. They verify that invalid port
+	  octets cannot produce a usable data server socket address.
+	  Results are reported in TAP format when the test module is loaded on a
+	  KUnit-enabled kernel.
+
+	  For more information on KUnit and unit tests in general, refer to
+	  Documentation/dev-tools/kunit/.
+
+	  If unsure, say N.
+
+config NFS_FLEXFILE_DEVICEID_KUNIT_TEST
+	tristate "KUnit tests for flexfiles XDR decoding" if !KUNIT_ALL_TESTS
+	depends on PNFS_FLEXFILE_LAYOUT && KUNIT
+	default KUNIT_ALL_TESTS
+	help
+	  This builds KUnit tests for the flexfiles GETDEVICEINFO and LAYOUTGET
+	  decoders. The tests cover valid device information, data-server cache
+	  reuse, and malformed address, version, and filehandle counts supplied
+	  by an NFS server.
+	  Results are reported in TAP format when the test module is loaded on a
+	  KUnit-enabled kernel.
+
+	  For more information on KUnit and unit tests in general, refer to
+	  Documentation/dev-tools/kunit/.
+
+	  If unsure, say N.
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index c895521f27f3..e68648f236b0 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -33,6 +33,9 @@ nfsv4-$(CONFIG_SYSCTL)	+= nfs4sysctl.o
 nfsv4-$(CONFIG_NFS_V4_0)	+= nfs40client.o nfs40proc.o
 nfsv4-$(CONFIG_NFS_V4_2)	+= nfs42proc.o nfs42xattr.o
 
+obj-$(CONFIG_NFS_PNFS_DECODE_KUNIT_TEST) += nfs_pnfs_decode_kunit.o
+nfs_pnfs_decode_kunit-y := tests/pnfs_decode_kunit.o
+
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += filelayout/
 obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
 obj-$(CONFIG_PNFS_FLEXFILE_LAYOUT) += flexfilelayout/
diff --git a/fs/nfs/flexfilelayout/Makefile b/fs/nfs/flexfilelayout/Makefile
index 49f03422b6ad..8dcc8fad4106 100644
--- a/fs/nfs/flexfilelayout/Makefile
+++ b/fs/nfs/flexfilelayout/Makefile
@@ -4,3 +4,6 @@
 #
 obj-$(CONFIG_PNFS_FLEXFILE_LAYOUT) += nfs_layout_flexfiles.o
 nfs_layout_flexfiles-y := flexfilelayout.o flexfilelayoutdev.o
+
+obj-$(CONFIG_NFS_FLEXFILE_DEVICEID_KUNIT_TEST) += nfs_flexfile_deviceid_kunit.o
+nfs_flexfile_deviceid_kunit-y := tests/deviceid_kunit.o
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index f94d328b67cd..816eb7f77853 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/file.h>
 #include <linux/sched/mm.h>
+#include <kunit/visibility.h>
 
 #include <linux/sunrpc/metrics.h>
 
@@ -442,7 +443,7 @@ static void ff_layout_sort_mirrors(struct nfs4_ff_layout_segment *fls)
 	}
 }
 
-static struct pnfs_layout_segment *
+VISIBLE_IF_KUNIT struct pnfs_layout_segment *
 ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		     struct nfs4_layoutget_res *lgr,
 		     gfp_t gfp_flags)
@@ -660,6 +661,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 	dprintk("<-- %s (%d)\n", __func__, rc);
 	goto out_free_page;
 }
+EXPORT_SYMBOL_IF_KUNIT(ff_layout_alloc_lseg);
 
 static void
 ff_layout_free_lseg(struct pnfs_layout_segment *lseg)
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index a5bd00f69e82..34cba1ec160b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -228,6 +228,12 @@ nfs4_ff_layout_calc_dss_id(const u64 stripe_unit, const u32 dss_count, const lof
 struct nfs4_ff_layout_ds *
 nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 			    gfp_t gfp_flags);
+#if IS_ENABLED(CONFIG_KUNIT)
+struct pnfs_layout_segment *
+ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
+		     struct nfs4_layoutget_res *lgr,
+		     gfp_t gfp_flags);
+#endif
 void nfs4_ff_layout_put_deviceid(struct nfs4_ff_layout_ds *mirror_ds);
 void nfs4_ff_layout_free_deviceid(struct nfs4_ff_layout_ds *mirror_ds);
 int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 6c104b1e5ff4..81cf8cfa84fd 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -12,6 +12,8 @@
 #include <linux/module.h>
 #include <linux/sunrpc/addr.h>
 
+#include <kunit/visibility.h>
+
 #include "../internal.h"
 #include "../nfs4session.h"
 #include "flexfilelayout.h"
@@ -36,6 +38,7 @@ void nfs4_ff_layout_free_deviceid(struct nfs4_ff_layout_ds *mirror_ds)
 	kfree(mirror_ds->ds_versions);
 	kfree_rcu(mirror_ds, id_node.rcu);
 }
+EXPORT_SYMBOL_IF_KUNIT(nfs4_ff_layout_free_deviceid);
 
 /* Decode opaque device data and construct new_ds using it */
 struct nfs4_ff_layout_ds *
@@ -191,6 +194,7 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 	dprintk("%s ERROR: returning %d\n", __func__, ret);
 	return NULL;
 }
+EXPORT_SYMBOL_IF_KUNIT(nfs4_ff_alloc_deviceid_node);
 
 static void extend_ds_error(struct nfs4_ff_layout_ds_err *err,
 			    u64 offset, u64 length)
diff --git a/fs/nfs/flexfilelayout/tests/deviceid_kunit.c b/fs/nfs/flexfilelayout/tests/deviceid_kunit.c
new file mode 100644
index 000000000000..2b4e08600bf9
--- /dev/null
+++ b/fs/nfs/flexfilelayout/tests/deviceid_kunit.c
@@ -0,0 +1,286 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * KUnit tests for the NFS flexfiles XDR decoders.
+ */
+
+#include <kunit/test.h>
+#include <linux/mm.h>
+#include <net/net_namespace.h>
+
+#include "../flexfilelayout.h"
+
+static void flexfile_deviceid_put_u32(char **p, u32 value)
+{
+	*(__be32 *)*p = cpu_to_be32(value);
+	*p += XDR_UNIT;
+}
+
+static void flexfile_deviceid_put_string(char **p, const char *string)
+{
+	size_t len = strlen(string);
+
+	flexfile_deviceid_put_u32(p, len);
+	memcpy(*p, string, len);
+	*p += xdr_align_size(len);
+}
+
+static void flexfile_deviceid_put_address(char **p)
+{
+	flexfile_deviceid_put_u32(p, 1);
+	flexfile_deviceid_put_string(p, "tcp");
+	flexfile_deviceid_put_string(p, "10.0.0.9.8.1");
+}
+
+static void flexfile_deviceid_put_version(char **p)
+{
+	flexfile_deviceid_put_u32(p, 1);
+	flexfile_deviceid_put_u32(p, 4);
+	flexfile_deviceid_put_u32(p, 2);
+	flexfile_deviceid_put_u32(p, 1048576);
+	flexfile_deviceid_put_u32(p, 1048576);
+	flexfile_deviceid_put_u32(p, 0);
+}
+
+static struct nfs_server *flexfile_deviceid_server(struct kunit *test)
+{
+	struct nfs_server *server;
+	struct nfs_client *client;
+
+	server = kunit_kzalloc(test, sizeof(*server), GFP_KERNEL);
+	if (!server)
+		return NULL;
+	client = kunit_kzalloc(test, sizeof(*client), GFP_KERNEL);
+	if (!client)
+		return NULL;
+
+	client->cl_net = &init_net;
+	client->cl_proto = IPPROTO_TCP;
+	server->nfs_client = client;
+	return server;
+}
+
+static struct pnfs_device *
+flexfile_deviceid_pdev(struct kunit *test, struct page *page, size_t len)
+{
+	struct pnfs_device *pdev;
+
+	pdev = kunit_kzalloc(test, sizeof(*pdev), GFP_KERNEL);
+	if (!pdev)
+		return NULL;
+	pdev->pages = kunit_kzalloc(test, sizeof(*pdev->pages), GFP_KERNEL);
+	if (!pdev->pages)
+		return NULL;
+	pdev->pages[0] = page;
+	pdev->pglen = len;
+	return pdev;
+}
+
+static void flexfile_deviceid_free_page(void *data)
+{
+	__free_page(data);
+}
+
+static struct page *flexfile_deviceid_page(struct kunit *test)
+{
+	struct page *page;
+
+	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+	if (!page)
+		return NULL;
+	if (kunit_add_action_or_reset(test, flexfile_deviceid_free_page,
+				      page))
+		return NULL;
+	return page;
+}
+
+static void flexfile_deviceid_free(void *data)
+{
+	nfs4_ff_layout_free_deviceid(data);
+}
+
+static int
+flexfile_deviceid_track(struct kunit *test, struct nfs4_ff_layout_ds *device)
+{
+	if (!device)
+		return 0;
+	return kunit_add_action_or_reset(test, flexfile_deviceid_free, device);
+}
+
+static void flexfile_deviceid_reject_huge_multipath_count(struct kunit *test)
+{
+	struct nfs4_ff_layout_ds *device;
+	struct nfs_server *server;
+	struct pnfs_device *pdev;
+	struct page *page;
+	char *start, *p;
+
+	server = flexfile_deviceid_server(test);
+	KUNIT_ASSERT_NOT_NULL(test, server);
+	page = flexfile_deviceid_page(test);
+	KUNIT_ASSERT_NOT_NULL(test, page);
+	start = page_address(page);
+	p = start;
+	flexfile_deviceid_put_u32(&p, U32_MAX);
+	pdev = flexfile_deviceid_pdev(test, page, p - start);
+	KUNIT_ASSERT_NOT_NULL(test, pdev);
+
+	device = nfs4_ff_alloc_deviceid_node(server, pdev, GFP_KERNEL);
+	KUNIT_ASSERT_EQ(test, flexfile_deviceid_track(test, device), 0);
+	KUNIT_EXPECT_NULL(test, device);
+}
+
+static void flexfile_deviceid_reject_zero_multipath_count(struct kunit *test)
+{
+	struct nfs4_ff_layout_ds *device;
+	struct nfs_server *server;
+	struct pnfs_device *pdev;
+	struct page *page;
+	char *start, *p;
+
+	server = flexfile_deviceid_server(test);
+	KUNIT_ASSERT_NOT_NULL(test, server);
+	page = flexfile_deviceid_page(test);
+	KUNIT_ASSERT_NOT_NULL(test, page);
+	start = page_address(page);
+	p = start;
+	flexfile_deviceid_put_u32(&p, 0);
+	pdev = flexfile_deviceid_pdev(test, page, p - start);
+	KUNIT_ASSERT_NOT_NULL(test, pdev);
+
+	device = nfs4_ff_alloc_deviceid_node(server, pdev, GFP_KERNEL);
+	KUNIT_ASSERT_EQ(test, flexfile_deviceid_track(test, device), 0);
+	KUNIT_EXPECT_NULL(test, device);
+}
+
+static void flexfile_deviceid_decode_single_address(struct kunit *test)
+{
+	struct nfs4_ff_layout_ds *device;
+	struct nfs_server *server;
+	struct pnfs_device *pdev;
+	struct page *page;
+	char *start, *p;
+
+	server = flexfile_deviceid_server(test);
+	KUNIT_ASSERT_NOT_NULL(test, server);
+	page = flexfile_deviceid_page(test);
+	KUNIT_ASSERT_NOT_NULL(test, page);
+	start = page_address(page);
+	p = start;
+	flexfile_deviceid_put_address(&p);
+	flexfile_deviceid_put_version(&p);
+	pdev = flexfile_deviceid_pdev(test, page, p - start);
+	KUNIT_ASSERT_NOT_NULL(test, pdev);
+
+	device = nfs4_ff_alloc_deviceid_node(server, pdev, GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, device);
+	KUNIT_ASSERT_EQ(test, flexfile_deviceid_track(test, device), 0);
+	KUNIT_EXPECT_EQ(test, device->ds_versions_cnt, (u32)1);
+	KUNIT_EXPECT_EQ(test, device->ds_versions[0].version, (u32)4);
+	KUNIT_EXPECT_EQ(test, device->ds_versions[0].minor_version, (u32)2);
+}
+
+static void flexfile_deviceid_reject_huge_version_count(struct kunit *test)
+{
+	struct nfs4_ff_layout_ds *device;
+	struct nfs_server *server;
+	struct pnfs_device *pdev;
+	struct page *page;
+	char *start, *p;
+
+	server = flexfile_deviceid_server(test);
+	KUNIT_ASSERT_NOT_NULL(test, server);
+	page = flexfile_deviceid_page(test);
+	KUNIT_ASSERT_NOT_NULL(test, page);
+	start = page_address(page);
+	p = start;
+	flexfile_deviceid_put_address(&p);
+	flexfile_deviceid_put_u32(&p, U32_MAX);
+	pdev = flexfile_deviceid_pdev(test, page, p - start);
+	KUNIT_ASSERT_NOT_NULL(test, pdev);
+
+	device = nfs4_ff_alloc_deviceid_node(server, pdev, GFP_KERNEL);
+	KUNIT_ASSERT_EQ(test, flexfile_deviceid_track(test, device), 0);
+	KUNIT_EXPECT_NULL(test, device);
+}
+
+static void flexfile_deviceid_decode_cached_address(struct kunit *test)
+{
+	struct nfs4_ff_layout_ds *first, *second;
+	struct nfs_server *server;
+	struct pnfs_device *pdev;
+	struct page *page;
+	char *start, *p;
+
+	server = flexfile_deviceid_server(test);
+	KUNIT_ASSERT_NOT_NULL(test, server);
+	page = flexfile_deviceid_page(test);
+	KUNIT_ASSERT_NOT_NULL(test, page);
+	start = page_address(page);
+	p = start;
+	flexfile_deviceid_put_address(&p);
+	flexfile_deviceid_put_version(&p);
+	pdev = flexfile_deviceid_pdev(test, page, p - start);
+	KUNIT_ASSERT_NOT_NULL(test, pdev);
+
+	first = nfs4_ff_alloc_deviceid_node(server, pdev, GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, first);
+	KUNIT_ASSERT_EQ(test, flexfile_deviceid_track(test, first), 0);
+	second = nfs4_ff_alloc_deviceid_node(server, pdev, GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, second);
+	KUNIT_ASSERT_EQ(test, flexfile_deviceid_track(test, second), 0);
+	KUNIT_EXPECT_PTR_EQ(test, first->ds, second->ds);
+}
+
+static void flexfile_layout_reject_huge_fh_count(struct kunit *test)
+{
+	struct nfs4_layoutdriver_data layout = {};
+	struct nfs4_layoutget_res lgr = {};
+	struct pnfs_layout_hdr lh = {};
+	struct pnfs_layout_segment *lseg;
+	struct page *pages[1];
+	struct page *page;
+	char *start, *p;
+
+	page = flexfile_deviceid_page(test);
+	KUNIT_ASSERT_NOT_NULL(test, page);
+	pages[0] = page;
+	start = page_address(page);
+	p = start;
+	flexfile_deviceid_put_u32(&p, 0);
+	flexfile_deviceid_put_u32(&p, 0);
+	flexfile_deviceid_put_u32(&p, 1);
+	flexfile_deviceid_put_u32(&p, 1);
+	p += NFS4_DEVICEID4_SIZE;
+	flexfile_deviceid_put_u32(&p, 1);
+	p += NFS4_STATEID_SIZE;
+	flexfile_deviceid_put_u32(&p, U32_MAX);
+
+	layout.pages = pages;
+	layout.len = p - start;
+	lgr.layoutp = &layout;
+	lgr.range.iomode = IOMODE_READ;
+	lseg = ff_layout_alloc_lseg(&lh, &lgr, GFP_KERNEL);
+	KUNIT_ASSERT_TRUE(test, IS_ERR(lseg));
+	KUNIT_EXPECT_EQ(test, PTR_ERR(lseg), -EINVAL);
+}
+
+static struct kunit_case flexfile_deviceid_test_cases[] = {
+	KUNIT_CASE(flexfile_deviceid_reject_huge_multipath_count),
+	KUNIT_CASE(flexfile_deviceid_reject_zero_multipath_count),
+	KUNIT_CASE(flexfile_deviceid_reject_huge_version_count),
+	KUNIT_CASE(flexfile_deviceid_decode_single_address),
+	KUNIT_CASE(flexfile_deviceid_decode_cached_address),
+	KUNIT_CASE(flexfile_layout_reject_huge_fh_count),
+	{}
+};
+
+static struct kunit_suite flexfile_deviceid_test_suite = {
+	.name = "nfs_flexfile_deviceid",
+	.test_cases = flexfile_deviceid_test_cases,
+};
+
+kunit_test_suite(flexfile_deviceid_test_suite);
+
+MODULE_DESCRIPTION("KUnit tests for flexfiles XDR decoding");
+MODULE_LICENSE("GPL");
+MODULE_IMPORT_NS("EXPORTED_FOR_KUNIT_TESTING");
diff --git a/fs/nfs/tests/pnfs_decode_kunit.c b/fs/nfs/tests/pnfs_decode_kunit.c
new file mode 100644
index 000000000000..74ffe14a089c
--- /dev/null
+++ b/fs/nfs/tests/pnfs_decode_kunit.c
@@ -0,0 +1,222 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * KUnit tests for pNFS data server address decoding.
+ */
+
+#include <kunit/test.h>
+#include <linux/mm.h>
+#include <linux/sunrpc/xdr.h>
+#include <net/net_namespace.h>
+
+#include "../pnfs.h"
+
+static struct page *
+pnfs_decode_make_stream(const char *netid, const char *addr,
+			struct xdr_stream *xdr, struct xdr_buf *buf,
+			struct page **pages)
+{
+	size_t netid_len = strlen(netid);
+	size_t addr_len = strlen(addr);
+	struct page *page;
+	char *p;
+	size_t offset = 0;
+
+	if (XDR_UNIT * 2 + xdr_align_size(netid_len) +
+	    xdr_align_size(addr_len) > PAGE_SIZE)
+		return ERR_PTR(-E2BIG);
+
+	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+	if (!page)
+		return ERR_PTR(-ENOMEM);
+	pages[0] = page;
+	p = page_address(page);
+
+	*(__be32 *)(p + offset) = cpu_to_be32(netid_len);
+	offset += XDR_UNIT;
+	memcpy(p + offset, netid, netid_len);
+	offset += xdr_align_size(netid_len);
+	*(__be32 *)(p + offset) = cpu_to_be32(addr_len);
+	offset += XDR_UNIT;
+	memcpy(p + offset, addr, addr_len);
+	offset += xdr_align_size(addr_len);
+
+	xdr_init_decode_pages(xdr, buf, pages, offset);
+	return page;
+}
+
+static void pnfs_decode_free_addr(struct nfs4_pnfs_ds_addr *addr)
+{
+	kfree(addr->da_remotestr);
+	kfree(addr->da_netid);
+	kfree(addr);
+}
+
+static struct nfs4_pnfs_ds_addr *
+pnfs_decode_addr(const char *netid, const char *addr)
+{
+	struct page *pages[1] = { NULL };
+	struct xdr_buf buf = {};
+	struct xdr_stream xdr;
+	struct nfs4_pnfs_ds_addr *decoded;
+	struct page *page;
+
+	page = pnfs_decode_make_stream(netid, addr, &xdr, &buf, pages);
+	if (IS_ERR(page))
+		return ERR_CAST(page);
+
+	decoded = nfs4_decode_mp_ds_addr(&init_net, &xdr, GFP_KERNEL);
+	xdr_finish_decode(&xdr);
+	__free_page(page);
+	return decoded;
+}
+
+static void pnfs_decode_valid_ipv4(struct kunit *test)
+{
+	struct nfs4_pnfs_ds_addr *addr;
+	struct sockaddr_in *sin;
+
+	addr = pnfs_decode_addr("tcp", "10.0.0.4.8.1");
+	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, addr);
+	sin = (struct sockaddr_in *)&addr->da_addr;
+	KUNIT_EXPECT_EQ(test, sin->sin_family, AF_INET);
+	KUNIT_EXPECT_EQ(test, ntohs(sin->sin_port), 2049);
+	KUNIT_EXPECT_EQ(test, be32_to_cpu(sin->sin_addr.s_addr), 0x0a000004);
+	pnfs_decode_free_addr(addr);
+}
+
+static void pnfs_decode_valid_ipv4_max_port(struct kunit *test)
+{
+	struct nfs4_pnfs_ds_addr *addr;
+	struct sockaddr_in *sin;
+
+	addr = pnfs_decode_addr("tcp", "10.0.0.4.255.255");
+	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, addr);
+	sin = (struct sockaddr_in *)&addr->da_addr;
+	KUNIT_EXPECT_EQ(test, ntohs(sin->sin_port), 65535);
+	pnfs_decode_free_addr(addr);
+}
+
+static void pnfs_decode_valid_ipv4_zero_port(struct kunit *test)
+{
+	struct nfs4_pnfs_ds_addr *addr;
+	struct sockaddr_in *sin;
+
+	addr = pnfs_decode_addr("tcp", "10.0.0.4.0.0");
+	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, addr);
+	sin = (struct sockaddr_in *)&addr->da_addr;
+	KUNIT_EXPECT_EQ(test, ntohs(sin->sin_port), 0);
+	pnfs_decode_free_addr(addr);
+}
+
+static void pnfs_decode_valid_ipv6(struct kunit *test)
+{
+	struct nfs4_pnfs_ds_addr *addr;
+	struct sockaddr_in6 *sin6;
+
+	addr = pnfs_decode_addr("tcp6", "2001:db8::5.8.1");
+	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, addr);
+	sin6 = (struct sockaddr_in6 *)&addr->da_addr;
+	KUNIT_EXPECT_EQ(test, sin6->sin6_family, AF_INET6);
+	KUNIT_EXPECT_EQ(test, ntohs(sin6->sin6_port), 2049);
+	pnfs_decode_free_addr(addr);
+}
+
+static void pnfs_decode_expect_invalid(struct kunit *test, const char *addr)
+{
+	struct nfs4_pnfs_ds_addr *decoded = pnfs_decode_addr("tcp", addr);
+
+	KUNIT_ASSERT_FALSE(test, IS_ERR(decoded));
+	KUNIT_EXPECT_NULL(test, decoded);
+	if (decoded)
+		pnfs_decode_free_addr(decoded);
+}
+
+static void pnfs_decode_reject_high_octet_over_255(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "10.0.0.4.300.1");
+}
+
+static void pnfs_decode_reject_low_octet_over_255(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "10.0.0.4.1.300");
+}
+
+static void pnfs_decode_reject_integer_overflow(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "10.0.0.4.999999999999999999999.1");
+}
+
+static void pnfs_decode_reject_empty_low_octet(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "10.0.0.4.8.");
+}
+
+static void pnfs_decode_reject_empty_high_octet(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "10.0.0.4..1");
+}
+
+static void pnfs_decode_reject_negative_octet(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "10.0.0.4.8.-1");
+}
+
+static void pnfs_decode_reject_leading_plus(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "10.0.0.4.+8.1");
+}
+
+static void pnfs_decode_reject_non_numeric_octet(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "10.0.0.4.8.x");
+}
+
+static void pnfs_decode_reject_trailing_garbage(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "10.0.0.4.8.1x");
+}
+
+static void pnfs_decode_reject_trailing_newline(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "10.0.0.4.8.1\n");
+}
+
+static void pnfs_decode_reject_bad_address(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "999.1.1.1.8.1");
+}
+
+static void pnfs_decode_reject_missing_port_octet(struct kunit *test)
+{
+	pnfs_decode_expect_invalid(test, "10.0.0.4.8");
+}
+
+static struct kunit_case pnfs_decode_test_cases[] = {
+	KUNIT_CASE(pnfs_decode_valid_ipv4),
+	KUNIT_CASE(pnfs_decode_valid_ipv4_max_port),
+	KUNIT_CASE(pnfs_decode_valid_ipv4_zero_port),
+	KUNIT_CASE(pnfs_decode_valid_ipv6),
+	KUNIT_CASE(pnfs_decode_reject_high_octet_over_255),
+	KUNIT_CASE(pnfs_decode_reject_low_octet_over_255),
+	KUNIT_CASE(pnfs_decode_reject_integer_overflow),
+	KUNIT_CASE(pnfs_decode_reject_empty_low_octet),
+	KUNIT_CASE(pnfs_decode_reject_empty_high_octet),
+	KUNIT_CASE(pnfs_decode_reject_negative_octet),
+	KUNIT_CASE(pnfs_decode_reject_leading_plus),
+	KUNIT_CASE(pnfs_decode_reject_non_numeric_octet),
+	KUNIT_CASE(pnfs_decode_reject_trailing_garbage),
+	KUNIT_CASE(pnfs_decode_reject_trailing_newline),
+	KUNIT_CASE(pnfs_decode_reject_bad_address),
+	KUNIT_CASE(pnfs_decode_reject_missing_port_octet),
+	{}
+};
+
+static struct kunit_suite pnfs_decode_test_suite = {
+	.name = "nfs_pnfs_decode",
+	.test_cases = pnfs_decode_test_cases,
+};
+
+kunit_test_suite(pnfs_decode_test_suite);
+
+MODULE_DESCRIPTION("KUnit tests for pNFS data server address decoding");
+MODULE_LICENSE("GPL");
-- 
2.54.0

