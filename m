Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B13D9339395
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 10:42:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788172952; cv=none; b=dax61mIIRNCtY7+xASt5IJK4LdD07iQi31mqwb5azcv9sHXhktbGg+BYvIMJDnekxbD4L+2x7iNXjYFFBKNDbYDPX/lzQ0ipJUJilZHhCtziyWTcY5R7gan06Ioq62iWF0hIkP/pIYpNl1/0nkh1S2HP4tViU7rTwYLysoLDoQU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788172952; c=relaxed/simple;
	bh=lxTqCGHbSa5Aw3NEJz6cx0j/2uqqWe8kMbQTF41HP2s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=XIXc2cxaOO7VZ1iKkU0WF5pufa9bG/e/MMGxwe6zf+IlH+wMtukQXp6BCLE7y3X4ssr0ekFlEZbCbIlmLuXlTsNBox/x4v3+eFE4Pj5Zv9dp+Ga5ImfUsrLh1pn4dREr+jK0RmJC2/+884vL5o0xCSRmg5TpzJJ8N/ED6T1vFJM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=dPQfuj2W; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=Zj0ZjqI+; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="dPQfuj2W";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="Zj0ZjqI+"
Received: from pps.filterd (m0170397.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V7xfua2857150
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=B0JfKdOkRTHx
	HaqI8Uju2//8h/hvPVcVgXhnXzCWw1E=; b=dPQfuj2WTm442AHtzPbZkpjgbEmh
	SPLofwWbQgVlS7t/8sxBWmStgLknNmxONb7J8azlrIBVh1tFAJn/bmJmInONXij4
	6GQbgPcaq1chqlRLCj1FB+EGOKG5fV80QkIyEHyHhv0btLQzOM2lB1S+pL2E6tFJ
	wJj2VelXMOKeZb8uZHajuj+4UrdPf+HWZIHgX4Q0GPHUVuTTD3WPZMIiI3wMn6PC
	1XPuTyETEa61DW3pgAavAwqGBqNOD4x9YXgoyKjrxV8bjMLmbWI90PkMpNcwVbB5
	zxYJwj64v9fazBty2DAveXtN5Xd2jU/OICgk1VUaucnp0HM11x+sn3nv+w==
Received: from mx0a-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbrgq5pfh-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:29 -0400 (EDT)
Received: from pps.filterd (m0089484.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V80NHA4129968
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:29 -0400
Received: from esapsmtplv04.us.dell.com (esapsmtplv04.us.dell.com [143.166.203.152])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gd4xnjb1c-3
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:29 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788172949; x=1819708949;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=B0JfKdOkRTHxHaqI8Uju2//8h/hvPVcVgXhnXzCWw1E=;
  b=Zj0ZjqI+hAp0/zE1XnHb2PtxL70ZDprm0hx6GGXgTda2FORexoJ8DblT
   qJAYeY/GR/GouUWaCPkcX+/E6+bqjE94xPnIvhsopeRclWGA0FAKQOTnT
   PbGxITZibYq464OC0bbEZH3U+F/NOVe4eyrtv5QDJc6tR7MIdaQImrtLc
   0wUZCyS10hTo8Q/SEH71u99hR6KVmunZchwY7uOdAeykUxGdZ286eqAey
   cNGElm+1J7LC09y2yl+J0KsJgfXhGe0Y4qHFTfg30+EdctRLWFBJt+aZ6
   puUuceO81iQEyX26L/TJ7PHIur+8HnN8rnkTdWyJcdOt5Gj0J338dgidB
   g==;
X-CSE-ConnectionGUID: GW3ThQuNSdeAdPIRXmQQ7w==
X-CSE-MsgGUID: g+OXnhiORZ2vk04RmdGGUA==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv04.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 10:42:28 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: linux-nfs@vger.kernel.org
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH 2/2] statd: document the NLM port options in usage()
Date: Mon, 31 Aug 2026 10:42:21 +0000
Message-ID: <20260831104221.2310-3-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260831104221.2310-1-prabhakar.pujeri@dell.com>
References: <20260831104221.2310-1-prabhakar.pujeri@dell.com>
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
X-Proofpoint-GUID: DalgS8Bs3xcbRBoSZN7ylGnLnJywGoQb
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfX/NZ3tz5DKyjg
 O0KWk9KoASClZ9lAsZCOP+/YcGUuFV+nITo2JRlF7TD2X9qazeAf2oh517QK6LX2iTwcJsHJ4IC
 FOdhpI0SepebFFCkJSekS+MSHDuRouG4Evf24jqNky0RiSRI4xOMKwgWH0+iZgqn6gueweHyi2f
 tp/IhiJNCbMxn6eMkLnOaRM3aLyIjE+VrDJLaaP13BGq3sQnDD4a8sBl2xetLFJ2cDVIW5zhXR7
 rPpgn/NXR7MfvqITnHu8Nqx/qlTiioBFtuZoT9h/zQOA43qqQ0Kku1uHIRDZGw6u1ra8nLAValw
 1p/sMPFt4tWA3EJWUYyWjACzka97YDzexwzf9gDx0kA/077/Cbwle2dltpdcRTHkb3hD3Hpg+1w
 TalncFlNLREe5ETbmNW/UZivBTRUKlvtT+PCbsnaxCTXF7ALN1AlW8ngpJTOCmV5l3fesrPyL22
 B+iQnmEZzX04z0ezECw==
X-Proofpoint-ORIG-GUID: DalgS8Bs3xcbRBoSZN7ylGnLnJywGoQb
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfX8RVMr/Yuy0Qn
 pEKDKmzRlE0T1wCQH57d9yFed66e+bNrJBEfpYZ1HIKtUrveTpjF13Vw/xICIJdxXFgh7C1RD9u
 Jc/B/gCYauPeCofeSWI2CV4mHegImTg=
X-Authority-Analysis: v=2.4 cv=IoQutr/g c=1 sm=1 tr=0 ts=6a955a95 cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=XtseytAk/c9oG0Kwoj6KRQ==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=U3ti1ie9CgboSd2qXsAw:22 a=iLNU1ar6AAAA:8
 a=1F02Q7WEpGxq6sX0wvgA:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0
 spamscore=0 phishscore=0 clxscore=1015 impostorscore=0 suspectscore=0
 adultscore=0 bulkscore=0 lowpriorityscore=0 priorityscore=1501
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310092

rpc.statd accepts -T/--nlm-port and -U/--nlm-udp-port and both are
described in rpc.statd(8), but usage() never mentions them.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 utils/statd/statd.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index a469a67a..fa43ba17 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -153,6 +153,8 @@ usage(void)
 	fprintf(stderr,"      -d, --no-syslog      Verbose logging to stderr.  Foreground mode only.\n");
 	fprintf(stderr,"      -p, --port           Port to listen on\n");
 	fprintf(stderr,"      -o, --outgoing-port  Port for outgoing connections\n");
+	fprintf(stderr,"      -T, --nlm-port       NLM TCP port (and UDP, unless set separately)\n");
+	fprintf(stderr,"      -U, --nlm-udp-port   NLM UDP port\n");
 	fprintf(stderr,"      -V, -v, --version    Display version information and exit.\n");
 	fprintf(stderr,"      -n, --name           Specify a local hostname.\n");
 	fprintf(stderr,"      -P                   State directory path.\n");
-- 
2.55.0

