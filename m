Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.151
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794185718;
	b=A+bWHahtDGU+H1pYGC9E0EQ25W3EYB8U33xfQ4RWzbjzQ1azQESHR3QdOPjhSLh0tH8L
	 XWmEO6cFEUZRyuZDHsihDYboIUroqnowjj3KABfsqrqppDUS6lffq2wcndbkTJcLOQcdt
	 3ZA5MvFqQ5PcTg1D74meHp6/zvMcvYcE2OHAMWWIvPSnqsMnnBq9vK97Q3PulPsUW5yX1
	 4MY8U/M9kRdRO139K/xMYPVlcFw42N5hqPPh+KZoeX81WggsD8E1i+j/udq5JR9k3xsOp
	 h8JBGd/Lr9yuBvVAdSCn4zMpG3Eexn3PxrGYwnCTswfFR6+jWFPOVEUlGgyhGwycXPg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794185718;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:Reply-To:
	 MIME-Version:Content-Transfer-Encoding;
	bh=FdsyhMQOp+T8xwEmn4Ja5KwFr41M8qapERW6BS7QKBA=;
	b=Hb0r8s30vuPM3RuXXX5cQCUAtlppnuNr9Dz0szKCDO2Xe89KrezpkjZLa57fC3k9oQ9+
	 ygXm8zzhpq+V1aoaPEKcgMLXEIibfn0TpCjS08zKLbo2f94+Ku0mVRoTh0rarDrIm49di
	 vTSEhXnPzj9CJv265r1hdlYwXBml8JOn2yYIVFHg6CUOmOMUqcTJsnD+Nw1dNSyUQmjw2
	 SgvfXWxxvQezWjqkV/72boK7twXwKND5kuf9vJUMBCoQorae7KtbLZlvm3GEfBz2PEf5R
	 mzo+FP8tvex0Qf/xKxxiQ/H8qIxuWjO9Xag2uDLIXdcmoAXW/PD1WkDjZoMMTi61w3Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=W3oK235f;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b="L7t18z/L";
	arc=none smtp.remote-ip=202.12.124.151
Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A00F8606A31C
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 00:55:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A00F8606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=W3oK235f;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=L7t18z/L
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.stl.internal (Postfix) with ESMTP id E94821D000BD
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 19:55:16 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Sun, 08 Nov 2026 19:55:16 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm3; t=1794185716; x=1794272116; bh=FdsyhMQOp+
	T8xwEmn4Ja5KwFr41M8qapERW6BS7QKBA=; b=W3oK235fT77Ju15mr8lGs9ouaf
	MSST4HQToitDVCV3ncrZig/yzWwRRwBLXhWpD24r9nZF9RgAs+pvfoE+L4vomXjz
	5fMKguO3i+agk4FFxqFJdB/E/dldL8dp9szLtxPf7hprLAZYzHY/0wNQmshfrFdp
	9PG5Wvi2QalkTur5SorMVR1PsIaJuA3+FXYzNlLurLPmm2PHNKZbyGDuWSaWAwJ0
	lSFSv9SfBQVYMnYTI4fKNNyni3rSP8QKaQaJ1q2WZnLAyt9yNBppW0gxUYDxVHJS
	1cCXNN5BdTbfMeBLhn+f54h8fbR97kDaMfe9x7Ql5OeM8GhVQExE4jLO8hJA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm3; t=1794185716; x=1794272116; bh=FdsyhMQOp+T8xwEmn4Ja5KwFr41M
	8qapERW6BS7QKBA=; b=L7t18z/LHLtxNndhGTFaG5g81EstPqWmREqpCnyc6OWm
	biPpbg0EnWKJ327V+RUV2SDuFH8LKRsZxAv8KawsirfBx9q8NCeEl0VUxCL8lzk6
	1p8k34wGjId4BgHHHuXKihAQiXOkA/zN2XMX8aoPAP++Yk6KvFjgNbuODHDy0srb
	970lxYRsEjyBAwQWnczSt4lREWblZqtGv+bogW3L+/11VCtjbX2Z35T3JqS1Wg6d
	4ZtOwhq5AaT/HKjWgal3HJRL2rOjSIqCXmXUc3W32WZPTTZNV9heQqrBDBHqinXV
	rnh7u81iPNu7JrwnBc/FblXpmis9vAKpmBv5fuCPsQ==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794185716; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm3:rsa-sha256:w5TWlVKhJ01qkKF9Y+bqN1ocfmxlRGJ6RO1GZrf9khC7axy
	w4Po7GNJgGuWluRcOZc4+eirHkIQuiUed9CZsnx91jZ/eZxiK1e2qq2Hq/0kP40Q
	kbWQJDfUBXMkurxh3LDUx9q5JzMx4uanHgvOe2LxOdvXkK3jccg1cBjvmRyfrZ4h
	ApcP8wf83yt4iqbiY7cQuw1kKeH4iQN10oAIGS39S7URmDtpoOTky5GKthxmGPfu
	lsbkUODlOpyzz6xibtrskjnbJW7ewafX4FvFajALtUbYDD/nf823+9v4eXjwYffG
	H67Zx//zIXOnvYc35bcWFryCcItNeXgPCMXXZUQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=10;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	message-id,mime-version,reply-to,subject,to;
Message-Instance: m=1; h=sha256:By4hrD8Rv1lRub/bUWLT7Mfxr/lZHJ8K2Npoy860Ado=:g/G1ZcpNZA8VisajFa4oZuCOorxBoW1J8o9P5yfBAqQ=;
X-ME-Sender: <xms:9BnxagiPPaFcOGhwvaK47Wp0Zj9QGWDMM3BeesKnSmD-tAahV1Da4w>
    <xme:9Bnxav78Q9wnS9_BLS1r0m7RCBgCc7pE676YI5QhMByCmccLS50Li0u9TpWz8Asuc
    bxCayhDzBqiBDBTynCg45Pxn-njHISRrniFx33oCJgMv2hqkQ>
X-ME-Received: <xmr:9BnxagZ_ef9RJKBtw47ZRJMlzSDL396_GTb3aOR_9BaFYaX-YcemtOxITGUMgI4SxsTHQA829j4C7V1_z6KtG7YrdG67B-w>
X-ME-Proxy-Cause: dmFkZTFYopHkmG1WkLyYUYo8xSPp6QJD+QewfBd+aEWu6jm+W4TOpRhYJHat1Vn1Npoz0p
    zhGUvLxDQdAJFOWjJWgcRmi5igCt53/z5vxqBI9shMdT50f6cqTcRvB2Kw+UQqvM3y3GBJ
    XxxSKBS2tQM117WzSsijtzhDy8Wa9b7X5Xsi2QIwU59ZtRNXbm31GG4vZWIsYPiIgwC0LK
    CKNGoZq99zLxvwa0K1l8bWYjUNGS7XdWHfsd43AQh3RRO074TGWsSCShaRN6a9XWCTZpVR
    umthQLltWlNg+MimjOCrEajfOX1huC9Y7HiaRgDUSMfIpq7LjOPsNXwl+KESQJeGA45jU9
    5qjPR7GSwQQkasehPdeBkwJiVVzzcJnbwp/rMQqJzprBfDYq2uvt6X1kbRAFjth2gUmGQK
    iCBa6YwCAX/ZkbuVFCk1DMTHQp4hlg2c0Z+xiKWVBGqisoKhACU4Jy7I0mXMfNgwPgeVrW
    XFqaElKegWyjdQT8ho9Dz0HUkYX80gcKjrWqMDB7W6/t0Mg+snnjgv1V4cwZ3Rl1aKT21k
    DYdtedNMQDs9G7NDgmlMzysDjbghwDZdbBiQWW2M4QbSpW9+TD9Pbj5S39/gxHBOh8NFpE
    nlnbBc6Y0L94MtB+yWsvntPVsHxX2p0uTqzPfxkUibzkAIQjV1vbOwopzbfg
X-ME-Proxy: <xmx:9Bnxas6jA8LWOw-ZgsciiSGg2ypWC5o3FqooFTfl_clkFlLF0mpIOA>
    <xmx:9BnxarCPtbuEWwFxD7FkcrhOmJnd9tUdvosJJHRNLU5CY9E9GfC3Xw>
    <xmx:9BnxaqenoiXh7jZbOrJWoOcOWwQdS8ITl-tApD99cCozS7yXoNZ_EQ>
    <xmx:9BnxaiK0Dt_PofzYLNznaE8ueQPnqXI4TfLmur0ckdlAd-BQRuhl3g>
    <xmx:9BnxavHHogVKa49goXPHQl7hXPgJ4MUpM4Gz9HALQGSnYC-96TXtF6bn>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 8 Nov 2026 19:55:14 -0500 (EST)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 0/8] nfs: prepare for locking changes.
Date: Mon,  9 Nov 2026 11:52:29 +1100
Message-ID: <20261109005504.1804605-1-neilb@ownmail.net>
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

In this v5 I've dropped "nfs: fix nfs_call_unlink()" because it enabled code that was
buggy.  I have ideas how to fix this properly but it belongs in a separate series.

I've also revised the barriers in "nfs: fix open-blocking with d_fsdata", thanks
in part to Jonathan's input.

I think the rest is unchanged.

Thanks,
NeilBrown

 [PATCH v5 1/8] nfs: fix open-blocking with d_fsdata
 [PATCH v5 2/8] nfs: remove d_drop()/d_alloc_parallel() from
 [PATCH v5 3/8] nfs: use d_splice_alias() in nfs_link()
 [PATCH v5 4/8] nfs: don't d_drop() before d_splice_alias()
 [PATCH v5 5/8] nfs: don't d_drop() before d_splice_alias() in
 [PATCH v5 6/8] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
 [PATCH v5 7/8] nfs: use d_alloc_trylock() in silly-rename
 [PATCH v5 8/8] nfs: use d_duplicate()
