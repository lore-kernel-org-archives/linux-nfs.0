Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF4757E792;
	Sun, 23 Aug 2026 11:43:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787485394; cv=none; b=fXAoUgdRTqIGx6tYr1El/hpX6HXDsMr8eHSqdTE+Ls/WyV5t1ToA5U/EktKA3kumqPV7U8iiAqZEug8t6D+D+1P04ZpFdOetgiZ1tnM/3fpHqDmWIE6nDxGQsqd73B7usRu/Rr3TQiUbq8zuhz/4+hOfxa0znKiNRWZsXq3+gCg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787485394; c=relaxed/simple;
	bh=KeLPilb3CjKp2bgd3ia8SlPD6Pu3zciG+ibulvSu1Jo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pfVQNk7SkgfcnRWwzYHoZ/tJi+P/+3NA6c9IeigrFNj3ABkoHrJWLy0mteyoKE2pCvrSbCdbriiRVyGwGjwDvhWdTChtCfvjuejklXJfNR+i0nZGat8Zh96fXcRwmAA9O/RLfvxQNLvIdfeuEz+fnrAE80DWUyYpcWT/kJLGRSA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=MveLJHFF; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=qkBygdcR; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="MveLJHFF";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="qkBygdcR"
Received: from pps.filterd (m0170392.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NA9RUP316059;
	Sun, 23 Aug 2026 07:43:06 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=u3SC7M7vaxBx
	QLrtLqS0QHIyGtg400DJe1A2GuGT6hg=; b=MveLJHFFWNnZ3V7AD67wEXbQ2dIC
	NOqsRpQ0doNrwyTveNC3WNq0mOrv+RHRg8nvnAQgOCNwHHtoyqZr8yH938PseQXe
	nj6SYXegjtLeCwyBbL08xrTc0VWEV/PxgRqxKgv8Lkzivz7T90zMG5zrrvlkQJBK
	C9g69xNVNNiuX0kfKRCHa8kq0DikVJWzcUifIuV/A+4ejstEBSqNFuBhrBSx4ULp
	snbpS2P5AQTMeflfBYIAtLaFr5CQLnNWWjx0Ctxf0SIFOBauQRDT85NOPtuTMbMi
	T2pSLde8oX2cGEgMw5G9GMeOBlTi9syNZRGXluHjqqq/JuB4kitEiweo4w==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4g76xctjsb-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Sun, 23 Aug 2026 07:43:06 -0400 (EDT)
Received: from pps.filterd (m0142693.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NAA2RT370768;
	Sun, 23 Aug 2026 07:43:06 -0400
Received: from esapsmtpat01.us.dell.com (esapsmtpat01.us.dell.com [143.166.211.146])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4g7wevhp69-2
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Sun, 23 Aug 2026 07:43:05 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787485386; x=1819021386;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=u3SC7M7vaxBxQLrtLqS0QHIyGtg400DJe1A2GuGT6hg=;
  b=qkBygdcRAGcPnbv0+nH1HdITq1tofQT21qsyD3OuExTQLLoa6TTSKy1a
   i4HszVEFDNQBYU9tzM5SJricHzivlwyjq9qDIJXShF7R3HDxV/p2gF439
   5Igzj48tOW9HrhgoV76tVAzfr30+mR2nmxDSTLZb9D0m1FfM09tITaFCC
   hTuLhAub1nHdM9qtz/wJL5FcyGcsRUdt7Iw4ak6jywNLi5lHVdjfhJbry
   /GjhK5GfmrMEl4QmVgLY7oT2ze6dP5Kmm5q+Xp8TnyyjkiD6BrBUab7iD
   3yJoBeswHx3AIY3HNhKZWH0t9RwknUemrv7wKn6/sFp7+kWtbKLxpNWnA
   g==;
X-CSE-ConnectionGUID: 2jQa3kHbQGCAFi7aDTKn/w==
X-CSE-MsgGUID: /y4oOkebTaKXGJKfIP7jzg==
X-LoopCount0: from 10.17.189.166
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from unknown (HELO W-96J1TH4.blr.amer.dell.com) ([10.17.189.166])
  by esapsmtpat01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 23 Aug 2026 11:43:03 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        stable@vger.kernel.org
Subject: [PATCH 1/4] NFS: validate pNFS data server port octets
Date: Sun, 23 Aug 2026 11:42:41 +0000
Message-ID: <20260823114244.3883-2-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260823114244.3883-1-prabhakar.pujeri@dell.com>
References: <20260823114244.3883-1-prabhakar.pujeri@dell.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-23_04,2026-08-21_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 impostorscore=0 adultscore=0 clxscore=1011 lowpriorityscore=0 bulkscore=0
 priorityscore=1501 malwarescore=0 suspectscore=0 spamscore=0 phishscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608230106
X-Proofpoint-GUID: U5ED2HErl4OkRJ9Lq7STxf9t1T_vGZUc
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODIzMDEwNiBTYWx0ZWRfXz2h5IvvTnLWA
 sk3zoI17bMqOIpCjmceIYwAzNTpZYpbzbKu/09umex4d6NjeJMs3ovSv/cr4Kgk+WvcSBjFJPvt
 9eg+Yxxff9dazgW3N3aW98uoc2UzkGZkXIjG8x1h/n1HPZdaUp3gkRUtzhf1wGKawkBOOzn7n2e
 eW/7QSwCzVcfJuHrerB2p7+ihO3mjglOxoFohAG5dGDdWPWdQsXNV+XiAiWG6nFNS89/5jWhVCi
 7YoC0xzzWY3QA4bIwgl8uNw5p0gZrBokbOEHDDEgg0XuiHAThseMCPBgONhUDAZ7Gku/I1GUB3i
 WQ3KAKo+150kIKdC3b5CX+uNV/UJQ+jv3h/zmpMsUACxP5WKqh2gFvGfkKd3aVWj5cRhOZ4jqxO
 oTQzw1GsQLFOhyZc2M1Y4Rrvzl5Nh+gxkeooGSUUmqMWz8Ppb8Mbfdd+3Gv8zNvHuBWyuUv9oMs
 dOTM+z5HxOjmMVDRufA==
X-Proofpoint-ORIG-GUID: U5ED2HErl4OkRJ9Lq7STxf9t1T_vGZUc
X-Authority-Analysis: v=2.4 cv=A79c+aWG c=1 sm=1 tr=0 ts=6a8adcca cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=MDsIxxkBee3CUfGUG3hQZw==:17
 a=b3DhMmMkJVNBYjixYE3i3TbOsPs=:19 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=m3zZTHMLHbwB7Lmtoed2:22
 a=VwQbUJbxAAAA:8 a=iLNU1ar6AAAA:8 a=VZJtwKKvAAAA:8 a=NxIssioeBxkeEXFklJ4A:9
 a=gbU3OgOOxF9bX48Letew:22 a=vzdIw8kzLcqZOxdJCU6L:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODIzMDEwNiBTYWx0ZWRfX3pJ1xuqp3kz+
 oYTL8Fi2o9YV8ocxT235ZdOTyQC5BGRrC70HCLr6Eng7+QungN+XVD88/t1X/o63qP6CSfujmxc
 qJ6G5I8wrx7z9TV6ARDLY6c26y+22To=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 priorityscore=1501 clxscore=1011 suspectscore=0 lowpriorityscore=0
 malwarescore=0 bulkscore=0 impostorscore=0 phishscore=0 adultscore=0
 spamscore=0 classifier=typeunknown authscore=0 authtc= authcc= route=outbound
 adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608230106

nfs4_decode_mp_ds_addr() parses the two decimal port octets in a
server-provided universal address with an unchecked sscanf(). A missing
or non-numeric field leaves part of the temporary array uninitialized,
while values outside the octet range are silently folded into the
resulting port.

Split the two port fields at their delimiters and parse each with
kstrtou8(). This rejects missing fields, trailing garbage, integer
overflow, and values outside 0 through 255 before constructing the data
server socket address.

Fixes: 6b7f3cf96364 ("nfs41: pull decode_ds_addr from file layout to generic pnfs")
Cc: stable@vger.kernel.org
Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 fs/nfs/pnfs_nfs.c | 47 ++++++++++++++++++++++++++++-------------------
 1 file changed, 28 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index b539e1a44d26..0c8c50eab4ad 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -8,6 +8,7 @@
  * Tom Haynes <loghyr@primarydata.com>
  */
 
+#include <linux/ctype.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 #include <linux/sunrpc/addr.h>
@@ -1059,6 +1060,19 @@ int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 }
 EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_connect);
 
+static int
+nfs4_parse_port_octet(const char *str, u8 *port)
+{
+	const char *p;
+
+	if (!*str)
+		return -EINVAL;
+	for (p = str; *p; p++)
+		if (!isdigit(*p))
+			return -EINVAL;
+	return kstrtou8(str, 10, port);
+}
+
 /*
  * Currently only supports ipv4, ipv6 and one multi-path address.
  */
@@ -1066,10 +1080,10 @@ struct nfs4_pnfs_ds_addr *
 nfs4_decode_mp_ds_addr(struct net *net, struct xdr_stream *xdr, gfp_t gfp_flags)
 {
 	struct nfs4_pnfs_ds_addr *da = NULL;
-	char *buf, *portstr;
+	char *buf, *portsep;
 	__be16 port;
 	ssize_t nlen, rlen;
-	int tmp[2];
+	u8 porthi, portlo;
 	char *netid;
 	size_t len;
 	char *startsep = "";
@@ -1089,37 +1103,33 @@ nfs4_decode_mp_ds_addr(struct net *net, struct xdr_stream *xdr, gfp_t gfp_flags)
 	if (unlikely(rlen <= 0))
 		goto out_free_netid;
 
-	/* replace port '.' with '-' */
-	portstr = strrchr(buf, '.');
-	if (!portstr) {
-		dprintk("%s: Failed finding expected dot in port\n",
-			__func__);
+	/* Parse the low port octet and remove it from the address string. */
+	portsep = strrchr(buf, '.');
+	if (!portsep || nfs4_parse_port_octet(portsep + 1, &portlo)) {
+		dprintk("%s: Failed parsing low port octet\n", __func__);
 		goto out_free_buf;
 	}
-	*portstr = '-';
+	*portsep = '\0';
 
-	/* find '.' between address and port */
-	portstr = strrchr(buf, '.');
-	if (!portstr) {
-		dprintk("%s: Failed finding expected dot between address and "
-			"port\n", __func__);
+	/* Parse the high port octet and terminate the address string. */
+	portsep = strrchr(buf, '.');
+	if (!portsep || nfs4_parse_port_octet(portsep + 1, &porthi)) {
+		dprintk("%s: Failed parsing high port octet\n", __func__);
 		goto out_free_buf;
 	}
-	*portstr = '\0';
+	*portsep = '\0';
 
 	da = nfs4_pnfs_ds_addr_alloc(gfp_flags);
 	if (unlikely(!da))
 		goto out_free_buf;
 
-	if (!rpc_pton(net, buf, portstr-buf, (struct sockaddr *)&da->da_addr,
+	if (!rpc_pton(net, buf, portsep - buf, (struct sockaddr *)&da->da_addr,
 		      sizeof(da->da_addr))) {
 		dprintk("%s: error parsing address %s\n", __func__, buf);
 		goto out_free_da;
 	}
 
-	portstr++;
-	sscanf(portstr, "%d-%d", &tmp[0], &tmp[1]);
-	port = htons((tmp[0] << 8) | (tmp[1]));
+	port = htons((porthi << 8) | portlo);
 
 	switch (da->da_addr.ss_family) {
 	case AF_INET:
@@ -1226,4 +1236,3 @@ pnfs_nfs_generic_sync(struct inode *inode, bool datasync)
 	return pnfs_layoutcommit_inode(inode, true);
 }
 EXPORT_SYMBOL_GPL(pnfs_nfs_generic_sync);
-
-- 
2.54.0

