Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794945760;
	b=PmM4HgW4iccy2tR5FBDL0YGTc/kA5EjT/X9zkn71nb+y0TkPLIqPJpPNGSmg3PlSvYnf
	 oykEFVhXr07+K1x1tkDfPYoIZ1dn+Tpa/40Id8kRjMYjCzswBzfI6TJB7zXk1YgoFh2Jl
	 PxQEx6qHlcd2OvCCo/oAmqdjsmWucoYZwsWQ8IK/N75XxMY9cGNma03ZteF1H1Dz9yIkz
	 50cqoyoA1ivJcNpVc3Fzj/QmNet36MXjQD0TcjUv2LQ/AY2sSgEiDUqbnoBn5MiaStqsn
	 Zo7xa1FYEAJk1TkigatiVzpXhJrNGXDRYRzueDN+WHfp17jVjzywZhqOk+RRFHfgnNQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794945760;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=pH7i3rIEVULR+ZSAOdZjHq+LUo/ew2g18YNxqrflUKo=;
	b=CvXmTvQ/6bQk1hwJXcUI9qBqoqwjjJr9kWCHf+VxLt8yqx5fwnjuTjfxWOqDP/YE8+CN
	 RhRJlNqe4E8+hd+fE+mSEkbRpHYu+6vMs6p/fcUpiKOb2Iya8j9Q8oMaZzF4UBsXOANWn
	 Yf831ZGwL6ky6nTJU1qysZGYL/9/UU0k2d/2KzZSqKlJJXuo3hW9zeWv7jP6SVwYtxACY
	 pE06h8My+fNNrk5LsP1Ruz4UxUarmVuW3LJhXq1Akluu8qfi3K4U+lybrqgBkO7k2E/NR
	 RM0F5+w8zZTA0eiSz/3NOsHVV6dwSCPUUIzgi7Besdr+vUeqxjUK1TisqZt9kAHYrNQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BA+we53M;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA67B606A32C
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 20:02:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BA+we53M
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 64FD61F000C7;
	Tue, 17 Nov 2026 20:02:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794945760;
	bh=pH7i3rIEVULR+ZSAOdZjHq+LUo/ew2g18YNxqrflUKo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=BA+we53M4Z4v50M4KA+HBsG91U5zlyLkq+PZK/QeQf5SOcAVmy9D3RvPMRMl5PbY0
	 BkyBrijaBWrUwtO1S3CTlbpg4SrVucNo/mheNzrFfSkXu7j5SARu7PLMmn+RhspFYz
	 B4aZ+cvCqGt+z4IbHzPEEIbrLJcOPDMVPuY10XtrpPyyRh3gz+DSt0q/MRrV81nCRW
	 aZsV0DUWOr5En3HyHhkTHFbu4GSojW3DT7cnbSlmRLt2Zr301QdfGn6X4T5PAWkTuI
	 5MJLaB76ja71Aj0nnDbzAgU2cUkDYXg7x8kYGfFVACnfjJmR2le6SSZ4HZD4j2wnqi
	 qvKuiGRyIKDoA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 8CF4CF40066;
	Tue, 17 Nov 2026 15:02:39 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 17 Nov 2026 15:02:39 -0500
X-ME-Sender: <xms:37L8ajRnEA7CKCDpkcG72AKrZdqDxixndO6FDh1rdD5xUtVDlAwIbQ>
    <xme:37L8avl8M9E9FCQOHSC3Gyo8UItcBpOHW5ripup8WJiTMVCJFiEDfichJ-sUxyXkc
    fMAaUPw7nIu7-gArBIpvDTCfOMClI2hFz6BGnUHdqYny6W1MiWycHJX>
X-ME-Proxy-Cause: dmFkZTE2M532g5mZoKvRo7mPdInQOsQvAsWWlSVmjU4F/WCxLVfWkt/2QUbV13XH84/CG7
    l8LL2Z34uP7Zk6pV5XBN2FdddJ/RkcHEk2eAx6BZLBwl8ndqDubbcgTbMTRZGR8pnEVFkW
    pDL4qS4oKqQ/VT1yLWJNkR/g4c1MFQoRnDNc34fkaHO3kC14PHL2mOml/lIPgm6bMbQNNS
    jOm/T2gx2ppAbSZwevgcE0QI5A6gT1Bs6IxzbAgQXJacTo9rmPnIrLRA5R/hlrvozdFAkh
    xkmN/JXJbFwjyuH2DytA7AmFtI3m8+X1pwCULna1HDOnMT00gNdyA0xDY3T78XKLetYghl
    wKP7yFp36/saNacub2tP/SKbmLN4+gcdSi7/PbLpgOkam7LG2BEz7iDXnbwf4qIGdjhgVF
    iqgaf5eN46fhuyuzxqgZEs/a8ZatfD1A91+CL1gk65zFA6WtX7RwRLfQ5ubgmaYGG4zdCV
    pH15PfzGFjSDHoE9ixtKeFZu6mCKQ56K6dfCYF9q0lK6Ihj9aUjDCmyp7ID/I7kJu0VcNt
    41rd/wNuhQqUMcN2nIh4mz5nkgeN5v4zrBqd4FQ2BwNrflE1JP7DoUq+8U+zJS0dhOJiqd
    HwjKaC2u+ebCr4ZwADEBgdclNa2p9vwIDwXoEr60WiTrjfZOJpHi5vM0gMqw
X-ME-Proxy: <xmx:37L8aqWSy2wi75cX4bNNURqQO_0PzXI4HimA3JvacMSTOQR-dXHaiw>
    <xmx:37L8aoHYKgSG5d3sFZObeQcVv0Lajip-2uTKBKL3xhQqOWn-hAgScw>
    <xmx:37L8aufRw-4O69WFgADrcsjHno0mL8sl-XDo2B4zSlPD5jt4mzpnXw>
    <xmx:37L8ahJD5m4eBbzaAhq9MWOaPCoHNaGSVvpO7SwlEGBHCURepQvMrw>
    <xmx:37L8arECHt_xJpa7PtRt0Mz_7XQMllfI1LFzBAfGB2brnYAC6lu8yxeU>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 6B2FCB6006E; Tue, 17 Nov 2026 15:02:39 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: A1ErcsuEOLNc
Date: Tue, 17 Nov 2026 15:02:19 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>, linux-nfs@vger.kernel.org
Message-Id: <2ae94011-4981-4507-b75e-cd0d326989b8@app.fastmail.com>
In-Reply-To: 
 <179494500179.1728055.16539025879082560214@noble.neil.brown.name>
References: <20261109005504.1804605-1-neilb@ownmail.net>
 <179488445814.1728055.9049767251296971441@noble.neil.brown.name>
 <759d7deb-f380-4094-bb6b-35a4db945d56@app.fastmail.com>
 <179494500179.1728055.16539025879082560214@noble.neil.brown.name>
Subject: Re: [PATCH v5 0/8] nfs: prepare for locking changes.
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Nov 17, 2026, at 2:50 PM, NeilBrown wrote:
> On Wed, 18 Nov 2026, Anna Schumaker wrote:
>> Hi Neil,
>> 
>> On Mon, Nov 16, 2026, at 10:00 PM, NeilBrown wrote:
>> > Hi Anna/Trond,
>> > is there any chance this series might land for the next merge window?
>> 
>> That's what I was expecting. The patches looked okay to me!
>
> Great - thanks.  I was expecting to see them in -next by now if you were
> okay with them.  When did you think they might land there?

I don't know. The 7.5 merge is Trond's turn, and I'm not sure when he'll
get a chance to start building a linux-next for it. I have been keeping a
private branch with changes that I expect to go into 7.5 so nothing gets
missed, however. I'll ask Trond what his plans are next time I talk to him.

Anna

>
> Thanks,
> NeilBrown
>
>
>> 
>> Anna
>> 
>> >
>> > Thanks,
>> > NeilBrown
>> >
>> >
>> > On Mon, 09 Nov 2026, NeilBrown wrote:
>> >> In this v5 I've dropped "nfs: fix nfs_call_unlink()" because it enabled code that was
>> >> buggy.  I have ideas how to fix this properly but it belongs in a separate series.
>> >> 
>> >> I've also revised the barriers in "nfs: fix open-blocking with d_fsdata", thanks
>> >> in part to Jonathan's input.
>> >> 
>> >> I think the rest is unchanged.
>> >> 
>> >> Thanks,
>> >> NeilBrown
>> >> 
>> >>  [PATCH v5 1/8] nfs: fix open-blocking with d_fsdata
>> >>  [PATCH v5 2/8] nfs: remove d_drop()/d_alloc_parallel() from
>> >>  [PATCH v5 3/8] nfs: use d_splice_alias() in nfs_link()
>> >>  [PATCH v5 4/8] nfs: don't d_drop() before d_splice_alias()
>> >>  [PATCH v5 5/8] nfs: don't d_drop() before d_splice_alias() in
>> >>  [PATCH v5 6/8] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
>> >>  [PATCH v5 7/8] nfs: use d_alloc_trylock() in silly-rename
>> >>  [PATCH v5 8/8] nfs: use d_duplicate()
>> >> 
>> >>
>>
