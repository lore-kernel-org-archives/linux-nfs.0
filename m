Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81E893E1738;
	Mon, 31 Aug 2026 11:48:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788176918; cv=none; b=j88tcxugmOAAVKh5f9BnROrluEYzQ6aYl8RY1jMqwwRAyBYAwJn+DEoG+De2fHCtfwYcK+ZS0mKByFIyLyjigKQPw6qwJ0ZtF8ZZPYKpMtj8iMs1JYkqJsMnOJejaloaVDVLqbn1n3FFPE7pFvvug8LBmXGL1DqLhw2hVz2ybQY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788176918; c=relaxed/simple;
	bh=XdU2uFQocdR6v5+g0mArGECSXudUKGXIktpeDIYq5a4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tWZTZVqgB8cMiA+fw6mjNBULkaRMkwES0qoBtSsx6QavUfCZ/zwNReZ4N5Rae9/AvP3/ZjNwWf0thaKOQBeaF7CrkzmG3qlj7vjF5u7q9tmxbJg6THboVdqeKYx+quTetyHwasO/51150rBtTXhc5EPhWelSNQUYST26/DtjEDo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=s9XAYWRL; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=JTtnj6DK; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="s9XAYWRL";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="JTtnj6DK"
Received: from pps.filterd (m0170390.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VBA2ii1455120;
	Mon, 31 Aug 2026 07:48:36 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=N5dCSOKyaIw0
	e44AcC3OiqA6t8mL83l0ZzKnys0BBlE=; b=s9XAYWRLyj0zCCWruhp+/9LlCDFN
	tDgOAI36NLgZeVrMGMZONxAEK0lhFnfE6HPdpxOiBSpMIHkr4kZ0l+YVGufMeHJN
	Fsey0bssGmcF2FM34utaEusEUQiuiSUrxvCSm5sZFZOF9axAPBB8PEP76tDIThhu
	3w+tjVlgzFvQDD3UiM8eBDvATvzqOg6XB+3MOlRMwt1x97Oljxu52NEj5wqzWJR2
	1mEbnwBxNlbSE72/R0cVvbYA8RsgcTmfSVb17nKIjBD9+p0B3MVfX/6NTxmZaCm8
	mtwGLyrh1k6zz5g4rJQJDgesy+TaJXbuykW9TiWEHLNEJ02l8o5LyNs3JA==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4gbtfwdp51-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 31 Aug 2026 07:48:36 -0400 (EDT)
Received: from pps.filterd (m0142699.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VB9oRu3049667;
	Mon, 31 Aug 2026 07:48:36 -0400
Received: from esapsmtplv01.us.dell.com (esapsmtplv01.us.dell.com [143.166.203.147])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gd7wp8uqk-6
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Mon, 31 Aug 2026 07:48:35 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788176916; x=1819712916;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=N5dCSOKyaIw0e44AcC3OiqA6t8mL83l0ZzKnys0BBlE=;
  b=JTtnj6DKQQSr7ENu11yGHQZVYRJPPHxSFdoOzIf9j5fMIXdh1gkVFPTD
   7/Qztl60wxiqsa/kAHhbC7hkNa6qko5Ubmb4Xoi6aAQBaOZDwo5mGItta
   QYkc3ialGWu30J8+eUXEa9pHWUGT39nxy7n+MsVtitSA12iFFoUIx3jU9
   p0r1JPxjJsoh0hb4MLv/LhpcqA7tO5vk9VcdLcrWvTk5IBmfcJZKhOS09
   IIP8pMqNI3dG46AeTBuyCFcOBHui9SVhpa/WZclVp45RjoIBUpU2JfiQV
   d6OMImaT1wmJA0OIZyjlYOharng+ydL+gU0QhNMzdp3tIPZQWs6ODrpSi
   A==;
X-CSE-ConnectionGUID: oFDJBqcNQTW0oVIP2FaShw==
X-CSE-MsgGUID: j64EooYKRCK084Bu02A8qA==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 11:48:34 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        stable@vger.kernel.org
Subject: [PATCH v2 5/7] NFS: bound multipath address count in file-layout GETDEVICEINFO
Date: Mon, 31 Aug 2026 11:48:16 +0000
Message-ID: <ffec82e3540ae23d46486ef9c7f50ea05d4b49db.1788173789.git.prabhakar.pujeri@dell.com>
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
X-Authority-Analysis: v=2.4 cv=BdToFLt2 c=1 sm=1 tr=0 ts=6a956a14 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=L/h6WUVEnF1aJ0/14Ndw0A==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=sEWawkeXllE7TocFc0N_:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=joGJ0ms7GCESNpv40vsA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX3UGGqMPH+nCw
 JnTSPvPnw4RDCO7cM2d/BBUBQ+ldJtTi3tMAx9ZhKwwwKNLZBENX8pQ5AjGeKCc0KrnnZTSRvZt
 qLYOBkcptFL7a54NeN/JF7+eFkeq3Kx01lM2hjopAf4f+jtACgYgbnpr5zKYAFGPY6wgd0eOnu3
 LWR+et/TNYLFlwvIwItpc74VGP4QrnNde5CPkcqrqmHbgDRfKEMSpMiHnbceaACG15w8u7nmg7V
 p8gnxiI/0aqN6NYC8VSyuFiM4MmkONTczCuojHVjwrNhTwZncBjg4tgnYK9lWF99m/A/07767pU
 2+GR5hvSY4iuKiNZiZub6dKHBdtq+fs8QokRQsDCMxY8hSae1T5aAPdBZUazf23vNba0pkEL68d
 OnxJu6M9LvBA/TTU7am3ldKtgr90Ug6JO/vyBAuUy3UiKZd8BoTQViTjCAqO1bJP5gz+duB2lLC
 /l091F+DjWR6g5fcYXA==
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfXyifKkBuf5aoz
 PN83jy9YEH2qhVrIP4jNcOVifn6NsCuBhgStSzxV5OseNovrRtYrtoPArAcA0GTEvZ0gPdB9s51
 wpWrTOxZa/b8CaBJRyyqzNAimPD65/E=
X-Proofpoint-GUID: EE2QiwndYgDfDAQDSPNqmLa-5JnaL3Ls
X-Proofpoint-ORIG-GUID: EE2QiwndYgDfDAQDSPNqmLa-5JnaL3Ls
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0
 lowpriorityscore=0 suspectscore=0 bulkscore=0 impostorscore=0
 priorityscore=1501 adultscore=0 phishscore=0 spamscore=0 clxscore=1015
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310102

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
index 878f1f13be16..18b2e8909bed 100644
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
index 6ea390c8cd9a..0951c39afdbd 100644
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

