Received: from mailout2.samsung.com (mailout2.samsung.com [203.254.224.25])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4454541A55C
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 07:23:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=203.254.224.25
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792048999; cv=none; b=Mbsjqru+asa9lH0wl61sBOv94G2yUa6FdjFLF609uqUM04NOJW/Rgx7fTEaRTLnAEfB91r9+PAboPsjoxn4JnNm43WYHZaiQHtK8zQfRMZOmjY8V9qaLou4uXKkxW1700CgMaaqpA1Tw1rO21YuC3ljz9hmIgUFsc1Y9e6IPT1A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792048999; c=relaxed/simple;
	bh=PtXIDX13fP+iqj3+gIFVKLJBnzkOyRNgQGSwKBXgoZY=;
	h=Mime-Version:Subject:From:To:CC:In-Reply-To:Message-ID:Date:
	 Content-Type:References; b=CaLT5HYrsTKENtDzlr3bWHf5PT6wHpYgzKis4P8xp0Cu6NYQvL9CrkzFtzCND0ZnBl0c+LVnPGCe31TO7aTIOaVBKoz/5khGmh8qnMLb8JfbYdY11bI3XSBRgmAah3HIoeE/BhpcfPqEECrO3SlmABDSLQxYn0NQMot/+C/lADk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com; spf=pass smtp.mailfrom=samsung.com; dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b=tG9SLedw; arc=none smtp.client-ip=203.254.224.25
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="tG9SLedw"
Received: from epcas2p2.samsung.com (unknown [182.195.41.54])
	by mailout2.samsung.com (KnoxPortal) with ESMTP id 20261015072308epoutp0299b7409621bef035f5aa4c71421af862~eow_KSkmt1473814738epoutp02g
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 07:23:08 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout2.samsung.com 20261015072308epoutp0299b7409621bef035f5aa4c71421af862~eow_KSkmt1473814738epoutp02g
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1792048988;
	bh=mzgpWt5GGty/dFKO10uL2LGjZTMzcw//rSUxcOQYofI=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=tG9SLedwVr0vpK5hrhsLcjRFy4vU7d3uzWRTnosQ7qElVSsEd8rSezGJL7NZuqQCQ
	 x0AEqEKXa7X+j3divkqDityEP4FfysxXihy8Zb49665FO5XdEvA2y4WC/JDVcpwVrY
	 yY/S+B/dNJEko2hJ+W/3enow5tZk5auugztj3gZw=
Received: from epsnrtp03.localdomain (unknown [182.195.42.155]) by
	epcas2p1.samsung.com (KnoxPortal) with ESMTPS id
	20261015072308epcas2p1a5fd64d6aad5cfe556346c3fc133828b~eow9zGyFZ0873508735epcas2p1B;
	Thu, 15 Oct 2026 07:23:08 +0000 (GMT)
Received: from epcas2p1.samsung.com (unknown [182.195.38.209]) by
	epsnrtp03.localdomain (Postfix) with ESMTP id 4j500X1cZ8z3hhT9; Thu, 15 Oct
	2026 07:23:08 +0000 (GMT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Subject: RE:(2) [PATCH v3 5/9] xfs: refuse a direct allocation whose block
 reservation would wrap
Reply-To: daejun7.park@samsung.com
Sender: Daejun Park <daejun7.park@samsung.com>
From: Daejun Park <daejun7.park@samsung.com>
To: Christoph Hellwig <hch@lst.de>
CC: Carlos Maiolino <cem@kernel.org>, "linux-xfs@vger.kernel.org"
	<linux-xfs@vger.kernel.org>, "Darrick J. Wong" <djwong@kernel.org>, Dave
	Chinner <dgc@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton
	<jlayton@kernel.org>, Dai Ngo <Dai.Ngo@oracle.com>, Sergey Bashirov
	<sergeybashirov@gmail.com>, Andrey Albershteyn <aalbersh@kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, Daejun Park
	<daejun7.park@samsung.com>
X-Priority: 3
X-Content-Kind-Code: NORMAL
In-Reply-To: <20261015060932.GD14035@lst.de>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261015072307epcms2p858823bf9dcc139b102794d87e2efe5e2@epcms2p8>
Date: Thu, 15 Oct 2026 16:23:07 +0900
X-CMS-MailID: 20261015072307epcms2p858823bf9dcc139b102794d87e2efe5e2
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261015060942epcas2p4bcb321d2f040673f793404daa724e83c
References: <20261015060932.GD14035@lst.de>
	<20261015-xfs-pnfs-batch-v3-0-54fc7b2e467d@samsung.com>
	<20261015-xfs-pnfs-batch-v3-5-54fc7b2e467d@samsung.com>
	<CGME20261015060942epcas2p4bcb321d2f040673f793404daa724e83c@epcms2p8>

On Thu, Oct 15, 2026 at 08:09:32AM +0200, Christoph Hellwig wrote:
> I think the limit needs to be lower, as xfs_bmapi_write can't hand
> out such large limits.  We'll also need to make sure pnfs can
> request multiple maps.

Thanks, I'll limit the count to XFS_MAX_BMBT_EXTLEN in v4. nfsd asks
again for the rest of the range since commit cc6c40e09d7b
("NFSD/blocklayout: Support multiple extents per LAYOUTGET"), and
letting a single ->map_blocks call return several mappings is what
patches 4, 5, 7 and 8 of the ->map_blocks series did [1]; I'll resend
those for the next cycle.

[1] https://lore.kernel.org/r/20261008-xfs-nfsd-map-blocks-v1-0-560026cdccb6@samsung.com
