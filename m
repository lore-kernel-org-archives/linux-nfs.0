Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BCEF3E2752;
	Mon, 31 Aug 2026 11:48:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788176922; cv=none; b=mh2QVc9tQGdol1ctUp+tBm7e58FMnF1UKXR23U0fE54lzdX5GGkdSxSUR0BMKFo/M6TkjRNax4e06csFyDJyRMOz98ivGibhM5PRou3lI3dICKChn4VgAH1htHZs4F0H8y12Ri3c163W5Rl8/yeVU2hMNe+nkiJ4AbxbOOHnKTE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788176922; c=relaxed/simple;
	bh=Xfy1fNMJ3XKixkJ9/rq8gl8TQ6XBOPu3YP1pnl5eP08=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ehoUE0Rc61zutOVd1xwmpKSHsdDIGBLXIZXQMuq6THYO5yx2vN1su4e0WU7QjcIBz3KYTTe18i26nppXrXxAjogQgds7neesf/mrYtq0UQmsDhi50gt/tRZAXRuRrYcepq4LbEgYfZzYHB7NXDoIreEhyM5ek4rsM5wMuLnMHNE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=Bj+GCbXo; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=C+1FvceK; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="Bj+GCbXo";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="C+1FvceK"
Received: from pps.filterd (m0170398.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VBA61Q2885251;
	Mon, 31 Aug 2026 07:48:39 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=69Tv0XLjnDn1
	urfUISd2E1wjK0F+DsgeEDfmJPCg+tk=; b=Bj+GCbXoQarKbe0Gi+UC8D7fBb5Z
	v8wku7ayyQn/ZX/AdMalQfvHJ094FZMHhuxCv9SnYcop7Bjcx+yV6g/6DHAokWlJ
	zBX8QcRmtzPWqQlfs+i5QpTwj7dXzvpgtdFi/0Onv1yKqnEd7eo6IZ9g6z84U1+d
	4ahzaKTbAdijXOJ6ZjyvOs9bdUskLX0bfzpjL8r9pR3tVMZuR4EMc2F0eliAJ14A
	oDa63lSyKVIZ9Kn0MuNXkhJd+YIvlA6opHrzCx7wgiNN+5sgNQmMOzA94Y/35YG8
	NgijovE8nA6mdVeHVB1H4VtAwl17Ko18ZEoD49TNVobcV8EBFK8AMKGKnw==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbtn4wpv2-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 31 Aug 2026 07:48:39 -0400 (EDT)
Received: from pps.filterd (m0142699.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VB9oRw3049667;
	Mon, 31 Aug 2026 07:48:38 -0400
Received: from esapsmtplv01.us.dell.com (esapsmtplv01.us.dell.com [143.166.203.147])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gd7wp8uqk-7
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Mon, 31 Aug 2026 07:48:38 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788176918; x=1819712918;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=69Tv0XLjnDn1urfUISd2E1wjK0F+DsgeEDfmJPCg+tk=;
  b=C+1FvceKG5WXOICNSj+vpwQ2bkpu7DXn0YrDeVhTNXT3ES/ZsGSU1yV8
   1KuHApwgoQOxV/KUA6usPYyfbLH10RNWud6shp/dtotdl5rPWWBlyxJNt
   88ODzbZ68o6hYzsfp4CG89tAuBM2YXUkr5GatU+FYFNg0U7w4KKOaJjrz
   MFHsWcQmk7rmC8Qt/Njtw4ZI+9drYimpqr86204NLOLXQ6zmFLzjhxr/t
   GS8hZkP3ssAAtA2vEqMhOORh+lHEA3YVec0fZS2GgjkDcO/lr3yOOff00
   MAe8bBPXk9W0NZMFEIlK2ovbXPHKgeCb5jHtfy5wzPY8L3vcX3nn9P4UH
   A==;
X-CSE-ConnectionGUID: NQ3Bs1faSUOjQYnayZ8GIw==
X-CSE-MsgGUID: d7jVlrJ8SQqYmgZMReDt/g==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 11:48:36 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        stable@vger.kernel.org
Subject: [PATCH v2 6/7] NFS: bound multipath address count in flexfiles GETDEVICEINFO
Date: Mon, 31 Aug 2026 11:48:17 +0000
Message-ID: <517ac6d5c035a9486b7aa39e85ee6f0d1eb80284.1788173789.git.prabhakar.pujeri@dell.com>
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
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX6fw/jcpCSKUb
 pY9mdkaMxYKTAeX7Y+aTGBXIpuEoHvpTSEvaHlQ3gz5JJeDDZs3TQ72Qz4kOUgfKWsDEKo+crg3
 cQydHyo4cdFRVPbIBago4jqanIsKAOg=
X-Proofpoint-ORIG-GUID: 7vdMCjzoH5gocEZu1TdcqoI-kj8xX9oS
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX+o2rx0EKWrQ/
 4oOJ0WTbwScxMVGKJDHSKbaCK13dglrMzjaEVogkBIuuQQjdQr+tG45qANFWTg+ORfE4ylRofmE
 pj51vhmInp62q8YET3baV/WGn81M3wfbWa943NuEdGwOUgmGrLPpIQjHRa+rA4tNofxH1L7OJvh
 wio1AedM2bTwnvzCXg5WxsilowvbBaSTK8Ba1zcni1YOYSWM3QrUTN/VUI23z29tYBUBRlO7yuL
 mGct/fetXGmHJeU3Qugj/ErhGgiIxNy8rjNiecOBymJpEKCFMTng1fTaA837IEPmnmUs5zSxtUA
 wRRas/YYexQDl4kmUlBcvsatZipC+wNw1m7no1Bt6EZkCNM1w9ZSb7zv49S/4pCQkj+Jy/8rEn7
 Az+9VcbM0IMgDlA59x3t7IhsQQITNBHg+QADjY3eZ9WpvvTl5R79nXe0qXUcDwtm8niSC0SMTng
 HBsUoGiQwPBkuscuUQw==
X-Authority-Analysis: v=2.4 cv=FMIrAeos c=1 sm=1 tr=0 ts=6a956a17 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=L/h6WUVEnF1aJ0/14Ndw0A==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=vUAfKriDyi6VqHAKCLgX:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=AAw7t8U_PN4oECDQQJ8A:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-GUID: 7vdMCjzoH5gocEZu1TdcqoI-kj8xX9oS
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 priorityscore=1501 clxscore=1015 adultscore=0 bulkscore=0 suspectscore=0
 malwarescore=0 phishscore=0 lowpriorityscore=0 impostorscore=0 spamscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310102

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
index 96f14c1f070e..6c104b1e5ff4 100644
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

