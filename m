Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 445FB7E792;
	Sun, 23 Aug 2026 11:43:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787485398; cv=none; b=Fk94MjH/hOij1QFW1YYhLSjjsAtUJqWGRt3FSemriZoFf4Ru4SGFxgRCqrBSMmdfCUAjSSWFflUhkS/x9mkVQyWrQI4sC1bBDoKKz+KuJGQ5+A/U+rLcXh9dtmsTDJL63l0+lM1j/JK9q+jVzw33vX6TDPRJM0XZBK20DjA+0Qs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787485398; c=relaxed/simple;
	bh=w6jBaQeTuVv4WZufSATfHC7rrbJSQrLoOo/tvS8+qKM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gKj6a5+6YAQRso0UJ9prf8nOpRyHIMkcM4OnrxNSqoMo0K7n5a1WsiPzVdmakTofWRfv/mQhQ98voR3ROnruPWfGGnaFin2Ql6Z6gG+uXcDFDJp2huds4pIvbWdZ+j8UTguN3c64up0WjOs6Pk+ENzj6bvjMRRBmLTk1FF1G3dw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=tn+4/u1P; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=ZFa59vrK; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="tn+4/u1P";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="ZFa59vrK"
Received: from pps.filterd (m0170397.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NAAFcf372051;
	Sun, 23 Aug 2026 07:43:16 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=2Ssq5yLoj5mC
	xEdr1g7GpNpAqlfKv8Kdvp0vcKY0SXw=; b=tn+4/u1PQZoW1IMTH2Gk1y6lVcA4
	kE+nSBcaRoy2y9FMYQT0ucB225fiwpfnaymTsXTuvJvxngngWES6hc2R5NY+cVng
	zI0h/fG4hUJPD5lYSC2jgLLkIbxvaVEYaUrDX/BjdZ2K1Tt8AXEnO7M1htPCQxhy
	4pLjJB3Oe0skmoLOk6EXLuiGVWh6mh5QAj4APEcVuSVpkwSX7eZbJK/+Gw/Gd2AQ
	8FgwD6dkXD5Ns1wVwSzci3SRm/0yxMCaecVSnQLlF95fIb8yU/vwuIeTotGhbiu/
	+5z58E8HZ4UzhRov1612JmpQkY0VaRdsFP2XR+pIZYQ4u0n/mpy9db3jZA==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4g74upaujm-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Sun, 23 Aug 2026 07:43:15 -0400 (EDT)
Received: from pps.filterd (m0142693.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NAA2RV370768;
	Sun, 23 Aug 2026 07:43:15 -0400
Received: from esapsmtpat01.us.dell.com (esapsmtpat01.us.dell.com [143.166.211.146])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4g7wevhp69-4
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Sun, 23 Aug 2026 07:43:14 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787485395; x=1819021395;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=2Ssq5yLoj5mCxEdr1g7GpNpAqlfKv8Kdvp0vcKY0SXw=;
  b=ZFa59vrKbe3vNQWrkjH0so2R6lqnvjrMCM8SVGdwRgCGTZaI2sP6LDUH
   +7JpiwX8wUQmN0oQKTlJHczT1X2PShmJ7ZdgOtzs7YmsUnnQfdYippx93
   A8OFsyj8RmYEAGs99YBWKoXh512nN+TQJISSglJEL2bDVofgHt0vZF0y0
   pF1DpidbGq7PkINoODzghBEui1CByab++9ZdMjfiWn6Vt0aLd3WBFHTlF
   qCOvmv1sruVNGR8NVpQSks46TzNsyvm9+VJYp8V8H4NmH6355y8zBl8f5
   pxCJ5se/GDe0hBoCxZdcXwTWBsRSkEPkNBZpB8gt/0coMpQqX7rUfg7gv
   A==;
X-CSE-ConnectionGUID: AVmIb9fUQnyYjvnh4YAxmw==
X-CSE-MsgGUID: ZyKDF2bqSyGspJ2dAl4PEA==
X-LoopCount0: from 10.17.189.166
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from unknown (HELO W-96J1TH4.blr.amer.dell.com) ([10.17.189.166])
  by esapsmtpat01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 23 Aug 2026 11:43:12 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        stable@vger.kernel.org
Subject: [PATCH 3/4] NFS: bound multipath address count in flexfiles GETDEVICEINFO
Date: Sun, 23 Aug 2026 11:42:43 +0000
Message-ID: <20260823114244.3883-4-prabhakar.pujeri@dell.com>
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
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODIzMDEwNiBTYWx0ZWRfX/u2lT3Q3CebO
 Sa53wj8w43cxXpHNO2DsXeGlWMQQobuXC9oXvwqLeVKWAlwI5YuJiISNTAMamE2tjwisOIVVF78
 WToQ4I5pwykqa5xbr8xIwgz2wsD85BLeZk3e/Iugba33K/npQaQ77i+IKXV0gtDFSudeGzB04ig
 uN/bPfjYHJ7tDYn7WAp+3qAaIv6PGfLfUe+r75dDkk/HmwpKgN3kTgUE+IJVBh/GmzQhssUbS8M
 Kw+H7X3qLHUK6OFgZ72Zuc+CJGKqlz/cYA+ryuuMy6m2GD6GtWC+im2Lwco3kr+siwjNHl+Yq/B
 o4G3eojJ3lV53q/vqN+R3CXjG4YRVbKHETYnPNHeXtJo7/N2rVeAMsuMQvrzQw0ZI2HCKSzgxIP
 eeEy37VN5g7oQIqQYy3peJvpUazUDulcz6PSgqBk08E1+YlK00c+9C6GbN5ztHoaIdtSz5q/YJh
 TF3t8k6g6m+XwscxIgQ==
X-Proofpoint-GUID: pJg6AjabfWq29pcmmHWLpNAbb7DMRA_G
X-Proofpoint-ORIG-GUID: pJg6AjabfWq29pcmmHWLpNAbb7DMRA_G
X-Authority-Analysis: v=2.4 cv=dtDrzVg4 c=1 sm=1 tr=0 ts=6a8adcd3 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=MDsIxxkBee3CUfGUG3hQZw==:17
 a=b3DhMmMkJVNBYjixYE3i3TbOsPs=:19 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=U3ti1ie9CgboSd2qXsAw:22
 a=VwQbUJbxAAAA:8 a=iLNU1ar6AAAA:8 a=AAw7t8U_PN4oECDQQJ8A:9
 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODIzMDEwNiBTYWx0ZWRfX+vZeMzXhLN0z
 5QfUy1SSshEZNyVOWOwRMnMyuA0zCGKbGSWwoHeAVQKFMacGdwft0rbbnbrWRTBMVmvlX9rTjwL
 5YvG6zMw3dIjEwZlXCbFNM8SkBSmViw=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 lowpriorityscore=0 priorityscore=1501 bulkscore=0 clxscore=1015 adultscore=0
 spamscore=0 malwarescore=0 suspectscore=0 impostorscore=0 phishscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608230106

nfs4_ff_alloc_deviceid_node() loops over a server-provided multipath
address count without validating it. Once the XDR stream is exhausted,
nfs4_decode_mp_ds_addr() returns NULL without consuming input, so a count
near U32_MAX can keep the client spinning in kernel context for billions
of iterations.

A netaddr4 contains at least the two XDR length words for its netid and
universal-address strings. Reject a count when that minimum representation
cannot fit in the remaining XDR stream. This makes the loop bound
proportional to the reply length without imposing an arbitrary protocol
limit, matching the protection in the file-layout decoder.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Cc: stable@vger.kernel.org
Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 8be5c730e101..181a5854fa37 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -78,6 +78,11 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 		goto out_err_drain_dsaddrs;
 	mp_count = be32_to_cpup(p);
 	dprintk("%s: multipath ds count %d\n", __func__, mp_count);
+	if (!nfs4_pnfs_ds_addr_count_valid(&stream, mp_count)) {
+		pr_warn_ratelimited("NFS: %s: multipath address count %u exceeds XDR capacity\n",
+				    __func__, mp_count);
+		goto out_err_drain_dsaddrs;
+	}
 
 	for (i = 0; i < mp_count; i++) {
 		/* multipath ds */
-- 
2.54.0

