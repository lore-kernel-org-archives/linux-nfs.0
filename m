Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 568183CF21E;
	Tue, 25 Aug 2026 06:52:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787640724; cv=none; b=qPZYEcG8Mpoq2sGdeztf5sVe+1OQ953DWR/Bk1id6rPr7pXzA0M3hed05iFymjQHEcjVuGfTnDhscIRpFBDPC4CeaFHN0DDx5vEQfKIDyd1jVfjOM5CqpurB+cWOxe79auqFqq2Rnqz0lZO2dARPKul3fP26hlujh612+1mCUfg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787640724; c=relaxed/simple;
	bh=vVsFnEeAF7RgSF4eIN8pX+/YULBjqBQ2ILL0ti+V0fk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WGpRyqZBCVPydgJU4qQvvlOwgL+QNiA4973IqChVAA4mP6+SDHdDgIaxxAQD8mgOOGIUmqpI1xS0e3IhmBz77wDaJRs8CguR4CtlV26bH1csU4GAhExrPJB6ej3Wue7qGh0MVRjPKrObCKfDZ8TgqgmqO+pnEGiXOWbfJbPNFmg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=yet7n7wg; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=G1eG1j4w; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="yet7n7wg";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="G1eG1j4w"
Received: from pps.filterd (m0170390.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P2R0Fi3564430;
	Tue, 25 Aug 2026 02:51:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=I2eM7lZ898NI
	tMJ2Atd2Uis5jVFbDnvth5GUgV9CY/o=; b=yet7n7wgCXvu4/V0sM68OSac+KzQ
	cUn9HBt39i3QP+B6o5R35sRngXurUz8ZRZlAiTEnkRMtHzYmtRmgdarYXXyPTcpC
	WcXZU/+bv3vMi1d1i4iqFtVp3KMpi9D/TYFDiArFO3ZUgUs6Fx4pLGfKMq5rMkiy
	HrA5phe6kbK/Nax/NgwnF1FVJVp3BwIFsV8OM/mI9u/LwlWhV6F5EfAnux2HS70t
	1ghNyttM14JoquZKXXpaaNWtGVUWJzrtQYmBrD2+uoOswNwznkWZe4Yhi/P03tef
	/BB/yeFzbe/f28KckhiPQcmvUk1kBnni5bs817Rs1yCi/HcEqCBOCPMpaA==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4g76ty226c-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Tue, 25 Aug 2026 02:51:57 -0400 (EDT)
Received: from pps.filterd (m0133268.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P6UCvD2872376;
	Tue, 25 Aug 2026 02:51:56 -0400
Received: from esapsmtpat10.us.dell.com (esapsmtpat10.us.dell.com [143.166.211.153])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4g91j0jy3f-2
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Tue, 25 Aug 2026 02:51:56 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787640717; x=1819176717;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=I2eM7lZ898NItMJ2Atd2Uis5jVFbDnvth5GUgV9CY/o=;
  b=G1eG1j4wTWqzOPiHPS+ZNSzXJO6mozXAPoiftn61ST/oXMH7rOuTQulL
   8J7W6OjylrnQrswpWl07vytd5f2ppTZ3zek8qY6XrW3LkhxoflWjCMdVc
   wl4v6uJZT9Xmdy4S3TcKXLMv66lpSmmoCBXXMrCW4yG54DQQ62LanAdep
   0UrFuFnGr8KVGrVi8A0VBf70Go/dFCYsSFUC4BxYmd0w6+tYZrFVcJchj
   IO9kWlyVmCBtJAGzM8aWrKVn9xWnhjqoi+shNm1NrP1ievzJ7YgsaeYvz
   +EEtdgh+CvSEoo72aQjd4WvsLiMciTyQGvakhhSsu+HWCtnx3U1U5xFV4
   w==;
X-CSE-ConnectionGUID: NcbP7+P3R1CQA8YMnxvHsA==
X-CSE-MsgGUID: /9g1AdjwR7+TOAl0Wxnybg==
X-LoopCount0: from 10.94.13.48
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.13.48])
  by esapsmtpat10.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 25 Aug 2026 06:51:53 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: cel@kernel.org, jlayton@kernel.org
Cc: neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
        donald.hunter@gmail.com, kuba@kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v1 1/3] nfsd: report NFSv4 grace state through Netlink
Date: Tue, 25 Aug 2026 06:51:45 +0000
Message-ID: <3fd25e2178458fbb44f57f1b0e068c12a6503d17.1787638668.git.prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787638668.git.prabhakar.pujeri@dell.com>
References: <cover.1787638668.git.prabhakar.pujeri@dell.com>
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
 priorityscore=1501 suspectscore=0 adultscore=0 spamscore=0 lowpriorityscore=0
 phishscore=0 malwarescore=0 clxscore=1015 bulkscore=0 impostorscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608250056
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX6m4SGgVNsnwI
 W4UXV504ue+0SFT2aGUlOpIpwCXp+YBWoqlgAYiOrhUd6WPznj/8LKF4yED9Ssmbyf+TZ/pkbB2
 B0S34YGMXmVocypSDsBmjIIazvStiDd6q61DhiHQERdrAbwdvs4V7tLb2o2kTUe41mCtdZz+KXy
 4nlnv4CcwC8uUo4bfVKVDSQfN9xMkXPy/Bef7oCc/raxtkuxMtEW1XoOJJaEfwGd+6sEBduJXxn
 qbxwHAaEyCx2Lju4oLjDKFe8qZYySuFnPg7Pl+/J6HGCunQII9CiFtDWpGUdf6x5zPyBoz8L09r
 5RrXM6iKpHlSwcmQw/KC5f5sbJFHW4/tT46DjA+Drex130iFIVfEIHRkbeWlFv7T4guYRyT2x6M
 M34BggauGM08ja0U0zK/p3y29w0JYVdSp+V2BRuziBdZjHVU/4vVrFKlrNYWmBRKZ84ZmlHPryW
 yRiK74Dc8T25CAUKeNA==
X-Proofpoint-GUID: TmMnCm8SSi6NTlwIH-SFuH4ByQvnNT-X
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX1S19jYo537Ec
 vMaCFr5GQrxU6HA5t4hCQfVHERDYL/F6dYpRcRtelWskPMi3f4z2SCinY7xLhIrHHUcrEB8K0g4
 hF3D9/TaFkFVjnhOKmUYgyhwmd2GcXQ=
X-Proofpoint-ORIG-GUID: TmMnCm8SSi6NTlwIH-SFuH4ByQvnNT-X
X-Authority-Analysis: v=2.4 cv=BMGDalQG c=1 sm=1 tr=0 ts=6a8d3b8d cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=zctdXvwhg3EK6xEvKeLW8g==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=sEWawkeXllE7TocFc0N_:22 a=iLNU1ar6AAAA:8
 a=lXXOwkYEy2pcZcTpNIYA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 lowpriorityscore=0 malwarescore=0 clxscore=1015 spamscore=0
 priorityscore=1501 adultscore=0 phishscore=0 suspectscore=0 impostorscore=0
 bulkscore=0 classifier=typeunknown authscore=0 authtc= authcc= route=outbound
 adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608250057

Operational tooling needs to distinguish a server that is accepting
normal NFSv4 state operations from one that is still accepting only
recovery requests. The existing Netlink threads query reports
server-wide configuration, but recovery state is available only through
the nfsd filesystem.

Add an in-grace value to the threads-get reply. Return it in every reply
so user space can distinguish a server that is not in grace from an older
kernel that does not provide the attribute.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst | 3 +++
 Documentation/netlink/specs/nfsd.yaml                   | 6 ++++++
 fs/nfsd/nfsctl.c                                        | 9 ++++++++-
 include/uapi/linux/nfsd_netlink.h                       | 1 +
 4 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
index c05926f79054..35c174000ab3 100644
--- a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
+++ b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
@@ -25,6 +25,9 @@ udp and one tcp listener at port 2049 (see nfsd_init_socks).
 On startup, nfsd and lockd grace periods start. nfsd is shut down by a write of
 0 to nfsd/threads.  All locks and state are thrown away at that point.
 
+The ``in-grace`` value in the ``threads-get`` Generic Netlink reply reports
+whether the NFSv4 server's recovery grace period is still active.
+
 Between startup and shutdown, the number of threads may be adjusted up
 or down by additional writes to nfsd/threads or by writes to
 nfsd/pool_threads.
diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlink/specs/nfsd.yaml
index 642268819c6f..d01d93f39392 100644
--- a/Documentation/netlink/specs/nfsd.yaml
+++ b/Documentation/netlink/specs/nfsd.yaml
@@ -130,6 +130,11 @@ attribute-sets:
         type: binary
         checks:
             exact-len: 16
+      -
+        name: in-grace
+        type: u8
+        doc: One while the NFSv4 server is in its recovery grace period,
+             otherwise zero.
   -
     name: version
     attributes:
@@ -464,6 +469,7 @@ operations:
             - leasetime
             - scope
             - min-threads
+            - in-grace
     -
       name: version-set
       doc: set nfs enabled versions
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6e63950a99e1..7ea865b372cc 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1775,6 +1775,7 @@ int nfsd_nl_threads_get_doit(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net *net = genl_info_net(info);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	bool in_grace = false;
 	void *hdr;
 	int err;
 
@@ -1790,6 +1791,11 @@ int nfsd_nl_threads_get_doit(struct sk_buff *skb, struct genl_info *info)
 
 	mutex_lock(&nfsd_mutex);
 
+#ifdef CONFIG_NFSD_V4
+	in_grace = nfsd_vers(nn, 4, NFSD_TEST) &&
+		test_bit(NFSD_NET_UP, &nn->flags) &&
+		!test_bit(NFSD_NET_GRACE_ENDED, &nn->flags);
+#endif
 	err = nla_put_u32(skb, NFSD_A_SERVER_GRACETIME,
 			  nn->nfsd4_grace) ||
 	      nla_put_u32(skb, NFSD_A_SERVER_LEASETIME,
@@ -1797,7 +1803,8 @@ int nfsd_nl_threads_get_doit(struct sk_buff *skb, struct genl_info *info)
 	      nla_put_u32(skb, NFSD_A_SERVER_MIN_THREADS,
 			  nn->min_threads) ||
 	      nla_put_string(skb, NFSD_A_SERVER_SCOPE,
-			  nn->nfsd_name);
+			  nn->nfsd_name) ||
+	      nla_put_u8(skb, NFSD_A_SERVER_IN_GRACE, in_grace);
 	if (err)
 		goto err_unlock;
 
diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_netlink.h
index 87da1d0bb21e..e1fc2db00046 100644
--- a/include/uapi/linux/nfsd_netlink.h
+++ b/include/uapi/linux/nfsd_netlink.h
@@ -84,6 +84,7 @@ enum {
 	NFSD_A_SERVER_SCOPE,
 	NFSD_A_SERVER_MIN_THREADS,
 	NFSD_A_SERVER_FH_KEY,
+	NFSD_A_SERVER_IN_GRACE,
 
 	__NFSD_A_SERVER_MAX,
 	NFSD_A_SERVER_MAX = (__NFSD_A_SERVER_MAX - 1)
-- 
2.54.0

