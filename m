Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=203.254.224.25
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793332704;
	b=ET0h1/iM1QCMxD9yk0wtswsaxsMFD8EsByRiMhJoA6DhHAfFiQNPoejeLKvpnpltz5/s
	 t9kACiw6YAJeeNBmvfg4stRGuaoNQ99uiHcgoiNAtEoJKx2h+Bqe0ExioAajOvd7cBAFA
	 PtOSLhoAYqz/tJHEzfrcn3dRhvgf6Bs8MYkwGzrnETufI6mWYmdBHp9twGd5AKP6f0S1U
	 AtHQbo/oAsFj3YuzIm/jpTukzx6nW7fj/1jAaJTHsXxAuzCiUQ5+NmKMGijM85LiiK7hD
	 l92ND6W3MYSGbXxig2RWGgAkoc1n3mg4VEZr3VOuwARMDQAGSS4BlVOThk6h442XoVw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793332704;
	h=DMARC-Filter:Received:DKIM-Filter:DKIM-Signature:Received:Received:
	 Mime-Version:Subject:Reply-To:Sender:From:To:CC:X-Priority:
	 X-Content-Kind-Code:In-Reply-To:X-CPGS-Detection:X-Drm-Type:
	 X-Msg-Generator:X-Msg-Type:X-Reply-Demand:Message-ID:Date:
	 X-CMS-MailID:Content-Transfer-Encoding:Content-Type:X-Sendblock-Type:
	 CMS-TYPE:X-CPGSPASS:X-CPGSPASS:cpgsPolicy:X-CFilter-Loop:
	 X-CMS-RootMailID:References;
	bh=zUgWx4GG7nQpPVnN3H3kzUWlHZSJp8Dns2isdJHCWMk=;
	b=YxYecyy0zDmijXrc/1CjyllJWfnNYgCZn6S6dbTsGJ9WFgTnyOn5NRGjirjAqbpMTTpC
	 ZO0DQ6wnwmdL3SkI0Kj9QjR4PPWTKFWQ5QIJ15nQ9+p9VYjx+JLJwvTb25EtD84UbW+ZD
	 0BXScwE8WwsCAkY++KDKRZt9h4nBoooYVJUmUGy9X8zNpkYht79orPyVRcLMZGE4h2Bt/
	 gm5yOvN+qDhtDpWV9vE3Ohb+2oTqCwNscSy1whmZypDeAcUVv7j1K5dudf45j3MHTCwhJ
	 QTQ4f1cftreYVBmF2NiqD87ldpTErRDFroMWAlqZT7s+ExZcCNxoT6YGoI3Ash3MtBA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=samsung.com;
	spf=pass smtp.mailfrom=samsung.com;
	dkim=pass header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=tLpJQtZb;
	arc=none smtp.remote-ip=203.254.224.25
Received: from mailout2.samsung.com (mailout2.samsung.com [203.254.224.25])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 00A9D606A323
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 03:58:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 00A9D606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=tLpJQtZb
Received: from epcas2p3.samsung.com (unknown [182.195.41.55])
	by mailout2.samsung.com (KnoxPortal) with ESMTP id 20261030035820epoutp029dc04f3a4264ace4b279ccdc96c4be79~jMpcDDc6B0738907389epoutp02g
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 03:58:20 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout2.samsung.com 20261030035820epoutp029dc04f3a4264ace4b279ccdc96c4be79~jMpcDDc6B0738907389epoutp02g
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1793332700;
	bh=zUgWx4GG7nQpPVnN3H3kzUWlHZSJp8Dns2isdJHCWMk=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=tLpJQtZbM3CyMtSLgcRu8MW9wVm3LQBQ3p8fGdei6RAq6Kcq4N5od5MfkN6+kxlA2
	 /cQKPS4VUDmzjQFrtqFXQG2R/QgkB4Tu+nSe3UB3525N5ORe3RuW3aig2OCW+1yfr3
	 ZBeaii9kWuDLNLQrE094xGdpD7Jb+5an5ZxF/p1o=
Received: from epsnrtp02.localdomain (unknown [182.195.42.154]) by
	epcas2p1.samsung.com (KnoxPortal) with ESMTPS id
	20261030035820epcas2p13fb76da0364c476189f2cf78971e553e~jMpb4DP_n2047120471epcas2p1A;
	Fri, 30 Oct 2026 03:58:20 +0000 (GMT)
Received: from epcas2p4.samsung.com (unknown [182.195.38.199]) by
	epsnrtp02.localdomain (Postfix) with ESMTP id 4jG6lJ2SwPz2SSKf; Fri, 30 Oct
	2026 03:58:20 +0000 (GMT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Subject: RE: [PATCH v3 2/2] pnfs/blocklayout: report data lost to a failed
 LAYOUTCOMMIT
Reply-To: daejun7.park@samsung.com
Sender: Daejun Park <daejun7.park@samsung.com>
From: Daejun Park <daejun7.park@samsung.com>
To: Benjamin Coddington <ben.coddington@hammerspace.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, Christoph
	Hellwig <hch@lst.de>, Daejun Park <daejun7.park@samsung.com>
X-Priority: 3
X-Content-Kind-Code: NORMAL
In-Reply-To: <054f354ecaa596514da593698461206e356004ac.1793302358.git.bcodding@hammerspace.com>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261030035819epcms2p4d812654812819bd39f5f79c499fb618b@epcms2p4>
Date: Fri, 30 Oct 2026 12:58:19 +0900
X-CMS-MailID: 20261030035819epcms2p4d812654812819bd39f5f79c499fb618b
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261029193431epcas2p2e4d09667120683dbaf654417fd8d7f61
References: <054f354ecaa596514da593698461206e356004ac.1793302358.git.bcodding@hammerspace.com>
	<cover.1793302358.git.bcodding@hammerspace.com>
	<CGME20261029193431epcas2p2e4d09667120683dbaf654417fd8d7f61@epcms2p4>

On 29 Oct 2026, at 10:47, Benjamin Coddington wrote:
> I'll send a v3 with your change in patch 2.  Ok to add your
> Suggested-by and Tested-by?
>
> Was there another write before the close() that returned -EIO?

Thanks, Suggested-by is fine.

The close() that returned -EIO was in a separate test, not after the
failed fsync():

- New file, one 64k write, then close(), with one injected
  NFS4ERR_BADLAYOUT.
- The server got one LAYOUTCOMMIT, the one close() sent, and failed it.
- close() returned -EIO, and 0 without the series.

I did not check close() after the failed fsync().

Daejun
