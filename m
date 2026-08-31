Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1B8F13C2BBA
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 11:48:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788176908; cv=none; b=dbkeNDxLn0KOPE4pD1zkepyJm8MYrlzk4RZWomM+2qo6WiOWTGUwUCc/qNfTgUTSccP1N+5KMAP1NKYX1kbeE5/WM3VEHxflMwmapq9JFxV3dyxK6dzANuFe+zeP9+wWDnhhCSqxhWYGzQNltM7me6gZqB0esDBQYAY+Jpemi5s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788176908; c=relaxed/simple;
	bh=RksqpiEuoKBLo+q2L3jJuMZsCM6K3zq7Ffq4oLrYUqA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ux+QsvPvvdVtE7Azhrpy2cBGqVDBGxxMHAIo5p78QPIn5/I/WN+OMVadOkM/1nyPOeyeGQgcUIjMuHmeNJe+pU4WG4NfabPzdFJFuzXvqaqTXHPh7jov9UVUjnoXAbXqSZtLDbFFNbvZT9Gtg5gbpMiKOjcWF6v+PNJK6TYfxIs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=aPlPPp8B; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=BXfIDWu4; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="aPlPPp8B";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="BXfIDWu4"
Received: from pps.filterd (m0170398.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VBAAcH2885371
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 07:48:25 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=smtpout1; bh=omf6k6xphVZspjfp/o0d1OFbFOt04LsNalqt
	qlGAj0Q=; b=aPlPPp8BT6FCOBDwtCG4GCYompyadBQq0G7eDw/QpseZOZRgwkt7
	udrtmmS3iDI0W/ZvAlw/tKwFk+fBK9oSxAoaVHgJoFqq0hbcAHl39cUMbKAgcR98
	ZLClExdmPN7cqFxHaVJYLAtpK0hA7e4+NaNA2BH/H3Gy5DNv77GbetRJ3htv37q5
	kUOre8oqE7o7KyiwdfF+n0/pWxCb557X+c8TvtSi5rJHJUE9dvwiG3Odi/kv8tak
	8qj84ERXf9zMGadEBXaySuh/549AUkawyIx2gdic8ZU+P9s2hsBpeME8/J0F8MPK
	nILZchVsr8R6WaAwRZSyV2mP6WVQRWsq4A==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbtn4wpu7-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 07:48:25 -0400 (EDT)
Received: from pps.filterd (m0142699.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VB9oRo3049667
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 07:48:24 -0400
Received: from esapsmtplv01.us.dell.com (esapsmtplv01.us.dell.com [143.166.203.147])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gd7wp8uqk-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 07:48:24 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788176904; x=1819712904;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=omf6k6xphVZspjfp/o0d1OFbFOt04LsNalqtqlGAj0Q=;
  b=BXfIDWu4YY9qull10BRRlBRTsoUXaDhA8k8j5yeeRAmR1iYep5lccUR/
   XlIGYv7pMxJfGxOAFvv0Z6oR9YBCEsQCCw3QtQPPtoEiYAjG7jxqXUP5I
   DC+p5RKX4B+Tf0qI/8xslBXmT0j8rQCmA3yiRlXq4nTVNQy9ymMphmLGp
   SFbnKynU5zTG9E1fNOIz/RDm6BSlVyVsz2S+Rt+bYhDTosZdGQnjBtF7X
   sdz3BNS1BcFFYF6OVa5cZZUa+VAOXAW8tBJvHD0mfH2teokVqG6ov8r4t
   ZdfJRmmaTNX+0fgZkaw9U/DTYrLRtwxsSgIFjA+mRj9tROy2qTmhEhZBV
   A==;
X-CSE-ConnectionGUID: QGjcOGDVTq+7VdOVWOD5Kg==
X-CSE-MsgGUID: zY53SErsRTC6JvyoIq4oSw==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 11:48:22 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v2 0/7] NFS: harden pNFS XDR decoding
Date: Mon, 31 Aug 2026 11:48:11 +0000
Message-ID: <cover.1788173789.git.prabhakar.pujeri@dell.com>
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
 definitions=2026-08-31_04,2026-08-27_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 adultscore=0 lowpriorityscore=0 impostorscore=0 suspectscore=0
 priorityscore=1501 bulkscore=0 spamscore=0 phishscore=0 malwarescore=0
 clxscore=1015 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608310101
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfX440052qJHbH4
 ozvSN2uQEC/FWGSCz+6Iytww0bEzqGG0qZpitA4Mmw9Bt5gS2u28gaXJ+PgPeST1xc4Ycf5Gaq5
 POXneLjO5PPFyKXiIsbuAzqVPyHy6J0=
X-Proofpoint-ORIG-GUID: n_cKSEErpQz7WalnUWjVtcVIIVPAkS1s
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDEwMiBTYWx0ZWRfXxtXVI/WMOY6/
 bbhKRc4VfPJDfakphh5oyyT3v7I5BMBDVzCNOe9AZPrr6yr1me2dpJJAzBUbFimXE998CHpUXUq
 qbG519FmIA4KIonEXDUb7IUkCBxZ0X7LDzFDPOcXRh4UCSLXHa9QOB7wVE/nepzwIRkn4djc9vV
 sPwgUBUPb9us6ASKCh7RrsLuHawNNRSfDmEzEEPEsTnIDFvHjE8Mk5jGO+PutDFkUMadYL3pMwO
 Ki0CODZ3SIYhsd+KwdP/Wc/y1uUyXI3GpeIuBpc5GvAjfDN9R+Iy1sd1QGqFXe+QoLSnPq6jw0r
 1WJ2G96bjDgAjDmd5uC2SNPvOEx3cGc8MnFRZci+UHzYNfr7s0Gui8PtduflKNpyqd5uZiH1zAx
 R/snBxmZOO+EKoS2O0dCw6JEJHZqxTeGDRzBx+G4SOioaGFqbNzL1SCHo1zPHsfOAAlYhFv3K0O
 26lzan8TT3CbtsS0mnQ==
X-Authority-Analysis: v=2.4 cv=FMIrAeos c=1 sm=1 tr=0 ts=6a956a09 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=L/h6WUVEnF1aJ0/14Ndw0A==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=vUAfKriDyi6VqHAKCLgX:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=ZKBrNrx8SFssq2kCzBIA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-GUID: n_cKSEErpQz7WalnUWjVtcVIIVPAkS1s
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 priorityscore=1501 clxscore=1015 adultscore=0 bulkscore=0 suspectscore=0
 malwarescore=0 phishscore=0 lowpriorityscore=0 impostorscore=0 spamscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310102

pNFS device and layout replies contain several counts and strings supplied
by the server.  The current decoders trust some of those values before the
reply has proved that the corresponding XDR objects are present.  A broken
or malicious server can therefore provoke oversized allocations, very long
decode loops, malformed data-server ports, or leaked netid strings on
temporary-address cleanup paths.

This series makes those paths proportional to the received XDR length.  It
also validates both decimal port octets and uses the common data-server
address destructor wherever a temporary address is discarded.

The last patch adds focused, page-backed KUnit coverage for the address,
GETDEVICEINFO, and LAYOUTGET decoders.  It covers 16 universal-address cases
and six flexfiles cases, including cache reuse and malformed multipath,
version, and filehandle counts.

This version is based on v7.3-rc1.

Validation:

  - nfs_pnfs_decode KUnit suite: 16/16 passed
  - nfs_flexfile_deviceid KUnit suite: 6/6 passed
  - GCC 16 W=1 build of fs/nfs/: passed with no NFS diagnostics
  - Clang 22 W=1 build of fs/nfs/: passed with no NFS diagnostics
  - GCC 16 W=1 build of fs/nfs/ with KUnit disabled: passed
  - Sparse C=2 checks of every touched C source: passed with no diagnostics
  - GCC 16 W=1 full kernel and modules build: passed
  - git diff --check: clean
  - per-patch checkpatch: no errors or code warnings; patch 7 reports only
    the generic FILE_PATH_CHANGES warning for the new test files

Changes in v2:

  - rebase from the NFS client linux-next integration commit 10f307e525a1
    to v7.3-rc1
  - free da_netid on file-layout and flexfiles temporary-address paths
  - bound flexfiles GETDEVICEINFO version_count before allocation
  - bound flexfiles LAYOUTGET fh_count before allocation
  - expand flexfiles KUnit coverage from three to six cases, including the
    cache-hit and malformed-version cleanup paths
  - rename the test patch to reflect the broader XDR coverage

v1: https://lore.kernel.org/r/20260823114244.3883-1-prabhakar.pujeri@dell.com

Prabhakar Pujeri (7):
  NFS: free netid when discarding pNFS DS addresses
  NFS: bound flexfiles GETDEVICEINFO version count
  NFS: bound flexfiles filehandle version count
  NFS: validate pNFS data server port octets
  NFS: bound multipath address count in file-layout GETDEVICEINFO
  NFS: bound multipath address count in flexfiles GETDEVICEINFO
  NFS: add KUnit coverage for pNFS XDR decoding

 fs/nfs/Kconfig                               |  34 +++
 fs/nfs/Makefile                              |   3 +
 fs/nfs/filelayout/filelayoutdev.c            |  11 +-
 fs/nfs/flexfilelayout/Makefile               |   3 +
 fs/nfs/flexfilelayout/flexfilelayout.c       |   7 +-
 fs/nfs/flexfilelayout/flexfilelayout.h       |   6 +
 fs/nfs/flexfilelayout/flexfilelayoutdev.c    |  22 +-
 fs/nfs/flexfilelayout/tests/deviceid_kunit.c | 286 +++++++++++++++++++
 fs/nfs/pnfs.h                                |   9 +
 fs/nfs/pnfs_nfs.c                            |  50 ++--
 fs/nfs/tests/pnfs_decode_kunit.c             | 222 ++++++++++++++
 11 files changed, 619 insertions(+), 34 deletions(-)
 create mode 100644 fs/nfs/flexfilelayout/tests/deviceid_kunit.c
 create mode 100644 fs/nfs/tests/pnfs_decode_kunit.c


base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
-- 
2.54.0
