Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D24733E49D5;
	Mon, 31 Aug 2026 11:48:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788176914; cv=none; b=T8HFKDUpXtW0BWaAPX1CDsN3bwym7L+mbCuHApaMrsXO2UDgPA9GvG7muhuWIuYLV+DGLNruFGrXyp/GNgxQRul1Tv/LI4k0CawInHV8ewJvevkOodkRPhhsbsGLU+gOYrgTXMYHStiI5QavZOQxH/v/+Sl9/h/7ytwT5elv1ys=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788176914; c=relaxed/simple;
	bh=LYh4KqKVNmDm/coOX6KXg56Wyb7+W2SRasonnA6EQzQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jxPVKIW5eEQcR2KZSeNyJZk59fWZ5NJpKpkWrroXRqJSjWIJYcEfnzX/uRnmYVDWFWWPah6SZifrwvhalaF4gTi10x3FINJ3LNYKdb46eeFFS77g8k1bntQGu3KWqOHLF4ML8aOoYDQ7ljsCPKIOSRNgn9TR+nyo7Z6HLK+fub8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=I1zOICS0; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=fUPaSIpH; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="I1zOICS0";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="fUPaSIpH"
Received: from pps.filterd (m0170389.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VBAASj3026601;
	Mon, 31 Aug 2026 07:48:32 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=wVgmdZSI0wug
	LsLKLNeKAjU6b1XDS793a5u1p3WWTOI=; b=I1zOICS0OTw4S485PQ2B9wRt6btr
	Xz55IVANg2KiU2uO/+iq817wrHc/hvj7ubgmrF53z2fS3Z4gpl67vSHxh2jpdW01
	otrMN/3Yj/R4RfIi5WR3UsVqlv9KUABOukVlHA/NDio/b+4VHyJR/iGDrbxF/+vE
	K4p6SC5Jv7BDdaFUJMasnra6Adb0AvHbw6QpaxNhYnW1K5pU8tlTQLDjSSMkbvT7
	bzH8Yb18rvkV2QXD9hLMiBLUL2H+yZ2/yocyMllG1okyQuPQVa2j7NjS4HDZHEVX
	i9qJ6tKMgnCLrEFF/jxaDfMMH4Qj6GEaAKvZEZFgQmdhHSkdy2goOt23yQ==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4gbuedwh8k-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 31 Aug 2026 07:48:31 -0400 (EDT)
Received: from pps.filterd (m0142699.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VB9oRs3049667;
	Mon, 31 Aug 2026 07:48:31 -0400
Received: from esapsmtplv01.us.dell.com (esapsmtplv01.us.dell.com [143.166.203.147])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gd7wp8uqk-4
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Mon, 31 Aug 2026 07:48:31 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788176911; x=1819712911;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=wVgmdZSI0wugLsLKLNeKAjU6b1XDS793a5u1p3WWTOI=;
  b=fUPaSIpH9MWdiJ25WKOu5Jcxw4vf19v1/d0qnA8oF7Ur4A5YSq9cpZlp
   kzti+apS8PFKHufjShRrMKSSmEaSJE0KcdrVkXUvO2JEXeyTpQu0tap8W
   rE3bBUPQYtQXfavQnTSZ8nmUEmXrUrGKgP7S99s8tUTUV70B116XOR0I8
   vxKcaogToAqq7f7CZ5FWLC/FGEbR1mwfmc2/Oh/4BRf9W8UJo/TkBg0f0
   e6NZIMvwJuWeOrJKt8pY5dSJxhz1LwL4iiZFd6IeC28WqeMS1pXNIe+7h
   FcDUYmvbOOzhC4Z5SWZ+HRnYL9T0gZlNy6ba3DVX2Kp9G+QprCbhypvSe
   Q==;
X-CSE-ConnectionGUID: I0g9qFqLRmyROCOWOJc8lQ==
X-CSE-MsgGUID: 9sXZdxvJRXKZfDiAA/hbSw==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 11:48:29 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        stable@vger.kernel.org
Subject: [PATCH v2 3/7] NFS: bound flexfiles filehandle version count
Date: Mon, 31 Aug 2026 11:48:14 +0000
Message-ID: <e00ed21d7f259b6b609d004c32fb42e02c45906b.1788173789.git.prabhakar.pujeri@dell.com>
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
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX2iOL0wIN7oCk
 jEdYCETtWkqiZKcqRGnE+MnI84WJzy2EVfmCLtRDO+f2PARVfYVVwg+sT50rAQyLVBKe+3cthqi
 aYoSR48FhwsYPReSQeGdooEOo5n5Yw4=
X-Authority-Analysis: v=2.4 cv=FbUHAp+6 c=1 sm=1 tr=0 ts=6a956a0f cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=L/h6WUVEnF1aJ0/14Ndw0A==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=PpEg0BoV_A2aca28hXd0:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=R1B-8ATixRUzBlqyqq0A:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-GUID: NjIiURy2R3FqMwKNnwSInsfW0UL4NOSm
X-Proofpoint-ORIG-GUID: NjIiURy2R3FqMwKNnwSInsfW0UL4NOSm
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX0TVqsj2z/jhB
 CXRrPiiMNejT0lYqTF5mIyggT6m8IK8qVYKOnxuUzf9dGWN6hRqzOnO8ppR/VdP3ZTdLivaxDfq
 18wxVFX/G30trOqcQXLzZ/4jmsJMrQDiTaj+rJBw7kO3ahD8HGJwmZwJ0IjAq5gdtA2DwlZiM9z
 YHi4MdTSopp+nQJr5a5/0qg7+4bOt1WFa4M8Uy/bY5xJO1dOJ8/50Ac2KPoe01pdTiDtivc3KPQ
 6WTwAEtBArWyOjE14QFB40rswwaNUli7ZEDQ7LHRQscTQwgSAJ1d6s3BWOWUlE1zGJ3tfs0KIBj
 fQxZA9ZZA0am5WuQ+6tmjiKq7ZiVvbKieoNAA4CpTQQ0R+KCKdsn9CqOSHofakiIbV1ev6p8+LH
 ePuh7fzneue5WG7LTNK23dlLuv0ftHnaCOSDxdF6aGI2qYW7xLFCr1gu8fuP30NhhqxE+g+S6QQ
 gZZu+g3YxShTPsD0Rdg==
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 spamscore=0
 phishscore=0 clxscore=1015 suspectscore=0 lowpriorityscore=0
 priorityscore=1501 impostorscore=0 adultscore=0 malwarescore=0 bulkscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310102

ff_layout_alloc_lseg() allocates a filehandle-version array from the
server-provided fh_count before checking that the layout body can contain
that many filehandles. A large count in a short reply can therefore trigger
an oversized allocation.

Even an empty XDR opaque value consumes a length word. Bound fh_count by
the number of length words remaining in the stream before allocating the
array.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Cc: stable@vger.kernel.org
Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fe8b91fa47c..f94d328b67cd 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -551,7 +551,8 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 			if (!p)
 				goto out_err_free;
 			fh_count = be32_to_cpup(p);
-			if (fh_count == 0) {
+			if (fh_count == 0 ||
+			    fh_count > xdr_stream_remaining(&stream) / XDR_UNIT) {
 				rc = -EINVAL;
 				goto out_err_free;
 			}
-- 
2.54.0

