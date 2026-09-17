Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 012DA4B8285
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 10:30:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789641067; cv=none; b=o3BBtj/uL0MgNtLnIfuC15VuCBsnqaaopNNr58c6UkPPjQc1Q16MzhgrDv3nzofZmWEAJwZ9kyHi55tkZgtevjOa8GlN0EebqsXtFjlfDqhrVyrfsKkTqvqdAH2MvFFmQtBb8GNVIPX2uUc8T3E4q0tgQhIkznSkvhunk1ChVfw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789641067; c=relaxed/simple;
	bh=0ZzK31dCFLedBqQWXgf+xt3vjW+esUNCNbiPc11RGb0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=d1mba5uNtkJOalTiZoiy0pN4wlegOIUojX3sUkVPycJbKFDRAqsm/9gYHtooulTT7fjrg666CSacK3mbL0Qb38fQV3qBFJ0Q9weg/xVH/TJurb4k1iNeCwsIOboC1yL/vXQu65K+Lf0sN/cv/wFipX3htN3dlM+w1jypDZzOtdU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=YCsGDU30; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=F1Jg3hyz; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="YCsGDU30";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="F1Jg3hyz"
Received: from pps.filterd (m0170391.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 68H9b7sY1686279
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 06:30:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=smtpout1; bh=z
	tvrA7LNlG1aZDAQpYv0aVD1ymXPAaMOTv1oVMGbGhM=; b=YCsGDU30MiyhIH5v4
	xRdqMJjL9DgMqLsaPkmqoEFuedOl8jRcUvLq6PHX2tcp1lclZVyjD1VqUKi+UbTY
	tRYaw6Y9QpChADzVwsh8wILHtkWP1uDZfcowzPNaKkkdwDRHDRhH8ZH/lw9tGn0U
	NrRMzKnE/9lMmCfjwlK6QvTKRSfZqGBHEHKF07qcbtATc/epw/+RpJ+RydE2qNI+
	lgxfPM3mHQVTSK9naxF6vgdBKTThp52CG7A9bSJTVNhTHqUEp1PShNqBIeScuAV7
	x/RQXIt8hY1ivQc6+p0JhqCS2zia1kdAMLFsLg1QY3VkXwGdw6qlu5I8nXQABJW+
	Qv04A==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4gn1vsdsta-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 06:30:52 -0400 (EDT)
Received: from pps.filterd (m0142699.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 68H9cvAj1083292
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 06:30:51 -0400
Received: from esapsmtpat03.us.dell.com (esapsmtpat03.us.dell.com [143.166.211.152])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gratnjy55-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 06:30:51 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1789641052; x=1821177052;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=ztvrA7LNlG1aZDAQpYv0aVD1ymXPAaMOTv1oVMGbGhM=;
  b=F1Jg3hyzrLL2YFJfsq4VSHKLo7y2rwUEUFiiXAtsvAcCX/MvDkfT636P
   tMiBvslh8NtoFygliCXyusASQFbqX2YEsX1uIhiNoxOInUb8I/L/XSDO2
   f6lW4tlIngqA1GqUuxsymRHO7gjX7z2UpAVNj7db8w0m50TTByhuZop+l
   uqwi3rZW3C0R50i/ryr/ckG46JhnFXUcCdLiNnAvYaTDA6cUBUfVDIfIw
   74qaq2UmZ+HdhQwl9r76K/r1LZRaEMk+N3mhshkpm/ORYWHKc2ON5zm6Z
   f5UVKueifb5+IHxsrgLiT9n9ZfgaHBm543LBCbTjUl+ks6xx4zFj+8WX8
   Q==;
X-CSE-ConnectionGUID: PC8DfOf1TaCcOLifAghfBA==
X-CSE-MsgGUID: CEpnHCCnS9arG58zngXHiw==
X-LoopCount0: from 10.94.9.174
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.9.174])
  by esapsmtpat03.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 17 Sep 2026 10:30:49 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Chuck Lever <cel@kernel.org>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [v1] NFS: use TCP for MOUNT when xprtsec= selects TLS
Date: Thu, 17 Sep 2026 10:30:46 +0000
Message-ID: <20260917103046.16018-1-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260916204336.14436-1-cel@kernel.org>
References: <20260916204336.14436-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-09-17_02,2026-09-16_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 spamscore=0 impostorscore=0 adultscore=0 suspectscore=0 priorityscore=1501
 lowpriorityscore=0 malwarescore=0 phishscore=0 clxscore=1015 bulkscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2609040000 definitions=main-2609170145
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwOTE3MDE0NCBTYWx0ZWRfX1ZvOclBFdSI0
 MUQuFJrN1pB/XmaUZJWsu6kWQ7yN/+w0tpyKfAsGyKcjdk11IyB/F7YHHLxf6pDdamDNVOZouZ0
 KcC2I6LZTucyhM+yMTuPsAwRZJLipmVA5LPNxrpYbURmNEjM6pmNO42igmvZ4pWt7+mTwrTLgpT
 O6TbeGh5Y5hbh6GgFNt44ruy8erw4NWY+CMclYNMZXEpev/unYnlwRv6Jv29LIzYghLXpzxM2Ql
 kcDKWU1X3UPcbW1z5BB75OBUsNJR/dle7PWNXV2JNMF3pt1naLBbMB6+jJIJK3dlTyyW9/3Upii
 aIzIcZHoSoddfqmftUKEKKzbkjtHgP6WIBUdIzYb0fnh//DHXrLBG8f6bkBxQ2NfFqB8Ow7mW3I
 bxBJfW2wrngc6Hx2t/VeVF/s7ISC+SvVXoq/qJB+1GYfiEtiR7HQVVBF9b/3pYQWuXT2wN8h2ya
 L5SXwuT4VQ13sGL/X2g==
X-Proofpoint-Spam-Info: AW1haW4tMjYwOTE3MDE0NCBTYWx0ZWRfX9CNul8UZsY27
 HMn8/kEESF4TzbWDcC4zbggs821Dl9sUwk91LWuaIXR49N0/ieRfF46LJO1OW+Rup+NJvEXsv2t
 gyyhtYfPTnKgZxRxzL0w/0ctQ1GTMQc=
X-Proofpoint-GUID: me4_U421GXfYtStfHdIT3FpiCIiN-vIS
X-Authority-Analysis: v=2.4 cv=R9aWitRX c=1 sm=1 tr=0 ts=6aabc15c cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=Exi4HLWdEtKd1bGGvbjpxg==:17
 a=kj9zAlcOel0A:10 a=VdqzKS8jKosA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=aNt9FJNJ8fZyd9HhltU_:22
 a=VwQbUJbxAAAA:8 a=iLNU1ar6AAAA:8 a=sZKph9fpN2MIvm1kfg4A:9 a=CjuIK1q_8ugA:10
 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-ORIG-GUID: me4_U421GXfYtStfHdIT3FpiCIiN-vIS
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 clxscore=1015
 bulkscore=0 lowpriorityscore=0 priorityscore=1501 spamscore=0 adultscore=0
 impostorscore=0 suspectscore=0 phishscore=0 malwarescore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2609040000 definitions=main-2609170144

Hi Chuck,

Reproduced the reasoning against v7.3-rc3. nfs_server.protocol gets set
to XPRT_TRANSPORT_TCP_TLS by xprtsec=, the switch in
nfs_set_mount_transport_protocol() has no case for it, so
mount_server.protocol stays zero and nfs_init_timeout_values() lands in
its default BUG() while setting up the MOUNT client. The one added case
is the smallest correct fix:

- There are no TLS transport variants for RDMA or backchannel, so this
  case covers every selectable TLS value today.
- MOUNT running over plain TCP matches what mount.nfs already arranges
  (it probed rpcbind and appends mountproto=tcp), so no security
  downgrade: MOUNT never runs over TLS either way on NFSv2/v3 text
  mounts.

> 	case XPRT_TRANSPORT_TCP:
> +	case XPRT_TRANSPORT_TCP_TLS:
>  	case XPRT_TRANSPORT_RDMA:

looks right.

Two notes, neither blocking:

- This is a mount-time BUG() reachable via a bare fsconfig() caller
  (mount -i). With Fixes: c8407f2e560c dating to mid-2023, it feels
  worth a Cc: stable@vger.kernel.org.
- As a follow-up, not for this patch: BUG() on an unrecognized
  transport is a harsh way to fail parse-time input. A WARN + error
  would make the next unknown transport friendlier to debug, and keeps
  with the current no-new-BUG() house rule.

Reviewed-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
