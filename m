Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8F543939A9
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 05:45:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788414312; cv=none; b=guBw18o+0KQtmgvb0At8UrYFl2sovmKnebvvJuOidb8Oed2eTLfx3/Rp4/WJVcsUctO+9Oop4VIItwzLzrR0c+OGx/Agx65W7vFZ0mlpqCJi2ryFlOoY59WIabGiAQmylZvc+PT36pS7y9EpAx7VO7tGjkhXPs3GgxwCMAuWyAU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788414312; c=relaxed/simple;
	bh=du3ibYx3q1NcYSbwgVvdVnzPVApvqB1vwzFFXt4M6Tw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=tjqu6hZZFr4Fx/4FuzijGyk/IqkBt/LKKTMufRGD8w4Fk3WO5OqVCQTxJedobnjqYcGcxELsTBIl1gEgRLguXj31iN813hXSsPvzfPSVO/lH+XBb13bFY3MxPKmpLAU0qyOaSwHqWL5aAVrmtBYwgyIY42Gge9fwTOa2jXMGmnM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=kDahPZvc; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=qqRJ407O; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="kDahPZvc";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="qqRJ407O"
Received: from pps.filterd (m0170394.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 6832vp4X2726675
	for <linux-nfs@vger.kernel.org>; Thu, 3 Sep 2026 01:45:09 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=smtpout1; bh=d
	u3ibYx3q1NcYSbwgVvdVnzPVApvqB1vwzFFXt4M6Tw=; b=kDahPZvccCP73/ubq
	F4cXC0iIzWpQDdBoQJXVfajejLY4/dRjf9pj40/jroLXWT9iDin6zeTIyYzeSscA
	cNg00vJ8PIrd5wlW/Q1oiszQEkaudJurZgxY7je9gz6TDpcJAp6j+LknfmYuiAcI
	qsO/LxEaULLeqGKWwn+pfBG6DDZ3irjkbKTpyUndw9TTwiu+6aBmszyfrxFVuUJW
	0thtNgPPATlJrZdZEnFvQgnXL+Ikjl6/Jh0YH3s28JF5eatC3dsH8ZtqUXAaic5Y
	AcXHQGIkMYGeSUa6SB4oAVlnG2H1Bta8WOkQlJrvsQcINGrX0rkPKNefP4B3/Ty1
	7ymlg==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbt01wcc2-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2026 01:45:09 -0400 (EDT)
Received: from pps.filterd (m0090351.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 6833jQdH3498535
	for <linux-nfs@vger.kernel.org>; Thu, 3 Sep 2026 01:45:08 -0400
Received: from esapsmtpat05.us.dell.com (esapsmtpat05.us.dell.com [143.166.211.154])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gf0wksa3s-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2026 01:45:08 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788414308; x=1819950308;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=du3ibYx3q1NcYSbwgVvdVnzPVApvqB1vwzFFXt4M6Tw=;
  b=qqRJ407O0UZydFRIDUO7w/IGP+UKhoXcaQzDc/KxGQFcUkT4cszTgHOu
   luVmF3vkgQYJp3M14rfgK225FsyQTIX/Na1SGnpb3cY/X8L5yCi6/fGIj
   NiDgB4AAnJqVUIhIpBqEphBTeM9daXV/Ru7lD5FPQgQ7Gs5VC8SewqAEf
   HIcLlXLc7goQ02O7CTBqoYf7apZo3gLKZJTQQe3X1nKhDYhNXxWyha9Sp
   9oEp+LV8bGRzSny1zDZsQtUx8CtSC9GJ/3sPzW4BlYn/yBsO/5up46TAY
   wRlGULM7SQfzExqhdMB/zgsm3fZsfY5YlxEY/NRnntJML+nEHHcHXpwuk
   w==;
X-CSE-ConnectionGUID: XcqDbUuoTPipIQauQ6iDHQ==
X-CSE-MsgGUID: 4ZJU7HuIQMiCK7CUqqSj/A==
X-LoopCount0: from 10.94.14.196
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.14.196])
  by esapsmtpat05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 03 Sep 2026 05:45:06 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, linux-nfs@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 1/2] nfsd: add a Netlink dump of NFSv4 clients
Date: Thu,  3 Sep 2026 05:45:01 +0000
Message-ID: <20260903054501.1365-1-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <31530d8e7bc120ae48d018001e126ad345995d9c.camel@kernel.org>
References: <2d682b47dca234b5c270b0b1ea03022c28bbeaa3.1787988917.git.prabhakar.pujeri@dell.com> <31530d8e7bc120ae48d018001e126ad345995d9c.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-09-03_01,2026-09-02_04,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 adultscore=0 spamscore=0 bulkscore=0 impostorscore=0 suspectscore=0
 malwarescore=0 priorityscore=1501 phishscore=0 clxscore=1015
 lowpriorityscore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2609030049
X-Proofpoint-ORIG-GUID: KJznVnmI3CWSMUcdq1hYq1PHgMAto-eK
X-Proofpoint-GUID: KJznVnmI3CWSMUcdq1hYq1PHgMAto-eK
X-Authority-Analysis: v=2.4 cv=H67rBeYi c=1 sm=1 tr=0 ts=6a990965 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=uswt3CficuEu8DJvSCSroA==:17
 a=IkcTkHD0fZMA:10 a=VdqzKS8jKosA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=gLxAKuEMs0EQMVFiDJnH:22
 a=aU3BLVHYNG9BcryuNOQA:9 a=QEXdDO2ut3YA:10 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwOTAzMDA0OSBTYWx0ZWRfX87i3p5xqxhIN
 uZBy3M2+1aslYlKjqMuG1Rl0XyF7wxxDmCHDmMqYH6wj1bwOe1Zpx8GIkJrF/rb89CElJWF2rr2
 HSctzAyHED7usjxQ4gp+LA0CcgrLQfY=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwOTAzMDA0OSBTYWx0ZWRfX1A4ohmSCx6Ta
 vEZqHak5vs42Vco02Cc4oiQ9uIITwXeacpZCa3x/m+SFsJIFVxhDRioGgskGtmmFClDrDwXnIgf
 QoCwF25f7nF4cYWZ5ixqCe/J3p+2jAvCEaonD/YAjKRHag7mEgd6tdmm2Qrtabfl7MyxS77gdOV
 yWfrCTM7OnLuQdQS4II47wNMzgj4m2MDqmsB4VW7vFaDBQyCQzvkDu8ECECpy4+ZFKUbvcNSrnQ
 jNqCnQxt/0UOHnytAOTpm1YlQVytGC/vaSNdYpYBeoG6j71krdPfsoM0jy7X571M63w7UAFVOgy
 8CXw1XbNZV+BhD85Q1nzwzBlAYSAkUgI5py6U6zhhMJhBjp2AF3emXGyM5LRyInDFs+LwiYe3AI
 0NHyOYbNCh3fYZa15F/AQhBKeIkn1+KP2lWtEpG8VM/BZcT7jtRiaP6vYAISUxDVo9z+IeBvzZC
 OzkFdAmHhD4Osz131Eg==
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 bulkscore=0
 priorityscore=1501 spamscore=0 clxscore=1015 lowpriorityscore=0
 suspectscore=0 phishscore=0 impostorscore=0 malwarescore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2609030049

On Tue, 2026-09-01 at 14:02 +0000, Jeff Layton wrote:
> I'd call this nfsd_nl_find_client() as we usually use "get" in terms of
> reference counting.

Good point, renamed in v3.

> This means that table == NFSD4_NL_CLIENT_DONE means the same an
> "UNCONFIRMED". The caller shouldn't call it in that case I guess, but
> this is a lack of defensive programming.

Fixed: nfsd_nl_find_client() now selects the table via an explicit
switch and returns NULL for any unexpected value.

> In nfsd, we often use "put" with reference counting, so looking at this
> cold, this is confusingly named. Maybe change this to be named
> nfsd4_nl_client_marshal_address() ?

Renamed as suggested.

> This while loop is a bit too clever for our own good. cb->args[0] is
> effectively a state enum, so why are we incrementing through its
> values? It's looking at confirmed, then unconfirmed clients, but that's
> not evident here.

Agreed; the table ordering is now documented where the loop is, and the
comment states that args[0..2] track table, bucket, and offset. The
enum itself keeps its declaration order (confirmed, unconfirmed, done),
so the iteration order is visible at both sites.

(Alternatively, if you would prefer an explicit two-phase loop over an
array of tables rather than relying on enum order, say so and I'll
restructure it that way instead.)

Thanks for the review!
-- Prabhakar
