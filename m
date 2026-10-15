Received: from mailout3.samsung.com (mailout3.samsung.com [203.254.224.33])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E3223368A2
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 01:03:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=203.254.224.33
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792026197; cv=none; b=Qh5vpGJxAimwuTfRlJykBIN5fbmDebNi1P8HTcTU5UbvWdnSW+bthIGM3GZzE0+sPVyWNzdy5JIfUJizop0BMz0yP8sf53Qa9ipH8evQ8CacBkfQTtgA6rbUn4h6Y6WhIFPzLl50iukK5l/yiIBaHRoRugPoGnX2eqCmrahb/jw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792026197; c=relaxed/simple;
	bh=On1LJt1oAnoDqy4by3pmCaDqKbYHI1mJmpCVPYrJwac=;
	h=Mime-Version:Subject:From:To:CC:In-Reply-To:Message-ID:Date:
	 Content-Type:References; b=ACGx12Iir1WWc1QbrJrRX2wf5QtoyJJg20TDS5EFyrtxu9Wb7HlENvyIl7Zhn7Cx9OkOnd9pPBFHIWw66Hrm4lVoq7z57HDB82+4d+shNievIWsyVwY1eVRJUT8Dq6LzPQ/SHsIdda0e4rIDq5dL+q+ES+Qwxibv/VzoVfASMT0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com; spf=pass smtp.mailfrom=samsung.com; dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b=YPVA5bpa; arc=none smtp.client-ip=203.254.224.33
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="YPVA5bpa"
Received: from epcas2p2.samsung.com (unknown [182.195.41.54])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20261015010311epoutp03a2a08c974ef7fdb01c2a10d28057ee81~ejlOyTkxb2076220762epoutp03O
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 01:03:11 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout3.samsung.com 20261015010311epoutp03a2a08c974ef7fdb01c2a10d28057ee81~ejlOyTkxb2076220762epoutp03O
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1792026191;
	bh=On1LJt1oAnoDqy4by3pmCaDqKbYHI1mJmpCVPYrJwac=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=YPVA5bpayoByQaD6rdm6nzmzkkdwzNEMxW9WpW6PlxGGTZcOUtxmRjAlGa7LZt4AQ
	 RjY9v1mK3TbRf4m1YrlzmpKWn0oLPE1FZPRRjrSKih94XCtetpihY5B/alCOQ2dZCq
	 c/cEZCHu51evh4t6Nxrb4IJA8zGIqG827nok9UUI=
Received: from epsnrtp04.localdomain (unknown [182.195.42.156]) by
	epcas2p1.samsung.com (KnoxPortal) with ESMTPS id
	20261015010311epcas2p186fc350c8a5762b8a0b4e7717e20e6ac~ejlOUz8LU1300613006epcas2p1Z;
	Thu, 15 Oct 2026 01:03:11 +0000 (GMT)
Received: from epcas2p3.samsung.com (unknown [182.195.38.207]) by
	epsnrtp04.localdomain (Postfix) with ESMTP id 4j4qZ66Tgzz6B9m8; Thu, 15 Oct
	2026 01:03:10 +0000 (GMT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Subject: RE:(2) [PATCH v2 2/7] nfsd: answer NFS4ERR_DELAY instead of waiting
 for a layout recall
Reply-To: daejun7.park@samsung.com
Sender: Daejun Park <daejun7.park@samsung.com>
From: Daejun Park <daejun7.park@samsung.com>
To: Chuck Lever <cel@kernel.org>
CC: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Olga
	Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
	<tom@talpey.com>, Christoph Hellwig <hch@lst.de>, Benjamin Coddington
	<bcodding@redhat.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker
	<anna@kernel.org>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daejun Park
	<daejun7.park@samsung.com>
X-Priority: 3
X-Content-Kind-Code: NORMAL
In-Reply-To: <deacbd2d-a82f-4691-92e5-0ea98856c3cc@slotpi15m67>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261015010310epcms2p4c2fa373c449c71323341e321250329cd@epcms2p4>
Date: Thu, 15 Oct 2026 10:03:10 +0900
X-CMS-MailID: 20261015010310epcms2p4c2fa373c449c71323341e321250329cd
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261014210000epcas2p25968c73bf30a4b4d8239f95044d2dadc
References: <deacbd2d-a82f-4691-92e5-0ea98856c3cc@slotpi15m67>
	<20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
	<20261014-nfsd-layout-recall-v2-2-764462bddfd1@samsung.com>
	<CGME20261014210000epcas2p25968c73bf30a4b4d8239f95044d2dadc@epcms2p4>

> This recalls layouts only for a synchronous COPY. The asynchronous
> branch above it hands the same work to nfsd4_do_async_copy(), which
> calls nfsd4_do_copy() with no recall at all.
[...]
> The recall therefore belongs before the sync/async split, so both
> paths will execute it.

Thanks, agreed. v3 will recall before the split.

Today the async copy waits for the layout to be returned in
xfs_file_write_checks(), which breaks layouts on each write, so it ties
up a copy kthread rather than an nfsd thread. Recalling up front gives
the client NFS4ERR_DELAY instead of that wait.

> Nit: See if you can cut down the verbiage in the new comments.
> kdoc comments are meant to document API contracts. Operational
> details can be described close to the code itself (concisely,
> please).

Will do, thanks.

Daejun
