Received: from mailout1.samsung.com (mailout1.samsung.com [203.254.224.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F15A243956
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 01:03:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=203.254.224.24
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792026227; cv=none; b=GQHOpjgR4RvH2akEkUNOmA2Mh4aJuU5Kbc8EMkTyDWf1ndNXSZebgOtnA8kNTCXvFmzhB7xsl66mVHiw7nT/nnn5UAP4whrMXQOlbf5GciATWWGDdD9UqQFLCEjDZi5Xb1agubkk5wzimZ25vAlcQKoLpcFJyzH0RdXZksabepU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792026227; c=relaxed/simple;
	bh=r7yz4oTsCE1D9UIg0gThaeV4+qIHhLZRmOf2V9mCoNQ=;
	h=Mime-Version:Subject:From:To:CC:In-Reply-To:Message-ID:Date:
	 Content-Type:References; b=Z3+feRggluLpPv/XoN+aQwRVchZtvIJ4Yqdel+dD7kZsNUn+OaWEIMV9tUHXuygUcreeGaYA5RxX5MBhAcH2pRJxtKCcLeEvJGmxu1ls69tnKQCcSSFnWPiWtFBqEo5migWDbzaEbZUh+E+v2AXD6Ieeys0eQNrqlGpkwtqrJLk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com; spf=pass smtp.mailfrom=samsung.com; dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b=sXKtEsrk; arc=none smtp.client-ip=203.254.224.24
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="sXKtEsrk"
Received: from epcas2p3.samsung.com (unknown [182.195.41.55])
	by mailout1.samsung.com (KnoxPortal) with ESMTP id 20261015010343epoutp01ba193f759fa726f25fdd2e3325b53d2e~ejlr3oVdj1342413424epoutp01l
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 01:03:43 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout1.samsung.com 20261015010343epoutp01ba193f759fa726f25fdd2e3325b53d2e~ejlr3oVdj1342413424epoutp01l
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1792026223;
	bh=r7yz4oTsCE1D9UIg0gThaeV4+qIHhLZRmOf2V9mCoNQ=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=sXKtEsrkUDPGog59AVLxRzvoim8ayaaOYfHBrPyOOeMnLUX0jViumtxaN3jz1UVzK
	 FSr7GRKbglrQAfak6QzhPLzbLXosDWladowOqMvO+9Jpj6ltPXjg6sg1Wr/iP/tQuZ
	 QAM3FI9x4FgKbrx41acZeG9dAV1jhKNywhb0A6GE=
Received: from epsnrtp03.localdomain (unknown [182.195.42.155]) by
	epcas2p3.samsung.com (KnoxPortal) with ESMTPS id
	20261015010342epcas2p3c87feca465c677238a851123f003b8ef~ejlrVyYwR2981929819epcas2p3j;
	Thu, 15 Oct 2026 01:03:42 +0000 (GMT)
Received: from epcas2p3.samsung.com (unknown [182.195.38.208]) by
	epsnrtp03.localdomain (Postfix) with ESMTP id 4j4qZk2BZTz3hhTF; Thu, 15 Oct
	2026 01:03:42 +0000 (GMT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Subject: RE:(2) [PATCH v2 0/7] nfsd: layout recall and lease break fixes
Reply-To: daejun7.park@samsung.com
Sender: Daejun Park <daejun7.park@samsung.com>
From: Daejun Park <daejun7.park@samsung.com>
To: Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>,
	NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai
	Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
CC: Christoph Hellwig <hch@lst.de>, Benjamin Coddington
	<bcodding@redhat.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker
	<anna@kernel.org>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daejun Park
	<daejun7.park@samsung.com>
X-Priority: 3
X-Content-Kind-Code: NORMAL
In-Reply-To: <46ba944d8dcb989c60c276813339dcb8564a823f.camel@kernel.org>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261015010341epcms2p8a29007af44a655fd830f4cc153fe807a@epcms2p8>
Date: Thu, 15 Oct 2026 10:03:41 +0900
X-CMS-MailID: 20261015010341epcms2p8a29007af44a655fd830f4cc153fe807a
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261014112609epcas2p1744da3eed81a6017758a715935a1867a
References: <46ba944d8dcb989c60c276813339dcb8564a823f.camel@kernel.org>
	<20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
	<CGME20261014112609epcas2p1744da3eed81a6017758a715935a1867a@epcms2p8>

> I think 5 and 6 should be squashed together, but the series itself
> looks fine. Nice work!
>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>

Thanks for the review. v3 will squash 5 and 6.

Daejun
