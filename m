Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 923252F363F
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 10:42:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788172942; cv=none; b=tK7SuK5v5yXcSP0Di1PZSmYf8Da9YEV6HPjxtZOkEhwWZceE/G4kRfI928/X+hLWAo/hzCqqFD5ExwC6CjqEofegdwzzGzO5zUGEMakdwN2bN9Ant6Ehvr9f04VeONT00vJE0bPJAFwilTC3ooxgjssIKWrAMNEKKZUwZEizZCI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788172942; c=relaxed/simple;
	bh=XGdG62evDnDOCDyTLdLsQVc4oJaCzd9B2duGNUQNj+U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hf6/klMjJPlP6Ws+nnkt2a3EYG0Qn3hiJiEDueO3FkDLXl7V2BB5hWclcprmnu5xM90uGAf7IjmW9xPHBYavK43rfvnhjxiWAJpuo6cYNrhliemyee9GgWzUIg4wFphczqKT0dR/IVDfx+JwjH1dhRMd4RIqZ8Ek5qGkbc6Yojs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=fmMTdS9s; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=QXmrNWOv; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="fmMTdS9s";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="QXmrNWOv"
Received: from pps.filterd (m0170393.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V7wtR72648192
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=q0LVYO3cn/Xf
	fbiLEOi82Q7X0oKIr7ECvy5J92K93xY=; b=fmMTdS9st/a0p8UEa31otlkoFFn6
	Iy/bCfx8E5/sHXQMciWf46KdMjEOlcrlPMbzZBOQBIWRcuq/zTCRL0uVgZ0xTFhI
	BHwnb3s1DWawk7gRW1yg92eiAshjHdck05OvZYIlfWdHZLs5OMjLxZdobyE2nNye
	41OTQ3aW+jXoe94yVgcLunlGrcXJ1tw54+UGsQ18HO1wbBCIWb+MyNCpPNT19AG9
	A47VpxcndNOQqG7x3Bhs2iZD9yLLElCIdV8f59tOv6bAnsoeLwLdWi7+yFyq/mu0
	q81bKSDKgPuC6uH60thl8WHsQy5wv/c7KsZC3G01Kw+MPmKlFfarxVLWKA==
Received: from mx0a-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4gbtrfwd9s-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:20 -0400 (EDT)
Received: from pps.filterd (m0089484.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V80NH54129968
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:19 -0400
Received: from esapsmtplv05.us.dell.com (esapsmtplv05.us.dell.com [143.166.203.153])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gd4xnjaxv-3
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:19 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788172940; x=1819708940;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=q0LVYO3cn/XffbiLEOi82Q7X0oKIr7ECvy5J92K93xY=;
  b=QXmrNWOviQ6GwMS0I4Mr0lp+0zaARoNk/5sSneHd4tnydQ5pB1dTz1O1
   /VPq68v5d7n8eOFxZKj4tj/DihuUO70IbNdUrL4s7zB5llJjcFtXMfPB3
   yHt0mcWgkYQeG6S5M7lWQR3apkrDqbHeKe2KYLkdDZTaEeU2drs9gDzmU
   G2ITDZTc8hRcg7I1oGdo1zPy1Zz/EZhqjNnpDouWmadK3KAJnnkMkr2Un
   LPLVL2T+hM2Zjsi3t9u9iUDNwDI2FCV17a67CA/SyIJN4UFFFufV1EABT
   8SviLUSxbTQF4lWqoq0UjsTAt3+QXHACicZyJu5lzcrp5tY9qImtfOL4W
   w==;
X-CSE-ConnectionGUID: WOYA6+YzTdiHJVwZHZhL8w==
X-CSE-MsgGUID: MV/8sziSSXiGVKUoR8YUuw==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 10:42:18 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: linux-nfs@vger.kernel.org
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH 2/3] idmapd: validate NAMETOID names within their fixed-size field
Date: Mon, 31 Aug 2026 10:42:10 +0000
Message-ID: <20260831104211.2297-3-prabhakar.pujeri@dell.com>
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
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfX57KFR6rs1KTo
 vXW/mHJuggnebRvBjJQRSi0qhIneczIokjbX43xiAHcBTfN7wvZXVbQyYOI8ApXHo8M1LY42Ccn
 nvqcG4vGyPte9K688bmy25rY71KSdk3qaz6ioArRzKdefN2Gc7gtesgvv4eHRTMjXqMal8XKcuE
 XbIBclbApAN9tNWxRReQpBxoVJaCJMGBF/Mvp//aauh8K1JGkk0nNke0Za9yLt22ZZ2nDqd71MD
 X27/NsdlAZcSg4zMSG81IsBR7uxoTAMjhrq/WYt2c8gzLmhvL6iftcAAUT+AlkQVqK7EHehnNXD
 nvIvp+9PqFNeBjFTSLJXuB7ED7r6dvbfL50i11tyJA21NL5I8RSrDWVp7MFJh/vTGk15NGY074y
 2umtyX+tnQvDypbw/Zr9smcerm2tL0dPrvyoE7esVaXPG9xxT78zLIcZxIV5SnXcBL5PAUkOH1Q
 LvxDZTVg6IJRYhCAMKQ==
X-Authority-Analysis: v=2.4 cv=SeXHsPRu c=1 sm=1 tr=0 ts=6a955a8c cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=t4Iba6VQkoKuxR139xjPXA==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=2Lpba0WeoN7BYVdwMO11:22 a=iLNU1ar6AAAA:8
 a=84mBGd5ajIh6WywAL50A:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-GUID: Zu8Jxe6GdZIkf0-XToKVdNEKEHt6v1HZ
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfX/N/g/QFvdypw
 K/tfwILnE6F3lnGT9nYfuzGgRy9iCvlu3yDtY5MyB9+uiPk/C68Xi8JPvlMAU9UKvgS6DelGM8a
 9VApf9+y/9SdfYIfk6xrGTpbdBiU35o=
X-Proofpoint-ORIG-GUID: Zu8Jxe6GdZIkf0-XToKVdNEKEHt6v1HZ
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 lowpriorityscore=0 malwarescore=0 clxscore=1015 priorityscore=1501
 suspectscore=0 adultscore=0 phishscore=0 impostorscore=0 spamscore=0
 bulkscore=0 classifier=typeunknown authscore=0 authtc= authcc= route=outbound
 adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608310092

imconv() limits len to IDMAP_NAMESZ - 1 and then reads
im_name[len + 1].  An unterminated name makes this read beyond im_name,
while a terminated name can be rejected based on the unrelated byte after
its NUL character.

Use strnlen() to require a terminator within im_name.  Mark an
unterminated request as invalid before returning it to the kernel.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 utils/idmapd/idmapd.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 5231f56d..c41ae1f0 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -767,8 +767,6 @@ nfsdcb(int UNUSED(fd), short which, void *data)
 static void
 imconv(struct idmap_client *ic, struct idmap_msg *im)
 {
-	u_int32_t len;
-
 	switch (im->im_conv) {
 	case IDMAP_CONV_IDTONAME:
 		idtonameres(im);
@@ -779,10 +777,11 @@ imconv(struct idmap_client *ic, struct idmap_msg *im)
 			    im->im_id, im->im_name);
 		break;
 	case IDMAP_CONV_NAMETOID:
-		len = strnlen(im->im_name, IDMAP_NAMESZ - 1);
 		/* Check for NULL termination just to be careful */
-		if (im->im_name[len+1] != '\0')
+		if (strnlen(im->im_name, IDMAP_NAMESZ) == IDMAP_NAMESZ) {
+			im->im_status |= IDMAP_STATUS_INVALIDMSG;
 			return;
+		}
 		nametoidres(im);
 		if (verbose > 1)
 			xlog_warn("%s %s: (%s) name \"%s\" -> id \"%d\"",
-- 
2.55.0

