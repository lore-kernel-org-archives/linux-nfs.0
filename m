Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7BB872620DE
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 04:59:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787806768; cv=none; b=H0GUgXf1ZuWIvY03P7jnWB/wZDSoolaTpchlckCwDERik9qj0HRTKN+1nQ/goXh8HTqNIyUJqxYutwdGRjFF3w6viJE+Mtl1mzxfRQgwLHDi78VlLQgkhjmefz2FffkjIW8iQmTf+8T+UlNi1v1PKwj6t8ZTTnp4WyR/smb8Z08=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787806768; c=relaxed/simple;
	bh=1KhsHzpqnDqyZGnr6eNW8QCWOwEw46fvWSe1zHw+V5A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MytxRXJTzt11YI1tkcZH9fDCFPl74UOe/XP8sG4EMzKkQzlk/vuCsPjMQdn/Q1oY5Fck6NOH+U6NtD5DJFSPZd28A5j7jv1ySR7T2NjVmnEC7TKSdoQtABvSZwLAdYMBolUO55V9DXoRoN0XpW9tVL3EPVwn8RDoT28RKh+dAgA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=vTc9R4du; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=Eytpffhh; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="vTc9R4du";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="Eytpffhh"
Received: from pps.filterd (m0170390.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67R3HYgI1513432
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 00:59:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=8nF11ZanslR7
	I3IQiCOLtuCjx+lqtM6paKjOiUPX7w4=; b=vTc9R4dumbckddZ0humTGMN5zIJE
	yMqy60NQv6xyayUifqipnLULH7dUSBW3cyQIqxbUYpr7T/TsHCtUMFMzEP3P2Mkz
	ufCHqyMtCynIsIUptzXoXstQLBjeJ3R8GkZ1KYHjg8l7bHAXL8zgRWoKgqT9nyHK
	ubHtY3RMGHyiwavs1Fli96Y6+29Ad7vUsHby6fix6MQHnqbWpCcf5SclvJBq8d+g
	Xshr2j5PQWlEStWJI/3SYK9zFJywJTT0aHSq78XeR9UgK0n0E8cII982/URJK3oA
	wRg+N74FBmKeFJqOMhVODirZHkQZDNp3FOWplsV1WypCu0RyrD1YxfLCdA==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4g76tych2m-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 00:59:26 -0400 (EDT)
Received: from pps.filterd (m0090351.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67R4UMx6351941
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 00:59:26 -0400
Received: from esapsmtplv04.us.dell.com (esapsmtplv04.us.dell.com [143.166.203.152])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gae96g7yj-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 00:59:26 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787806767; x=1819342767;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=8nF11ZanslR7I3IQiCOLtuCjx+lqtM6paKjOiUPX7w4=;
  b=Eytpffhh8emlk0fz8U4S0jaB4YMNuhFRX4lazrlp7dDFCHOmdcu+DMgj
   sK+69Dq5D8DuKNIkp8oniBxfoNBxkhCdCX+nK71ZhqBIatls6E6AbzTUG
   Fn355kWiW/rI/8PwqdWY39//t7XmmERc8VhDEBytaMj9SMMsr8ID+ue/q
   F2zeO3x35wgE5PKPgCRWDvGjKepmaw2Wqj5YW/CalehB4guKGJcvULUEN
   QD0mWzLaw4nPLIjZUuCOg5BCHiCdapAFK84H3YMxlEFeDtOQ365/zbf3H
   0U8AI2RT0SzGLhgJt4idiWl8ZJp01E5mTLX16KVl3RRHlY/khsSaMcIxd
   Q==;
X-CSE-ConnectionGUID: ZYSuAv0pRtmtV9w515cXlA==
X-CSE-MsgGUID: 1J8Wm+0yS7+dVnMGGviHIQ==
X-LoopCount0: from 10.94.13.48
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.13.48])
  by esapsmtplv04.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 27 Aug 2026 04:59:23 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Chuck Lever <cel@kernel.org>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
        Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
        Tom Talpey <tom@talpey.com>, Rick Macklem <rmacklem@uoguelph.ca>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: release POSIX ACLs of unexecuted compound ops
Date: Thu, 27 Aug 2026 04:59:19 +0000
Message-ID: <20260827045920.4737-1-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <2805508b-99b1-4bfd-bdd5-cd07ba0789f5@app.fastmail.com>
References: <20260823113255.3417-1-prabhakar.pujeri@dell.com> <2805508b-99b1-4bfd-bdd5-cd07ba0789f5@app.fastmail.com>
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
 priorityscore=1501 impostorscore=0 phishscore=0 bulkscore=0
 lowpriorityscore=0 clxscore=1015 adultscore=0 spamscore=0 malwarescore=0
 suspectscore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608270038
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI3MDAzOCBTYWx0ZWRfX9RCtE6yq8gUI
 Ay5tt1cPXDFF/ouG8gbXrG8bosJu1UHVQIXl/37sUO2xOEFUZxNp0tcZlkOqmC3KKkA98Y+1q79
 MvFEfTQxS8o0On3HWFXiTssnNHD95PouIOx4ytzoBuVoEfaPo97xmxEwFJ3Ewg7xXI0hKfTIPsD
 e5hcrZgPbNgnLbA/J3UIioNWLS2lZwE/i0RacdQRJlfVri2Yw+7cIQktCPyYlEL+Sr5EBOk4AnB
 5SlJxF95vDJ/zvtExQHzMaxOYmE/U/59vAwtNMPKbHXWFL6ZXHCV66cv2+feew5iUTiHLREp1aS
 wRhq2DLSJEExsQHRJ5Ml6Dp7VVqk0crxCBk6ZUDXUtDgcwGA/wPwbyNS5A3T473RoMOPGSXGVlJ
 0oLuPQQu/C9tKyxwkskFw7ls8vY/ck0SYH2OEyvD+auKiQK8xgJ8i+e3tHqam/eS0dmc/3c5FHN
 Uw/B4p/xHkVcxRDz/yA==
X-Proofpoint-GUID: iTQfZvJIoY-flLC4Ou4dTbDnmQpC7VK4
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI3MDAzOCBTYWx0ZWRfX45CvS2vwA3vd
 fcOfjOnGNqP2AUuMTYBbTwfGWb91p8dfSxO419iOj+g9I7/5R37uR0J3/Iq99zn8uWABMSFG1WZ
 AOtr+jlfWV14YfNp0G/M2Iv6W5bdh3I=
X-Proofpoint-ORIG-GUID: iTQfZvJIoY-flLC4Ou4dTbDnmQpC7VK4
X-Authority-Analysis: v=2.4 cv=BMGDalQG c=1 sm=1 tr=0 ts=6a8fc42e cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=XtseytAk/c9oG0Kwoj6KRQ==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=sEWawkeXllE7TocFc0N_:22 a=sJCFo_cA0p22xgH3cmUA:9
 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 lowpriorityscore=0 malwarescore=0 clxscore=1015 spamscore=0
 priorityscore=1501 adultscore=0 phishscore=0 suspectscore=0 impostorscore=0
 bulkscore=0 classifier=typeunknown authscore=0 authtc= authcc= route=outbound
 adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608270038

On Sat, Aug 23, 2026, at 12:17 PM, Chuck Lever wrote:
> Thanks for the report. I agree with the diagnosis and its status as
> triggerable by a remote. After careful review, I have decided to
> split the work into two patches.
>
> Your two opcnt assignments fix something separate from the ACL leak,
> and that fix needs to be backported to stable kernels.

Thanks, the split makes sense, and separating the opcnt fix so it can
go to stable on its own is clearly the right call -- it stands
independent of the ACL question and is the part with the wider blast
radius.

> For the ACL half, the underlying issue is that ->set_acl() borrows
> the caller's reference rather than consuming it. That makes pointer
> ownership the true root cause, which IMHO needs a different approach
> than your proposed fix.

Agreed. My sweep in nfsd4_release_compoundargs() cleans up the symptom
at teardown; putting the fix at the ownership boundary is the more
durable answer, and it makes the release path idempotent by
construction rather than by careful pointer-clearing. Happy to defer to
your version. Since POSIX ACLs in NFSv4 are experimental and off by
default, treating the ACL half as mainline-only with no backport also
seems right.

I'll hold my patch and review/test yours once it's posted; please keep
me on Cc so I can give it a Tested-by against the reproducer below.

> I'll post these as a two-patch series soon for you to review and try
> out.
>
> Can you share the test that generated the 512 crafted compounds?

Yes. The shape of it:

  - Build a single NFSv4.1 COMPOUND that decodes an ACL-bearing op
    (OP_SETATTR with a fattr4 carrying an ACL, or OP_OPEN with an
    attr set) and then place, immediately after it, an operation that
    makes compound processing stop before the ACL-bearing op is
    executed -- so the ACL is allocated during decode but never
    reaches ->set_acl() and its op_release() never runs.
  - Fire that compound N times (N=512 in my run) and watch
    kmalloc-tracked posix_acl allocations climb monotonically with no
    matching frees, e.g. via the posix_acl slab in /proc/slabinfo or a
    kmemleak scan.
  - Baseline vs patched: unpatched leaks one ACL per iteration;
    patched holds flat.

I ran it as a small raw-XDR client harness rather than through pynfs;
I'll clean it up and attach it here (or push it somewhere you can pull)
so it drops straight into your test setup. If you'd rather I fold it in
as a pynfs case so it lives with the existing NFSv4 tests, say the word
and I'll target that instead.

Thanks again for picking this up.

--
Prabhakar
