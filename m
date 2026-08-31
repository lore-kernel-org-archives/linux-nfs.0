Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F39A53C2786;
	Mon, 31 Aug 2026 09:27:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788168462; cv=none; b=B53q6TU6JoHFCKO7FpgP89obtFpShJgOpUqgHQNL0NvVtdi4JHIS+vTdLtC0FkhfNsVcp/X8tKTehOHOYkcha3HKAMnirCAqLlhCtp0Lc1OUc9VPnvEDzzd4Dgr1lK1eB+7P7AhWqIt0+sZKC2fWVAMMRRxYHDEwymQ1P+FG9H0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788168462; c=relaxed/simple;
	bh=wIhp71090GDEJ1QK+cA8DxlXafezB7136WFRQLm0IBI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=B0qVda3O2INMRdNvJ2UR4w0jiL2e9wxx31S6UGLRoVppTDz49ul1UmmvuFwJndzHf54M1T5zmZbBPkc880rgQPHx1RxDxLo2St/zfP08viF2wZGrkzB7CfgicgxnRQky4XcQoouWaJ3DF7GlIq7cab2j36tjxagvqU+5Ha3ZRYw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=PdRG1z9T; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=qcAlrKmK; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="PdRG1z9T";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="qcAlrKmK"
Received: from pps.filterd (m0170398.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V7x1YL2499288;
	Mon, 31 Aug 2026 05:27:34 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=smtpout1; bh=Z5i+DFYA8T3eZXJqc8MJlIKzEcTKeuYcMn1q
	0tEKpLo=; b=PdRG1z9T0PDl0TQ2l7pUwVpr7F7yIu5o5MavaJaOHdyl3s5m2jyb
	5gYabPWYK0ntde7GaP7GUSVH+qi71zv4YfYgWy5cS+xe028ADtXL/57qY9xy4U9/
	wUIIn95asjxQGi/CGbU45WY7wXcLEf6NZ21Tpy4TlkzZId9F8Sbtlkn3PKAoB5zn
	pxTZrltHlmWfmgbjMPpKCDg2Jm3iDyNkYrzeKWXvJJ9n7lLf+aAwaaus1BCAfOFt
	tAmGV0Vo93pCiNeaJQvCyCIDBYGIGmCwRkSatcogyGlOo2yKgODhf3Myof1dovZC
	b9l26SMjOyHu4A13HcoaJaaQV77XO9Co5A==
Received: from mx0b-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbtn4w7jd-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 31 Aug 2026 05:27:33 -0400 (EDT)
Received: from pps.filterd (m0144104.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V8Xvhd4129725;
	Mon, 31 Aug 2026 05:27:33 -0400
Received: from esapsmtplv05.us.dell.com (esapsmtplv05.us.dell.com [143.166.203.153])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gd67b8h8c-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Mon, 31 Aug 2026 05:27:32 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788168453; x=1819704453;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=Z5i+DFYA8T3eZXJqc8MJlIKzEcTKeuYcMn1q0tEKpLo=;
  b=qcAlrKmKucXM6VV9LNzuiqnT96HkieaZSc//SeONikSmB34oV5Nm1VT7
   Fe0jf4gzgkk83VsW3Y7atPWww2yInLcCpGNwmk79nA5LBwZX5Vp/aOMnt
   OnIZ82NRdYDZSkebcjdlSzCryaiuZb7CBS7VJsoRsc69YrHhXjrSfx5I/
   3Wht34Kb3TsxcX0BSf4MGcZzRu0h2fv9b5iHvxYx7nZx3V2Sxt/oKVeqG
   cf7DQvZfPNz+aNbKDpePpDARO3vG7DcBBt6vfrBhtiF88JXgPnxzbRBHu
   04hSSP64Y9Hm1rtIf5WIgAMWKExF0Q0oaYX5cG2FtDBkrSo41HxvCRYFY
   Q==;
X-CSE-ConnectionGUID: f3a0U+AvRYOi0XypAr6aKg==
X-CSE-MsgGUID: V/95TOZYSWCINZGBTVezgw==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 09:27:28 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: cel@kernel.org, jlayton@kernel.org
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, neil@brown.name,
        okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
        donald.hunter@gmail.com, kuba@kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH v2 0/2] nfsd: expose NFSv4 client state through Netlink
Date: Mon, 31 Aug 2026 09:27:22 +0000
Message-ID: <cover.1787988917.git.prabhakar.pujeri@dell.com>
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
 definitions=2026-08-31_03,2026-08-27_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 priorityscore=1501 bulkscore=0 adultscore=0 phishscore=0 clxscore=1015
 malwarescore=0 spamscore=0 lowpriorityscore=0 suspectscore=0 impostorscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310080
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfX66P1PgAhM6Xf
 UI2u2HLnHrdeegLdYijbsoUdEw1x5jqlDja6p3P5dXmy7XRREvD2vubfPhsyFUKXRljRZc6dGRc
 IEmvNHE5dgUoz6xon1xGcWIT//AwMYQ=
X-Proofpoint-ORIG-GUID: aLzxBsHlG5-YVd3SbxesolCJwkiKlixd
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfX5Opv575xuux/
 P3OHhXjkkPXJ9aUGBXwD3mK8HDh2BYR9OFKJ4YF0ZeiVM7ybzBJNwxgmxWkTmJ+Le1fmFtFiBJz
 llqLP3j0X3craIGpj8iAyX0hjZOb1WYxq5+u4NbUS+TFWm5SmtN700KpekR+NHfTmhAiEofTIVr
 g8Vt1WbAqhEhGLducyg04wszPaJhShSuqwsZGZWQxEXUyFM8EE4tf73hqh00/nMxELUm1UuB6dw
 aGOOMyJJrUYUDwwPOiSnqB8ueIHecCXCZhpXMqRvhQ1RlMXY1bbC3GPwJs2dYZg/Vsp7icuhDba
 GwSg5lxQvHp8L4Cicg1qrNqY/UV6/1ilTZ9Xz+5sfK98h9Gmv7D3Q1njk1toV+hgsx3dKMmVzNV
 ZKnprPLu+ue7BZdJZ0aEYEOiyrI1qQbjvBbmIgw0p6pwWiKjxtxQ7sTEYLXFLmxAJBlzShV+/yv
 5M0ZeWr9Ur9nToHR+yA==
X-Authority-Analysis: v=2.4 cv=FMIrAeos c=1 sm=1 tr=0 ts=6a954905 cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=t4Iba6VQkoKuxR139xjPXA==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=vUAfKriDyi6VqHAKCLgX:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=-y_wPE8gx4dmNtE7TfYA:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-GUID: aLzxBsHlG5-YVd3SbxesolCJwkiKlixd
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 priorityscore=1501 clxscore=1015 adultscore=0 bulkscore=0 suspectscore=0
 malwarescore=0 phishscore=0 lowpriorityscore=0 impostorscore=0 spamscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310081

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

  - strict checkpatch on both patches: no errors, warnings, or checks
  - YNL regeneration and all 33 schema checks; generated files remained clean
  - headers_install and NFS admin-guide and Netlink-spec documentation builds
    with SPHINXOPTS=-W
  - full x86_64 GCC 16.1.1 kernel/modules build with W=1; no NFSD or
    changed-file warnings
  - focused NFSD W=1 build and Sparse over every fs/nfsd translation unit:
    no findings
  - two independent two-vCPU QEMU boots of the exact locally built kernel
  - each boot created one live NFSv4.2 client with one session, open stateid,
    lock stateid, and delegation stateid, and zero layout stateids
  - raw Netlink, nfsdctl, and /proc/fs/nfsd/clients state agreed in both runs
  - no kernel warning, Oops, panic, sanitizer report, lockup, or stall

Development assistance: an LLM assisted with review analysis, implementation,
commit-message drafting, and test-harness development; Sparse was used for
static analysis.

Assisted-by: LLM sparse

v1: https://lore.kernel.org/r/cover.1787638668.git.prabhakar.pujeri@dell.com

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
 fs/nfsd/nfs4state.c                           | 341 +++++++++++++++++-
 fs/nfsd/nfsctl.c                              |  13 +
 fs/nfsd/state.h                               |   7 +
 include/uapi/linux/nfsd_netlink.h             |  43 +++
 11 files changed, 553 insertions(+), 10 deletions(-)


base-commit: 65b583e874b371d539314272006833653364a06b
-- 
2.54.0
