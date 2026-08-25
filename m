Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6807B3921E9
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 06:52:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787640746; cv=none; b=jEwUYKmLuHzzVqX0PpoA0vQUy5KnYbH6YU0F7Q3s/XPbv0OuHOxFyVtI43kFETWCKIM+xGwBuHggPAmVqy6huCB9h5Epghz/J91esQiMSWxWODg1kLsaFZ3pWuR8UG0imDOfp2v/S6fcub9FVrrpI8yC+gmLafmtTAjsc+iM3z4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787640746; c=relaxed/simple;
	bh=73ZsctZhDlTrrCb+Q5HIzgWZUxTSgs5q/M5iuIGz7JQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=X92xT4E8Oh3OdZ1odijSZPfzG3oTdgBxEU+OEkqJjP/ZCJ6skPGtnopt7dfEltIlulFaCF4/s7o26ldW9TtU5pOGs9Lahr5kazz64SygsgcWf1RKnZdpx6V2Z1NYPxHHgv5K7WJemrmhcsIeSaSSLfCSMEjcctnhi7SNk17wNNs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=RPjOGYNf; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=Ni7eD5km; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="RPjOGYNf";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="Ni7eD5km"
Received: from pps.filterd (m0170392.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P2R23W1081241
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=smtpout1; bh=Zg3iYRJh8jtyW+x4oOnypE/48WuL5KAtuUM9
	UnQDvNw=; b=RPjOGYNfYY9l9ZT2f2dE9l7d91JIHJQSx4fM0pUeITvDGdx9hLmx
	IpKTTzyRrThGtOlZU691E8owPKaRRREV+MlLr6zZBjTOp3sd4+ykRZpXLr0fV3jb
	kuIQ/8hcZ+5b1Bn5WSLuN7Uuakz8M1NG89fbnhtU1LcK0InPB3W410D4rBOu3dc+
	CHbXJrdyHkDApdQAHbI5jaJVKJ/Yt+uSYgw51VvemlXcSfeoVdsJc07y2QtyO4L8
	nmD4L6OE+gz6GYNaXfdA7i6FWKF/QAUQWWnfRcvgHn1nt2Qf0dRpWftbbdgPFuFS
	sXxhLNaWPHiQvY5SZhIxxBb5w16pFOccZw==
Received: from mx0b-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4g76xd21q6-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:24 -0400 (EDT)
Received: from pps.filterd (m0144104.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P4bBjg889540
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:23 -0400
Received: from esapsmtplv08.us.dell.com (esapsmtplv08.us.dell.com [143.166.203.145])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4g946b9ahw-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:23 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787640744; x=1819176744;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=Zg3iYRJh8jtyW+x4oOnypE/48WuL5KAtuUM9UnQDvNw=;
  b=Ni7eD5kmWnWXOts5VBLa3qi72nsFj/qwqfjKRJbh9g+I3uCLfrrTp3vb
   ZmYwwC0ZoNCngN+bpnaxyemQjpnjZFZT4uLql4QxyVdFAFJXKN7qlkjQa
   4iYcUQAQ4WNndLHg+zZ5hrpoOQywDIu+fRvFLbGYb4FYARpPg0m3v99UO
   e5Jv6ox4zc4S+LxRxk58X25hyuasPQ/bd5yqt/RdoDJpLQyWwPVhx0VPV
   bLjcg1p2FGwKFY1HNSk7dT2DczbTaN3uo0i2vYzZ8KZfRtYvdeawWwNmC
   OGKK2p+dVL/PzcLqpsDeg6dANm4zWtyUwkPwemZ+/TSxaNrl4wPg2nxWT
   Q==;
X-CSE-ConnectionGUID: fQpsAkJuSUqJGGca7+Z/cQ==
X-CSE-MsgGUID: sqSNKRK4RvigyWJSvbzYtg==
X-LoopCount0: from 10.94.13.48
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.13.48])
  by esapsmtplv08.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 25 Aug 2026 06:52:21 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: steved@redhat.com
Cc: cel@kernel.org, jlayton@kernel.org, linux-nfs@vger.kernel.org,
        Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v1 0/3] nfsdctl: list NFSv4 clients
Date: Tue, 25 Aug 2026 06:52:12 +0000
Message-ID: <cover.1787639206.git.prabhakar.pujeri@dell.com>
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
 phishscore=0 suspectscore=0 malwarescore=0 impostorscore=0 adultscore=0
 clxscore=1015 bulkscore=0 lowpriorityscore=0 spamscore=0 priorityscore=1501
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608250056
X-Proofpoint-GUID: sQUsY6d40Fzil0kO4XcI7hwTqrw6E4OX
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX/pV3qGLtYYHu
 NDcc+DSy9BBoghN3MoB4VHZUYzCgMnaH62X3FQV3LaNm9Pjpoc1w3cOnEeTK4UOTY8/jLndac1g
 iJf0G47oF5655KvjHjoKEe+ZXv7aaBmsDm4KDD/tzquL/5mcFYx/jjy4cNlrV2j9srt28oaxEth
 XH65iXzQzasLGKggnkjHXnaDC1Abl1Y7nR1oSR9/REpEaY6+0ntmOCEsFq3cP6xHLqa9NDu4uE7
 quZvWb3X+usEKjCVgkL9UwtgKeeVdMkBIRDLSSO9dHEvN2xaf81U82haf2HV2Uhh9v4g94K6DQj
 0XaEXChj4pjOL8asbzAZht4d8NQFQ1F49QCaLsu7pdy0ARB1y4mUs4m3Y35/4SDCuoJGHidUOjk
 F7DkDOlVd/6YIXjvso0P1uRgrHPbPQFzbBmAVWUDjyPMwLDmkUPaFqO6+IrKzdGOmaDGbsW8Eyj
 +PYCw8nDaMqXUpi0hYg==
X-Proofpoint-ORIG-GUID: sQUsY6d40Fzil0kO4XcI7hwTqrw6E4OX
X-Authority-Analysis: v=2.4 cv=A79c+aWG c=1 sm=1 tr=0 ts=6a8d3ba8 cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=7aFXbidJGpJUqALx8qt4zQ==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=m3zZTHMLHbwB7Lmtoed2:22 a=iLNU1ar6AAAA:8
 a=X3nbaGD60Uun2pRVtKcA:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX9pGmDT2Y2Vnz
 vxryEPwSB85A7BH13iArz3oOdp4wioVAAuivDVRuxChW+M1U4gbKQn3GrGkFAlhUvojP6rrwNZb
 xt9W/1wZ7AZ9qO1pl/ec6yRxImwiP2s=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 priorityscore=1501 clxscore=1015 suspectscore=0 lowpriorityscore=0
 malwarescore=0 bulkscore=0 impostorscore=0 phishscore=0 adultscore=0
 spamscore=0 classifier=typeunknown authscore=0 authtc= authcc= route=outbound
 adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608250057

Add the userspace consumer for the companion NFSD Netlink client-state
series, whose cover Message-ID is:

  <cover.1787638668.git.prabhakar.pujeri@dell.com>

The series mirrors the kernel ABI split:

  1. Display the explicit recovery-grace value returned by threads-get.
  2. Add a privileged `nfsdctl clients` table for basic client state.
  3. Extend the table with session and stateid record counts.

Attribute presence remains the compatibility boundary. An older kernel
omits the grace value, and missing count attributes are displayed as
dashes. The bundled UAPI header permits building before the new kernel
header is installed. The configure probe requires the final count
attribute, so a system header containing only the base client command also
falls back to the complete bundled copy.

Validation performed:

  - full nfs-utils build at each applicable patch state
  - final `make check`: no failures; one environment-dependent test skipped
  - bundled nfsd Netlink UAPI compared byte-for-byte with the kernel copy
  - two-vCPU QEMU test with a live NFSv4.2 loopback mount
  - grace yes/no transitions displayed by `nfsdctl threads`
  - live client row showing one session, open stateid, lock stateid, and
    delegation stateid; zero layout stateids
  - callback, reclaim, lease, peer-address, and client-ID fields checked

The series is based on the current nfs-utils master branch. The exact base
is recorded in the base-commit trailer below.

Prabhakar Pujeri (3):
  nfsdctl: report NFSv4 grace state
  nfsdctl: add a command to list NFSv4 clients
  nfsdctl: display per-client NFSv4 state usage

 configure.ac                   |   2 +-
 support/include/nfsd_netlink.h |  41 +++++
 utils/nfsdctl/nfsdctl.8        |  22 ++-
 utils/nfsdctl/nfsdctl.adoc     |  15 +-
 utils/nfsdctl/nfsdctl.c        | 268 +++++++++++++++++++++++++++++++++
 5 files changed, 345 insertions(+), 3 deletions(-)


base-commit: 67ed1bdb1af1c70a5fd3b377a997401b7676b827
-- 
2.54.0
