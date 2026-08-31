Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 114373E7173;
	Mon, 31 Aug 2026 11:48:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788176916; cv=none; b=hBiSTppR+xmo65WgIAKmecO7iQ77TsNZNk0i2Em52L3mVNVqZlOQsRb1fo/CjpcaSsLAhVZPn+2JdYrNGjqJZYLInM/lBdLE7yiHZH8dSumjzJKEwsyh+v4wRvg6Y++AJCZYBDITRN1rUg4Ggf1pECHaYs0TS/6WLdNYsNuA92I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788176916; c=relaxed/simple;
	bh=GwVbrmgVvOIh6u+SyjwGI5UkGn35iUiQiNRDKY+ZvRU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dTuApHT44lcGcp2t01sKvQNw0fPk+863cenhSp65PacgABEv1FI+u8uVTyO24OfPOjeJhquNF5bjYioH2wMRzmTTMDnkXjOx8SRexjTjS4oJNKsHAKMGKm/XmdSZtcmiy40T4+NDG4fmlcQUEjTzHGky146y2jrs7jGE5r5N/dQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=F+5+nkpT; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=JzvLf/3c; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="F+5+nkpT";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="JzvLf/3c"
Received: from pps.filterd (m0170392.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VB9sxm3165501;
	Mon, 31 Aug 2026 07:48:34 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=Y68l3o/TsK+j
	AZ9sIea0jbVyIO4x1ujhgknEkQ3ZJWY=; b=F+5+nkpT/IPx5Za3td/lbs+ydPB7
	MUJ4CglsRT0YCdUioRTDGCUohwM6T1UWKlIlRECsLEAXZGy8WuXiiiZmvhbG1TTS
	r4APOY23cbP/Zj3LzddzoUezKmG7bV4CYlHsXbrhSs7XFfgF60BUS2LcCDsoWB7H
	fl0+FGNvMQg+TG8BXKGrRPWFyoKp5UO1OuKLVzb4hfePVQEv07hTLeA1YmFPndLf
	eITc1eSrTo4BIzWuWswu9xmeYSDElvzKKBrzHmq436ZhxfGO9Jv82+jYrya4deKO
	1U+v+u1tqs4dFzwzzjHUuF13KZm8JnIFCA5zqL9LK2PLQuOlZ6d7Usztyg==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4gbtk6wp1b-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 31 Aug 2026 07:48:34 -0400 (EDT)
Received: from pps.filterd (m0142699.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VB9oRt3049667;
	Mon, 31 Aug 2026 07:48:33 -0400
Received: from esapsmtplv01.us.dell.com (esapsmtplv01.us.dell.com [143.166.203.147])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gd7wp8uqk-5
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Mon, 31 Aug 2026 07:48:33 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788176913; x=1819712913;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=Y68l3o/TsK+jAZ9sIea0jbVyIO4x1ujhgknEkQ3ZJWY=;
  b=JzvLf/3cbtT4FCRlmyXvmZBMXC2Th8GkdmJjDpyS3VcP/Ff2H81K19wz
   W44lX+nqa7aUUfKaCOMZEwRAqF/hfXGPMUo3aZdDNypnIp3LlxQz6+cXG
   AKaJn5ZvwumiqqqnZKo0adFvDxVRycgo154D8eGRM7/M5Ifebx4P0pZy1
   Ev/QntY7U+tTGqv/lLXFHryVVx/VCQQui/dQQHy2oupJMco+rxQQw2PWG
   J9eYwcggtNezLSnDkQgzmqd9gz9nexSCZ3rx4bMfPmdcGi+sdQnuvKkFL
   zuS3ePn9DVL4INwwp5kKphBcEMwTGRSgq+YGB3kttPH96c7dqUQ+XtNbO
   Q==;
X-CSE-ConnectionGUID: v8G1Z3cpRNO6+5Pqy25lyg==
X-CSE-MsgGUID: I9GpNNLIR6qP/Hg+1C2U3g==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 11:48:31 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        stable@vger.kernel.org
Subject: [PATCH v2 4/7] NFS: validate pNFS data server port octets
Date: Mon, 31 Aug 2026 11:48:15 +0000
Message-ID: <5bf0470b45d43c93515dffb286adb9e51db557eb.1788173789.git.prabhakar.pujeri@dell.com>
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
X-Proofpoint-ORIG-GUID: 1_VblvExhCaox7pdijMAcpIyI2ymGqdi
X-Authority-Analysis: v=2.4 cv=PL0/P/qC c=1 sm=1 tr=0 ts=6a956a12 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=L/h6WUVEnF1aJ0/14Ndw0A==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=m3zZTHMLHbwB7Lmtoed2:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=VZJtwKKvAAAA:8 a=NxIssioeBxkeEXFklJ4A:9
 a=gbU3OgOOxF9bX48Letew:22 a=vzdIw8kzLcqZOxdJCU6L:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX7zV+kcx6v3pJ
 8JOt0s8k9yQR+q2dVmpK4rzBACHRinmXcK3v0rfawC2I7rk18xDOs8xxa0lg/4wqVUd4elWyrZB
 YyOdB1RcCUD3nu5d2itLweuShakYA+c=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX1e7R4gJ6CV1L
 giMNAx1wQ/V/nXnzbLiZ79gJA5ogQm54/S8M4Ji/UhiZopPc+niP6/2c33bvbqu88YHxNbERgN1
 7gIU1uyW3U9SkYrI+MdQYHR8gIJYq6Swa3V4/qqLlahmuJWassb2EX8ZWpqPJru7da5PUkfYRs3
 CzN1HgfLlVRBUb8kPPhw4rmf+SEAHqQnHZ2JfvMCdJAC+RKwTA+3GgJ3Yv3e3Ihn8is3b8NMwYC
 aawOO9cMesqPMdNQjesN78zDxMvxe48+Ovl5TBgBTXx59EIdMI5JfMZqvB9r2eorgvVb/hK1Gek
 kH+u3TpBzxCZktosJu9xSR7rMd2tu/Xg6FlhCr+wa0pPcPdpCEDY8ELhGDR1Hj96HUPl7R0HcGZ
 LUDvma0QXGw/NFOAsNsdAjp0MR5kixBudS8T+CC9ed6u3W9zzbmSIRKfyUUhzG/Qsu0BSo9xwY0
 dzzy9eQuZEtOdjdVYkw==
X-Proofpoint-GUID: 1_VblvExhCaox7pdijMAcpIyI2ymGqdi
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 spamscore=0
 lowpriorityscore=0 bulkscore=0 malwarescore=0 adultscore=0 impostorscore=0
 phishscore=0 clxscore=1015 priorityscore=1501 suspectscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310102

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
 fs/nfs/pnfs_nfs.c | 46 ++++++++++++++++++++++++++++------------------
 1 file changed, 28 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 33d64287e500..f09826415251 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -8,6 +8,7 @@
  * Tom Haynes <loghyr@primarydata.com>
  */
 
+#include <linux/ctype.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 #include <linux/sunrpc/addr.h>
@@ -1064,6 +1065,19 @@ int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
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
@@ -1071,10 +1085,10 @@ struct nfs4_pnfs_ds_addr *
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
@@ -1094,37 +1108,33 @@ nfs4_decode_mp_ds_addr(struct net *net, struct xdr_stream *xdr, gfp_t gfp_flags)
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
-- 
2.54.0

