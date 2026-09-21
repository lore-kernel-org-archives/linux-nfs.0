Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69AFC261B71
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 04:47:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789966067; cv=none; b=oCG/3/uXIWHWCI4NmgkZ1NAhM9ASq1q98qjBb87zkEzJj0d1Kc1zkIyKRRbeNbhyLRlDJJKFtYFsae/uhbdfNk+CQWR36406gAiNPSMdar7khAs7qiQSAnQVgmOO9DWtGnp3SppJvmAWC/roLjJLoNPEkEuSk2ww0Ews6GTYNJc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789966067; c=relaxed/simple;
	bh=L00a45TD8r3Snjji/Hb1MMtxBP1RQPeqnleGtb0kOoI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=SOZiM8G7EjcFAUklqL0mqogzrGv/ivYPMBiLQYN13LHynQbc7ST6l3yLGTG+HGkXUk2MU/W69vQ2EqpICO5vuIJ5y2RDZvozJ+S9PGd1efvJGPVcSr2X9ItZdK/NrcJ2e48bJ8d8wa3H51vjr/L8sW3N4G+R3oRr77PvAA+jL38=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=BP0MKW/A; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=An4R7czw; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="BP0MKW/A";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="An4R7czw"
Received: from pps.filterd (m0170398.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 68L3YjIF3696124
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 00:47:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=smtpout1; bh=O
	Bn51F0a2qRFvTOy2pWfpV/3V3jOBoZqVih6sWymTqI=; b=BP0MKW/Aruc5ZIaNA
	fsePE+4OpHIp/4qpivq49coDjm/a4wctOovEBBcxNNQ0I8C7Gzs0wSA/TY3ffVr0
	FXywaFYfd4VK82px4zCsyibIFDfvmKrxDrmrk/f7nm2l6WqTTh+H52RP9Lpkn05c
	X8feFa/QmKi9bHsmrHp1ETxKwJxNmOYcZvFsjsNL8zOTDYrM6Lo7kQ7GBjpDt9jL
	te24LP+OjMXl4t4tkm/J85SYcKOmLWlbAlf/pEsUhdOfgnXY04YNroSm1dUF0WfG
	xoJt77/E/trj5gfE0g+7RCk0AZC1pQuTjM48W5DSqBaW5QSW7k6TFrLhB+33fW24
	sT08w==
Received: from mx0b-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gsnm2mfq5-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 00:47:38 -0400 (EDT)
Received: from pps.filterd (m0144103.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 68L3XqHA3476604
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 00:47:38 -0400
Received: from esapsmtplv03.us.dell.com (esapsmtplv03.us.dell.com [143.166.203.148])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gtgw3p531-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 00:47:38 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1789966058; x=1821502058;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=OBn51F0a2qRFvTOy2pWfpV/3V3jOBoZqVih6sWymTqI=;
  b=An4R7czwrTyVq7FUGd2HdOuMAA+uu2H8orgwOeJUlfh/Rz4+2wms3Kk+
   7+dwMQxygYI6x6tRZS+U6BI06m1Frxfs1UU29DUnO3IBGmdSabYLjsjVQ
   gf6jsWb80+OFaWRiZnDoGP+5yCp85rhLv7HqKmcz+Gc5SQNhtcbVTWSwA
   zF5ZFRptuU00IkmSh42ILF/lbVECHztu8t8OqCExMJpXQij3mlSFYfLFg
   tJZJuxYDgK4KunEYS6fa1cnI6OzsLhexu71z+jaJDAYrtubJ7N+McYaBC
   ze7NlKkLsx1EXGfgh5MD2vgeoye7rYc65IU6crygJQImLvTqx1n+Ux/16
   A==;
X-CSE-ConnectionGUID: A82qVszgQq2j9o+uDzZADw==
X-CSE-MsgGUID: elIZO0cVSsKLDzIsmXO3LQ==
X-LoopCount0: from 10.94.9.174
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.9.174])
  by esapsmtplv03.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 21 Sep 2026 04:47:35 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Tim Menninger <tmenninger@everpuredata.com>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: pNFS: avoid repeatedly cancelling I/O for the same lseg
Date: Mon, 21 Sep 2026 04:47:30 +0000
Message-ID: <20260921044730.24614-1-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260916232906.4101987-1-tmenninger@everpuredata.com>
References: <20260916232906.4101987-1-tmenninger@everpuredata.com>
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
 definitions=2026-09-21_02,2026-09-16_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 priorityscore=1501 malwarescore=0 spamscore=0 phishscore=0 clxscore=1015
 lowpriorityscore=0 bulkscore=0 adultscore=0 impostorscore=0 suspectscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2609040000 definitions=main-2609210065
X-Authority-Analysis: v=2.4 cv=Ne1zRGD4 c=1 sm=1 tr=0 ts=6ab0b6ea cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=iGMIhCliR854E25UHWhNxg==:17
 a=kj9zAlcOel0A:10 a=VdqzKS8jKosA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=vUAfKriDyi6VqHAKCLgX:22
 a=iLNU1ar6AAAA:8 a=_vj4xWLidF4nuP3LecYA:9 a=CjuIK1q_8ugA:10
 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwOTIxMDA2NSBTYWx0ZWRfX9AZCbdTnNxxj
 8Z7F2bzDfuTednAuDQgTbuY85PWM3Fb2TVE9lcxErRJPNOqVVCIQswZ5+d6YizK/SDmL+2j3fdf
 I69q4SK9/VnZwTohGTntu8Qld/w9hZk=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwOTIxMDA2NSBTYWx0ZWRfX4PxZcOQMimLJ
 sGaf618Mk8IwlOFk28K4Ls0rxrdvduYBq9u4dn91h9UZ1QE8E721GoFNYz7dgVU4WI08zrWGZiH
 IiR8zLe6+lcHdRvzSZI+qDi4Zk++b5FctHK/kLDls0EweiWAY/vyhdndQz4xaj1zcwvgRnNGFqB
 hiBAhp6e6XxLDKfnYQGzk4QjhYK6Is4YBMpMKL95EGN9kamkiNV9Ip+nBVUAlILNe3WeCX8CpPU
 baFF17CsGZrVwI6bHoDbREPhraMdJqUfWa3GjNe2HrRMhigvPfkOGfjodJ4LuDW0aDjWRX6QZ0n
 EYd8edrbATV9eIO7Hpmsp7fPUDsibMmv32sbjiGW0N3XInLcmN27TJWxMIY8Pj2MLKdc6/8H87j
 mZOmOSSTUztXvgtFWqEIHXXuF3fku1NdAb0DpcuUFWSltmTnmYXp6O+IrjH6DCuHcYLKV7px02A
 EIIKIqlnjhr/0oZ4PEw==
X-Proofpoint-GUID: 5VK32Sr4WW4XvsJuLcCTUP4--eH2k40B
X-Proofpoint-ORIG-GUID: 5VK32Sr4WW4XvsJuLcCTUP4--eH2k40B
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0
 adultscore=0 impostorscore=0 priorityscore=1501 phishscore=0 bulkscore=0
 spamscore=0 lowpriorityscore=0 malwarescore=0 clxscore=1015
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2609040000 definitions=main-2609210065

Hi Tim,

Walked both call sites in fs/nfs/pnfs.c against v7.3-rc4. The
mechanism holds: pnfs_mark_matching_lsegs_invalid() rescans plh_segs
on every recall pass, and a referenced-but-invalid lseg stays visible
to the next scan, so cancel_io() fired once per scan rather than once
per invalidation.

> +	NFS_LSEG_IO_CANCELLED,	/* IO cancelled on behalf of this lseg */

Tail of an internal enum, no ABI or wire impact; fresh lsegs start
with zeroed pls_flags, so a re-instated range still cancels on its
first invalidation.

> -	if (server->pnfs_curr_ld->cancel_io)
> +	if (server->pnfs_curr_ld->cancel_io &&
> +	    !test_and_set_bit(NFS_LSEG_IO_CANCELLED, &lseg->pls_flags))
>  		server->pnfs_curr_ld->cancel_io(lseg);

test_and_set_bit() is atomic against the concurrent recall and
layoutreturn paths, which is exactly where the duplication race
lives. Once mark_lseg_invalid() clears NFS_LSEG_VALID an lseg is
terminal -- never re-selected for new I/O -- so the bit never needs
clearing.

One bounded-behavior point: with the latch set, if the driver's
cancel_io() did not fully cancel on the first pass there is no retry
-- intentional, since the lseg is draining and cancellation is
best-effort, but worth a line in the changelog if you respin.

Posting carried no test evidence; understood if this was observed
under real RPC/RDMA data-server recovery. A reproducer pointer would
help stable reviewers assess impact. Optional.

Reviewed-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
