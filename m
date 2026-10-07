Received: from mailout3.samsung.com (mailout3.samsung.com [203.254.224.33])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60DEC34E74D
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 02:11:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=203.254.224.33
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791339062; cv=none; b=G6V+RbdztOtY7NejL/5iF7aGjLNubI1G/fXp1pOjuYG3SnH+rp5o4Atzo70AynT1Absz4BSC+MjTyoUQ5rfbw9Phpj0BvAd62z5lwumtuXK1E58nx4HiTlpYuXc+sAD0z0heSNT+bOo9jipIqtwVNjjPOBKV1T9zwwpln/WvZQQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791339062; c=relaxed/simple;
	bh=x4jZBfKLhpwiyBVrYC7K3MT4ILYuuXBaSljEG6yPYiM=;
	h=Mime-Version:Subject:From:To:CC:In-Reply-To:Message-ID:Date:
	 Content-Type:References; b=CROvk578edtk3+DAg0JVqglVcEdHQ0RZAMJncF3D/bArTrF/HLvuGjIT6yM1VR5OBERtbFIe5F3UBVYRC6XWizunxCKi0T1rhHMs7DIPvMLGAEqrso9gSAwMvvbKg2/UJjQsPnaskzZ+BzUAFerowRu3W0AQyFTlPV0/7o+YO3w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com; spf=pass smtp.mailfrom=samsung.com; dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b=ibL5NVo9; arc=none smtp.client-ip=203.254.224.33
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="ibL5NVo9"
Received: from epcas2p4.samsung.com (unknown [182.195.41.56])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20261007021057epoutp03d260c24f251f9be1566e2bacbcbbccf8~cHWHaXo1Y0850708507epoutp03K
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 02:10:57 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout3.samsung.com 20261007021057epoutp03d260c24f251f9be1566e2bacbcbbccf8~cHWHaXo1Y0850708507epoutp03K
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1791339057;
	bh=CY72gnnRNcbS6NB787BVXd8l89OKke2vtryppYrUZjE=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=ibL5NVo9jvi+TBnAuENsYA8CwgOwLfy1UAGHYpXkMC9CD+cc4efKUVL9rSDrPIAxT
	 Whzu2Tdz43G3RwpxiUe9ZTrweg7h2GL9dhAFIMLaCF9BfDOgIf5Nx7ns1mfYkSWeK1
	 IhrUNn8cgZF/10PlMDqiWvdvuLBvvvqNGW8zpl3w=
Received: from epsnrtp02.localdomain (unknown [182.195.42.154]) by
	epcas2p3.samsung.com (KnoxPortal) with ESMTPS id
	20261007021057epcas2p32f5aeae17b2eeb3c07d9983ae9b7d0c0~cHWHBNI1Y2358823588epcas2p3J;
	Wed,  7 Oct 2026 02:10:57 +0000 (GMT)
Received: from epcas2p4.samsung.com (unknown [182.195.38.207]) by
	epsnrtp02.localdomain (Postfix) with ESMTP id 4hzxS10TLfz2SSKX; Wed,  7 Oct
	2026 02:10:57 +0000 (GMT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Subject: RE:(2) [PATCH 0/6] nfsd: layout recall and lease break fixes
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
In-Reply-To: <63ef8d7c-086f-4cc8-84bb-72c1b23bf596@slotpi15m67>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261007021056epcms2p180289a2c55fd8e5efb8153d8aba43919@epcms2p1>
Date: Wed, 07 Oct 2026 11:10:56 +0900
X-CMS-MailID: 20261007021056epcms2p180289a2c55fd8e5efb8153d8aba43919
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261006194708epcas2p2df158d7a6f0f9eb57cf1f6c3a0ec0c4b
References: <63ef8d7c-086f-4cc8-84bb-72c1b23bf596@slotpi15m67>
	<20261006-nfsd-layout-recall-v1-0-b59b31caf342@samsung.com>
	<CGME20261006194708epcas2p2df158d7a6f0f9eb57cf1f6c3a0ec0c4b@epcms2p1>

On Tue, Oct 06, 2026 at 03:46:40PM -0400, Chuck Lever wrote:
> I think the fix has to come first. Before the WRITE or SETATTR, call
> break_layout() non-blocking to start the recall, and return
> NFS4ERR_DELAY on -EWOULDBLOCK, as we do for delegations. Then the
> fence worker and the poll loop can take as long as they need and no
> nfsd thread waits on them.

Agreed, I will put that patch first in v2. Besides WRITE and SETATTR
with a size, XFS breaks layouts in fallocate and in remap, where
xfs_iolock_two_inodes_and_break_layout() waits on the source file as
well, so ALLOCATE, DEALLOCATE, CLONE and COPY will be checked too, the
last two on both files.

That also covers a wait that is unbounded today. For the SCSI layout,
when fencing keeps failing, the fence worker retries without limit and
nfsd4_layout_lm_breaker_timedout() returns false while it is in flight,
so the thread in __break_lease() keeps waiting (read from the code, not
run).

Two things I will test and report with v2:

- The check in nfsd and the break_layout() in XFS are not atomic. A
  LAYOUTGET granted between them still puts the thread to sleep in
  xfs_break_leased_layouts(). No new layout lease is granted while a
  recall is in progress, so this needs a layout granted when none was
  held at the check.

- A writer going through the MDS now retries after NFS4ERR_DELAY
  instead of waking up when the layout is returned, so a client that
  keeps getting new layouts could starve it.

Daejun
