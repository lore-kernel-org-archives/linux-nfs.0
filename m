Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 23F923DB332
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 09:27:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788168473; cv=none; b=kEcYiePb2z+Cm57z70m4+aBwhhyIYHWLAAKF/oVfk3ROsqEXrYGX1JqDn1DWEcZ+nWKSmpBhPs0cj4WxADakrMOyOaux0tTDDpUVkP0xU/hmOpTd7o4M8Gy7yU+IgYIf2OAAXPJx6GJGsWLWn1Q+ZWA6XEDAC2+oBq0YhPsAtrU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788168473; c=relaxed/simple;
	bh=rW8Kxw6tIPsTqLJOhzuvXsoCk2EHT0HnU7eCPIzultU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=HSRBlnLYHq2tF3rIZp+Jt234Uu7yZIjn+VDe+dDM3c682ubLMxoaejzPy5MS3/t4Z4hx3DVBGaqe3v6xCmzyKGXmXe9lIYsmBzLKsNtBCB1q7WtABH9ybu+NKir0BH5XpJ4dzOv7wOIgfNGWSOtSm8JpmheMGbzW3B+4QmDGE7w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=PMDozPf1; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=qZGFppyp; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="PMDozPf1";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="qZGFppyp"
Received: from pps.filterd (m0170395.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V7xMdV3192106
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=smtpout1; bh=Pz9haVmrr/jt4+K6mta4WZazemzwFOQDymZP
	W/nIfeY=; b=PMDozPf1XV2pwpMvPedDmKCPQlBfLOXJuo29nDjylGOqXSZjY6IX
	5Ue7wZJYSivCn6++ZxbFa9xGKzwFUWWsuhAys4zNyakpSlcrGSlbnqLuinVL5fIZ
	0LLNOjiesDis4zD4a0hwxKLZMoERxkhbeMVIaPf4QHfPTPpm1s5tMZy6sAKyzgTv
	jnSa+i9T1FpN6tZkuepassnmrGuRViTej8SkbzHgbpf7qZouMUE0EAXYmZmlnNfz
	dglDZJrNSX+jkZNkeEYqIYXiNDMbgs4ZKtiQi3uXf3pOyUlt+HXyMN3fXWLfrwQJ
	paUVVcUUEAIBEaxYSuybthm6Kb3Wz+1pvA==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbv3g4y85-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:49 -0400 (EDT)
Received: from pps.filterd (m0142693.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V90T6b2842117
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:48 -0400
Received: from esapsmtplv05.us.dell.com (esapsmtplv05.us.dell.com [143.166.203.153])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gd3pk2f8b-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:48 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788168468; x=1819704468;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=Pz9haVmrr/jt4+K6mta4WZazemzwFOQDymZPW/nIfeY=;
  b=qZGFppypfZOHIXp9GoYWCTuQ/kx2y1exau2gr7Iif6OmXHwvfDE8oJSJ
   Md+aQM4QzD5iIYAey9wZ7Ex91XmIFzSxf/btrFl3HSg9IIe4107voDUHi
   2iL7X9xgtHY/rDQBmXXyLh6cM1lNXeRVWCid/U2EuKIDC1MejlWzbz0t7
   43e+3P81U8QEb/1beYllXMR33cpjwT/GjaMfr5QYRgXkhPykDT3g211bc
   h5P1lKFFaNNvFrd0xZNhW/oXRqoxj3YVmjbbKrjIMZd8ZBVMm3lJeUjyM
   0EV4C0FSwfRqPfBYyQTMg2jTCuqbDrfUgM2FTI8lbsfPybIKtqZfEObQ+
   g==;
X-CSE-ConnectionGUID: UFs84lXJSwGrwNixkpPFoA==
X-CSE-MsgGUID: rQ2rAHwgSQuAApThBX+mjA==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 09:27:46 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: steved@redhat.com
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, cel@kernel.org,
        jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/2] nfsdctl: list NFSv4 clients
Date: Mon, 31 Aug 2026 09:27:39 +0000
Message-ID: <cover.1787988918.git.prabhakar.pujeri@dell.com>
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
 phishscore=0 lowpriorityscore=0 bulkscore=0 suspectscore=0 priorityscore=1501
 clxscore=1015 malwarescore=0 impostorscore=0 spamscore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310080
X-Proofpoint-ORIG-GUID: 3SWWFKKO6Vi6rfP3-OwbMCVJwfphqrJv
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfXycHMRxU+OiOd
 qbhEuMhvQj0dvNRNmSpYbFaMMFkQjjIoHp9iTnQpsH81oc2OUICV9aWNU+9cMvm+AK8Fp6UF8xD
 1caoN/BEB184eWTdMnvxBGRj+pTUgtycax8gj7RrT4bkJxXnDw+devMM6aPunhsGuBqm0wIL5OO
 9ZwdDvFwIw+U8BrAY35CikTGDfUaT/gu4vLmkX6wgASvKRaYHTJ4SH03icdsMHREKKA1awDRtEx
 2kloIF/ogyPp2m8At+BEPSFzarSNkxX22VVP5V3j9yTVrycQaftmxMqhh+Y5raCy+mERnkIZxgn
 CJTfUPpjgDTl18c5Lm5G4dsi8mp0skkoUkiya+V29Rxdq2/P48rXEfOlq3VjTPH/R3mHOE7KKz+
 5br+UDUpK3AfJxdgKZLFz5T30omQTp+lEl+pmwH/Ni/EGVIis8uvdvg/1XuhkGqJIvp8idxll/O
 hbwe+7ajWr61O4VVmRw==
X-Proofpoint-GUID: 3SWWFKKO6Vi6rfP3-OwbMCVJwfphqrJv
X-Authority-Analysis: v=2.4 cv=B7SJFutM c=1 sm=1 tr=0 ts=6a954915 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=t4Iba6VQkoKuxR139xjPXA==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=Qy6CKLcU0MZ4grw4BCWD:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=-GSv6bd47G79tlrnGXkA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfX0FFsdydLpU8d
 5gRYiuvyzuEnpAVe1yH+BRxcFcT1BFadYRWO3mYqjJYOuxY/9/bufQCm4tNBmcxwm1/OVnCovf8
 OKLrlGGUGMgvlj4xL4txHrKeyhiph4k=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 clxscore=1015
 suspectscore=0 spamscore=0 lowpriorityscore=0 bulkscore=0 impostorscore=0
 priorityscore=1501 malwarescore=0 phishscore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310081

Add the userspace consumer for the companion NFSD Netlink client-state v2
series, whose cover Message-ID is:

  <cover.1787988917.git.prabhakar.pujeri@dell.com>

The first patch adds a privileged `nfsdctl clients` table for basic client
identity, address, lease, confirmation, reclaim, and callback state. The
second adds session and stateid record counts.

Attribute presence remains the compatibility boundary. Missing count
attributes are displayed as dashes. The bundled UAPI header permits building
before the new kernel header is installed, while the configure probe selects
a system header only when it contains the complete count extension.

Changes since v1:

  - decode separate IPv4/IPv6 address, port, and scope-ID attributes instead
    of raw sockaddr data
  - detect NLM_F_DUMP_INTR on client records and NLMSG_DONE, and fail with a
    retry diagnostic rather than displaying a potentially inconsistent list
  - decode variable-width 32-bit or 64-bit uint count attributes and display
    counts as uint64_t values
  - drop the companion grace-status patch with the kernel-side grace patch

Validation performed:

  - strict checkpatch on both patches: no errors, warnings, or checks
  - full nfs-utils build and `make check` using the bundled UAPI header: no
    failures or errors; one environment-dependent test skipped
  - full build and `make check` against headers_install from the final kernel:
    no failures or errors; one environment-dependent test skipped
  - bundled and kernel-source NFSD UAPI headers compared byte-for-byte
  - two independent two-vCPU QEMU boots of the exact companion kernel
  - each `nfsdctl clients` run displayed the expected NFSv4.2 client,
    loopback peer, lease, callback/reclaim state, one session, one open,
    one lock, one delegation, and zero layouts
  - nfsdctl output agreed with raw Netlink and /proc/fs/nfsd/clients state

Development assistance: an LLM assisted with review analysis, implementation,
commit-message drafting, and test-harness development.

Assisted-by: LLM

v1: https://lore.kernel.org/r/cover.1787639206.git.prabhakar.pujeri@dell.com

Prabhakar Pujeri (2):
  nfsdctl: add a command to list NFSv4 clients
  nfsdctl: display per-client NFSv4 state usage

 configure.ac                   |   2 +-
 support/include/nfsd_netlink.h |  43 +++++
 utils/nfsdctl/nfsdctl.8        |  21 +++
 utils/nfsdctl/nfsdctl.adoc     |  14 ++
 utils/nfsdctl/nfsdctl.c        | 310 +++++++++++++++++++++++++++++++++
 5 files changed, 389 insertions(+), 1 deletion(-)


base-commit: 67ed1bdb1af1c70a5fd3b377a997401b7676b827
-- 
2.54.0
