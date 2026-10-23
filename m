Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.155
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792720378;
	b=vAOgapDznuDfSPIKcjQv/6fOcwox7Wnpr+P6jeMVsKHocoRgwCuyXGrJw+4eSj0ZpR4N
	 Fx3ugjIbMAq7IfZcTtVWfHA3pPJxjEY1I6vZTe87IwO/vpR8aPt9wU30XIzPxh4TjvBU3
	 x5ySTZZDRRmZdkgcRCAKQ91z6py2esdERH7ypTmZLtAy2Q6OD9V42dwGiD+Es+4IzcVKx
	 p5NnIZWfJr3a5RdDd3mUJ82yVg8NJLlpr7SSfCK1VLmgymMDhSbMuEZtnWjlzBRRSzUOA
	 LuxlE/nRwcblrC4b5FDCRUIi+8kCC2mms8c8HUKa1u9eVibcekkBOxW3zHnIuezU52g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792720378;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:Reply-To:
	 MIME-Version:Content-Transfer-Encoding;
	bh=cD6ambGXB73ssJDqyApt39o6A0cgIPa1xebyQdqUuRM=;
	b=DgL8B+ZjUMAw2RcAm9s0hSzIR1rY6GqTGoW38jQAWE4/OKuCPIJ0sIJVQDqFW25t6DW4
	 CEvK635aYqwvyHvfffai6AHXwgMtznSQB5R/P0PXurxz6QZm2q8JPLpa6iluhi5ufUqWa
	 rplgJZG7mPjPEtHVdENSDChgeeuf3bkZ4bA8DxjdYND5tPDj07k9CSgqnUrfK1BtxcgYi
	 BaskjoQmIBXNEEUPPXNYxgIylT6i9gD2NVE7gfJ2xfNnYBWP57VNADln/s1ihuLzdSQZ0
	 EmgjBh8yyd4Ay9s2O3zl6/nkhACnO7JrMcWpEkUeLCwg2l9uwG8sHWoGaIhycMmbfyA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=QpP9QY6M;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b="eFjE7Ys/";
	arc=none smtp.remote-ip=202.12.124.155
Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AF87606A31A
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 01:52:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7AF87606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=QpP9QY6M;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=eFjE7Ys/
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfhigh.stl.internal (Postfix) with ESMTP id B4FF17A01D3
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 21:52:57 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Thu, 22 Oct 2026 21:52:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm2; t=1792720377; x=1792806777; bh=cD6ambGXB7
	3ssJDqyApt39o6A0cgIPa1xebyQdqUuRM=; b=QpP9QY6MAbuqUjvJ+DIH9BS3/u
	iW14dS+f+LnhSrqZ0oD67fW5hdjoPEcfmO9FLmi/qqs5asSsSqDWvjUCZlWevqa/
	wAEcrRh5eevv5TMJGW3HE1QnO5EAs1Ru/60dxdHQopd+HbQdMsZH1cyV3Hbe4GIg
	LDlKNTDcmIdDqXROjJu2fODCM+vHI4HV52+OmNF+zY9ThAsjbPX4YPdo1QPpc7lI
	qz+LCaI8PuA33J/CPtQ23TT3akQTUroWo83xc97i1tfCHOmxETABtxLGJU3IT3NV
	/i6eE2RxwlQLBZW4kjbj/i4zorDD8ca2WYoE+KgD7Wc7uftjbgEp9fLAAR0w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; t=1792720377; x=1792806777; bh=cD6ambGXB73ssJDqyApt39o6A0cg
	IPa1xebyQdqUuRM=; b=eFjE7Ys/awcQQ2GanV7ZgDGv1OSyoMkpdosheOsW3pPn
	Fh7BSvWjtFwVdxhG7ThkktCWk90XFeR2kg5RlV3XtN4Iw3bLAK5QhpWNNKMXC5Tm
	yxIDMyNcOpiNSoGZxeeKkEh720q7v/4yTVLazvmG6bXwuv24jf8fTQKjbL6RciVQ
	o7E3n5Wrww8VXDaWMYYabcmyLLF1P62fZKyEgGu/m4HdRL+sFq2IDoglpWbKBfpY
	FHNvDoBI3PN/gzIScGH0OXQfXQAZIh79VTCtJToVsuYH2Zl/7LJhh4RU+fosDA6p
	s29dadf54kIlbzreQD1PGUFTfbojbHzdw4+HpkxJHQ==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792720377; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:W/xwm9ARVZd48lV7fpwE6dN3X0gDqhLL4BFO78RgdbLATl6
	c00v2nX60YBwstEAyFlqNBSSpyRpLRGTLbeCcUdeAeeY+Tv1DVEg7uCzTRr0uxWU
	r7c9gBihL0CWWz4ySNMPjoXjnx0hVL/Eksin25A6KxUdGYnwD2/aDL2oTnkdb9R/
	erBGFm2JmODHftHQtiEJjZ9PtSe+miEMWi9hlp4awNy4ne9oC9PfLn05vcFjfLpI
	P1RGgxbJ1pxRDJ4sDLfbcEx7cNDfbZ9tMgREfxAFegSK3As6GOanqlb6dBSP5INI
	XXhpMvR4s6Dke4qg0uOoQru1YWIqzbQgaJsrVpg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=10;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	message-id,mime-version,reply-to,subject,to;
Message-Instance: m=1; h=sha256:4JF+ZIJSDd7a16bsXCTNVhi2lGpaY06Nq339RHB4eWw=:cD6ambGXB73ssJDqyApt39o6A0cgIPa1xebyQdqUuRM=;
X-ME-Sender: <xms:-b3aako_IvVolgK7BOrImE92ONp8rTF8UChink8JxqgFNTOb48_9qw>
    <xme:-b3aattvHtkJwSRSA_tZjkAkDVxEIu06IKVAxf3DRTZv1UcHsO-bov3-A7MJcENzj
    Jmj4DAxtQiu5SE2R7zL0dv97Am98eJdgge-21xwhV7neoSV>
X-ME-Received: <xmr:-b3aaj06di6yjiga3y5hSaCvWMoF7VUgF1ebajmGzx_CmdwwRC0wfJERqj-PQVNg-6Gjh5jlpzcRRm87jFxE9iswshOus7s>
X-ME-Proxy-Cause: dmFkZTERkwtIMOGUZMHMdY1kHqHFpz+WwWYtGMcExDBZbCYs2pEUua7f29LsxCZoqkDSTD
    +/WHgNys0etvqLuX1rIqICejHIe8wtKISjKnDpOKPWqIYxCsE1Rs4ylY4TB3oGDg6uRMjn
    RRoz6QE810emuHDqMQ+daw1Y0EPY+pSTFZ4Yff8B9SHUx8PzjZPrkGWAO7+EMrqIrTEefc
    +LvVZnRNXDwa3M6fndQBYDQg5o9Cm+VCU2BUbxKZ2p8KVygcMh9wyz2MytjXxl9Uf9DNMb
    bDq2L55Xs1KIYaMXH4T/8nRgCKwadPwL+U9v2OqNqlsG+87a59trm+c4CjTQmLC+UIAfSj
    jHTEZjx6UxObjglHaHBnSyP3d/SyEAO3NzIGpc11ct0TF8r9W+N7F/oAdLgT5TaNpIwkHY
    wRmEqf3r74XvLq9yKj4Ncs0y+yZEZGRYNeT4UPULxL6q6mduEnhu5K2veewu1qrI+iPx05
    KAY+/tMT8JFl+lgWx+IIJGBNAvn97Lacvh7IYAFhhXvXccAwc9QwjjE4L7PNTCO4FwBxIr
    axn+0Q4m0ZYI5XMCXbALPo5pR5kBqv0+hnmVZZ+RTFuraIH/C9La5myOc3bhYO+QTkKkTV
    qOaEDVMKNtx5qXTWY0BNXHaZ9C6NjQfyn4WVtpGENVaeL/tI5Rv8jxAP3FBQ
X-ME-Proxy: <xmx:-b3aaoER6G_myrOJoMPPjqIsT-WHWUI6Wx4Zx_K1Y7jVqHybOWIRJg>
    <xmx:-b3aauvCNbq6nzn0CUX_xhFjjrt4pXAJZQslhIsf6HE_MgsnvrxUvA>
    <xmx:-b3aarowGdPVwT0_cQN-nMebut41GL-e20-NE1xFsPVWK-7YX4P6QQ>
    <xmx:-b3aalWdc0QZr8rEaLtXW7HrSkvVctuvZWSfipJGaMrrBUsY00LHNw>
    <xmx:-b3aakjjWEFaFPLo_VVEo-RM8WuE2nKh3k8xDoB5JPfD0ZQP0PjPWMV1>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 22 Oct 2026 21:52:54 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 0/9] nfs: prepare for locking changes.
Date: Fri, 23 Oct 2026 12:50:10 +1100
Message-ID: <20261023015239.2163480-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This v3 adds Anna's Acked-by and fixes three bugs found by Sashiko - all
error-path related.

1/ patch 5 - make sure d_drop() gets called in all error cases
2/ patch 8 - dput() sdentry on all error paths
3/ patch 9 - check error return from d_duplicate() correctly.

Thanks,
NeilBrown


 [PATCH v3 1/9] nfs: fix open-blocking with d_fsdata
 [PATCH v3 2/9] nfs: fix nfs_call_unlink()
 [PATCH v3 3/9] nfs: remove d_drop()/d_alloc_parallel() from
 [PATCH v3 4/9] nfs: use d_splice_alias() in nfs_link()
 [PATCH v3 5/9] nfs: don't d_drop() before d_splice_alias()
 [PATCH v3 6/9] nfs: don't d_drop() before d_splice_alias() in
 [PATCH v3 7/9] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
 [PATCH v3 8/9] nfs: use d_alloc_trylock() in silly-rename
 [PATCH v3 9/9] nfs: use d_duplicate()
