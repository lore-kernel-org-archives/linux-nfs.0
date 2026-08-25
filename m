Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EEE013CF026
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 06:52:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787640748; cv=none; b=Pr9VA/ds1oYF8wHw8nKhjE6yl/8VNAF5sW9ZZnTnhGCIc3iO+/ZmPX0mozwEgERkSR1bKRoq3KcU08PHoZwKIEjJ+St9TJNrBdcP0LBcQb4HZcKGCOSaJeu7yxMcrHAzMQof6kC/OMvlfp+lhiveUOoFTZwb/1P8m8T9p2Y6ZZo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787640748; c=relaxed/simple;
	bh=BZn0+lbonINwRuTqplIdZTT8kFG1/zNV5esrAHjRVzE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=q5hxCuRZsxVD/PmJRhuL1/KhiC7ezOg71Kflq1zkrsuv6DJ0qMbSeErC3g9/f+5WbEupOCI5zsSp0Qd5cM+bDuzrIPbuRN0dlxwowBvS7XiEcs6qqGKfYXlN4Z+6ua3siauEwdzfVLj+pbDUyxECzbEL27OUPWBIa9N/tPk0awY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=xtSppVqJ; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=KgATV44F; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="xtSppVqJ";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="KgATV44F"
Received: from pps.filterd (m0170395.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P2RBnO1437932
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:25 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=PD+fqKPqekAN
	dWQH2/CFr8Q2X2T73rb/GhabiXvTquw=; b=xtSppVqJu8vAuASKFUCv1Y3PRiAx
	M7PKsHeODkYJGkZOhcTr/31cya9S5sjoJMM1MsXTgHEW0oFv/DXt3wMyvzZfhy/b
	1RcZqF6EqOBe2vqMvBCf6MpCaf2HKZKLSQ3Dib1dJr4tBTGsxfmq06c7l2bDiw2L
	Gmyloqpe41fWucdL15S1Joe7rEWFW00NfY4BvK/QatbXKehAy2UKJYR8W51U8D9U
	aD5KYYAYHok+p8lOseDHryvRPBuRuoMtbInh2+lYyd1Pg276SzrsUE7mw12EWxna
	OLvkhF1pSO1+cKEjxOqOjZXS7r8VXiL7/yoW4Y40lUymoP5WN++rk4d2HQ==
Received: from mx0b-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4g78egstf2-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:25 -0400 (EDT)
Received: from pps.filterd (m0144104.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P4bBji889540
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:25 -0400
Received: from esapsmtplv08.us.dell.com (esapsmtplv08.us.dell.com [143.166.203.145])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4g946b9ahw-2
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:25 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787640745; x=1819176745;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=PD+fqKPqekANdWQH2/CFr8Q2X2T73rb/GhabiXvTquw=;
  b=KgATV44F/BHTquyWlCxY4l1igriK2JKdx6GdSfjR+YYEo79E/msnvua7
   OLcVxuKdnAFz/0ZIhfV7JMZfALiwC5cgYt9kxfyxGGdWgo2M/TFTzLPlQ
   D3tJnSdrxMZn4+6BHD/E/eTQ/bA1/slaLPst0ECxWhRlJ1czm1lR+6l5N
   +YOwH37h6F6c8zyYXukQ/gnSUD3c/Lpe4JkMzgmMe8KOIUClYOb9OZsQs
   esj/nLogaIP4bKkjw9DS9c0H0SYiL8b2Cu0o/C+UTTePbV9H93pGOhnNt
   LYrxJSIQXiFVtK81awtyZ9mDzR2hmIyFFVOGE0JBQZxZ7yVLED1kNHpZc
   Q==;
X-CSE-ConnectionGUID: 5/5kxIQaSXSrStFX+FDSGA==
X-CSE-MsgGUID: nN5qIhw+S/CDEFEiZV6b4g==
X-LoopCount0: from 10.94.13.48
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.13.48])
  by esapsmtplv08.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 25 Aug 2026 06:52:23 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: steved@redhat.com
Cc: cel@kernel.org, jlayton@kernel.org, linux-nfs@vger.kernel.org,
        Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v1 1/3] nfsdctl: report NFSv4 grace state
Date: Tue, 25 Aug 2026 06:52:13 +0000
Message-ID: <ae1cdff0e22ee34415b416adf91c40976cafdd82.1787639206.git.prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787639206.git.prabhakar.pujeri@dell.com>
References: <cover.1787639206.git.prabhakar.pujeri@dell.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-25_01,2026-08-24_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 phishscore=0 suspectscore=0 malwarescore=0 impostorscore=0 adultscore=0
 clxscore=1015 bulkscore=0 lowpriorityscore=0 spamscore=0 priorityscore=1501
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608250056
X-Proofpoint-ORIG-GUID: Edby74kSC9RkI_ftvYpaUJzaEGiLooZ7
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX7/ea15jOTySe
 LBhmB0A8sbmkCFLrbXxcw1iHMZMKei4VHQizjoD/pm3fA97zCT9BrvF+fes2amjPKz1Oh54US9H
 a7IAnEDlaAaS+7JlnFG2gvJdR3ee50U=
X-Proofpoint-GUID: Edby74kSC9RkI_ftvYpaUJzaEGiLooZ7
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX2hfft13cJpJl
 Pg/XTX+shUi0SM6dUqqGuU7NNo7b3v8vB1ilCBhWiQXTH02i/+Npxpu2emeMPpVAUNynzS7K3yD
 pwpwEoA8rWdw1M2TnbgaL2Es9mlWB3XmRjfNFeImTDJRb4kGaOvk/tobCJVajJdDb4Vaby1/trJ
 4xulu5Er00czQyFRiHPUrENpCviyKms20U7c983CBef1L09uTb7Xv9R91ONbySdXLWj+LT1oJPf
 ICU7vq4jz+zGlwU8ljzJK1Rr+ReLxj5LoTUhKwoALqxA58TkiFN1ngFzob+hMLl4uvU0HvPnhue
 XNEvz8Rc0kbrT8flEMRaY/+lZfaTquwCMGxkRsqjdyJN5wTbEzJ7Yqd1t6DGatwsYAPWsrgSVK9
 VvhxD9HGyd3eGNzN1SQkb7KHVo6bmTKcDp2MSuxtTE/lDUf/j/9+/VzNH1VL4qILxBRoThb+dxS
 aoT27xOjd29CJrW3EpQ==
X-Authority-Analysis: v=2.4 cv=Z6Hc2nRA c=1 sm=1 tr=0 ts=6a8d3ba9 cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=7aFXbidJGpJUqALx8qt4zQ==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=Qy6CKLcU0MZ4grw4BCWD:22 a=iLNU1ar6AAAA:8
 a=UR6792PDAWLgY2ryifgA:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0
 clxscore=1015 priorityscore=1501 impostorscore=0 phishscore=0 bulkscore=0
 malwarescore=0 lowpriorityscore=0 adultscore=0 spamscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608250057

The threads command reports the server's thread configuration, but an
operator also needs to know whether the NFSv4 server is accepting normal
state operations or only recovery requests.

Display the kernel's new in-grace value when the attribute is present.
Checking its presence prevents a new nfsdctl from reporting an older
kernel's lack of the attribute as "no".

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 configure.ac                   | 2 +-
 support/include/nfsd_netlink.h | 1 +
 utils/nfsdctl/nfsdctl.8        | 3 ++-
 utils/nfsdctl/nfsdctl.adoc     | 3 ++-
 utils/nfsdctl/nfsdctl.c        | 8 ++++++++
 5 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index 2ce1e12..96aa82c 100644
--- a/configure.ac
+++ b/configure.ac
@@ -259,7 +259,7 @@ AC_CHECK_HEADERS(linux/nfsd_netlink.h)
 
 # ensure the system netlink headers have the latest features
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/nfsd_netlink.h>]],
-			                   [[int foo = NFSD_CMD_SERVER_STATS_GET;]])],
+			                   [[int foo = NFSD_A_SERVER_IN_GRACE;]])],
 			   [AC_DEFINE([USE_SYSTEM_NFSD_NETLINK_H], 1,
 				      ["Use system's linux/nfsd_netlink.h"])])
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/lockd_netlink.h>]],
diff --git a/support/include/nfsd_netlink.h b/support/include/nfsd_netlink.h
index 87da1d0..e1fc2db 100644
--- a/support/include/nfsd_netlink.h
+++ b/support/include/nfsd_netlink.h
@@ -84,6 +84,7 @@ enum {
 	NFSD_A_SERVER_SCOPE,
 	NFSD_A_SERVER_MIN_THREADS,
 	NFSD_A_SERVER_FH_KEY,
+	NFSD_A_SERVER_IN_GRACE,
 
 	__NFSD_A_SERVER_MAX,
 	NFSD_A_SERVER_MAX = (__NFSD_A_SERVER_MAX - 1)
diff --git a/utils/nfsdctl/nfsdctl.8 b/utils/nfsdctl/nfsdctl.8
index 1f526e7..58d5cd9 100644
--- a/utils/nfsdctl/nfsdctl.8
+++ b/utils/nfsdctl/nfsdctl.8
@@ -144,7 +144,8 @@ takes no arguments.
 Get/set the number of running nfsd threads in each pool. Pass a list of
 integers to change the currently active number of threads. Passing it a
 value of 0 will shut down the NFS server. Run this without arguments to
-get the current number of running threads in each pool.
+get the current number of running threads in each pool and whether the
+NFSv4 server is in its recovery grace period.
 .RE
 .sp
 .if n .RS 4
diff --git a/utils/nfsdctl/nfsdctl.adoc b/utils/nfsdctl/nfsdctl.adoc
index e85348e..7e03933 100644
--- a/utils/nfsdctl/nfsdctl.adoc
+++ b/utils/nfsdctl/nfsdctl.adoc
@@ -82,7 +82,8 @@ Each subcommand can also accept its own set of options and arguments. The
   Get/set the number of running nfsd threads in each pool. Pass a list of
   integers to change the currently active number of threads. Passing it a
   value of 0 will shut down the NFS server. Run this without arguments to
-  get the current number of running threads in each pool.
+  get the current number of running threads in each pool and whether the
+  NFSv4 server is in its recovery grace period.
 
 [source,bash]
 ----
diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index c712674..2b1faef 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -311,6 +311,8 @@ static void parse_threads_get(struct genlmsghdr *gnlh)
 	struct nlattr *attr;
 	int rem, pools = 0, i = 0;
 	uint32_t *pool_threads = NULL;
+	bool in_grace = false;
+	bool have_in_grace = false;
 
 	nla_for_each_attr(attr, genlmsg_attrdata(gnlh, 0),
 			  genlmsg_attrlen(gnlh, 0), rem)
@@ -337,6 +339,10 @@ static void parse_threads_get(struct genlmsghdr *gnlh)
 		case NFSD_A_SERVER_MIN_THREADS:
 			printf("min-threads: %u\n", nla_get_u32(attr));
 			break;
+		case NFSD_A_SERVER_IN_GRACE:
+			in_grace = nla_get_u8(attr);
+			have_in_grace = true;
+			break;
 		default:
 			break;
 		}
@@ -346,6 +352,8 @@ static void parse_threads_get(struct genlmsghdr *gnlh)
 	for (i = 0; i < pools; ++i)
 		printf(" %d", pool_threads[i]);
 	putchar('\n');
+	if (have_in_grace)
+		printf("in-grace: %s\n", in_grace ? "yes" : "no");
 }
 
 static void parse_pool_mode_get(struct genlmsghdr *gnlh)
-- 
2.54.0

