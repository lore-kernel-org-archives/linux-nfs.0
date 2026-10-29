Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=203.254.224.33
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793256312;
	b=i9PZk0pslVbFs/mOopg8Yht+FieycujMO80zXb0OsqblqjUtG6ScMVPIzp0wllU6mFcK
	 XMWBzePQHJA8yMnn2biNKIiK7C8d8z0OFXp4rgn951PH5oWJGQNMscXw6t9wILY3cjx3u
	 sxnBLfQW8EB2KRu/1GesD0CnDmfQ0J3hN6oyG4pwEdBpDV5iLl4cpDv7gx5A90DZOmmfY
	 DJtr7dl0L2iWC8OaxnSjAuQuKUQEAnrxCLvTaH+Ggqz1ryGxzHwp0TiMhLW95BbMSj9up
	 lePm8Ch8qrdJuDMxQR6I9ZdZ3PlJCUfbuv/zqEHG8pZjOxHkMBNJz30X1WVuwew4ufw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793256312;
	h=DMARC-Filter:Received:DKIM-Filter:DKIM-Signature:Received:Received:
	 Mime-Version:Subject:Reply-To:Sender:From:To:CC:X-Priority:
	 X-Content-Kind-Code:In-Reply-To:X-CPGS-Detection:X-Drm-Type:
	 X-Msg-Generator:X-Msg-Type:X-Reply-Demand:Message-ID:Date:
	 X-CMS-MailID:Content-Transfer-Encoding:Content-Type:X-Sendblock-Type:
	 CMS-TYPE:X-CPGSPASS:X-CPGSPASS:cpgsPolicy:X-CFilter-Loop:
	 X-CMS-RootMailID:References;
	bh=TDytEqN+Fxdf9lYANKPPJTJUpsBJQWIt6AGcQZOflFw=;
	b=xDsc1eWTiUGHhbgGYfty5R0xm7KrWAlkegG48V7fPRQac4JfPvg2dSiqF+Tuu+hKrpWK
	 Thf4JghRk85rXi0yHR+zPJ4b/I/Vxb18C/yE1urDQrUi+8W5tvq/vO39Ie2Ha5upRz4rW
	 9TOUsMX+d2RO1IhbwJ3yDE/RdaoZ7DeK2G2oDvA69S0zGnHARI375QbbiyGwdeMCC7/la
	 LSX3VLdHjkqfwE9UP36datku0jB4cw0IiyxIT7gB1zuCWAf0tQDoVlbPd3Bx8LDuMf8nj
	 1pQJgHs3Djdm0Fh5KufK6v6fjdbxe+vwrBRD8P/HjENTduMclXFgy1a7nJk8XJ8+5+g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=samsung.com;
	spf=pass smtp.mailfrom=samsung.com;
	dkim=pass header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=iW8TzyWb;
	arc=none smtp.remote-ip=203.254.224.33
Received: from mailout3.samsung.com (mailout3.samsung.com [203.254.224.33])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 90F3C606A31F
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 06:45:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 90F3C606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=samsung.com header.i=@samsung.com header.a=rsa-sha256 header.s=mail20170921 header.b=iW8TzyWb
Received: from epcas2p3.samsung.com (unknown [182.195.41.55])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20261029064504epoutp03d9ceaf66c9e8c5dfb780bd961d78c026~i7RuSxL0E0463404634epoutp03F
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 06:45:04 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout3.samsung.com 20261029064504epoutp03d9ceaf66c9e8c5dfb780bd961d78c026~i7RuSxL0E0463404634epoutp03F
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1793256304;
	bh=TDytEqN+Fxdf9lYANKPPJTJUpsBJQWIt6AGcQZOflFw=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=iW8TzyWbKHSgeGibvSwQsR+5BWTR+XUwa3FlOW54D817OPRU6kmKuxOcWXcErZS6H
	 nQEETQZG8A2vRr0SD9mPY004oA5DvByfKAf416jS8Xpafz3sbRpJTMo6HEj2R3Cbpz
	 uIjIqP3rzi7NRMSKQHP3760DF8PtS07Nf2+AVdZY=
Received: from epsnrtp01.localdomain (unknown [182.195.42.153]) by
	epcas2p1.samsung.com (KnoxPortal) with ESMTPS id
	20261029064503epcas2p1f9cb073da448c2ebf11a795059056d1a~i7RtOYIrW2698526985epcas2p1E;
	Thu, 29 Oct 2026 06:45:03 +0000 (GMT)
Received: from epcas2p1.samsung.com (unknown [182.195.38.208]) by
	epsnrtp01.localdomain (Postfix) with ESMTP id 4jFZV66gPkz6B9m5; Thu, 29 Oct
	2026 06:45:02 +0000 (GMT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Subject: RE: [PATCH v2 2/2] pnfs/blocklayout: report data lost to a failed
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
In-Reply-To: <f1a9f1337cbbb4039a29fb5808d8c2944b9a112c.1792157092.git.bcodding@hammerspace.com>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261029064502epcms2p4465d31caeafe380380266d726846a28a@epcms2p4>
Date: Thu, 29 Oct 2026 15:45:02 +0900
X-CMS-MailID: 20261029064502epcms2p4465d31caeafe380380266d726846a28a
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261026232757epcas2p444964cd7bba66ebaecad170a85048e3b
References: <f1a9f1337cbbb4039a29fb5808d8c2944b9a112c.1792157092.git.bcodding@hammerspace.com>
	<cover.1792157092.git.bcodding@hammerspace.com>
	<CGME20261026232757epcas2p444964cd7bba66ebaecad170a85048e3b@epcms2p4>

On Mon, Oct 26, 2026 at 07:27:49PM -0400, Benjamin Coddington wrote:
> +static int
> +bl_sync(struct inode *inode, bool datasync)
> +{
> +	/* An error nobody has seen yet is not this LAYOUTCOMMIT's to return */
> +	errseq_t since = READ_ONCE(inode->i_mapping->wb_err);
> +	int ret;
> +
> +	ret = pnfs_layoutcommit_inode(inode, true);
> +	if (ret)
> +		return ret;
> +	return filemap_check_wb_err(inode->i_mapping, since);
> +}

I tried v2 on v7.3-rc6 in VMs, block layout, with a test-only nfsd
change that answers one LAYOUTCOMMIT with NFS4ERR_BADLAYOUT. Without
the series, fsync() returns 0 and the data reads back as zeroes on the
server, so the problem is real. With it, fsync() returns -EIO, but two
things looked off:

- The same fd reports the failure twice. filemap_check_wb_err() does
  not mark the error seen or advance the file, so the next fsync()
  gets -EIO again from file_check_and_advance_wb_err() in
  nfs_file_fsync_commit().

- stat() can fail with -EIO: nfs_getattr() -> __nfs_revalidate_inode()
  -> pnfs_sync_inode() reaches bl_sync(). I saw it on a stat() after a
  second write.

Would it work to keep ->sync a plain pnfs_layoutcommit_inode() and
check the file in nfs_file_fsync() instead? I tested this:

		ret = pnfs_sync_inode(inode, !!datasync);
		if (ret != 0)
			break;
+		ret = file_check_and_advance_wb_err(file);
+		if (ret != 0)
+			break;

With it, the first fsync() returned -EIO, the next fsync() and stat()
returned 0, and close() still returned -EIO.

Daejun
