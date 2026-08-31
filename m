Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4EE4F344D99
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 10:42:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788172944; cv=none; b=QVWCJetOl77D01Nd3s4eNnNYvXPwYerYj0R67b+4TzAPFfOUKTxyuSm8CgJNm5AUs9iKcCwHQQdhG2zFU6hZFRjolkTOzUhAyNtqxkVfYusfxVggA3JR3sRyTzcMPWm6kWjahXWqjtFt/xdUCJzyLH9lTJVuo6JaLAPjdjCfRek=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788172944; c=relaxed/simple;
	bh=pVxKnyMx7g5auDuKPqHQqfOCcOiavYfV+KevlxrkAyQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EbIpTcGO3opW8T02TNr0ctp1GyMYQoQm9wtzUTK21JG8eJNoKIKPULwIum7AwQC4olQhfd3yvCqJBM+20Hhv4DD1700p9tWKlSVGECRHn/bAzesjlIoVeo3hYEKueS2Fc+hzW+mBr1FMz02xunabxcTD4BigEluKZrWxrjujUAk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=QJ+d9S7g; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=cE2eXIr/; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="QJ+d9S7g";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="cE2eXIr/"
Received: from pps.filterd (m0170390.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V7x1bd1070249
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:22 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=5gkr5NO3n5A3
	qTG42DpHm3dTr1ODWlNH3Mf6fRH6yzo=; b=QJ+d9S7gIHfjG5p0jxHlivy/bhSP
	UK/ijvTRI8dEQjkE39xFNi6OXlgE1B2QAVfP5HDbjgnqhmrUjWlVr6xoSUF+V0xM
	b3XSI5T2k/DkjrkZhw6E3z8EwPyT16sMDZ44RMFT3lls9FcxTJhOTIdWD+z+wf2T
	R1gIrDxzL7UI/6S4huvF8CSSzmGhmQ4QnAah2VxtscRN5CV3ywwwNuyNoaJB6Ihh
	QTbWIOv6IJhhr15n2TKFfKyCHUl+F17fz9DM6GvgA/EGOvUBcsqtyCzpL8Kb7GxU
	sBvpCPhVHAr7wS0uRPpvrAUMKacti4c9anGnwmHyyEWb832cRJkmvvHVoQ==
Received: from mx0a-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4gbtfwdf34-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:22 -0400 (EDT)
Received: from pps.filterd (m0089484.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V80NH64129968
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:21 -0400
Received: from esapsmtplv05.us.dell.com (esapsmtplv05.us.dell.com [143.166.203.153])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gd4xnjaxv-4
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:21 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788172941; x=1819708941;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=5gkr5NO3n5A3qTG42DpHm3dTr1ODWlNH3Mf6fRH6yzo=;
  b=cE2eXIr/Ix5kgJC/9O+Ice9wLt6gOhPmaQS+voRGuhd7wWYwZMdiVFzd
   f1sY0YekfQ4trvUiX7L8tlaotwEASkiAaYUyVbeAttmITyJ2UmrFplv1s
   l77PclKQSGVbcKct7S290ppEAmiMb5UJ23agg6q/RhLGRKmpgXw79PUr5
   aRVriD8y/osjCF4ZXqPcr4wJFAK9VfvPZUli0RMiYaoh1RjPDkfTHccwb
   mYJTyVydBqG8vPtlAmzBNW1j97/bWFKdElqYGzVjIJpPMK68jA6XFnRtq
   On/EMniObmTQ304Kbt7XQoAVEBEl/nh3h4Evh6+K63khL88llM4WAhb8F
   w==;
X-CSE-ConnectionGUID: yxym3LyCTGGi1XBf/IBN5Q==
X-CSE-MsgGUID: ySwVzOFgS+yoUKA1WlOpYQ==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 10:42:20 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: linux-nfs@vger.kernel.org
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH 3/3] gssd: reject server hostnames that do not fit
Date: Mon, 31 Aug 2026 10:42:11 +0000
Message-ID: <20260831104211.2297-4-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260831104211.2297-1-prabhakar.pujeri@dell.com>
References: <20260831104211.2297-1-prabhakar.pujeri@dell.com>
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
X-Authority-Analysis: v=2.4 cv=BdToFLt2 c=1 sm=1 tr=0 ts=6a955a8e cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=t4Iba6VQkoKuxR139xjPXA==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=sEWawkeXllE7TocFc0N_:22 a=iLNU1ar6AAAA:8
 a=XvIGpVyiO-i08diihGsA:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfX7jxg1jieaYTR
 wn3olSHgo55NmpOPQYsIRsBPbk8wtG4jb41LS/DleSveAcCOU68/hw7BEK84RmoV2eZYVb7QzJ8
 cKfBYsc413u4JBvw6FC1elVQafKhPmLAbOEyGZ4NP06uPOC2UhLbNM6407PmzUFHdOWdBjOWltB
 uHTQwZTjeCYSALMJbJqxgMZaun1ump8pSF8MlYm6Xp0ZMafCxipw5i+k0ePnKw59eO7CzAUuILz
 qo2x6CCIIfCEkVOJ2Vw+eBI0HBQ9dbKCEjSXTgtzATo9SjFg2T0nJK34DOvtOko/Qf4pRYKvfBb
 Lb4pz7322as8hfIco2KOCzW7uae4fZBmCRD1pTk69l4BIXMmGXYX2kyjJuGsYf6FVuUT/L8uwqK
 zGFazYOOY35VVum+XWwOEc6gvmm/Plwy6f43k/vbd+KATIwAJyZtuj0sbs56Fy2ZsLvVmjKu77L
 Sz288C4imBU+HpN9mYw==
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfXzJZ74M6VwOs6
 oOa5MLOUiHZaWeEz6KV1JnqFDriL982I9ksXO4VsL642kr2rNrjufet2FL4HVxb+oIFRwfvny0D
 UIXSGzDdiVShpnPyfk1+QlMJJ9XN0t8=
X-Proofpoint-GUID: hl83hYYabO6DciGaxiB6zsrzGgDNrqLb
X-Proofpoint-ORIG-GUID: hl83hYYabO6DciGaxiB6zsrzGgDNrqLb
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0
 lowpriorityscore=0 suspectscore=0 bulkscore=0 impostorscore=0
 priorityscore=1501 adultscore=0 phishscore=0 spamscore=0 clxscore=1015
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310092

find_keytab_entry() copies a hostname from the kernel upcall into a fixed
NI_MAXHOST buffer with strcpy(), allowing an overlong name to overwrite
the stack.

Use snprintf() and check its result.  Reject a truncated hostname with
ENAMETOOLONG instead of performing a keytab lookup with a different name.
The verified string also fits in the following myhostad copy.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 utils/gssd/krb5_util.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index bc063a8b..7ad67131 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -841,8 +841,13 @@ find_keytab_entry(krb5_context context, krb5_keytab kt,
 
 	/* Get full local hostname */
 	if (srchost) {
-		strcpy(myhostname, srchost);
-	        strcpy(myhostad, myhostname);
+		retval = snprintf(myhostname, sizeof(myhostname), "%s", srchost);
+		if (retval < 0 || (size_t)retval >= sizeof(myhostname)) {
+			retval = ENAMETOOLONG;
+			printerr(1, "source hostname is too long\n");
+			goto out;
+		}
+		strcpy(myhostad, myhostname);
 	} else {
 		/* Borrow myhostad for gethostname(), we need it later anyways */
 		if (gethostname(myhostad, sizeof(myhostad)-1) == -1) {
-- 
2.55.0

