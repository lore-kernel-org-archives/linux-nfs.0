Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=203.254.224.25
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793256245;
	b=Q863tNlE5jNZSh+23OSF5jH/WLaU+UOtE3AWQWNXgt7q2WGZGT/MtNAnUCowrDHdQhUm
	 2E0hm/TPFqxIm6ed4CF6/ercZCU8w2uV+sOUYIHl76eua9khnWbNpEaXNOdMLTSJ2VMVQ
	 j49F6u/1CmsgsTDkoa+IZQvbBxrK0KDp4eZYklYbik4Wxaa4oa4jrXH8D6vYXeAKsM3Bk
	 RcuTeaKJr2Ml7WaytismwStKX+LENNlQu3jPPLElvUd3C0vtV86pSfUSHFBfgN6wAYKut
	 LwjZudrSSxeab21r54mVbEOiHKxQu1+N4GY+bywr+TeNcf09Uea9ngaK7kj5mw7aScw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793256245;
	h=DMARC-Filter:Received:DKIM-Filter:DKIM-Signature:Received:Received:
	 Mime-Version:Subject:Reply-To:Sender:From:To:CC:X-Priority:
	 X-Content-Kind-Code:In-Reply-To:X-CPGS-Detection:X-Drm-Type:
	 X-Msg-Generator:X-Msg-Type:X-Reply-Demand:Message-ID:Date:
	 X-CMS-MailID:Content-Transfer-Encoding:Content-Type:X-Sendblock-Type:
	 CMS-TYPE:X-CPGSPASS:X-CPGSPASS:cpgsPolicy:X-CFilter-Loop:
	 X-CMS-RootMailID:References;
	bh=fsB/0Ku02kUxyA7dgq6tLMG0wze5fechr4pefFRJF4E=;
	b=p+7Qb24y/EfibkxqrOLla4BhRuFbvUUwICnjHF6IG4PNU3pKTrJOJt0aCMjilTN2LPIo
	 Sbno7o3JtBlji+Kl4H0fGwceEccbr+Gpe06B8uYtRoxpPv3rx68DK6urYVx5lvzg8sFv3
	 2Jit8MUN/AOGpUA9FZmH7Qv9D8aqTk4sve0UH1iZqxKgGje6mlK6CcXiv8tGEwCxXczbA
	 Wx89JiDAzKu9NPe3AszKIWGlRyU1cDLs1nZFEQBlqSmelDACc+7785BDhtNWXcZbi3qFL
	 pNooVJe8UgkifCsAzFeLpxM03Ky24XPJRnSkFKT1VxL1edHjofj25c2RcFwdYijWD3g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=samsung.com;
	spf=pass smtp.mailfrom=samsung.com;
	dkim=pass header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=vgaqLE65;
	arc=none smtp.remote-ip=203.254.224.25
Received: from mailout2.samsung.com (mailout2.samsung.com [203.254.224.25])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 419D0606A31D
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 06:44:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 419D0606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=vgaqLE65
Received: from epcas2p4.samsung.com (unknown [182.195.41.56])
	by mailout2.samsung.com (KnoxPortal) with ESMTP id 20261029064402epoutp028df9d3da3f1bc124d0ebf4b510fb1e2c~i7Q0XGXzs0579605796epoutp02Q
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 06:44:02 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout2.samsung.com 20261029064402epoutp028df9d3da3f1bc124d0ebf4b510fb1e2c~i7Q0XGXzs0579605796epoutp02Q
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1793256242;
	bh=fsB/0Ku02kUxyA7dgq6tLMG0wze5fechr4pefFRJF4E=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=vgaqLE65QbPaQ1NRCVBsFzBjkSxVI7ZjE/g4ml1hpXeCb1ep04gVUCJ+lKGZXGRVC
	 Bp92zdvRBZTAfUx3G/kBSZ79zoil8VGuVC2VGCwfggMuOWZX60KAgdbV0ZELj6+GRq
	 uyqG1tpzE7vexSVtGq54X3Sw4EY8emSMvkjZ/2Y8=
Received: from epsnrtp01.localdomain (unknown [182.195.42.153]) by
	epcas2p1.samsung.com (KnoxPortal) with ESMTPS id
	20261029064401epcas2p1d746c1d3aa4d575c08db8061f0932d44~i7Qz5OK653074930749epcas2p10;
	Thu, 29 Oct 2026 06:44:01 +0000 (GMT)
Received: from epcas2p3.samsung.com (unknown [182.195.38.200]) by
	epsnrtp01.localdomain (Postfix) with ESMTP id 4jFZSx2cf0z6B9mB; Thu, 29 Oct
	2026 06:44:01 +0000 (GMT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Subject: RE: [PATCH v2 1/2] pnfs/blocklayout: don't mark extents committed
 after a failed LAYOUTCOMMIT
Reply-To: daejun7.park@samsung.com
Sender: Daejun Park <daejun7.park@samsung.com>
From: Daejun Park <daejun7.park@samsung.com>
To: Benjamin Coddington <ben.coddington@hammerspace.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, Christoph
	Hellwig <hch@lst.de>, Daejun Park <daejun7.park@samsung.com>
X-Priority: 3
X-Content-Kind-Code: NORMAL
In-Reply-To: <8b5b2e8ecc7e1150c9b4505d1094da893db2e1a6.1792157092.git.bcodding@hammerspace.com>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261029064400epcms2p81abe9b998d705d216c59053a046fe8da@epcms2p8>
Date: Thu, 29 Oct 2026 15:44:00 +0900
X-CMS-MailID: 20261029064400epcms2p81abe9b998d705d216c59053a046fe8da
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261026232756epcas2p4bb04fcbe9c606214e73357405c8f2730
References: <8b5b2e8ecc7e1150c9b4505d1094da893db2e1a6.1792157092.git.bcodding@hammerspace.com>
	<cover.1792157092.git.bcodding@hammerspace.com>
	<CGME20261026232756epcas2p4bb04fcbe9c606214e73357405c8f2730@epcms2p8>

Looks good to me.

Reviewed-by: Daejun Park <daejun7.park@samsung.com>
