Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3C617E792
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 11:43:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787485385; cv=none; b=ufLEKv9qske5Bzwnsfgy2r1Ky5jp7PhZ3hhoWFhc2CrG8nxvjBrcVLu2ywk4OMe38fxP8Y24NvAru4hYsDVFfgpOfCL3DfL23sfQmvL7/JSjTsFtlpyTZ5f+7oLCnROrxSxX6pTfK6NXfb0z7FpqJ8+JztGp96D4PXNoylgog20=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787485385; c=relaxed/simple;
	bh=iSAQOKFAlYTPg0Fri2iyiHBkM47IUsj/SCF7M31Dpps=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=DQS+jSFhw3FYyZ4uXNKLj0l3+uQUz9Fai+NDgca4To0v0WKsPgehRl8zQNSFV3b4PsOk6SNONaHPDijH4FQbTEHvSmd9tkeUm7ZbkYPCNjpk11GVhNSp+dL0S+VrkuI18AOWv/A5IaRf3abJY5FG7wmXHWzfWCYKjrUTcY5/eD4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=ulgaXjr+; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=UA2dkMaS; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="ulgaXjr+";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="UA2dkMaS"
Received: from pps.filterd (m0170395.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NABghf663223
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:43:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=smtpout1; bh=AHH0fxmaKBn3Q7tJtFIrV+wVZYP2MazOczsr
	CXc9mow=; b=ulgaXjr+4YpxlRw4Z7Mtv7qpmRsINqQaRtFQj+igs9QqlrFj+2rS
	Qc9LbMNxYYvufMXVGUuyrrMPnRZv75PdgfwK0pM6F0WhDN7CkwkSuCi0BZSU7bpo
	dG7HGaWW66IJTWZg80hICAVvGsq7aY9dJkJudsVGHvTbVqIYx9wSH30ZHWg0UqAt
	4VzHNYLzwLvRVbx1IDPfMRU3+kVB6prC1M35LO1zHtCf3ZlDaQaYrZSNLEyoW+ez
	zpWgkWFvkGSKePLENRvLh/dbs93wUyIoYqLfLUVUa09UpRoDlU+oxsCV5HwVmU3w
	ekzSc8Ar5vmKiK+XNDBhXWsor8GcJCqeYQ==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4g78egjcnh-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:43:02 -0400 (EDT)
Received: from pps.filterd (m0142693.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NAA2RS370768
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:43:01 -0400
Received: from esapsmtpat01.us.dell.com (esapsmtpat01.us.dell.com [143.166.211.146])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4g7wevhp69-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:43:01 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787485381; x=1819021381;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=AHH0fxmaKBn3Q7tJtFIrV+wVZYP2MazOczsrCXc9mow=;
  b=UA2dkMaSKujIOpRygawA1Z/lHInAqYEAFHUwexvzrrFmrUXN6/uFR0/k
   io7wMZDFRYeFOxUz0g0YTGqTx0fJRAWMausLFD6olguWDOn022eBoir5i
   SkwgLqNXFsOXRUuC2WIcu0Vv5uW0dv9zi3khPhbQaBxb1rVe8xOMiHrDN
   0Ma28+/IN/5EnrL0Y2mTIyyLsAw5dmpqDY5Tmv4GWRBgI41ONQfa3YHuZ
   aDqMOt2kdOQzdBCJPqALMRUYwVVsxV1PGEBORuUYPxzHR6M7vIEHYVWzo
   18yXEdrfzTjRWNfXVr8yBumxPiVq9s/JD8esWnP2lzqCCF1VjhnTab2v1
   A==;
X-CSE-ConnectionGUID: WuLyTVu0S2iQV5dLz/w+5A==
X-CSE-MsgGUID: cK6xA+gaRBiwVvXYTMyUHQ==
X-LoopCount0: from 10.17.189.166
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from unknown (HELO W-96J1TH4.blr.amer.dell.com) ([10.17.189.166])
  by esapsmtpat01.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 23 Aug 2026 11:42:59 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH 0/4] NFS: harden pNFS device address decoding
Date: Sun, 23 Aug 2026 11:42:40 +0000
Message-ID: <20260823114244.3883-1-prabhakar.pujeri@dell.com>
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
 definitions=2026-08-23_04,2026-08-21_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 impostorscore=0 adultscore=0 clxscore=1015 lowpriorityscore=0 bulkscore=0
 priorityscore=1501 malwarescore=0 suspectscore=0 spamscore=0 phishscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608230106
X-Proofpoint-ORIG-GUID: k4xZi0v3DC3W9HD9u1d2pjIFcH7kBdbk
X-Proofpoint-Spam-Info: AW1haW4tMjYwODIzMDEwNiBTYWx0ZWRfXwE8P+aF+s1f6
 uJzpojexIE2j0A4ackPjTML6p3JYpap5aRELlLQOQKcYsbKP2g7h2hY8MNWJBG2HXMAlvppELVH
 qk6Lb3O9UJpSs4InsyecUORQplTYUa8=
X-Proofpoint-GUID: k4xZi0v3DC3W9HD9u1d2pjIFcH7kBdbk
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODIzMDEwNiBTYWx0ZWRfX9F0iM3T789C4
 jfC36z3Z8Flin+InBNJB79ZNIR0pdPYqdZN/a8+rwqtNZK1iGVqhTNjmb5Blk6DB8zLbfqo+1zr
 ysab0+XeTpIIKe+YxO2BOtNIbBk5S7eg1wxAoA5tfSDMMZgjHi6+cTJG2mmVPb83Sd+QPOBghE5
 F2IJXofb3tLfafdngWQWnnN1aGhpQ92fXm0JZAsFzkOctNwk3R9kZUvJOCUaKUozsL6cw9vFkBE
 gXAyUdk98wBIlmGYi1dJ5DI8GBvgJUKWNQ5WrVB+9denMQW0BGNBIJVDFnnHeGMGhSorwyZjl7I
 t17Sm2BRXzDOSHjx0/SuaTXnwC2l3RSqfln+JI544onX3cMyoyDZkMHWTur4D0qOL8Ge5AuMuGH
 SlD22jPS8qvgDych6KjtnXV/CA1mdpGu34koxbTiX3OSzyKNWwvFxyq0v4nXYT9Cd17NcZEpiov
 2B2F4w75KWeS0KB0lTQ==
X-Authority-Analysis: v=2.4 cv=Z6Hc2nRA c=1 sm=1 tr=0 ts=6a8adcc6 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=MDsIxxkBee3CUfGUG3hQZw==:17
 a=b3DhMmMkJVNBYjixYE3i3TbOsPs=:19 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=Qy6CKLcU0MZ4grw4BCWD:22
 a=RxdNRRqdi9sZ9ow4uF4A:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0
 clxscore=1015 priorityscore=1501 impostorscore=0 phishscore=0 bulkscore=0
 malwarescore=0 lowpriorityscore=0 adultscore=0 spamscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608230106

pNFS GETDEVICEINFO replies contain server-provided universal addresses
and multipath counts. The current decoders accept malformed port octets
and can spend billions of iterations on a count that is not bounded by
the reply length.

Patch 1 validates both decimal port octets. Patches 2 and 3 bound the
file-layout and flexfiles multipath loops by the minimum XDR space needed
for each remaining netaddr4. Patch 4 adds focused KUnit coverage.

This series is based on the NFS client linux-next integration commit
10f307e525a1, as published in next-20260821.

Tested on a Dell PowerEdge R660: the pNFS decoder KUnit suite passed
16/16 and the flexfiles suite passed 3/3, with an empty kmemleak scan.
No pNFS-capable server was available, so the affected decoder paths were
exercised directly by KUnit.

NFSv3, v4.1, and v4.2 data, locking, and parallel workloads passed,
together with NFSv3 ACL and NFSv4.2 xattr checks. The series builds
cleanly with GCC and Clang W=1 and passes Sparse C=2. Strict checkpatch
is clean


Prabhakar Pujeri (4):
  NFS: validate pNFS data server port octets
  NFS: bound multipath address count in file-layout GETDEVICEINFO
  NFS: bound multipath address count in flexfiles GETDEVICEINFO
  NFS: add KUnit coverage for pNFS address decoding

 fs/nfs/Kconfig                               |  34 +++
 fs/nfs/Makefile                              |   3 +
 fs/nfs/filelayout/filelayoutdev.c            |   5 +
 fs/nfs/flexfilelayout/Makefile               |   3 +
 fs/nfs/flexfilelayout/flexfilelayoutdev.c    |   9 +
 fs/nfs/flexfilelayout/tests/deviceid_kunit.c | 188 ++++++++++++++++
 fs/nfs/pnfs.h                                |   8 +
 fs/nfs/pnfs_nfs.c                            |  47 ++--
 fs/nfs/tests/pnfs_decode_kunit.c             | 222 +++++++++++++++++++
 9 files changed, 500 insertions(+), 19 deletions(-)
 create mode 100644 fs/nfs/flexfilelayout/tests/deviceid_kunit.c
 create mode 100644 fs/nfs/tests/pnfs_decode_kunit.c


base-commit: 10f307e525a1783570a39eb9ac146d45f4f16b3e
-- 
2.54.0
