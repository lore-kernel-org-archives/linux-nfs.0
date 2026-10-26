Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=203.254.224.33
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792977307;
	b=DtFhiU9nW0tH+YYu8GEeav/ukeiRMCTW6gvged5ibnQx9sqjNRmjt9q1cgGFoLkS5e6+
	 x+K0lSd1CYInfCXYt6s4wvMNQE2MrFhNS20N3NWdgPld1F7QO7j5dsUPuFGtstzl5SUEj
	 Gg+w8tDO4OA32dFLMViLV+8NcObnnf3yWIY6vtWClXCmrW00Wh0agXagLOw86qNSJNJNG
	 RdmsG4fo3vOti/JpqTUihPvgjaBtc1FPS6+eEmIUDDbVgiAM8IFD7ov8UuSzDGxNLdygH
	 Gx4orEnZwfpG/UxC+Hj1CejCJNj8sEZBChmEefY2KKMmUZSoczYmrP6CVeqayEh+GLw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792977307;
	h=DMARC-Filter:Received:DKIM-Filter:DKIM-Signature:Received:Received:
	 Mime-Version:Subject:Reply-To:Sender:From:To:CC:X-Priority:
	 X-Content-Kind-Code:In-Reply-To:X-CPGS-Detection:X-Drm-Type:
	 X-Msg-Generator:X-Msg-Type:X-Reply-Demand:Message-ID:Date:
	 X-CMS-MailID:Content-Transfer-Encoding:Content-Type:X-Sendblock-Type:
	 CMS-TYPE:X-CPGSPASS:X-CPGSPASS:cpgsPolicy:X-CFilter-Loop:
	 X-CMS-RootMailID:References;
	bh=FYICWiP/sodvW/eWoG1M+2lNLwpn+fHqlwqD0Rs9/EA=;
	b=BU7Pw6xg3CEXhsKoApFECnCQ8hETLJK5DlKEmtGzJ1jpNLf/TFVvOjj2dv2aOGCcb/Xe
	 Qpu5jqvzBPLTnnzKI79fhA8WcRFyGbnViL6J1CMz+vmNAn7+wqMbSnWuVU5ToJj26WxC0
	 78yQQf889n5INKZ/LR9YGklhYhAaSGs5JF3s/cVAPIW88zeq0huCjT5ch+bPxFG64mQUb
	 Pufeym5zKEYxxU1bKOTIIi27WlylkDIEnd68acgXSjWHh9PiqdzI0pg15MIGuuvxxH7dc
	 k6/I4pjJuk5i2sYu5p50DUxH02GTKBrf2ytHqALxbUrqvdRoBYNm+uLdOwUxnquCZRw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=samsung.com;
	spf=pass smtp.mailfrom=samsung.com;
	dkim=pass header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=W1xEYFAJ;
	arc=none smtp.remote-ip=203.254.224.33
Received: from mailout3.samsung.com (mailout3.samsung.com [203.254.224.33])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 289AB606A31B
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 01:15:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 289AB606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=W1xEYFAJ
Received: from epcas2p1.samsung.com (unknown [182.195.41.53])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20261026011457epoutp039a062c93b328ec912e06f099506b4c79~h71oheqlE2677526775epoutp03b
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 01:14:57 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout3.samsung.com 20261026011457epoutp039a062c93b328ec912e06f099506b4c79~h71oheqlE2677526775epoutp03b
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1792977297;
	bh=FYICWiP/sodvW/eWoG1M+2lNLwpn+fHqlwqD0Rs9/EA=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=W1xEYFAJcH/Xn6IhCKLEl84FECn7GPYLPqvLjSHO6ilMQEpuaW4cPPGbk+KNT+QRZ
	 ol9F3VhDO/SLtVqtfDSL3gv9uGfkQ8P7RbbbtY8hXOf2Cg/VXbdG6EmurJKN1Jbl5c
	 iH6f0Hbcm+jzfLMWLyIIc40C1RbSOEQeo1Eigfbw=
Received: from epsnrtp02.localdomain (unknown [182.195.42.154]) by
	epcas2p2.samsung.com (KnoxPortal) with ESMTPS id
	20261026011456epcas2p2bd53bec33c1f05dab69207a944e62831~h71n31WhC1803618036epcas2p2H;
	Mon, 26 Oct 2026 01:14:56 +0000 (GMT)
Received: from epcas2p3.samsung.com (unknown [182.195.38.208]) by
	epsnrtp02.localdomain (Postfix) with ESMTP id 4jCbJc04Yfz2SSKh; Mon, 26 Oct
	2026 01:14:56 +0000 (GMT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Subject: RE:(2) [PATCH v2 0/4] nfsd: keep a layout whose recall overtakes
 the LAYOUTGET reply
Reply-To: daejun7.park@samsung.com
Sender: Daejun Park <daejun7.park@samsung.com>
From: Daejun Park <daejun7.park@samsung.com>
To: Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>,
	NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai
	Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
CC: Christoph Hellwig <hch@lst.de>, Benjamin Coddington
	<ben.coddington@hammerspace.com>, Trond Myklebust <trondmy@kernel.org>, Anna
	Schumaker <anna@kernel.org>, "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Daejun Park <daejun7.park@samsung.com>
X-Priority: 3
X-Content-Kind-Code: NORMAL
In-Reply-To: <2f97e4ed4ea0d1869505436be9040f810d631460.camel@kernel.org>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261026011455epcms2p34ab803ddbfe392dfe82d17f9fc21678e@epcms2p3>
Date: Mon, 26 Oct 2026 10:14:55 +0900
X-CMS-MailID: 20261026011455epcms2p34ab803ddbfe392dfe82d17f9fc21678e
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261023105411epcas2p275c8e03b419be02713d4fa676f4bb0f9
References: <2f97e4ed4ea0d1869505436be9040f810d631460.camel@kernel.org>
	<20261023-nfsd-layout-refcall-v2-0-2160bddced0c@samsung.com>
	<CGME20261023105411epcas2p275c8e03b419be02713d4fa676f4bb0f9@epcms2p3>

> I'm still reviewing this set. The code itself looks OK for the most
> part, from what I can tell, but the patch descriptions are definitely a
> bit too wordy.
[...]
>     https://github.com/danyuchn/asd-ste100-skill

Thanks for the pointer, and for taking the time to review this. Agreed,
the descriptions are too long. I'll trim them down in v3, after the rest
of your review.

Daejun
