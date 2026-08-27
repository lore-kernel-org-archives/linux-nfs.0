Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D66157082D;
	Thu, 27 Aug 2026 04:51:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787806317; cv=none; b=OtzivX+1jsD9nEJcE753ns+NGg/f2L/xEBtGaznQFxp23XPZbSs0s+akRz9F6bnPnXHUjIrIrMDLLnqY2J6jBSzjwFg3AD+WH65Gn5Rk3RysL1NoNYBuQmjPr86I+lC51zgU0c83Ib6jmIPwaQKYL2khIH719CPkFZ84qNV+Xgs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787806317; c=relaxed/simple;
	bh=Xgse6h7bd5lA35XNrEmB9AIxaGP2ov/gYrlT0u3BAWw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QyxkQRJ7l4EtsrDFySt1x3lLAB32qxWt4QbzHVrO7u7IKm7LGLzLkjiOejueQkGs8WXjkZV/DPGalGXOWyhO+/3VD0tr4XzEkglArfp+UiRUcMd0fltZpO1OwFEBrs5KeSYnFnYhYFbEj3Ocz49KQhdsZLO3nEDATtJlJhFibts=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=jBmvrnUd; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=PfGGo5BL; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="jBmvrnUd";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="PfGGo5BL"
Received: from pps.filterd (m0170389.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67R3Hcoe3093841;
	Thu, 27 Aug 2026 00:51:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=T2RB/2li44XP
	m884BMP9QF2DhhDtOGSY5T1bKBnUfFw=; b=jBmvrnUdhVvPEX6r2sOBJJq2ww5y
	2X1QuXOV3beeMgKLHHkgSe9BWH+nybrv9efbsPXzdXqS6nIDFN4BxGdsMNPCEEGr
	epPzNYTyqnBPitz5RIb1SNG2tS3Zx/VYVDxlyNgBfwHOGi1hafA2JM7y8/Hd65B7
	z4NYy2yVgekKV1STme/xb9TxLfMtH/a/5BdV1bTMKQS+3BuTYPpopv2gxR2Kn1tn
	7rnSo7S7U31mfLcBUF+ziRURhLUJw+TVeFSl7zWXnppsk4D7v7uKKY3CuOXX/NDN
	T8KDOHHtGeqN0kC7HmE+7SkvOnNuPugfvG4uUxslNlaxipH5jUJID9WwHQ==
Received: from mx0b-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4g77sema3b-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Thu, 27 Aug 2026 00:51:48 -0400 (EDT)
Received: from pps.filterd (m0089483.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67R3eEfc053434;
	Thu, 27 Aug 2026 00:51:47 -0400
Received: from esapsmtplv05.us.dell.com (esapsmtplv05.us.dell.com [143.166.203.153])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4ga69n5tm2-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Thu, 27 Aug 2026 00:51:47 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787806307; x=1819342307;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=T2RB/2li44XPm884BMP9QF2DhhDtOGSY5T1bKBnUfFw=;
  b=PfGGo5BLcNmjkBe6J/fjJCXf/RjvTKk4/5exbLbqY0M6G6hhKZQb8z5L
   GhplIxTkv7TJ/aEFRCRpDpjMXootaeUnlPrRyNvAFTyhJd3yW39NQUCNN
   dZ+BZbsp1kiqvPZHbQIT5ckW1WxjeIJCLA/fTNdkPmNGalxSJJD9Kokxj
   rCq354bFL8++mzinvl7U7QiePjKyznv2gSUB9ndPe//vr1FTz3HSg9VKc
   y5Btp9SyJd/b3S3GlN6wDRbW1DPXZ7n/pH8MqKW274HQ1CmuJ8BdWg5kY
   sPp7MhO9lJJrZrchex/gvXBTsI+YJ9jlKetNaIVQbfo9UBbx9QlCNomJW
   g==;
X-CSE-ConnectionGUID: /r5jaFZ+So2BYxY6OnPNIA==
X-CSE-MsgGUID: GLU43B+qTH2mhIhzNcDxig==
X-LoopCount0: from 10.94.13.48
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.13.48])
  by esapsmtplv05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 27 Aug 2026 04:51:43 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, Chuck Lever <cel@kernel.org>,
        NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
        Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
        Donald Hunter <donald.hunter@gmail.com>,
        Jakub Kicinski <kuba@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v1 1/3] nfsd: report NFSv4 grace state through Netlink
Date: Thu, 27 Aug 2026 04:51:39 +0000
Message-ID: <20260827045139.4353-1-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <1046756851d9d7d688ac612a7f175e48745d2b84.camel@kernel.org>
References: <3fd25e2178458fbb44f57f1b0e068c12a6503d17.1787638668.git.prabhakar.pujeri@dell.com> <1046756851d9d7d688ac612a7f175e48745d2b84.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-27_02,2026-08-26_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 clxscore=1015 adultscore=0 spamscore=0 malwarescore=0 priorityscore=1501
 phishscore=0 impostorscore=0 bulkscore=0 suspectscore=0 lowpriorityscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608270037
X-Proofpoint-GUID: nNw38OqJL0HoBlwxVIn1Za71GUCVtCVi
X-Authority-Analysis: v=2.4 cv=AobeGu9P c=1 sm=1 tr=0 ts=6a8fc264 cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=t4Iba6VQkoKuxR139xjPXA==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=PpEg0BoV_A2aca28hXd0:22 a=iTTXWCemjofwsjQ5oiUA:9
 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-ORIG-GUID: nNw38OqJL0HoBlwxVIn1Za71GUCVtCVi
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI3MDAzNyBTYWx0ZWRfX8RGkwRy6CAQg
 mwJjXOPDDBvt4ifH+L7H+0HVeCqsv3VfLOAgozADIZ6XXUQCaJQbCyHJrsXR6sPNxP9KbEWJ5hU
 ZV3TR5Qfs6N/r4A7KePtCN6HRRpDR8uCkxwgWmEe6q1g72/8pMemGO6PUvaolFJwbP+MbEXN5F8
 qdn22OOYWLqSvIpVa6gy9VOy70QtLh0b1wC0Jn3z+ahEbK2L/i1zasED+eE7jo6MnbcZP6Zeclw
 tszeHpmwSGh8v9BU7yu+lL85i0RPCMLglRYwsnX4guz28bk3xN4R9cB2niL0+OA62EuGT9aEG3V
 PVBfz3Kg+gqtFzQnSdFLWrrarfJh5rXBXmPNFkS67yOggPWN7QocrrQ/fyqPayC9iX0JFQft52P
 yYZxC7ypqj/8f1vMU+rmOfEe9+fxbq7ZDDEROyYMRmtiVRKvHUizomA+LyGqp3mppKY9eNPDFFy
 nj9mkKkYdphveA11lTw==
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI3MDAzNyBTYWx0ZWRfXxAg3zp0yF/DX
 FWPYJc+5fSl50jqQSzqITRBoJKK/zCnJRzA4GLOIPFytEEq0hRt/bcuHiQ0wPLIu2vfTpGhsfud
 jjb515h/1qk9mB/cjdOOqLlLemYGYXQ=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0
 adultscore=0 clxscore=1015 phishscore=0 bulkscore=0 spamscore=0
 impostorscore=0 malwarescore=0 priorityscore=1501 lowpriorityscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608270037

On Tue, 2026-08-25 at 08:10 -0400, Jeff Layton wrote:
> What's your interest in reporting this info?

My interest is in making nfsd's operational state observable to
monitoring and validation tooling without parsing nfsdfs.

Concretely, I'm building a validation harness for NFS server
restart and failover behaviour: bounce the server, drive reclaim from a
set of clients, and check that state comes back the way it should. That
kind of test has to know when the grace period has actually lifted
before it can move on to the next phase. Polling
/proc/fs/nfsd/v4_end_grace works, but it is a text interface, it only
answers for nfsd's v4 lock manager, and new nfsd control and
observability interfaces are going to the netlink family instead.

So I would rather frame this as parity than as new information: grace
state is already exported, this puts it on the interface that is
replacing the one exporting it, and -- per your point below -- fixes
the semantics on the way over.

> Just because the v4 recovery is done does not mean that you will be
> able to access files. The overall system grace period is a union of
> both the NLM and v4 grace periods.
>
> This patch is reporting just the v4 one. If the goal is for the admin
> to reliably tell when the grace period has been lifted, then this
> won't tell us that.

Agreed, and "has the grace period lifted" is the question I actually
care about. I mirrored the semantics of /proc/fs/nfsd/v4_end_grace
without stopping to ask whether those were the useful semantics to
expose in a new interface. They aren't.

> Maybe this should just return the result of locks_in_grace() instead?
>
> Or, do you plan to add similar functionality to lockd? Then you can
> just do the union in userland to figure out if it has been lifted.

I don't think lockd needs to grow anything -- fs/nfs_common/grace.c
already gives us both halves, and nfsd calls into both helpers today:

  - locks_in_grace() is the union you describe: true while any lock
    manager in the net ns is still in grace.

  - opens_in_grace() is true only while a manager with ->block_opens
    is in grace, which per the comment on struct lock_manager is the
    NFSv4-and-up case; NLM doesn't set it.

So for v2 I'll report locks_in_grace(), which answers "can this server
hand out normal locks and opens yet" rather than "is nfsd's v4 lock
manager done". If it's ever worth distinguishing the two, a second
attribute carrying opens_in_grace() gets there without touching lockd,
and userland can derive the NLM-only case as (locks && !opens). I'd
rather not add that speculatively, but say the word if you'd like both
in v2.

Two things fall out of the switch, both improvements:

  - The #ifdef CONFIG_NFSD_V4 and the open-coded
    nfsd_vers()/NFSD_NET_UP/NFSD_NET_GRACE_ENDED test all go away.
    NFSD selects LOCKD which selects GRACE_PERIOD, so the helper is
    always available, and a lock manager that isn't running simply
    isn't on the grace list.

  - It stops being a v4-specific answer that just happens to be served
    out of the nfsd netlink family.

I'll rename the attribute and fix the yaml and rst wording so the
union semantics are explicit rather than implied.

One design question while I'm respinning. threads-get otherwise
reports configuration, and this is dynamic state, so grace could
equally live in its own operation. My inclination is to keep just this
boolean on threads-get for now, since that is the direct nfsdfs
parity, and to grow any richer grace/recovery detail -- elapsed time,
expected vs completed reclaims, whether grace was extended or
force-ended -- as a separate operation later rather than widening
threads-get. But if you'd rather grace not ride on threads-get at all
and start that separate op now, I'm glad to go that way instead.

Thanks for the review.

--
Prabhakar
