Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8BD930FF08
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 10:42:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788172941; cv=none; b=jgsvBnwr+YxDpp2SL9I5F+ZtjcBsIUhx5MqWGLiUZlkacFZmD/kMXBfzPwmZ2QVDwW8zYljUSy54sgq7FKv+ZP0npXf2YnCVD9KVwUfFKq7MeSNNTFnhpsWX5OT6fgguCu9j1lzeMzRYZSn91laq9OApFObC7e/1ZRBme3CQPnI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788172941; c=relaxed/simple;
	bh=g+TBhOTqKTZuWQc0ggzJm/ojKxe77dcWgZtZje+OZXw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tyxyQsJwFRuUcF3Yrsv/BED/K7hvxGwq9o5MpvsWyFeS41Z4SalqzfoJEqNyeGwXtdtRUBEkZrMJ7dh0qnwEPX196ERI6Yc2RkgOIsMlZiRWipa3BZ1Hx+PZ2EYKe3WhJi3nxWzh+a7i1Uqh6iU5B1nASD/CCLBYNq/vV/1Mjbs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=a482Xtjc; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=KLpBDKsP; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="a482Xtjc";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="KLpBDKsP"
Received: from pps.filterd (m0170397.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V7xPMd2856575
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=bFjKSbIe/dNr
	HTbT5iWoT2YJQRemqm5pNvMJuajDVnI=; b=a482XtjcfJIf2xXhtfFC3k3OZqcb
	Ek8c3QgD/3RwXKGn35ym+mItuFnKyWmlXIp2RUfwcFkB5+Ju3U1ExS6fezdtkK3G
	Zy6aINimkE4N3cSBjDvEyEnk2obql9TSNZQcPRHxmAE+JP6pPmlkn5E1pYTvb0dO
	ZEGnB1aCkdK0DTCMYOuthzhatf6xqNXd7oRSOj9aLXHxEhQzAJw1bbP1ztuODcf6
	XSpv47etMYCieqkd9X8IC36uBj5UIXmMe0K8WdiOHvWnFjUrgGM47cNbbnjAlCDK
	tfYG4jenAXLSLY6nHXL1oGF90adCmW/j2nKVroZjEjB5x7lae3anF6i+rg==
Received: from mx0a-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbrgq5pf1-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:18 -0400 (EDT)
Received: from pps.filterd (m0089484.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V80NH44129968
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:18 -0400
Received: from esapsmtplv05.us.dell.com (esapsmtplv05.us.dell.com [143.166.203.153])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gd4xnjaxv-2
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:18 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788172938; x=1819708938;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=bFjKSbIe/dNrHTbT5iWoT2YJQRemqm5pNvMJuajDVnI=;
  b=KLpBDKsPNp5OLae0w8T/ValnaCAbA/0d2bQi2yjFm8FJL56wNA5siwFy
   hRG/Rqn/3cZCUiCzB4YoGK1a8dSbeAaPIwbRM5WWgdqdtFlD51iO3Ql4Y
   W3dEy7Hg2G3DF2u/6a4PW28xdXp1tUzlvjsxlFLlMStYpYkoRMK4OsIYb
   uqn04iM4yHLmOqYfnlWXYlicPLiPwFQsTEG++lLdFLieXl4IfBkfcrYgH
   O7V1FsTQr7wKwwqDo3hNyJ45qxhQWr9B8VKRMXER9R/96vOKu6tXHZYBK
   vjUIA0OGh8TQmQ/HfzobihnyJouBd4FghKTfCbQntXoh/I8+YIrzoS/5J
   A==;
X-CSE-ConnectionGUID: NY9ACZQcTNeX5qVlsZxuYQ==
X-CSE-MsgGUID: AVtMiVY5RcyuJYkqjAx8Xw==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 10:42:17 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: linux-nfs@vger.kernel.org
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH 1/3] gssd: fix use of uninitialized memory in error message
Date: Mon, 31 Aug 2026 10:42:09 +0000
Message-ID: <20260831104211.2297-2-prabhakar.pujeri@dell.com>
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
X-Proofpoint-GUID: ZeNN0pQxpyfpdhJL0TwFVkBRY2he_zGg
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfXwnR7AQHzwdFF
 emdkaIM9yb4gNSr2+uhD6A8+fZPYkhyz0YehnUUOBY/MwJxmEaihKtCjtfaXswvbFTMigxRcF3K
 mxogTpTw7dVa+YEdN7w07nDIRyPqLFVNY7kTO9CeAo2u0eaBqOK7CQTVbaafYLQyNao0JqhiFec
 VG16TU+BHAACMNE92W4OfskUbn8sn+P5tK/GLhd+T3gRxjWzBUmZKgC469xBIiVfyTMKd+H80pb
 K7FUAojskeZOtS7KoL7Ap/QYZBTQSzAF4cUF/Pd+oY7uwcGvoCRE0yJbkNAGKkDGfRjxoiBOqYm
 8dp9XwXExYYiXqO1UWRtz2zwax3YMs3xVGbhcKJ7YR7z3moiHJPQniQilPyKT26oa3YMrs7vntd
 f1MZ6IJhHd2fvh5b60j23U+w4B/XvjCH4gITD2C6EHJK/hAx5LOGYzBmE3i3C3POqiilzESgQof
 9NcNvDOqlAFC/m4CBNA==
X-Proofpoint-ORIG-GUID: ZeNN0pQxpyfpdhJL0TwFVkBRY2he_zGg
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfXxVn+b/hLUYIu
 SOtC9HYt3G8Kum94NX7seWTP3u3jLGM0tPTYxoDJoshTf+cCvCWQ6U0bF5P9FSvdF/9kItGJAfA
 SbF+D3kLYX/ywLA3CEhEy1EVBLPFiLs=
X-Authority-Analysis: v=2.4 cv=IoQutr/g c=1 sm=1 tr=0 ts=6a955a8a cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=t4Iba6VQkoKuxR139xjPXA==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=U3ti1ie9CgboSd2qXsAw:22 a=iLNU1ar6AAAA:8
 a=LmFJ3v4uqnwa1tlcsA4A:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0
 spamscore=0 phishscore=0 clxscore=1015 impostorscore=0 suspectscore=0
 adultscore=0 bulkscore=0 lowpriorityscore=0 priorityscore=1501
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310092

gssd_get_topdir() prints tdi->name in the inotify_add_watch() error
path, but that flexible array member is only filled in by the strcpy()
after the call.  The message ends up dumping uninitialized heap memory
and can even read past the allocation if no NUL byte is nearby.

Print the name argument passed in by the caller instead; it is exactly
the directory the watch was being added for.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 utils/gssd/gssd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index bad92321..a0a65014 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -769,7 +769,7 @@ gssd_get_topdir(const char *name)
 	tdi->wd = inotify_add_watch(inotify_fd, name, IN_CREATE);
 	if (tdi->wd < 0) {
 		printerr(0, "ERROR: %s: inotify_add_watch failed for top dir %s: %s\n",
-			 __FUNCTION__, tdi->name, strerror(errno));
+			 __FUNCTION__, name, strerror(errno));
 		free(tdi);
 		return NULL;
 	}
-- 
2.55.0

