Received: from mailout4.samsung.com (mailout4.samsung.com [203.254.224.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A86903783B5
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 05:48:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=203.254.224.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791265733; cv=none; b=AU/PYWXKBc+RE72kFL0C4ZATvZOZnB25WXezErobmbqGYOxL366qKmwRIhan7Y3Igxj/sUfKS96dr7GB1guvo719FVhcwJpKBhWeIXfNaJD0bT4q7Pb7mKqV6S/KhfzImrdkBk6dtXzSoC1qy/10dK+jq4geFSvZ+KhgkAafWqY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791265733; c=relaxed/simple;
	bh=QxC3CPxmQGc7vcjk9S5d0nij7wuDioXkYk/OZ5aeW+M=;
	h=Mime-Version:Subject:From:To:CC:In-Reply-To:Message-ID:Date:
	 Content-Type:References; b=K3oYGBv1e0xsZDB/lVpyycKhk4QAXnZrrOOOTlEneSH2yjh+fD0BCEZSZF/Ny4UmbLZX2WzqxG8qskzbSpl8j54VPExTJsJNME8W8NHHmJpZ81a7i3DFQRAE/A0oYF78VsbJYO/hCoAQMhMOT8XitCoV5L7r6tATAweqTCFICZ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com; spf=pass smtp.mailfrom=samsung.com; dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b=nCGt/QBV; arc=none smtp.client-ip=203.254.224.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="nCGt/QBV"
Received: from epcas2p3.samsung.com (unknown [182.195.41.55])
	by mailout4.samsung.com (KnoxPortal) with ESMTP id 20261006054848epoutp0436e8c9d979199356710271260aa93f50~b2rBy-Ana3238932389epoutp04D
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 05:48:48 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout4.samsung.com 20261006054848epoutp0436e8c9d979199356710271260aa93f50~b2rBy-Ana3238932389epoutp04D
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1791265728;
	bh=QxC3CPxmQGc7vcjk9S5d0nij7wuDioXkYk/OZ5aeW+M=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=nCGt/QBVyjyXo61y1RrnPwBmOjWOhxHkI2WF9InPboRbeLJ9VbXOY45murtJUimAi
	 T2UZFt1Y++pPuYIA8pGoFA05Dvie3IfChB9/auIKVJw2QQ7y9AC2kqACawAqPkWwDi
	 OwXw09wMzZ1ZVkG5fUMDo9lOyu7i800pjzB4Dt40=
Received: from epsnrtp04.localdomain (unknown [182.195.42.156]) by
	epcas2p3.samsung.com (KnoxPortal) with ESMTPS id
	20261006054847epcas2p3bf8546ff659945993f035ca2109ffb47~b2rBLlEqa0946609466epcas2p3d;
	Tue,  6 Oct 2026 05:48:47 +0000 (GMT)
Received: from epcas2p2.samsung.com (unknown [182.195.38.202]) by
	epsnrtp04.localdomain (Postfix) with ESMTP id 4hzQKq1PYMz6B9m9; Tue,  6 Oct
	2026 05:48:47 +0000 (GMT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Subject: RE:(2) [PATCH] xfs: map pNFS layouts to the end of the extent again
Reply-To: daejun7.park@samsung.com
Sender: Daejun Park <daejun7.park@samsung.com>
From: Daejun Park <daejun7.park@samsung.com>
To: "Darrick J. Wong" <djwong@kernel.org>
CC: "cem@kernel.org" <cem@kernel.org>, "linux-xfs@vger.kernel.org"
	<linux-xfs@vger.kernel.org>, "dai.ngo@oracle.com" <dai.ngo@oracle.com>,
	"hch@lst.de" <hch@lst.de>, "dgc@kernel.org" <dgc@kernel.org>,
	"sergeybashirov@gmail.com" <sergeybashirov@gmail.com>, "cel@kernel.org"
	<cel@kernel.org>, "jlayton@kernel.org" <jlayton@kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daejun Park
	<daejun7.park@samsung.com>
X-Priority: 3
X-Content-Kind-Code: NORMAL
In-Reply-To: <20261006051324.GV2705364@frogsfrogsfrogs>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261006054846epcms2p8ebfcaa89742030bfc07a7d1bb5ee3dfb@epcms2p8>
Date: Tue, 06 Oct 2026 14:48:46 +0900
X-CMS-MailID: 20261006054846epcms2p8ebfcaa89742030bfc07a7d1bb5ee3dfb
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261006003425epcms2p586728e55ff5f9bbabc506b672fc4a421
References: <20261006051324.GV2705364@frogsfrogsfrogs>
	<20261006003425epcms2p586728e55ff5f9bbabc506b672fc4a421@epcms2p5>
	<CGME20261006003425epcms2p586728e55ff5f9bbabc506b672fc4a421@epcms2p8>

On Mon, Oct 05, 2026 at 10:13:24PM -0700, Darrick J. Wong wrote:
> I wonder, though, should the caller (i.e. NFS) do this trimming to
> protect itself from other filesystems making the same mistake?

I agree that nfsd needs a patch as well. nfsd4_block_proc_layoutget()
could trim every extent after the first to start at the offset asked
for, moving soff by the same amount for the written and unwritten ones.
If that sounds right, I can send a patch for it.

This patch still makes sense as it is. Mapping to the end of the extent
can only be done in XFS, and with the trim in XFS as well, the stable
fix does not depend on the nfsd patch. What the trim costs shows in the
4 KiB random row of the table: 15 LAYOUTGETs instead of 1, with no
clear change in I/Os done.
