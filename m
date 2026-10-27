Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=203.254.224.33
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793090111;
	b=O8F118tR2vixmBmnOBRPy3YswVhgkhRiGzAvIYvM0FdOffi4rCKpdSMekqu9xqvOPtrU
	 CT3g4NOxM7ws8uTeslCpWUn6JHPbIsTewF0u5iU1C+cuHtKfS/TlHdSpVhGr32FkNSSq4
	 EpeAF/Yh7xps0ZHj964wvR1kqJWTBC2yXiFWU1dQ1VF/dZY7vuqPTQDbWakL6mB8p++ih
	 D1howpxoYeLYNjp+4X65fokkyGV5fcwofEwA4WfD6AAEP1Fwv9STWiRoMWtmVd+MnArhk
	 K+94fERgNmCiVc4zEmz58gsjvI0FkGVitiLHt4th3L428lmNbbAe86lzvQ7GOY+UOGw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793090111;
	h=DMARC-Filter:Received:DKIM-Filter:DKIM-Signature:Received:Received:
	 Mime-Version:Subject:Reply-To:Sender:From:To:CC:X-Priority:
	 X-Content-Kind-Code:In-Reply-To:X-CPGS-Detection:X-Drm-Type:
	 X-Msg-Generator:X-Msg-Type:X-Reply-Demand:Message-ID:Date:
	 X-CMS-MailID:Content-Transfer-Encoding:Content-Type:X-Sendblock-Type:
	 CMS-TYPE:X-CPGSPASS:X-CPGSPASS:cpgsPolicy:X-CFilter-Loop:
	 X-CMS-RootMailID:References;
	bh=5bahGxfUN75E2T3mOHUJ9Zz0leyIiVRMhMYoQV+Rpgs=;
	b=Nfad+dnr19ijyM1lGzL8fn8uYt8O5dTtHOt5PPGyVl+rSLkhZwCDOXL6w8bwnCRsLXZH
	 OsgoPtrqf8wJkGdmE/N4YBAoEjv9JN+3Nbo2CxSarEzxc9j0Hftk5pfWqtW5tPoirq9Pc
	 dpM0x4z95mFbTnLFaS6XhDR4s+avj8au1RzCroYz8OhPCJ7uBfu7YISkfFw22oTKak88E
	 XWPFRbJCo5JlhRa1OGnWuUQNNTruKxKUIUXDFkpuYakmymDzeOCErmFqZ33DJbZ7GNY21
	 QHX3FC5d00ZIBvYYzYLPJW7V8JOmUlAU7Qv+70YySjyjTRbuHuoijnZdZOeIIih0Cww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=samsung.com;
	spf=pass smtp.mailfrom=samsung.com;
	dkim=pass header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=L4lEPNd+;
	arc=none smtp.remote-ip=203.254.224.33
Received: from mailout3.samsung.com (mailout3.samsung.com [203.254.224.33])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D34AB606A31D
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 08:35:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D34AB606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=L4lEPNd+
Received: from epcas2p1.samsung.com (unknown [182.195.41.53])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20261027083503epoutp037c945b1bc379df599623a3791407af1a~iVfMC9lgI1107611076epoutp03e
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 08:35:03 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout3.samsung.com 20261027083503epoutp037c945b1bc379df599623a3791407af1a~iVfMC9lgI1107611076epoutp03e
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1793090103;
	bh=5bahGxfUN75E2T3mOHUJ9Zz0leyIiVRMhMYoQV+Rpgs=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=L4lEPNd+F7ee8P3N/mHT/N1cn74Bk23jtK73oJvSICLDsyxIDUNmFDbFox9TiE9+x
	 ADQgI+Kd7P6lLh55lo/7d7+/uivKwLd3FhCIpos1hwluRZoNZuiJTwo7wna/3uI5WM
	 RB8L7kn8gWQ3LAMMrLPijurzgNnNQ3qzhXraLJ+s=
Received: from epsnrtp04.localdomain (unknown [182.195.42.156]) by
	epcas2p4.samsung.com (KnoxPortal) with ESMTPS id
	20261027083503epcas2p494af9311ba030f4f9573dc589ba17ada~iVfLXfW_z1990719907epcas2p4J;
	Tue, 27 Oct 2026 08:35:03 +0000 (GMT)
Received: from epcas2p4.samsung.com (unknown [182.195.38.208]) by
	epsnrtp04.localdomain (Postfix) with ESMTP id 4jDP1y6RkCz6B9mR; Tue, 27 Oct
	2026 08:35:02 +0000 (GMT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Subject: RE:(2) [PATCH v4 5/9] xfs: limit the count of a pNFS write
 allocation to one extent
Reply-To: daejun7.park@samsung.com
Sender: Daejun Park <daejun7.park@samsung.com>
From: Daejun Park <daejun7.park@samsung.com>
To: "Pankaj Raghav (Samsung)" <pankaj.raghav@linux.dev>
CC: Carlos Maiolino <cem@kernel.org>, "linux-xfs@vger.kernel.org"
	<linux-xfs@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "Darrick J.
 Wong" <djwong@kernel.org>, Dave Chinner <dgc@kernel.org>, Chuck Lever
	<cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Dai Ngo
	<Dai.Ngo@oracle.com>, Sergey Bashirov <sergeybashirov@gmail.com>, Andrey
	Albershteyn <aalbersh@kernel.org>, "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "stable@vger.kernel.org"
	<stable@vger.kernel.org>, Daejun Park <daejun7.park@samsung.com>
X-Priority: 3
X-Content-Kind-Code: NORMAL
In-Reply-To: <atoImJxtg70XcIjS@quentin>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261027083502epcms2p736b8c20d8a66bdc43b1f68e5cde0fc24@epcms2p7>
Date: Tue, 27 Oct 2026 17:35:02 +0900
X-CMS-MailID: 20261027083502epcms2p736b8c20d8a66bdc43b1f68e5cde0fc24
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261022130241epcas2p22506b749cfa884fea92c554d34d3df19
References: <atoImJxtg70XcIjS@quentin>
	<20261020-xfs-pnfs-batch-v4-0-9230fa2ca4a4@samsung.com>
	<20261020-xfs-pnfs-batch-v4-5-9230fa2ca4a4@samsung.com>
	<CGME20261022130241epcas2p22506b749cfa884fea92c554d34d3df19@epcms2p7>

On Thu, Oct 22, 2026 at 03:02:30PM +0200, Pankaj Raghav wrote:
> Isn't it better we add this in xfs_direct_write_iomap_begin() instead of
> adding it in pnfs?
[...]
> +       count_fsb = min_t(xfs_filblks_t, count_fsb, XFS_MAX_BMBT_EXTLEN);

Thanks. That works for pNFS as well, as xfs_fs_map_blocks() passes the
same count to xfs_iomap_write_direct(). I put the cap in
xfs_fs_map_blocks() because it relies on the caller asking again for
the rest of the range, which nfsd does, and the other caller,
xfs_direct_write_iomap_begin(), already limits a mapping to 1024 pages.

Daejun
