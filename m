Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E06B32868B5
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:32:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262773; cv=none; b=sO6Ply2RYlJ6ybhmwY6Xc2yul5pCY14aHux8BmgitrTXUgumrgzs7wJ66jUSQr8xLusinAxTAgmRE80nXANzl3rg7Br+NNgnJvmS25GEUU+a5oYJU+EBB3Q5cwM5H8CyBYFXFcrgiR31M7hGnVvn+IOCwaDZDOV4PS8Kl2W2cmc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262773; c=relaxed/simple;
	bh=9VMtx+sU2GBv2VKfHRHxIG44PeJiWqpAe2LqHMumj+8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=KfiQmHgcGXsqJyH3z+t+zdqTMETMKAcz2MmdX5bewQAa0h4rpN1hMmp9KmjThyEFH6UtXIWFg39oBLyg98pLgYc/Fyjz59OL/iw1RE+0n0iRvmb+ih22k0Gjk+t06FrPsFD56XN2hhkr7siP+hCfR18zPEKYS4vNWaZ7fWiEMWk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=mhFarJrN; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=j2lTvqjr; arc=none smtp.client-ip=202.12.124.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="mhFarJrN";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="j2lTvqjr"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id 970EF1D0001D;
	Fri, 17 Jul 2026 00:32:50 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Fri, 17 Jul 2026 00:32:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm2; t=1784262770; x=1784349170; bh=9VMtx+sU2G
	Bv2VKfHRHxIG44PeJiWqpAe2LqHMumj+8=; b=mhFarJrNxy6sXVJ870udaoVYkz
	aFKs01hN3emobv8b3jXpDhT0rmcFN9UbGLRtqWIX0+w3nVlAOFWLFE64V7xYrFD7
	b0BWBH7+S10OealWeX4jSm1PrPtMBJCB0rMSfu9JIK2e8V+2rvDNcJeryrgHeCgM
	uRslMZu212kMdFikIXh3HM2JwwhVzKQ9w+3x2WfuoVm+o5kF/PfCfVzyJ7grep2e
	BmsAkO6nWBcBEDpJFf5Go3YZuw/jkex1cjeajJZstYQ0fEnlbr/g7UFclA/V9P6w
	33BgKAQQJyfe5T7v9kL4YuJFQD9WPRyLpuQMfQ2tVovFgTSoK8AUdh6ZNmhA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; t=1784262770; x=1784349170; bh=9VMtx+sU2GBv2VKfHRHxIG44PeJi
	WqpAe2LqHMumj+8=; b=j2lTvqjrLyqWZyqhAHvGnA3UFNt2scghhW8CfRR8DfsZ
	aKjFnuxAXp6NWqbnlB8/OEtF6wvzTZrHS6OSdlkBAQ/JQwkZZoPhI82ejwD9WLtK
	sWnctH5j6se4KQB3laotiGkHUrYfxMUfp1K2lzYJAalboU+eK2xgNUW/yDL6rFri
	rXlZprh8aBL3TRMmZj2V/E8PqXUjJwMmIGsWJFbgxKRhkUTiZzLQcQ3J+loDx4qd
	ZiPzEPTcCdVbKO+f5UDk6WZ2/xRhn4euVwAVuX8vKJGmQT6LlXK4a1HCm4n5xxBw
	cPYxMAPS9zgBgSEJYfdlVjxuehYpAl2S1iqgcLkbEA==
X-ME-Sender: <xms:crBZaqHAslmq4N0R7pVY3KR5p3LJzU03L1u0MVDF82T--0fgYq9crw>
    <xme:crBZavDrCfR9n2WuA2iD1hnQdkq6XyM2BB-CB5ZsH289_4bsnAKBTLL4w_fmZsyXj
    9kkWm9LrRvOMbVS--5d30HbZ7iI9IBtE7Ly8tMXQc51_p7TNw>
X-ME-Received: <xmr:crBZat9vNryZmRycoumXBjfLyOYqv6Xlw_IGS_B6zOiJiEWQM1Xhe2a3Y95VdMuKNewdIb-cv9rkNa-6LwKd5vjT5z3xuoM>
X-ME-Proxy-Cause: dmFkZTG36WtVB2sOUeCKuTAai+1IXHBdAD6stYvuxpecM1E0h1N375ZpcUHU8YZzAasToq
    eFPm6VW2knlJnISOdhCfdbhPwiRdxCsT/y3gQNaKsenI2No+8prAFmds4KmBEyD83Xczlv
    +dbPKmt6ht+T9FxCUwy1VJMWXN5+AEravMSNiw2Z4h9dR90edJjQ1bLFHAU+fQ6VsjpTGr
    OTMkygYw8VxpYoX+HDmJ7cWmX1GMM9CImaiMr3wOOIH2t/FYogiic/AdUee3stuoenmk5E
    mDWhOUZ4JezZHShVmADUI2xJDn+AVz1ceSpgmOJzkeL3C1wBoMgaVXUBcX0L52DuyPqxlr
    KdYJ2Dcds5wiVhXANkzKrHRXnCdk4iMbN/4trZWRHG8kNy8zT+Xtgb08x58ZUcx1C9KS0s
    gL7NpP0gAly+LEMSWg7AiFluB2RbQuaR3R4B0jxqjFZF4H4sKTRGRLQVrj035pRuomk9ub
    5vHfEDQfyduz9ItCnP6ulBK61SdivPK8m3RdbEUl+XDR3cqj6e1ykAhcjr7tl6/xLkJQsx
    ipyl77yziqBMDdbuYG5Z6WyslLe9E6qEl4FNLNaMlBONwrlOr7z+3+o/uOQkhkAYmKSYo9
    rRTFQVhA2LykOplNbwk+mPvla9OYLK+2FG1h3ok0dO2lTViylfNjPwipvz/Q
X-ME-Proxy: <xmx:crBZarBrMXMX3aB3_pKii7s9z1v9WYUipRH8TQm_eIESh5PwZZIy4Q>
    <xmx:crBZaiTJgL-fioe6OfkNnAE1htX7FTfFC9rTOADhPd-QQak5Sz9xNA>
    <xmx:crBZaisb7HJWp-HOx65TjlaC2GkqIWIjMOOXeY7PtW8l3VIG7B0VoA>
    <xmx:crBZau2pnHJabEAjXHN4qaYrBqaDjm8vrV2sTxK0EO6j7nQ-_97JwA>
    <xmx:crBZavlElCSpIF2ZYxlKLdcBp3gZybGtWq7pL-comjfnFQjjeD0XsSmC>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:32:48 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 00/18] nfsd: refactor nfs4_create_file()
Date: Fri, 17 Jul 2026 14:30:58 +1000
Message-ID: <20260717043242.1865905-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This version fixes the v2 and v3 code for handling CREATE of mounted-on
files.

Thanks,
NeilBrown


 [PATCH v4 01/18] nfsd: honour client-provided attributes for
 [PATCH v4 02/18] nfsd: move check_nfsd_access() call into
 [PATCH v4 03/18] nfsd: correctly handle CREATE of mounted-on files
 [PATCH v4 04/18] nfsd: replace fh_fill_both_attrs() with
 [PATCH v4 05/18] nfsd: move fh_want_write() after preamble in
 [PATCH v4 06/18] nfsd: move more nfs-specific code into preamble of
 [PATCH v4 07/18] nfsd: remove subtlety from nfsd4_create_file()
 [PATCH v4 08/18] nfsd: in nfsd4_create_file() let VFS report if file
 [PATCH v4 09/18] nfsd: nfsd4_create_file(): Move NFSD_MAY_CREATE
 [PATCH v4 10/18] nfsd: fh_want_write) failure need not be immediately
 [PATCH v4 11/18] nfsd: (almost) always open file in
 [PATCH v4 12/18] nfsd: reduce range of directory lock in
 [PATCH v4 13/18] nfsd: open-code nfsd4_vfs_create() into
 [PATCH v4 14/18] nfsd: move some code out of the
 [PATCH v4 15/18] nfsd: reduce want-write range in nfsd4_create_file()
 [PATCH v4 16/18] nfsd: move v0 checking out of nfsd_check_obj_isreg()
 [PATCH v4 17/18] nfsd: separate out VFS-specific code from
 [PATCH v4 18/18] nfsd: use do_lookup_open() for non-creating open
