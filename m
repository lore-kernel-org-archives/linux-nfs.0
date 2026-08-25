Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9658D3921E9;
	Tue, 25 Aug 2026 06:52:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787640722; cv=none; b=GH9LTcVwfy1AsSqUD7OTbNMjB5wjw8VZ2ZmG01hlNypjbU616vqcWpxyGvOQhhNhDZaqpDkWRPf8cZ9mklo6xyIx4n7nDGDvM9i5q9ebIlLKDj4uad/tqXa4JkN9BysRF3Wb69UfQQn/5UHctKRPt4ixkqo5viotQZjNO/W7uyc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787640722; c=relaxed/simple;
	bh=m4g0Y5SRtu48GYy8jaiFc68FrTAG3GUzDtdu7XmsFSA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=izv8EdySzcN8LiNRzl4rPb4sqd4Z42pbt5aD129Xywnli9v+OBb2itC35xqwiPyiy2kv0tbupAxCtABDHw8gY+KHq4z32CPkrxf9i+sNrSXcTV+zGDLxJfGICeUquvGoUcus4epLjIvmSp7SOSAn7OPIjD6qnPrX4Y+uTLkCIio=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=CIYhXpAM; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=jHOHcUTY; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="CIYhXpAM";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="jHOHcUTY"
Received: from pps.filterd (m0170389.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P2R2WZ958732;
	Tue, 25 Aug 2026 02:51:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=smtpout1; bh=M2tXZvJMLyuVNKtCuS2X5Qi+wYdVIOMVbl/a
	G/Jsyok=; b=CIYhXpAMRH3lBeicxc4lYIuDlM1yueqtifM/WnnRj/+HXyX2N4Fp
	CvZ6mATdmG5gNLPkMHHKA5z0VshOUSzZ1O654OzeXlGMOZDrMcDXiN4RcnzTQIRt
	CJgPTo9f5l99jDn9o6b4e3iC+c4Bqq7qjPUyTyzfa64hZfg62YEd8mo3EKTbXndx
	vTa16W0TbkzF2KMQ0bS2bKbHy8qI+HsCuW1JkllRaZsOJfYcGp9m6k21CZR7yxEG
	DDpFTQPm9p5pC0pd0fhu9lBA6sOpk3247UhHODsxf2wsRpwUCoU2nM4Pt1ZKiS9f
	GYn6cc2LryZH9yAZ98syOrrtbDDgRBeo6w==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4g77se9wsg-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Tue, 25 Aug 2026 02:51:54 -0400 (EDT)
Received: from pps.filterd (m0133268.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P6UCvB2872376;
	Tue, 25 Aug 2026 02:51:54 -0400
Received: from esapsmtpat10.us.dell.com (esapsmtpat10.us.dell.com [143.166.211.153])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4g91j0jy3f-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Tue, 25 Aug 2026 02:51:53 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787640714; x=1819176714;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=M2tXZvJMLyuVNKtCuS2X5Qi+wYdVIOMVbl/aG/Jsyok=;
  b=jHOHcUTYSAtC8Rlx8cAyne1qL7R2YN01anseuCjGLRO0tlTSePcXHqvS
   03enzxZO4vAffh+xC/FEIos77nZZj2TmvnIZR+96qwFn9xlrMxKKoIWBS
   /GIKQrRkKxxHf/zjuhQjQlmnod2ACQVuRCd+ARTFpHtSaNo4XA2w3UlE5
   EZya/1IjaPrI4HWPun76VMoJmlERM2q2OWeReKnWRDCMp51CjA6WvlpXW
   ml1XVC6L7oAxzhqfUV6HpLVOjHjMr/GvB9BuS5g3L3tRiEQvh5tsPxCVQ
   lsWM0vWrDf5JIKgDZx0Gsr25zGqLdPSMXh95xo0aV6nKWI0xgSNQtn3EU
   A==;
X-CSE-ConnectionGUID: T3Ohx14MQyuvTwlOWo2A5Q==
X-CSE-MsgGUID: bVCFV0Z6S26ruHS/tECs6g==
X-LoopCount0: from 10.94.13.48
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.13.48])
  by esapsmtpat10.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 25 Aug 2026 06:51:50 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: cel@kernel.org, jlayton@kernel.org
Cc: neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
        donald.hunter@gmail.com, kuba@kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v1 0/3] nfsd: expose NFSv4 client state through Netlink
Date: Tue, 25 Aug 2026 06:51:44 +0000
Message-ID: <cover.1787638668.git.prabhakar.pujeri@dell.com>
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
 definitions=2026-08-25_01,2026-08-24_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 priorityscore=1501 suspectscore=0 adultscore=0 spamscore=0 lowpriorityscore=0
 phishscore=0 malwarescore=0 clxscore=1011 bulkscore=0 impostorscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608250056
X-Proofpoint-GUID: Fgt7TvJ2kQAmZuspJ_pvD80cGDBrxoCp
X-Authority-Analysis: v=2.4 cv=AobeGu9P c=1 sm=1 tr=0 ts=6a8d3b8a cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=zctdXvwhg3EK6xEvKeLW8g==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=PpEg0BoV_A2aca28hXd0:22 a=I1YeyxFUZiQI-HvKo-oA:9
 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-ORIG-GUID: Fgt7TvJ2kQAmZuspJ_pvD80cGDBrxoCp
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfXwoieZUK8oE+y
 M745nA1n8slK63NdfaYOKSv8FNAlQQuxkRiVHeQnNnel+jxNuCDEG9LxcrXtIxCjqXrZSJIXya4
 tC5lhXQ/qY0zT4qAram83V4Q3RiNTNDFkkjVrAmYeN87/UbM1N0Uv51qJquTsbEgm6O3ng8v5mY
 sdx/ZUG3+ZMu+QcfL5MZeWWr6eXtEgkQMi/O5Cg+k663GCP4lRxsfk27fdVrwEu1z6X/QLwdoye
 /+3YzrKOFWPn2K6DkWP0tC0mXvUfzA0Wyc41+YCEC0zx07Ir1X8n4bCIz8SKhO4YsK7G2EkSoOf
 icIyqhd7GlSMVTuiwHBccLo3BjNWYkQPUCLX9JQnDNtcHwwoNCuEiBttLJ1cckum0ycytauTi3i
 lD+idV5Xvqkf2v50bsFTbkblo7CyYnn6dBpZKDuPaZ3BY7H5nZjECTKaNuI+UCmHbFqwmHI2Pf7
 jHpYiufRuIcc2O64PEA==
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX8iERgHy8UnEB
 eHdlsdBcwYoUTDYx+u6gqE902kpGTRDcB7ICBYfcdCggTw2Hvd0rUjlfSyNOJt2VFnns73aqv81
 wtMClY2rlxOdU6TkT6dD21/S3ihNtps=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0
 adultscore=0 clxscore=1011 phishscore=0 bulkscore=0 spamscore=0
 impostorscore=0 malwarescore=0 priorityscore=1501 lowpriorityscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608250057

Administrators can inspect NFSv4 clients through the nfsd filesystem, but
collecting a server-wide view requires walking a directory and opening
multiple files for every client. That is useful for detailed inspection,
but awkward for monitoring and automation.

Add a compact query interface to the existing nfsd Generic Netlink family:

  1. Extend threads-get with an explicit NFSv4 recovery-grace value.
  2. Add a privileged client-get dump with basic identity, lease,
     confirmation, reclaim, and callback information.
  3. Extend each client reply with session and stateid record counts.

The split keeps the grace query independent, establishes the minimum useful
client ABI before adding the more expensive state traversal, and permits
older user space to ignore the count extension. The existing nfsd
filesystem files and their output remain unchanged.

client-get emits one bounded message per client. The dump pins each client,
uses the existing client and state locks for mutable fields, and serializes
against server shutdown. Client churn can still make a multi-message dump a
best-effort snapshot; the interface documentation states this explicitly.

The Netlink client ID places cl_boot in the upper 32 bits and cl_id in the
lower 32 bits. This is an architecture-independent representation matching
NFSD's logical and tracepoint representation, rather than the legacy procfs
rendering of the in-memory bytes.

A companion nfs-utils series adds `nfsdctl clients` and displays the grace
value from `nfsdctl threads`.

Validation performed:

  - strict checkpatch on each patch: 0 errors, 0 warnings, 0 checks
  - YNL regeneration and headers_install
  - scoped NFS admin and Netlink documentation builds with SPHINXOPTS=-W
  - W=1 NFSD builds with CONFIG_NFSD_V4=y and CONFIG_NFSD_V4=n
  - two-vCPU QEMU test with a live NFSv4.2 loopback mount
  - grace yes/no transition checked through both raw Netlink and nfsdctl
  - one live client with one session, open stateid, lock stateid, and
    delegation stateid; zero layout stateids
  - legacy /proc/fs/nfsd/clients output checked for unchanged fields

The series is based on the nfsd-testing branch. The exact base is recorded
in the base-commit trailer below.

Prabhakar Pujeri (3):
  nfsd: report NFSv4 grace state through Netlink
  nfsd: add a Netlink dump of NFSv4 clients
  nfsd: report per-client NFSv4 state usage through Netlink

 .../admin-guide/nfs/nfsd-admin-interfaces.rst |  22 ++
 Documentation/netlink/specs/nfsd.yaml         | 106 ++++++++
 fs/nfsd/netlink.c                             |   5 +
 fs/nfsd/netlink.h                             |   1 +
 fs/nfsd/nfs4ctl.h                             |  10 +
 fs/nfsd/nfs4state.c                           | 238 +++++++++++++++++-
 fs/nfsd/nfsctl.c                              |  22 +-
 include/uapi/linux/nfsd_netlink.h             |  41 +++
 8 files changed, 443 insertions(+), 2 deletions(-)


base-commit: 46ff234c7129c7c10ed493413d4f60d0cf4dd1f1
-- 
2.54.0
