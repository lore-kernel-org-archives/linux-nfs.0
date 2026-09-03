Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F0ED227A91D
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 05:31:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788413511; cv=none; b=X+4FfRyoAeiTFcO934TkBTsYBRMRBrNrFA4lCjss2A33hAOHoG/EwO8inSlN6L7nZGyAVEeM67bbUkddf08UElb/8PyVNX6/vGjOcRoRagWs7Yx6KJYvZBYiphLH2P1iRXjN9s8YcaQIKIqWmSTXXiMNxdWs2ScUbZ9NQkefrpc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788413511; c=relaxed/simple;
	bh=EjsMjXALJQ3Lvd1JcCawwt8OqDrKrctTb2jlRhFXvHg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=eDiDMkSLGY2oBrsWdCiDnIFEMHwbUVvWasJ28BG7Lu2LrdTf0oQa02SL25HxBKUsO/hCbXBdlpETkCIldKlkewF7s7Bb2R4ORooPDt2D7bZDLA1FNII1CapJEj9dvThbpAs7qK6hx3AyM2bjTXPcSeZgPpLJpHdHJrF+HojRLCE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=A2ZZTFfr; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=pAFdBw93; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="A2ZZTFfr";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="pAFdBw93"
Received: from pps.filterd (m0170395.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 6832w37H3152397
	for <linux-nfs@vger.kernel.org>; Thu, 3 Sep 2026 01:31:48 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=smtpout1; bh=JsH1atEAmRICMlKPjIu4a+0+pz6ETmZJgOvN
	X5stA0g=; b=A2ZZTFfrV0hBpuZ6fGhYTtvxiLXkjgTj8nPGXOR2CBc7mHd/9Dqq
	AzX0s7pdUftPdsmpae7l8oOIpXD6aoDq35Nte/oP5Lx8/SV0MkcYU6C0b2ph6Q5E
	/0K2goFgx5Nyv1WDxBv1ocyl4h+e03qGxJZcE26Bwi1nL7dRfPhYdgiuopUpnGQD
	PDl4J/lNhXzKo5Um75pBwMlxbL9LjsL93ZJ6jgnNDsIxWhx5alrQ7BYrF9jkuScn
	DWnGuN97GunBV9Gx8Tj8YlN9suWYnSrFyKqbZCKUYhXxSN6ht4+Wy5UfmGFWlk13
	F/MfuBp3BQgrSRGM9HsYlUpfluZDyG40FA==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbv3gn0uc-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2026 01:31:48 -0400 (EDT)
Received: from pps.filterd (m0134746.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 6833wteC3474327
	for <linux-nfs@vger.kernel.org>; Thu, 3 Sep 2026 01:31:47 -0400
Received: from esapsmtplv06.us.dell.com (esapsmtplv06.us.dell.com [143.166.203.146])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gf1fa0u7k-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2026 01:31:47 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788413507; x=1819949507;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=JsH1atEAmRICMlKPjIu4a+0+pz6ETmZJgOvNX5stA0g=;
  b=pAFdBw93tMh+OKY11aJr6s0MD0U3lEtJfp+SL7ZcpoWIqKAvllt71yKF
   +XXCofLVbAWn11NiVVR96ylFNLd4RhWzLg6056pzJ3RfAMG8RGKenLw2G
   CL7cKdCwrf6sGOyHTDBlZyiNlfoI9gMxlvbHQkpW6elm0YsMfN8hlfNPf
   V4OED5mMWb0VHfboc4g5mkzoMFUQ2zBEsKa4Man8CnXJjah4jimePl4WQ
   u12JnZqX1NuB6HZn/Su81K5XAy6PseRM1mCsyJ03dJ12qc2owQX5NDAvY
   dbxPb27wZX4i//oxDSSbubVASXkdOr43guWSqWHfMhAg49y6zIurTBQUv
   Q==;
X-CSE-ConnectionGUID: WGBJj806SzmL/21Wy+ExPg==
X-CSE-MsgGUID: XX5S1nToRqW4MEFeEKqDrA==
X-LoopCount0: from 10.94.14.196
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.14.196])
  by esapsmtplv06.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 03 Sep 2026 05:31:45 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@kernel.org, chuck.lever@oracle.com,
        Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v3 0/2] nfsd: expose NFSv4 client state through Netlink
Date: Thu,  3 Sep 2026 05:31:39 +0000
Message-ID: <20260903053141.1241-1-prabhakar.pujeri@dell.com>
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
 definitions=2026-09-03_01,2026-09-02_04,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 lowpriorityscore=0 priorityscore=1501 suspectscore=0 clxscore=1015
 phishscore=0 bulkscore=0 adultscore=0 impostorscore=0 spamscore=0
 malwarescore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2609030046
X-Proofpoint-ORIG-GUID: c_bKsJdTlR5fFZlaboKD5d-H9lckQN0B
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwOTAzMDA0OCBTYWx0ZWRfXyBtMq4QuAqqh
 8m3LQMtP6d/4DVd3p4tXYjpxEFuy7YCYaAtuqPNBvgHDv37EHkxStfrmRMx3ET515r9SEckFOtU
 HPv1B6eGNhSOcrdI3SKfgPpeo2kk/O23BfIVaFGDe+lsJhoaEuzexnP4dnBzkamhhdz/uc7eTJ5
 7cr92a2SbAjhHnsa58r38+UomMEaxwcSE+F7D8RYkF6XoUQ6ymtM3SEBDmqsLsXoYErS63eLbd+
 qW+FVV1u3RTfC/WWTOJLXHdNMrkJut/r+FLAdd4MihNlmTX4vA7xHECJSu+v3l9xpa9NLnmVkYe
 TvF+VgfQhbJOJk/yh3RXp0zennMMhPM/LvlWwJbpKYjro1pPM29Vdt7XNawPU+816g/6iGrDQYV
 iufu93luHHhKbXCUSVN3zWYK3c66qAeXNfLB2VVnUNAuAi8cDIK5C3QDHKtz0vnLQeQuPH+pfqP
 kaDX7YAwtXA7fcKy4GA==
X-Proofpoint-GUID: c_bKsJdTlR5fFZlaboKD5d-H9lckQN0B
X-Authority-Analysis: v=2.4 cv=B7SJFutM c=1 sm=1 tr=0 ts=6a990644 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=in+AvElAwLqdjTPPAWhuvg==:17
 a=VdqzKS8jKosA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=Qy6CKLcU0MZ4grw4BCWD:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=-y_wPE8gx4dmNtE7TfYA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwOTAzMDA0OCBTYWx0ZWRfX02hPM6qmhihn
 i808o2qHWiL2SrkEWzaAukt4y/qH4DVB3/jmdW8UmuO9wjYKZvYr5x2BvNwT2jJmUCVRXJ+BmOA
 TP7C6MnD2lib6W9NGtDyKqGucFcEOoM=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 clxscore=1015
 suspectscore=0 spamscore=0 lowpriorityscore=0 bulkscore=0 impostorscore=0
 priorityscore=1501 malwarescore=0 phishscore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2609030048

Administrators can inspect NFSv4 clients through the nfsd filesystem, but
collecting a server-wide view requires walking one directory and opening
multiple files for every client. That interface remains useful for detailed
inspection, but it is awkward for monitoring and automation.

Add a compact, privileged query to the existing nfsd Generic Netlink family:

  1. Dump basic NFSv4 client identity, address, lease, confirmation,
     reclaim, and callback state.
  2. Add O(1) snapshots of per-client session and stateid record counts.

The existing nfsd filesystem files and their output remain unchanged. A
companion nfs-utils v2 series adds `nfsdctl clients`; its cover Message-ID is:

  <cover.1787988918.git.prabhakar.pujeri@dell.com>

This reroll intentionally drops the grace-status patch. As discussed with
Chuck, that interface needs an explicitly scoped design that can represent
both current server-wide grace and possible per-export grace in the future.
I will address it in a separate proposal.

Changes since v2 (feedback from Jeff Layton):

  - rename the client lookup helper to nfsd_nl_find_client() ("get"
    connotes refcounting)
  - validate the client-table argument explicitly in nfsd_nl_find_client()
    instead of aliasing NFSD4_NL_CLIENT_DONE to "unconfirmed"
  - rename nfsd4_nl_client_put_address() to
    nfsd4_nl_client_marshal_address() ("put" connotes refcounting)
  - document the confirmed-then-unconfirmed table ordering in the dump loop
    comments
  - rebase onto nfsd-testing at ac579868af0c

Changes since v1:

  - replace the raw sockaddr attribute with separate IPv4/IPv6 address,
    port, and optional IPv6 scope-ID attributes
  - add a nonzero client-table generation and
    genl_dump_check_consistent(), so churn marks the dump NLM_F_DUMP_INTR
  - replace session-list and stateid-IDR walks under cl_lock with maintained
    u64 counters, making every per-client snapshot O(1)
  - encode counts as variable-width Netlink uint attributes
  - drop the grace-status patch for a separately scoped design
  - rebase onto nfsd-testing at 65b583e874b3

Validation performed:

  - strict checkpatch on both patches
  - focused NFSD W=1 build of fs/nfsd on nfsd-testing at ac579868af0c

v1: https://lore.kernel.org/r/cover.1787638668.git.prabhakar.pujeri@dell.com
v2: https://lore.kernel.org/r/cover.1787988917.git.prabhakar.pujeri@dell.com


Prabhakar Pujeri (2):
  nfsd: add a Netlink dump of NFSv4 clients
  nfsd: report per-client NFSv4 state usage through Netlink

 .../admin-guide/nfs/nfsd-admin-interfaces.rst |  22 ++
 Documentation/netlink/specs/nfsd.yaml         | 118 ++++++
 fs/nfsd/netlink.c                             |   5 +
 fs/nfsd/netlink.h                             |   1 +
 fs/nfsd/netns.h                               |   1 +
 fs/nfsd/nfs4ctl.h                             |  10 +
 fs/nfsd/nfs4layouts.c                         |   2 +-
 fs/nfsd/nfs4state.c                           | 353 +++++++++++++++++-
 fs/nfsd/nfsctl.c                              |  13 +
 fs/nfsd/state.h                               |   7 +
 include/uapi/linux/nfsd_netlink.h             |  43 +++
 11 files changed, 565 insertions(+), 10 deletions(-)


base-commit: ac579868af0c900d8fd9c8cfe9e10db46ccc5a75
-- 
2.55.0

