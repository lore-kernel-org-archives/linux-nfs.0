Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EED2E32E728
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 10:42:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788172940; cv=none; b=dfBl3Te3oqkt71sXPHWz8T7bdv1bxJ2onznjKQL6b+CZWxRtEWio9EtcRPMhnkWzUGCN/tsMRmiGSDg8yKMUFtIssX1k4vYVwbCZSDPafgJyP3X3R1+lCTM9f/vKC+OY0t0f7ty5IofPmZ1JgwRK6Wta/EVp8WwUv6ikSWSfj2Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788172940; c=relaxed/simple;
	bh=UbRd+GZvfaTNmCU50y5Cr4CwzXa4ZajWfDBTZRRRQ7U=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ePfwn37bqYW+Jsy/lxsQSmB1ezkxAKFoeM5VuJmahw1ueMSCMiCjNTl452nuXrDU3c2cnSEOKnxfF3KAHl657Yt8VycKg3B8OnGMHobBoFIzwImVUhEqc8IHWBnLPslpZ5E+IlXMwqlXqJ0P0D0UYSq0WjGWIOW1ma4ZqH7wVDo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=UH2kr1Ds; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=jIZxH6vF; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="UH2kr1Ds";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="jIZxH6vF"
Received: from pps.filterd (m0170394.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V7x9YY2784818
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:17 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=smtpout1; bh=3UTtMmMO0JkhcKW49W4n6szvRjsRDSwO1M99
	Nr263K8=; b=UH2kr1DsM2GeHJSwHmG6nB5rl7IKQQI3O8kTIpcMI/DPtoK2GiIg
	cLxOu2PKpYPIupm8Re9udsy18WqDg27LBOw5wKUyHzapf8mUgZil2Cnc0+eO4g6j
	dreRcTzRXxbA6lEfTHwtJFEKyjLcRoxju+7+umOOdiiMLYbGpuT1KOeoueO6fvXK
	TiO6F4MnFqwjzJV5h8G8wY7qutroegDY9V+nml5dca7RpmBpgIdg6p3AxOG4w+Er
	fsSWpaVNXbT7wW1UpucvLWG92NQr8HLunsqIKluqFh1sSicu0+VAYM69phRsL+Ae
	U734nsBGRhZeT8mn/81yQYaYn0jDbsFLjA==
Received: from mx0a-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbt01dgk5-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:17 -0400 (EDT)
Received: from pps.filterd (m0089484.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V80NH34129968
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:17 -0400
Received: from esapsmtplv05.us.dell.com (esapsmtplv05.us.dell.com [143.166.203.153])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gd4xnjaxv-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:17 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788172937; x=1819708937;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=3UTtMmMO0JkhcKW49W4n6szvRjsRDSwO1M99Nr263K8=;
  b=jIZxH6vF0Gx34N+y0mbXfJ4Et7XQZWytFyqLONcnx2+vGlE+Zm1m8HBZ
   nFXIfUUGOq/ul8UIZ4lS+jofHKxsvH0CiRFTO96A6Rh+1sQPgaIhjaA9i
   LUTa5knYtkOrVCzDUymFq1cJ1KdwNLUcgMGVDkplHbyhjbQ+Hp4dxUkv4
   PVsabeqGRPOEI99QRxPkjdjfjPnGNX7pCAKdrVyTifMINccyA7V3OFow6
   7mGyFxHN4Es55SSUQ7vt5AfcuOoDBMv4REfKDVYE+M0sIqC6FUdTwsyPq
   i6XE2Yh42l69wNqhRqCRQW4dGBpqtpFP/FaS1AcakoTgSVrINYi1IR8ev
   Q==;
X-CSE-ConnectionGUID: 8PsxifrVRLmE2CHyUUiPdg==
X-CSE-MsgGUID: w954YceXTcaxS3pjRaAlhw==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 10:42:15 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: linux-nfs@vger.kernel.org
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH 0/3] gssd, idmapd: validate names before using them
Date: Mon, 31 Aug 2026 10:42:08 +0000
Message-ID: <20260831104211.2297-1-prabhakar.pujeri@dell.com>
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
X-Proofpoint-ORIG-GUID: R8A7nMirBr5xEBbZLNIjdnGXF_JWGcSy
X-Proofpoint-GUID: R8A7nMirBr5xEBbZLNIjdnGXF_JWGcSy
X-Authority-Analysis: v=2.4 cv=H67rBeYi c=1 sm=1 tr=0 ts=6a955a89 cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=t4Iba6VQkoKuxR139xjPXA==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=gLxAKuEMs0EQMVFiDJnH:22 a=9kqhoay-hWj4G11ZvkcA:9
 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfX4BO26fV8TxY3
 blJvHJxeHPMD59xpM5XbqyvvIJYBNVmyY+OBYzZKpQUY3w/O6luCSAW/HASgUrclXJmpIcghCdx
 8D7cox0WIrTj9HCs/43JcoiWUol4bHI=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfXyYchUVpaJClJ
 VoUTg0f3S9PjZ+hhhZKVXgVkjRTJrxOid6DwzMfyYk6R9ITzGq7xh7OAH/0POZuFfRbrvxsXy/D
 9Koid5JzshfUEqullo1osxVi7sdWwHtMSPwfqv86IsuUvvpTY0EDwombvXJi36HSGa6jNTWC4bT
 R4j4kC64BF5T9dr18RzoHUgX1ZQu/2wdVn4VWZ6vl7QK1yN3KbMGZWUIb9PsohKWEYqg4qLBA6h
 uS+bTtGPJuCn+HMYzmhNEsrEUd7DAWArld3pPBVEfkVtDKHKPbrJAuJl8c/s375q34MDtflZk7u
 nEDVQb3IoPsf4AcqxSszlfQ8nwJJz6R7QYzEU2NZFyibue6nZhq6q24+wuJDWja12xgPFVshQp1
 0pVzG+a1uEVLmGmy54XR5F2zaC/7LV+6r73Rdz2ZHfmhM6uk0yZbjm1MetAT+lP7Zmp9eaimFJ/
 qhD3gMrTEkOsD63YKdw==
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 bulkscore=0
 priorityscore=1501 spamscore=0 clxscore=1015 lowpriorityscore=0
 suspectscore=0 phishscore=0 impostorscore=0 malwarescore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310092

These fixes validate externally supplied names before treating them as C
strings.  They correct an uninitialized read in an error path, keep idmapd
inside the fixed NAMETOID field, and reject server hostnames that do not
fit in gssd's destination buffer.

The series is based on current nfs-utils master.  A fresh autotools build
and make check complete successfully; the statd integration test is skipped
when its required service environment is unavailable.

Prabhakar Pujeri (3):
  gssd: fix use of uninitialized memory in error message
  idmapd: validate NAMETOID names within their fixed-size field
  gssd: reject server hostnames that do not fit

 utils/gssd/gssd.c      | 2 +-
 utils/gssd/krb5_util.c | 9 +++++++--
 utils/idmapd/idmapd.c  | 7 +++----
 3 files changed, 11 insertions(+), 7 deletions(-)

-- 
2.55.0
