Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A01E3C5855
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 11:43:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787485403; cv=none; b=SoaPEaLXEH7SeOrPwlJvvlfEW+0RcB6x1rTUnl6ZwXEjtpjCwiPODlYQBA+vtghZdK/HCsdmFyDeNX64c+lQLvTc4AIpeSO6fChM2B4QxZ6tchbWMQduSSPzeokO/hzJIgewBmTkqPSQpX+XiqZXLFej3/ltRUaydfdbePyxHM0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787485403; c=relaxed/simple;
	bh=419Ql29I1MYVvxGw59U+dEm3J23DC1BXonNN8WM00lM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rewgveMbrXMCOAPk8juaAnECE/uBFj/PxHaTp+rAtcgnQotPj6x1Ouv+KvY8mAmVXe+u0VPbJkaPpB1fn4r4oVtBKbk3KkciEPAMfr6n+zwFAs+MZmj/+VGFk20B7vQWUXIz6GIMefEgd5KmjHblYsV80xmkma3hMWvgB5kCnYQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=QXtuO0hf; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=UwQs+z00; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="QXtuO0hf";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="UwQs+z00"
Received: from pps.filterd (m0170397.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NA9rEL371614
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:43:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=n1JAKjS37efm
	NulGd8lLGbe+x2cd1f2Swo5XhcFyMxU=; b=QXtuO0hfskhrIcqmJUzMaE68j9Xf
	XR0gwFOpkNA62/gOOg0C13RONuAt+syqi0LbVNmOiCRzlj3ziKIXcq2vY7nBlmgn
	Usv+mCmnYd4N6XDjfJMTl9kAPoiZTbhgAZEb22uu6uaVIw3iF6jQMi2PZFGjRrfd
	TwmBn/Gil2IoTg5BDZLM78sgXkuZ746lcsoGNv4QQxfGjLX/No8nCTAkABR4pwq2
	if9oaGjQzsjiBn584f7CpiZ+hBmXHHRdawvudKWWGDX4F2FcMIDvtdakQFV59fTO
	YOk5JjGUHdec9e0OYVlV71wLN/iIsEHGygJ6k69qXYMFCQsRH7Zur3sM8A==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4g74upaujp-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:43:20 -0400 (EDT)
Received: from pps.filterd (m0142693.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NAA2RW370768
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:43:19 -0400
Received: from esapsmtpat01.us.dell.com (esapsmtpat01.us.dell.com [143.166.211.146])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4g7wevhp69-5
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:43:18 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787485399; x=1819021399;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=n1JAKjS37efmNulGd8lLGbe+x2cd1f2Swo5XhcFyMxU=;
  b=UwQs+z009yd/U0/9EuLsBSlN2Wm8YctzrFXS0++Hv/5B5K4orYmvv0p+
   Vdj3O4QTq9vrDObiexMGTnPe9dsbs5uqdf8DG/KHBPzvgKlZJ6aDumw8Z
   hHKNjypiWFrZHVRwQwLtpq0rTUCXnDqIodJq3HzQ2i/pt7IrE95fTSkL7
   eHznlB9IxV50lscBeIN9NISFSab6NtlMFW6Tu0fmfdbM0ONUzVHAe2YqX
   U/XHLhyshDiMo1HaOzfC27vsuFbTLxcLX8zdioYnDJt/hhCDHA4uVDvGj
   SKTQvYhzjhjJSlrtdMGT4KKhEN6BEM4rnIqq1NIOqjMlTLPvBo7cchnno
   A==;
X-CSE-ConnectionGUID: XG7LRGcMQA6uaOj2t1TiNQ==
X-CSE-MsgGUID: zS8sUHs1SECEtRuCfkqr/g==
X-LoopCount0: from 10.17.189.166
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from unknown (HELO W-96J1TH4.blr.amer.dell.com) ([10.17.189.166])
  by esapsmtpat01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 23 Aug 2026 11:43:16 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH 4/4] NFS: add KUnit coverage for pNFS address decoding
Date: Sun, 23 Aug 2026 11:42:44 +0000
Message-ID: <20260823114244.3883-5-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260823114244.3883-1-prabhakar.pujeri@dell.com>
References: <20260823114244.3883-1-prabhakar.pujeri@dell.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-23_04,2026-08-21_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 impostorscore=0 adultscore=0 clxscore=1015 lowpriorityscore=0 bulkscore=0
 priorityscore=1501 malwarescore=0 suspectscore=0 spamscore=0 phishscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608230106
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODIzMDEwNiBTYWx0ZWRfX0nbxWIZdTWsz
 Sa8MhBEEUkEmFDnoT4W1kQ56uAfI0wsASRW7GR3TE0u3J/0uP5OvAy/kq+aehanJTfUOH3U9F4u
 cdQaqvNK3SFumcAjxgaMPp9kXC6X0+kOFhsL49vRQOgy+bzln6SKWx59doJEPsX0ZtgWQ9x1vJq
 2uWrmNJm2mmwHshZZybl+CCceG6en5+7TjcWHGvA966nklxxgH6ZuRiRwP15Ni7+Qq97Zvgbb1t
 VaxKUawV6iMWjyl1f74YZwXK0mML59emlmuqSKUampQxZKB0DqGffILRtqsUtR8VEP4ZzBZuhV2
 kfWb157JJfTR4rK65Hl9FS7OT3s617gPVfPzsaKl7gB1m2OYH978KWlyQ1/mkWbnA2V11MZYU1j
 F0z9MWI6yrB48ee5wnSiJx31QIUusfB4d9tl80lipwjckniQv61bsAwuXx8XLM83HswYjN06Hfk
 ctEueYK2oSnwRUnxMhg==
X-Proofpoint-GUID: CB-uhDg91s9LCLZD-w9jPvOFNfrD-8wU
X-Proofpoint-ORIG-GUID: CB-uhDg91s9LCLZD-w9jPvOFNfrD-8wU
X-Authority-Analysis: v=2.4 cv=dtDrzVg4 c=1 sm=1 tr=0 ts=6a8adcd8 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=MDsIxxkBee3CUfGUG3hQZw==:17
 a=b3DhMmMkJVNBYjixYE3i3TbOsPs=:19 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=U3ti1ie9CgboSd2qXsAw:22
 a=iLNU1ar6AAAA:8 a=PkEcph5BUpEDHqEPUdIA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODIzMDEwNiBTYWx0ZWRfX98aCc9qZ5ISW
 GwJi4zchxzLWAnIi3LtKs/lfMtpzYoA64kA6PA+k6jHwivAiFilU1+XdifxjDHx7I/38CZYGM9F
 hOrfEYePJ5xDdvjQXZtcmlbuyv5FOBc=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 lowpriorityscore=0 priorityscore=1501 bulkscore=0 clxscore=1015 adultscore=0
 spamscore=0 malwarescore=0 suspectscore=0 impostorscore=0 phishscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608230106

Add page-backed XDR tests for nfs4_decode_mp_ds_addr(). Cover valid IPv4
and IPv6 universal addresses, boundary port values, missing fields,
non-numeric fields, out-of-range values, integer overflow, and trailing
garbage.

Add a separate flexfiles GETDEVICEINFO test module that exercises a valid
single-address payload and verifies that zero and U32_MAX multipath
counts are rejected. Export the two flexfiles decoder helpers only when
KUnit is enabled.

Keep both suites behind guideline-compliant Kconfig entries that default
with KUNIT_ALL_TESTS and can be built as modules. Manage the flexfiles
fixtures and decoded devices as KUnit resources so assertion failures do
not leak them.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 fs/nfs/Kconfig                               |  34 +++
 fs/nfs/Makefile                              |   3 +
 fs/nfs/flexfilelayout/Makefile               |   3 +
 fs/nfs/flexfilelayout/flexfilelayoutdev.c    |   4 +
 fs/nfs/flexfilelayout/tests/deviceid_kunit.c | 188 ++++++++++++++++
 fs/nfs/tests/pnfs_decode_kunit.c             | 222 +++++++++++++++++++
 6 files changed, 454 insertions(+)
 create mode 100644 fs/nfs/flexfilelayout/tests/deviceid_kunit.c
 create mode 100644 fs/nfs/tests/pnfs_decode_kunit.c

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 6bb30543eff0..0d7a01f7e10b 100644
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
+	tristate "KUnit tests for flexfiles GETDEVICEINFO decoding" if !KUNIT_ALL_TESTS
+	depends on PNFS_FLEXFILE_LAYOUT && KUNIT
+	default KUNIT_ALL_TESTS
+	help
+	  This builds KUnit tests for the flexfiles GETDEVICEINFO decoder.
+	  The tests cover valid device information and malformed multipath
+	  address counts supplied by an NFS server. They verify that oversized
+	  counts are rejected before entering the address decode loop.
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
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 181a5854fa37..1979a8017ad3 100644
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
@@ -193,6 +196,7 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 	dprintk("%s ERROR: returning %d\n", __func__, ret);
 	return NULL;
 }
+EXPORT_SYMBOL_IF_KUNIT(nfs4_ff_alloc_deviceid_node);
 
 static void extend_ds_error(struct nfs4_ff_layout_ds_err *err,
 			    u64 offset, u64 length)
diff --git a/fs/nfs/flexfilelayout/tests/deviceid_kunit.c b/fs/nfs/flexfilelayout/tests/deviceid_kunit.c
new file mode 100644
index 000000000000..d45fb80fd179
--- /dev/null
+++ b/fs/nfs/flexfilelayout/tests/deviceid_kunit.c
@@ -0,0 +1,188 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * KUnit tests for the NFS flexfiles GETDEVICEINFO decoder.
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
+	flexfile_deviceid_put_u32(&p, 1);
+	flexfile_deviceid_put_string(&p, "tcp");
+	flexfile_deviceid_put_string(&p, "10.0.0.9.8.1");
+	flexfile_deviceid_put_u32(&p, 1);
+	flexfile_deviceid_put_u32(&p, 4);
+	flexfile_deviceid_put_u32(&p, 2);
+	flexfile_deviceid_put_u32(&p, 1048576);
+	flexfile_deviceid_put_u32(&p, 1048576);
+	flexfile_deviceid_put_u32(&p, 0);
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
+static struct kunit_case flexfile_deviceid_test_cases[] = {
+	KUNIT_CASE(flexfile_deviceid_reject_huge_multipath_count),
+	KUNIT_CASE(flexfile_deviceid_reject_zero_multipath_count),
+	KUNIT_CASE(flexfile_deviceid_decode_single_address),
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
+MODULE_DESCRIPTION("KUnit tests for flexfiles GETDEVICEINFO decoding");
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

