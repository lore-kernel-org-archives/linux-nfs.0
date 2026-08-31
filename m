Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 872012F363F
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 10:42:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788172950; cv=none; b=R4rDg9NehTfgh1vgwiQxzsOqNl6YFz/DNY4mvHOpZMRIc5l9XdUIvMaLpJoHJeUS/pZ2rG2T/5xIhQda8AoPzDfULf9Yhm3KITVH6NueERr+Xnj9dFr4MeLJRiH6oktupJi8APZxos7JZbGvQQZdpUc1Y2KFTV2xDer+zV/IYBg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788172950; c=relaxed/simple;
	bh=ysys4/KtaQJECAl18ZFQZ0h9OAnEHlhpxxz9GYOtDZY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=r/6uIECqwewEX1zIkRK0/OTgvrfT++iPR4SwfaTJXmCtfHL/UAHP/YH/O/3qjRA+cdA2RKUYC/42lUxJ3WMwz337M5eKMa8qk7prWOPBpluBjChML1YQqGxpB/fWae8lWGgVFo4QVQ86KqjmG+z1aIx5QZchGqkB8xiJm+tJrm4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=Sl0AveAQ; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=LaVx5VGT; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="Sl0AveAQ";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="LaVx5VGT"
Received: from pps.filterd (m0170394.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V7x9YZ2784818
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=v4r3SqmUfo1V
	dl8k3CkVZHTYX8tRZLKDsYG2uGTsSGA=; b=Sl0AveAQ+MnDSzNNEFvE+ubHyX+G
	b6sIoxwJz2RDT6+1xoLY68HDOqW08qxNzCJX7GvwlWhqNGbh5y4iXgpGY2rv0hfa
	6tTHN98uqLZ4mBwQw61s0n4DD/ZD0NrBMXvMvKkF52N5FiJg4K0bBSJT6htZQGhs
	MgkUZ1stibcIuA64kKcQuz8zdXO8ae1Ztj3Y/gEB40Z1o4pAUGJVIkOQ1UMqpDV5
	QYoA0JNTOg3E7wxZg/b8yQdp4+FqJ61Scow5bgZDrj6Xc/Qr+kXRh7K3UGrt9+kw
	gYFrUeZCawZlJHBAZyAuVO6CZt3C/T/7C4buU4rOJZUOntKlDOSUdyv4sw==
Received: from mx0a-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbt01dgkj-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:28 -0400 (EDT)
Received: from pps.filterd (m0089484.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V80NH94129968
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:27 -0400
Received: from esapsmtplv04.us.dell.com (esapsmtplv04.us.dell.com [143.166.203.152])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gd4xnjb1c-2
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 06:42:27 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788172948; x=1819708948;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=v4r3SqmUfo1Vdl8k3CkVZHTYX8tRZLKDsYG2uGTsSGA=;
  b=LaVx5VGTwu6QseYS2ajSB+dMTZ4q0x9SeeFj8e3CPlj2mFMEjSNBiLnI
   zG26TJhtfXeCPQFNQ2OOH/TLDq9NoJtwDN5Rv/I5PNF+aI7S/8xsEUjJf
   Gj3Ej6xktQV3BygVYRChm6xWm1EZg8Fa+uMxttF+XN5nxWKD8k/Dr18XO
   M+rF0DTWjQJ1WyhLIitvZu9pk2qL1XdhoqO4mp3J9Kq4PkMT52rQ2LGSN
   BFUEJ2BHUP8snTybXtXyxrwMsVGBGPsEFxfQoYGXTCl94yllSnHtSayLO
   TtWp1ylpP2+9kMxxarRsnlYY7qPyk236IrxJ1vi0TBKfIA2jRB3/w8w4w
   Q==;
X-CSE-ConnectionGUID: YGlkuxB4S0S55N9Kkk4cMw==
X-CSE-MsgGUID: gpXipUKGSHylcWdd8EibNQ==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv04.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 10:42:26 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: linux-nfs@vger.kernel.org
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH 1/2] gssd: sync usage() and man page synopsis with actual options
Date: Mon, 31 Aug 2026 10:42:20 +0000
Message-ID: <20260831104221.2310-2-prabhakar.pujeri@dell.com>
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
X-Proofpoint-ORIG-GUID: ZzGNF4gno5sKmwZ5OYC-4uudPdWirpqL
X-Proofpoint-GUID: ZzGNF4gno5sKmwZ5OYC-4uudPdWirpqL
X-Authority-Analysis: v=2.4 cv=H67rBeYi c=1 sm=1 tr=0 ts=6a955a94 cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=XtseytAk/c9oG0Kwoj6KRQ==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=gLxAKuEMs0EQMVFiDJnH:22 a=iLNU1ar6AAAA:8
 a=etNdp7-QkMehrdfzxd0A:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfX2D46dZdNmi9n
 kIAGJdwm2mJF1AQqM8VpTjOmfSzyklVUXdDuh1TvMD1GincQxti0GO9cxN2gnjeY1yZAXMw/iog
 OCQ28nsECSPOCS1olsADAuRZwbrmvug=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA5MiBTYWx0ZWRfX9a3HMM1P4YIT
 Hp+YKeu1h5Lw/ps0qx3QGfoDaq5VDqd7DfVbh3XOPT86WHbRpt25UCmjatfFrZisCAun2i7iFoD
 Brd1a6Vwwm1B27MuRJymTzOmd1mevsLITuSiqWO6WS2EeioohhnrumZMDE3uJXNpGBwNVM5aWLU
 YcNvTFX5KdKnSzghPhHTZRCPuJfTGgWiZeV+5xiOMdNrAXYLp+6vLZWNGptKh7C1rKRKlxO8ckA
 RBG/6zWQ+4jWdjvbRAf7HbttHI6l8XKxhwQfeSzKW+KGyFYK9CN2l4YzROvAZE7vBc/1R7xM56K
 yXB4yu5K4dDsNAu8uYCN0RuouyiSIBckgrhaLGpb+PcOFpvSrrVYagqYqZLfSbf7fHKbP55S2eG
 e6AOeSLWT4CYyqfjbbN5guqwniZaL27nSvXDiSc4FnpVrX0tCO1X3DJCWwAc76WcCNp00MWPbnY
 a009UW2IxdLa3rg23Qg==
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 bulkscore=0
 priorityscore=1501 spamscore=0 clxscore=1015 lowpriorityscore=0
 suspectscore=0 phishscore=0 impostorscore=0 malwarescore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310092

The getopt string no longer contains 'l', so the '-l' advertised by
usage() and the rpc.gssd(8) synopsis only earns users an "invalid
option".  Conversely, the -T rpc-timeout option exists but was never
added to usage().

Drop the stale -l from both places and document -T.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 utils/gssd/gssd.c   | 2 +-
 utils/gssd/gssd.man | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index a0a65014..a5165c0a 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -1023,7 +1023,7 @@ sig_die(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm] [-D] [-H] [-U upcall timeout] [-C]\n",
+	fprintf(stderr, "usage: %s [-f] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-T rpc-timeout] [-R preferred realm] [-D] [-H] [-U upcall timeout] [-C]\n",
 		progname);
 	exit(1);
 }
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 57ad30cf..73ae02ca 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -8,7 +8,7 @@
 rpc.gssd \- RPCSEC_GSS daemon
 .SH SYNOPSIS
 .B rpc.gssd
-.RB [ \-DfMnlvrHC ]
+.RB [ \-DfMnvrHC ]
 .RB [ \-k
 .IR keytab ]
 .RB [ \-p
-- 
2.55.0

