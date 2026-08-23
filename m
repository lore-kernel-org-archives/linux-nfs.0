Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C59F13C455C;
	Sun, 23 Aug 2026 11:43:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787485398; cv=none; b=C0GvEixOOOBXM0JGIRibHqNP6VK1soaJsbrkMPjcDovtrQEehRHLSh9FOujSlBEhiEQzdcV2iiR+QfZlz0nypQI1TPJTJBcyhuZrrtFxZjUeBnhPfjmzJVVz5jrVAy9W4jcSMazKMPgj0Td1arFkb5AK13c3vvWCa5/fewm+sX4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787485398; c=relaxed/simple;
	bh=cCQUX9w09fhPjE7MLK9vvad3+gc/E39C2llUPi9wBAM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=cQvWSyK9jTi5NXBVaTXRopV01u7qhNnsSIjllZvRXgqiQnJFSQopjJ0GfBlAO5cXO/D84wQpCHA+EjmU4RzdkP81WS72h2HG1ILmHLFvURigpfFwLTeKEo399GxpOHZrFwoHljiNXXHifit9++bhpqWyEkUhj+YV/SF91Jbsv+0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=uKYIKlQ4; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=LJwDAEj5; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="uKYIKlQ4";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="LJwDAEj5"
Received: from pps.filterd (m0170392.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NAA05d316949;
	Sun, 23 Aug 2026 07:43:10 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=aICK4n5s0vH8
	bYV2ixkZsbSL8WA6FymnM8H/6KZUiDU=; b=uKYIKlQ4Jje0SpIx4gnzydUDU5tB
	KlR4HvgRpw5ZYl1Z/6Jwt2P5ITnxuvmeRk3I7oRjyaLuGZILyb/0dfKRdDnx/4Ff
	fsk+KGf5e3xQl1BtmauSOw6JWC3ZHSVCidDmGfSuw4zSZWX9joesAkJv56vys5Ni
	lW1x1PA8uemDH45H+hglxkqo0fnnQYIHKlpUrQT074LWr/v6utkkOUvLXOBBFKvW
	x5O2APRJUpL4puePdNE//Tvigf2YvJtOxGlB+K6AEMgKP/B7gd5yUzfBedShjqzC
	V/JERI60kt9XYbksZtkpQ9nCJ8GYrbO8TY7xNi4TD8uXr22m67CXyFDiUQ==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4g76xctjsf-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Sun, 23 Aug 2026 07:43:10 -0400 (EDT)
Received: from pps.filterd (m0142693.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NAA2RU370768;
	Sun, 23 Aug 2026 07:43:09 -0400
Received: from esapsmtpat01.us.dell.com (esapsmtpat01.us.dell.com [143.166.211.146])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4g7wevhp69-3
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Sun, 23 Aug 2026 07:43:09 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787485389; x=1819021389;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=aICK4n5s0vH8bYV2ixkZsbSL8WA6FymnM8H/6KZUiDU=;
  b=LJwDAEj5R6pSbzrlUHkX37I9aBK+H54P8jzSmwjHWHBLNle3IolGO3BT
   pinaslEo4qjYWUY53Uyywtnu2JitBZd9z/pF3ujp3GnfyNgHv+R9eabPw
   FT6omGWBVpthsXHTT+u6mU9z8E8rZmYtkNwFXhEKIMAE0crmPPpuv7cO+
   r+xelWM0V9HoW7iZkWkNDB9EhAgnI39F2pF2dfRxTtLV0B9Gf9khHWeRk
   dqC/oWlfkdQk/70Z/oRqO4xRZ/gSR4CjZY7crTJ18G/xfTZbpD8QH8vGi
   lsYD/EcSUs8tGPf8OxUkWyNnJ3KVnboChDZ66Qfbszjnxt/17or6WDcvA
   g==;
X-CSE-ConnectionGUID: ndpOSnttTIiSa57WNDrYhw==
X-CSE-MsgGUID: 8q9wnI9HSby3Q7JB/ReNyA==
X-LoopCount0: from 10.17.189.166
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from unknown (HELO W-96J1TH4.blr.amer.dell.com) ([10.17.189.166])
  by esapsmtpat01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 23 Aug 2026 11:43:07 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        stable@vger.kernel.org
Subject: [PATCH 2/4] NFS: bound multipath address count in file-layout GETDEVICEINFO
Date: Sun, 23 Aug 2026 11:42:42 +0000
Message-ID: <20260823114244.3883-3-prabhakar.pujeri@dell.com>
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
X-Proofpoint-GUID: SkdzA1sNYm9BK_fvGSuzzEgqy3sIJcR9
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODIzMDEwNiBTYWx0ZWRfX117uuBwXW+Kx
 JBujJxRXfq3GpKL7MI1sz+PJ3vmSsMLv+zR92uj95kjO26x0lFN/TH0hIa0S80kupVZq4fWkT0a
 b/JPEnVe9tvo0nt/VVgCaK1TNeYM/F9QkJPP7O9SfFsZ2Cah+6dtfJt9HVco+rd5f4sbqrK3Lxh
 D7VNaF6sHRbpPGRTaCJSZNrrhcuiX76NHWhWbQEBthP3pVvolu7o2v6BSco3WLXk9A/jML8CAPB
 bR//CZMyCSWxT3PWSL4w4gGB3NvZgB4XyxWLY/I/XjfcpUfS8cBTDalpH2nZ/ms4MvN+mUkGDkj
 h1Dhv9lElUNnPBt8sgTHYpSYYjQYFxPkFM+rVcoFrNJ7ZpUtAKmcNMqmuMaYfjjGvY3ePeMOajH
 J1hboE5yjnA2uBpqncHTMFOTqvk9EPRMidwecg0gfddw9+a21mwe9Hi/m7PBxPb9D3SnQgh0gJ4
 cR+Kqa0yUJkao2cUXyw==
X-Proofpoint-ORIG-GUID: SkdzA1sNYm9BK_fvGSuzzEgqy3sIJcR9
X-Authority-Analysis: v=2.4 cv=A79c+aWG c=1 sm=1 tr=0 ts=6a8adcce cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=MDsIxxkBee3CUfGUG3hQZw==:17
 a=b3DhMmMkJVNBYjixYE3i3TbOsPs=:19 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=m3zZTHMLHbwB7Lmtoed2:22
 a=VwQbUJbxAAAA:8 a=iLNU1ar6AAAA:8 a=joGJ0ms7GCESNpv40vsA:9
 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODIzMDEwNiBTYWx0ZWRfX5lTU97wX5FPS
 lLQl2NAH+bIe0antoH5M1A/ZGADarINUHNsl9MRj4DTrly7HMc+Q51Jjo7WNWXdyEmGf6utkYWX
 LX/kvRRv+rN9CM6b/1E16QnT2I94pZA=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 priorityscore=1501 clxscore=1011 suspectscore=0 lowpriorityscore=0
 malwarescore=0 bulkscore=0 impostorscore=0 phishscore=0 adultscore=0
 spamscore=0 classifier=typeunknown authscore=0 authtc= authcc= route=outbound
 adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608230106

nfs4_fl_alloc_deviceid_node() bounds the number of data-server multipath
lists, but not the number of addresses in each list. The latter count is
supplied by the server and can be as large as U32_MAX.

Once the XDR stream is exhausted, nfs4_decode_mp_ds_addr() returns NULL
without consuming input. The enclosing loop can therefore spin for
billions of iterations in kernel context when decoding a malicious
GETDEVICEINFO response.

A netaddr4 contains at least the two XDR length words for its netid and
universal-address strings. Reject a count when that minimum representation
cannot fit in the remaining XDR stream. This makes the loop bound
proportional to the reply length without imposing an arbitrary protocol
limit.

Keep the existing file-layout multipath-list limit separate because that
limit is tied to the u8 stripe-index representation.

Fixes: 14f9a6076f53 ("NFS: Parse and store all multipath DS addresses")
Cc: stable@vger.kernel.org
Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 fs/nfs/filelayout/filelayoutdev.c | 5 +++++
 fs/nfs/pnfs.h                     | 8 ++++++++
 2 files changed, 13 insertions(+)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index d06d303fdcc3..d44baac25d43 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -159,6 +159,11 @@ nfs4_fl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 			goto out_err_free_deviceid;
 
 		mp_count = be32_to_cpup(p); /* multipath count */
+		if (!nfs4_pnfs_ds_addr_count_valid(&stream, mp_count)) {
+			pr_warn_ratelimited("NFS: %s: multipath address count %u exceeds XDR capacity\n",
+					    __func__, mp_count);
+			goto out_err_drain_dsaddrs;
+		}
 		for (j = 0; j < mp_count; j++) {
 			da = nfs4_decode_mp_ds_addr(net, &stream, gfp_flags);
 			if (da)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index bab81f769636..38df700e6a0c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -33,11 +33,19 @@
 #include <linux/refcount.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/sunrpc/xdr.h>
 #include <linux/workqueue.h>
 
 struct nfs4_exception;
 struct nfs4_opendata;
 
+/* A netaddr4 contains at least the length words of its two XDR strings. */
+static inline bool
+nfs4_pnfs_ds_addr_count_valid(const struct xdr_stream *xdr, u32 count)
+{
+	return count <= xdr_stream_remaining(xdr) / (2 * sizeof(__be32));
+}
+
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
 	NFS_LSEG_ROC,		/* roc bit received from server */
-- 
2.54.0

