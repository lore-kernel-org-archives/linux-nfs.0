Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F2823DA7C5;
	Mon, 31 Aug 2026 11:48:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788176912; cv=none; b=ILKRmRG/zJJjFrm0X3ULJPHNmigHqCniio2ha5pVNjaFekl+AgX3oP5kKiURfgEEHjJG6PeTdVTD16CF630gCjioNOM4x5UnxDmfY3l3aJ/UNSGqVkCzS65id47/2PxtchPZn4zk6ugBvrHdwBRp+CfyP3OVINZ8qD4EHDkXruA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788176912; c=relaxed/simple;
	bh=LBVq+RJ9Pi1KSuDaeH1fPNwz1UXN5NY8+XElKl1FbWw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tkGHUHejahc4E3h18ZuDpg1ss4VfiRL+2Rjh6f6yqenqy9dpFIEDhsA0jd9mW0Xn+BAfkRjiDVgAgMevGe8190X7wIHexIojn/G384065pBUr/WTbY/sTp4mVcRwRAf7eSfDw8uF3AqqpKwKqNaF7WyLI+Ulxsg5i87IbjtvK1I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=oJd2mxwc; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=HfHG7mTF; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="oJd2mxwc";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="HfHG7mTF"
Received: from pps.filterd (m0170395.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VBA5pQ3577698;
	Mon, 31 Aug 2026 07:48:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=i3QRePNce5hV
	qwBHSOJCT3xt9QjfGFI15UzB/416HcQ=; b=oJd2mxwcBTLKIgUs4fQ8LajqT7yw
	aKtpet9xIfcZfhgOvX/AImmJGYwW8XGHkgwL5o19vCgAf/Xlj7uLLligVLPM6Y+7
	lAIs1ijP6ec7nc7rHrRuJVOL/vY6La2B5s2SKssdaM7kV2oTWmE1saBjX06QTi3D
	0KjplmJuUWWhsNcGH7mNuWNLC9ZJMJbb2d85nCOdS6aFNeYs/5Bla2wWQDffm/2H
	H3RtqIClnOTG2Jn3f+Ia7UEi5eFzhiP7tFcNGgJUl0+GC1EDaCSoGWf2mcOSQd2V
	L0zJ+RnW/7o6zvVDr/U+helRtx2ZeysGOhKvEVUAvSWF+Sof423OwR1zTA==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbv3g5eg1-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 31 Aug 2026 07:48:29 -0400 (EDT)
Received: from pps.filterd (m0142699.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VB9oRq3049667;
	Mon, 31 Aug 2026 07:48:29 -0400
Received: from esapsmtplv01.us.dell.com (esapsmtplv01.us.dell.com [143.166.203.147])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gd7wp8uqk-3
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Mon, 31 Aug 2026 07:48:28 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788176909; x=1819712909;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=i3QRePNce5hVqwBHSOJCT3xt9QjfGFI15UzB/416HcQ=;
  b=HfHG7mTFs/3QRnjJ0038X/vR8xRCpJ1meOKp5AeI5QSZ9/e7IjISYI56
   bD8OQkbLCaTJEJoRA27f4csbaOsqIhLgRpzFrRCHla9g83Beei7f9atBK
   R6x7Qt0xP08dVAoxiDH7mxknRLCWBPYkhOArxfx2VR0F3P8uvio7mVlaM
   mEsP67toMsYlzKe8KAeU9M1DA9LpboGkCAKigD/bIsIc5DpnqZI4xHSMn
   uCqUIrdsxgm1oYx3wSXZcWYDSMzM5FKJao9QJESowVZ4a1zorETFyJQIa
   PXc496+A7snPMH/1SXG+x7V7jX2R/VgPfRWSez+7l+kc1wstnAjDTK0FT
   g==;
X-CSE-ConnectionGUID: Fn3XpCDwQraYHoZDdtD02w==
X-CSE-MsgGUID: 8E9ZeRhSQo2IDcPbq0BrSw==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 11:48:27 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        stable@vger.kernel.org
Subject: [PATCH v2 2/7] NFS: bound flexfiles GETDEVICEINFO version count
Date: Mon, 31 Aug 2026 11:48:13 +0000
Message-ID: <902b77d318450d18ae422a9aef7f54711826c043.1788173789.git.prabhakar.pujeri@dell.com>
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
X-Proofpoint-ORIG-GUID: TuAOgr9j5NqCMNexFpBY5F-Wv5BMd7kX
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX7ujSgeus91zs
 vf1fsRay2z12OMD6iJbnMsZWTgYTc6aSIlGlaQwtcJ00814IvCQhfm/ZDp9wOEs/azGgnBmZSsJ
 +vGUEhd4HC7ETIDToMN226hRwRd0zJjKgkZGcXLvt+CwyNhXWtN/DSraPECSBrU4t9wuiCFMGh3
 ao+WncwgB6mbIw8bH25fIygA+Qwxajkpmpb9K3g9GAPwmY0CQCuRGbZuCn8SUFmJ3Xk0QOdqDkq
 08h5OtBIlcCXwEAHXN1fpM4qwNjNz3iJ1ULP3ORBFBysAbyETdPATNyq2RaRYZvSWRDx3kJwyyL
 plj2p30KMJXHillF/xgiAEkU7B0C+lTa06V4nY/ViFeNVU35DeV054T52qATXbdhMV88Ow4TW7L
 +Tm88gz50bnwdl1QiKNFmHrvereOPToXjVgiJVbl1LVdR2FvVZZnQPfmEnQwBlAjOHYfxnIYBgv
 4f6POUHRU8dzmKio4uQ==
X-Proofpoint-GUID: TuAOgr9j5NqCMNexFpBY5F-Wv5BMd7kX
X-Authority-Analysis: v=2.4 cv=B7SJFutM c=1 sm=1 tr=0 ts=6a956a0e cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=L/h6WUVEnF1aJ0/14Ndw0A==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=Qy6CKLcU0MZ4grw4BCWD:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=Ycju_gVlqriiIU_1qAAA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX/lTNUY/xishZ
 Qzmd/yW7RyWePYfZRF3hwLo9pqSLpPDsHeAatt95WrDyS8cb+XYjyawRjo7vy/2pgV4pKhF/+R9
 vZfX6c52LGOVch7fVuBvFTyQbE1OCwY=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 clxscore=1015
 suspectscore=0 spamscore=0 lowpriorityscore=0 bulkscore=0 impostorscore=0
 priorityscore=1501 malwarescore=0 phishscore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310102

The flexfiles GETDEVICEINFO decoder allocates ds_versions from a
server-provided count before proving that the corresponding fixed-size XDR
tuples are present. A large count can therefore provoke an oversized
allocation from a short reply.

Each version tuple contains five XDR words. Bound the count by the bytes
remaining in the stream before allocating the array, and use the same
expression when decoding each tuple.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Cc: stable@vger.kernel.org
Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 95cb54c498a9..96f14c1f070e 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -98,7 +98,8 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 		goto out_err_drain_dsaddrs;
 	version_count = be32_to_cpup(p);
 
-	if (version_count == 0) {
+	if (version_count == 0 ||
+	    version_count > xdr_stream_remaining(&stream) / (5 * XDR_UNIT)) {
 		ret = -EINVAL;
 		goto out_err_drain_dsaddrs;
 	}
@@ -110,9 +111,7 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 		goto out_err_drain_dsaddrs;
 
 	for (i = 0; i < version_count; i++) {
-		/* 20 = version(4) + minor_version(4) + rsize(4) + wsize(4) +
-		 * tightly_coupled(4) */
-		p = xdr_inline_decode(&stream, 20);
+		p = xdr_inline_decode(&stream, 5 * XDR_UNIT);
 		if (unlikely(!p))
 			goto out_err_drain_dsaddrs;
 		ds_versions[i].version = be32_to_cpup(p++);
-- 
2.54.0

