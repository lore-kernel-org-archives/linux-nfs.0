Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=203.254.224.34
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793332620;
	b=NT8h32RQJEd7Rtlq+tSLBtLSWqL3vlwtNB8nPyEQrVylPrxlijwP+klg3oxMXqLeYWid
	 mHAbV6eVLs/8pF/aZtZsh45DHin8e58XHJRF7Y2xiBfvGqV/tZs1pfaSdZO2JAldwK8U7
	 kGqJEfMSvZ2uyzv/mvRxGo3UIN/I8C2MdktIvJ8Z6dYIlndEsx79rUsEfJ8UDootpWkaZ
	 tu27cqN8XBwAEglvQsT792lmFnCyE/sAvcTzDWBwB3c2l0aNUtgIb499FMBEHwYf+j0/2
	 IF36iD+CuD5tI6GQKng6FzRbjbjCNejPmlSJHMPwkARbOCGc+1ttZKmYKg7S6JPJVHQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793332620;
	h=DMARC-Filter:Received:DKIM-Filter:DKIM-Signature:Received:Received:
	 Mime-Version:Subject:Reply-To:Sender:From:To:CC:X-Priority:
	 X-Content-Kind-Code:In-Reply-To:X-CPGS-Detection:X-Drm-Type:
	 X-Msg-Generator:X-Msg-Type:X-Reply-Demand:Message-ID:Date:
	 X-CMS-MailID:Content-Transfer-Encoding:Content-Type:X-Sendblock-Type:
	 CMS-TYPE:X-CPGSPASS:X-CPGSPASS:cpgsPolicy:X-CFilter-Loop:
	 X-CMS-RootMailID:References;
	bh=k7y5H+KgCQHh48QC5iqA8pI+doKg/Z4Z6K9J/eA0NYQ=;
	b=JMIWoCKgGvoBArUzWn09YL0rZQCO9nEG+bIr4n11AB5UCe2R6AGF8iyTbtabDQ3qNxOQ
	 Ln2P0n1b537TrQ/7At0IOjjjpoOQC++9WzvwxAYoHRWX/GAr0VOAlsI6pGY3xhagMM4mm
	 dEkX4OEOnifTLRhZ18Ju1NBGOFA39NkNsrzIDYdRQJF02wo75fgSoysrTSYjYb6HquLZ9
	 IcYZ1FGgyq+TDIiQklao75ixEDRHKpHSoJDshxRulOj0YYaa/gyZ25jzT/IdBMmnqj5Vx
	 fFnhCPrOdG0jaytZiAP0t5mrYrkgDsvwqEgbze1WfI2hjOoepVxyu5j4stN1R2oeKrA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=samsung.com;
	spf=pass smtp.mailfrom=samsung.com;
	dkim=pass header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=WUVYvEYV;
	arc=none smtp.remote-ip=203.254.224.34
Received: from mailout4.samsung.com (mailout4.samsung.com [203.254.224.34])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E53BF606A31A
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 03:56:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E53BF606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=WUVYvEYV
Received: from epcas2p3.samsung.com (unknown [182.195.41.55])
	by mailout4.samsung.com (KnoxPortal) with ESMTP id 20261030035656epoutp04d6ce98fa4109259785978e8bccdfdd1d~jMoN3hsO83000630006epoutp04V
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 03:56:56 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout4.samsung.com 20261030035656epoutp04d6ce98fa4109259785978e8bccdfdd1d~jMoN3hsO83000630006epoutp04V
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1793332616;
	bh=k7y5H+KgCQHh48QC5iqA8pI+doKg/Z4Z6K9J/eA0NYQ=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=WUVYvEYVVwufUrKCTy7bLPGNKqdrE1yXL/t7FR/Es9csFr6o9eP8XZuoxBrg9a6Gi
	 qYKc7kCvT+oZ716IBjaVCyTIhABN7ZfwgMss4tqcwzlVajyZdxSgXgh4fdxncrXAdm
	 M8+G0C1opHbLDRsbvv/vOtnG+MUGtivAhG4HC7yk=
Received: from epsnrtp02.localdomain (unknown [182.195.42.154]) by
	epcas2p1.samsung.com (KnoxPortal) with ESMTPS id
	20261030035656epcas2p1a23ccc0f17909c0618c0f322691097b2~jMoNWI4eB2094620946epcas2p10;
	Fri, 30 Oct 2026 03:56:56 +0000 (GMT)
Received: from epcas2p4.samsung.com (unknown [182.195.38.211]) by
	epsnrtp02.localdomain (Postfix) with ESMTP id 4jG6jh0Kp9z2SSKb; Fri, 30 Oct
	2026 03:56:56 +0000 (GMT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Subject: RE: [PATCH v3 0/2] pnfs/blocklayout: report LAYOUTCOMMIT failures
Reply-To: daejun7.park@samsung.com
Sender: Daejun Park <daejun7.park@samsung.com>
From: Daejun Park <daejun7.park@samsung.com>
To: Benjamin Coddington <ben.coddington@hammerspace.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, Christoph
	Hellwig <hch@lst.de>, Daejun Park <daejun7.park@samsung.com>
X-Priority: 3
X-Content-Kind-Code: NORMAL
In-Reply-To: <cover.1793302358.git.bcodding@hammerspace.com>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261030035655epcms2p1195ad019395d60cccef85ee6404f1bbe@epcms2p1>
Date: Fri, 30 Oct 2026 12:56:55 +0900
X-CMS-MailID: 20261030035655epcms2p1195ad019395d60cccef85ee6404f1bbe
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261029193427epcas2p23c4a29bb4ff78e1718bb5eeec0481315
References: <cover.1793302358.git.bcodding@hammerspace.com>
	<CGME20261029193427epcas2p23c4a29bb4ff78e1718bb5eeec0481315@epcms2p1>

On Thu, Oct 29, 2026 at 03:34:19PM -0400, Benjamin Coddington wrote:
> Daejun tested the patch 2 approach on v2 in VMs, against an nfsd that
> answers a LAYOUTCOMMIT with NFS4ERR_BADLAYOUT; I've only compile-tested
> v3.

I ran v3 as posted on v7.3-rc6 with the same tests. The results match
the change I tested on v2:

- fsync() returns -EIO once. The next fsync() on the same fd and on a
  new fd returns 0.
- stat() after a failed LAYOUTCOMMIT returns 0.
- No KASAN or lockdep reports on the client or the server.

Tested-by: Daejun Park <daejun7.park@samsung.com>

On your question on v2: the close() that returned -EIO was in a
separate test, not after the failed fsync():

- New file, one 64k write, then close(), with one injected
  NFS4ERR_BADLAYOUT.
- The server got one LAYOUTCOMMIT, the one close() sent, and failed it.
- close() returned -EIO, and 0 without the series.

I did not check close() after the failed fsync().

Daejun
