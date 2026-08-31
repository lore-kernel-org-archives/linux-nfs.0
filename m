Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 260FC3B0AD4;
	Mon, 31 Aug 2026 11:48:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788176909; cv=none; b=ADS4bZj5cgns5hpmmoPZtMjPqKiSFZNsVWY8xHHnUyqQFbygzhGhUYypBq1E3SV7zR4PDv8D/mjOSLbG0YA9wlOdCT9lF+IhJR6nkU54Cxrr5brUtDttuajZY2eXQZbvVphji5Yu9VmiCxACo/1oC4EAcT51AR2g4kf4oM0Jlbc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788176909; c=relaxed/simple;
	bh=fXj0O2AshEHjDxAVlis0fGK2k3yRCIh5selNsdlsH/w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TQGrNhT+ufWly7jY+EuiRVoESIAElAi6v6KsBThXA1splTFIfHJUoujtMtx4IoOKtFqZEK8nnTIAg7/Fd9CKP7aLvb39H0y3SsdciHBYD7jcfnvjqEF+1ohLU78YVqC0Qw/K99qjhBNDQI5382nBG+4mb1PVmHPk04F68laxzkg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=LuEpYU1P; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=UnfQoDyW; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="LuEpYU1P";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="UnfQoDyW"
Received: from pps.filterd (m0170393.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VBAEd23033451;
	Mon, 31 Aug 2026 07:48:27 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=lCfqBrIEqvjc
	QoBSVbTJ8sKbXSMhBNg4fRv76oyu1ds=; b=LuEpYU1PGWdWinhOwn/A6wGUpxP5
	6ILMk+VOspnqC7GVyETH8Xq+ka6fibeh7TaQOjsZEMhH9S9xx2bjaYHxS4PUBUI6
	AZZuUng1MW7U615OxXzoQf8+zq04wwd8+hS7DEyipoMOu0WIp5+5pZtmy9sBVOBH
	RUHnYOyzlAD5p/F8qVhojofu9feTTciwhKGUzPQdBraAGc6L7NrgC9oTx4JZ5L+K
	MKmJTeyets5YRyG+oOSbB8uzL9X/Ki2OitfEGgJhDqZfUGFwd8UJQhDG41As4m+g
	jfQilUkea0EPbfH3dXcfbBAUjUCVMblNvJwjGKkPHBkOXjqXsMhj8w6S0w==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4gbtrfwm8n-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 31 Aug 2026 07:48:27 -0400 (EDT)
Received: from pps.filterd (m0142699.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VB9oRp3049667;
	Mon, 31 Aug 2026 07:48:26 -0400
Received: from esapsmtplv01.us.dell.com (esapsmtplv01.us.dell.com [143.166.203.147])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gd7wp8uqk-2
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Mon, 31 Aug 2026 07:48:26 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788176907; x=1819712907;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=lCfqBrIEqvjcQoBSVbTJ8sKbXSMhBNg4fRv76oyu1ds=;
  b=UnfQoDyWGZAUSS0i5MXUXH+0c2EbyzNymtuzbwhih1J9mX5CvYTZu5eK
   MWd8itQpBTDAKD36wtgfCEyBsu8/h4i4mbqXrQjetyEJKNBfiupIaX/9+
   kW8Vm+MFJR3poGogbBfgu9uUnZzdfMtjBHSRLDEYcxpIQiKBcM0Z/uV6F
   hG189pDky8MbJbQ9RxLEC+Q1240W9lWzLQGcjFjl7dEai8Jfynw6JAcya
   m3qJUjKDA20Jf/lRTzIGjeWvDLsk5Sel8cmm4XKnwN2xcvE7OBzToPAuW
   +0E6kf+8rNjHLOA37nYn1pcJyvsap/TQE4+P8AnXM9JfE4q5k0k639HbB
   Q==;
X-CSE-ConnectionGUID: /psVBA1EQnivyE78LlGK2w==
X-CSE-MsgGUID: rV5ekkxMQX227Ax741/0vA==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 11:48:24 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        stable@vger.kernel.org
Subject: [PATCH v2 1/7] NFS: free netid when discarding pNFS DS addresses
Date: Mon, 31 Aug 2026 11:48:12 +0000
Message-ID: <89bb918bcf3e010d43bb2884a44a6afbc91a8ddb.1788173789.git.prabhakar.pujeri@dell.com>
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
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX/QiFji+x5QN0
 J6sdGs3cAv1kmcxbkOsf8ZrhYflmzCh7XtF4LOKy2qpK12SlCHjxNHgrpXTK1OJPSDPJKSnQpQX
 FyFaZX3/t30xbVW2kV3W4WrdJsF8xdpqxNHk1eP5HnPOojpWD12kHiomuMlyoiol29MK0Vs9NLB
 m1HeSEKvTvBF/KdaZ8spCulk875+yrF2lmwMtMAMwmUSiRh+lTDtVY312dRO74PkGQjUCTYap1V
 tn/aelpKQpqFB3RJt9umSKIphOKqo3M+UqOu9+OIgL6sYzV/+1i1hGKANeZDn+pZOKAaZ6T64Jh
 FaQkcJPoFtW6HKmVGLIrT0hCGZM1oXUvjoalV0mw8pjH1I5XtCSyOTrfOzjqPKWGe7uuvLdmDb1
 hYNZDKahv9UCftOI/erdm6A3j7ZhTj06eQz+J6ZDeS7RIIVODd40bMLpnBWtuVrA0hvPiPpk8o0
 faVBWZQyyK2ruf5EKLg==
X-Authority-Analysis: v=2.4 cv=SeXHsPRu c=1 sm=1 tr=0 ts=6a956a0b cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=L/h6WUVEnF1aJ0/14Ndw0A==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=2Lpba0WeoN7BYVdwMO11:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=g2ZcH_FSLCBm_W9tHeoA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-GUID: ekgp-3tD8-aGGMp4F4AZTnHSuaQKppZU
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX6p/r6g/vyr9i
 pUjtWbsaxsZ+1Lvywo8HanXhbjzXtfZDgIAYX1aeyvQPe4Mf5fYfRjonmw/XE04eIjeT2G0Etq0
 2pUZu+Jhh17gnCRSKj4j5jSYDUZFYis=
X-Proofpoint-ORIG-GUID: ekgp-3tD8-aGGMp4F4AZTnHSuaQKppZU
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 lowpriorityscore=0 malwarescore=0 clxscore=1015 priorityscore=1501
 suspectscore=0 adultscore=0 phishscore=0 impostorscore=0 spamscore=0
 bulkscore=0 classifier=typeunknown authscore=0 authtc= authcc= route=outbound
 adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608310102

nfs4_decode_mp_ds_addr() transfers its r_netid allocation to
da_netid. The generic data server destructor releases that field, but the
file-layout and flexfiles drivers open-code the disposal of temporary
address objects and omit it. Cache hits and later decode failures therefore
leak one netid string per discarded address.

Make nfs4_pnfs_ds_addr_free() available to the layout modules and use it
for every temporary address list.

Fixes: 4be78d26810b ("NFSv4/pNFS: Store the transport type in struct nfs4_pnfs_ds_addr")
Cc: stable@vger.kernel.org
Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 fs/nfs/filelayout/filelayoutdev.c         | 6 ++----
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 6 ++----
 fs/nfs/pnfs.h                             | 1 +
 fs/nfs/pnfs_nfs.c                         | 4 ++--
 4 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 88bc79ec3459..878f1f13be16 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -182,8 +182,7 @@ nfs4_fl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 					      struct nfs4_pnfs_ds_addr,
 					      da_node);
 			list_del_init(&da->da_node);
-			kfree(da->da_remotestr);
-			kfree(da);
+			nfs4_pnfs_ds_addr_free(da);
 		}
 	}
 
@@ -195,8 +194,7 @@ nfs4_fl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 		da = list_first_entry(&dsaddrs, struct nfs4_pnfs_ds_addr,
 				      da_node);
 		list_del_init(&da->da_node);
-		kfree(da->da_remotestr);
-		kfree(da);
+		nfs4_pnfs_ds_addr_free(da);
 	}
 out_err_free_deviceid:
 	nfs4_fl_free_deviceid(dsaddr);
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 5c0216bd5fce..95cb54c498a9 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -164,8 +164,7 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 				      struct nfs4_pnfs_ds_addr,
 				      da_node);
 		list_del_init(&da->da_node);
-		kfree(da->da_remotestr);
-		kfree(da);
+		nfs4_pnfs_ds_addr_free(da);
 	}
 
 	folio_put(scratch);
@@ -176,8 +175,7 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 		da = list_first_entry(&dsaddrs, struct nfs4_pnfs_ds_addr,
 				      da_node);
 		list_del_init(&da->da_node);
-		kfree(da->da_remotestr);
-		kfree(da);
+		nfs4_pnfs_ds_addr_free(da);
 	}
 
 	kfree(ds_versions);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 70d20f779678..6ea390c8cd9a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -415,6 +415,7 @@ int pnfs_generic_commit_pagelist(struct inode *inode,
 							int how));
 int pnfs_generic_scan_commit_lists(struct nfs_commit_info *cinfo, int max);
 void pnfs_generic_write_commit_done(struct rpc_task *task, void *data);
+void nfs4_pnfs_ds_addr_free(struct nfs4_pnfs_ds_addr *da);
 void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds);
 struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(const struct net *net,
 				      struct list_head *dsaddrs,
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 93d63f75a355..33d64287e500 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -626,12 +626,13 @@ static struct nfs4_pnfs_ds_addr *nfs4_pnfs_ds_addr_alloc(gfp_t gfp_flags)
 	return da;
 }
 
-static void nfs4_pnfs_ds_addr_free(struct nfs4_pnfs_ds_addr *da)
+void nfs4_pnfs_ds_addr_free(struct nfs4_pnfs_ds_addr *da)
 {
 	kfree(da->da_remotestr);
 	kfree(da->da_netid);
 	kfree(da);
 }
+EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_addr_free);
 
 static void destroy_ds(struct nfs4_pnfs_ds *ds)
 {
@@ -1230,4 +1231,3 @@ pnfs_nfs_generic_sync(struct inode *inode, bool datasync)
 	return pnfs_layoutcommit_inode(inode, true);
 }
 EXPORT_SYMBOL_GPL(pnfs_nfs_generic_sync);
-
-- 
2.54.0

