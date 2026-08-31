Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3385339395
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 10:42:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788172950; cv=none; b=J7JzrHwu0FlZ2v1+QEkQ0Rj+HSVEh/rqVWk1qHBX46qtqwcVJqGGPnrbLLFFg59UkP/XHcVz0xkX+NXMKCI4qp8H+rAV6DXpMSJW86wkVOOVYeJEGML/aRyprjIaSNDluRS9VhvYugqMas/MQI4dRMY0reT+OfiXCuKmIUNEmOY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788172950; c=relaxed/simple;
	bh=3u1HXnIo1n//m8L9w1iYT3/v4TP4y8ymKTPSSmIhYAg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=t6IlYU+TxUreY3oaFF3t9AP/GAgzgFANbCHqWuL7bp+C9DxH2yjMABfsg4r6AtWTun1YV0UfCPhRw89VuHqJwp9RwvF+yvQdj7/SLBxcnO1/Ym9UupIcIIYQeHLP9Ryo+2J35v/3l800WSqwk2q4/1AtdQRdhzqYus4im7Fay8E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=W7/vommV; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=NEZYQxwK; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="W7/vommV";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="NEZYQxwK"
Received: from pps.filterd (m0170391.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V80NCS2700740
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=smtpout1; bh=SvrB1QKImXkD/MIpcxBeh3LoHUZUx/G2vMYp
	vgLTRs0=; b=W7/vommVKR/kDmZ90Ceg7KrpV27QOADzuW8Hj3VeHYnOuVVDZZQq
	gRJgWNM7k36K1I73ZNZVADIA66bSdEmLFkyR1QZdZPTiYkuUiYrzZDP0ikJr18oh
	51swJLOoElMvXIEV0BtG+IR1G8llPa0cYRUbqOMVwCk7hoyK4tEQZSI0A1W5cMyX
	XKcvzFPNIK/3N+UmC8W7kBPZhcQzlO1sAc9rhtpwGEpNJfOgYz1CIvjIhXm34DkM
	YUqO2fAb8VcEMHtsViKVcUPu1CnkTskSDP0HrE1BqZopQbOBHprVRW8ECWN9YqOl
	O212Y1y52h8Qb4wXf9WU62e8v03xEQHCwA==
Received: from mx0a-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4gbtjsde56-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:27 -0400 (EDT)
Received: from pps.filterd (m0089484.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V80NH84129968
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:26 -0400
Received: from esapsmtplv04.us.dell.com (esapsmtplv04.us.dell.com [143.166.203.152])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gd4xnjb1c-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:26 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788172947; x=1819708947;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=SvrB1QKImXkD/MIpcxBeh3LoHUZUx/G2vMYpvgLTRs0=;
  b=NEZYQxwKAtYG5TBgkPH6tqQ+BLXDwshYDqnOpyDoYIjtbb0nSoHv1J9r
   dcSfmVkSs2QJmZ/ZSCEIVWXIyF2lD/+tfLhim+elwZbGu/WXaPzR1kiUD
   /Zoa8rdz0Xsd1QKXpKXmh33lwL7qBAagfo/fXnC0MegbI3JgeDUKWhf0a
   RCF5ho+zuqhOczR2R7DYMOOxTU+uiKh+9WDSZrp1fqir8FLXl2iRF9xue
   taVmmh4IzjAGeBARZ/7cQ6dX+CkWeNQoFNE5kWenGxLHDcwjvCKXgRzGm
   XdUEEmo7/+kVtIFrCsDpo3w6Z4DTlrW3HjO27bArh671J+RkXfr0Aub+Z
   g==;
X-CSE-ConnectionGUID: BZqeQLMPT0ixpvG7E74Yig==
X-CSE-MsgGUID: zpYj1LwUQqWifdAsqi1x1w==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv04.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 10:42:25 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: linux-nfs@vger.kernel.org
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH 0/2] gssd, statd: correct command help text
Date: Mon, 31 Aug 2026 10:42:19 +0000
Message-ID: <20260831104221.2310-1-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-31_03,2026-08-27_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 spamscore=0 adultscore=0 malwarescore=0 bulkscore=0 clxscore=1015
 impostorscore=0 suspectscore=0 lowpriorityscore=0 priorityscore=1501
 phishscore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608310091
X-Authority-Analysis: v=2.4 cv=R9Yz39RX c=1 sm=1 tr=0 ts=6a955a93 cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=XtseytAk/c9oG0Kwoj6KRQ==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=aNt9FJNJ8fZyd9HhltU_:22 a=0F21_NOdGHfHwvXvrbAA:9
 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-ORIG-GUID: 9mSa9EjJCr6SL3hjL4xl4abG73uNuMT-
X-Proofpoint-GUID: 9mSa9EjJCr6SL3hjL4xl4abG73uNuMT-
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfX0G2/C/U03Gsp
 TC3BgLn174Dm41qDzAL8JFQ4hL9N5DBm8BsZ0wuBRPAv3Oos4yDstJ8gOsi/gN924SziVJMNoqS
 hJ+JBGqCPBui538/ec5G5T6lQyGTE0AikOy9DvHdffr6yVVhEPrPsWfcEGpwm2CBA/RQnDDSHZy
 6SpVOVJ9Q1Y9p9komXa4gcBUGb5B7k11Ljde+eyL/BlF813v39+1h0Allhr0jqsbKzmsmWyFXoK
 /izliqb1WAfnOdgiJFBjkIo6+Viarzvx5tR/aV2AhvqMd1WtwF7HDrHROGjOet7Vlm1+Zq+pOiO
 oSMVw7JBMAP3UlqGcRZdgy46figozIzRU5qzDalK/n/fWdpAUsh8q+Baui5d4aWx98uY3znq3KT
 bgqEMBoBUhoDl+wjxjsx+UaLqcldNoxc/aDTJ8SvhXlYse6H+1mRctVNmNh0P9YU5z8WxI2Fw4N
 dmJsHNs3pjCIQT+Feog==
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfX4qvt2O8jkDo/
 gEwpZh6OTkEVvzAoVeyEO+RmoGXoyj3SWuAdG+3Y80rfuJ6BXACljhTwjS3iC8Qg/cTER7gmupn
 m5js9sJeUgoPBzFNuz8JZi1ml/UXSOw=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 clxscore=1015
 priorityscore=1501 impostorscore=0 lowpriorityscore=0 adultscore=0
 suspectscore=0 phishscore=0 spamscore=0 malwarescore=0 bulkscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310092

Bring the command help in line with the options accepted by rpc.gssd and
rpc.statd.  The first patch removes a stale rpc.gssd option and adds its
timeout option.  The second adds the existing NLM port options to rpc.statd
usage output.

The series is based on current nfs-utils master.  A fresh autotools build
and make check complete successfully; the statd integration test is skipped
when its required service environment is unavailable.

Prabhakar Pujeri (2):
  gssd: sync usage() and man page synopsis with actual options
  statd: document the NLM port options in usage()

 utils/gssd/gssd.c   | 2 +-
 utils/gssd/gssd.man | 2 +-
 utils/statd/statd.c | 2 ++
 3 files changed, 4 insertions(+), 2 deletions(-)

-- 
2.55.0
