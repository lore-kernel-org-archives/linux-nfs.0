Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 19A2F2741AB
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2026 15:04:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769180674; cv=none; b=o2Z8zgnIQ4bTsb4holekfvauePazUUhCBmFMO3NFn4Q89KO75n9Fgrb2Mcwqp8MlGDC7M/Nye2iznII4CciR/Dd4UzUlTDytBCQVPESdF8UW5WokVJuGa9A7sIlFEimqZWv6XTfFd6IbPg1yqTFr/NJdWUtZpPXfYKpys/302h8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769180674; c=relaxed/simple;
	bh=SQEkIT8KGpmXjBQ7hOiB1ApldseNUijZtb1nmtU0/2w=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=N8+/pNE/O68REKqmdEgWh/d2JhBQNdYTojhpKFii4qCOaNBQC4haI9RXh067MpLe2MPxcKnaKWeU00qp7Ojo/i3w0y/PL8IaputwjSxxER+ZQuVE/9kfaQdPnygdtF3cOGjIi0iqUDAc394ENJbpyXVsfxo/RNLfZ/IYHwaBP88=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=tOOBu/Fl; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="tOOBu/Fl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7B977C4CEF1;
	Fri, 23 Jan 2026 15:04:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769180673;
	bh=SQEkIT8KGpmXjBQ7hOiB1ApldseNUijZtb1nmtU0/2w=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=tOOBu/Fl0Sb1oRJcW1PwSnwDRN/15MQgU91eDslS54k1IxuItlfHKu1TDSo1PVE+v
	 iO2gRsNMhi2Cj7SPSNUYWSbe5Qnj45/IBJJUSDIUOp+RijPRIua3hPSbOaRNSYzTmv
	 98cYHnjjywap5BbwUZkPguB6alR6XA60RzxemS/4HQZ7gwlqtiqya2DIPcYR3iogBt
	 05s4oWtBFIiz+50wbFSXU5/Grt1I74B7eAmDGn7FRuCAq2hdaBC9t5GIgAJwNZyxWL
	 gN4PeUvd1Hf/AJq+b9YAItH4MoYvbnh368KZiydKkVlyQTveWbZPUb/fVtrC8eqbrX
	 gwAswm6qc/rTg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5FBFAF40068;
	Fri, 23 Jan 2026 10:04:32 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 23 Jan 2026 10:04:32 -0500
X-ME-Sender: <xms:AI5zaZdyR9iiUbiT-DmhBIy0fzo7l0Dua1JYi8JvIlidbvjmndjJGg>
    <xme:AI5zaSBIIriBEaYEvHLkOIWzfjcqG4uddRMhFgYwWCm46ATk4LRJmIQ8LKxUPWgoQ
    P_YdrcruTNUlELUTJ_njlcC5Fr9Lc2fPxeYLZNjxyHMHJ12yN3fujM>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddugeelfeeiucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpefhffekffeftdfgheeiveekudeuhfdvjedvfedvueduvdegleekgeetgfduhfefleen
    ucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutg
    hklhgvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleel
    leehledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrg
    hilhdrtghomhdpnhgspghrtghpthhtohepuddupdhmohguvgepshhmthhpohhuthdprhgt
    phhtthhopehjlhgrhihtohhnsehkvghrnhgvlhdrohhrghdprhgtphhtthhopehlvghonh
    eskhgvrhhnvghlrdhorhhgpdhrtghpthhtohephhgthheslhhsthdruggvpdhrtghpthht
    ohepjhhgghesnhhvihguihgrrdgtohhmpdhrtghpthhtoheptghhuhgtkhdrlhgvvhgvrh
    esohhrrggtlhgvrdgtohhmpdhrtghpthhtohepuggrihdrnhhgohesohhrrggtlhgvrdgt
    ohhmpdhrtghpthhtohepnhgvihhlsgesohifnhhmrghilhdrnhgvthdprhgtphhtthhope
    hokhhorhhnihgvvhesrhgvughhrghtrdgtohhmpdhrtghpthhtohepthhomhesthgrlhhp
    vgihrdgtohhm
X-ME-Proxy: <xmx:AI5zaVAaS5hwhCf5XyueGpN5GBd8kNwz7GOcPuVQOp861ZdjT4HTfg>
    <xmx:AI5zafbmQuqdChk7-q8KdLkKoVYUA9FJzoP5oQTFZFjPODe016UpoA>
    <xmx:AI5zadl1kOilZhTmBPun2X_-IS0_WC_Fzyc8WXdizLmIcjxYrxkEUA>
    <xmx:AI5zaUqOoF4J82W2GBV6psHE1CENPuBFpPDFwIMklF3Y2pkryYFCCA>
    <xmx:AI5zafBKvKoUdA9SqsLnNALIuTlg0dONMEEHAIeTw1fOakObdrNYo5dO>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 3D723780077; Fri, 23 Jan 2026 10:04:32 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A3GYIHtTJmvw
Date: Fri, 23 Jan 2026 10:04:07 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Christoph Hellwig" <hch@lst.de>
Cc: "Jason Gunthorpe" <jgg@nvidia.com>, "Leon Romanovsky" <leon@kernel.org>,
 NeilBrown <neilb@ownmail.net>, "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-rdma@vger.kernel.org,
 linux-nfs@vger.kernel.org, "Chuck Lever" <chuck.lever@oracle.com>
Message-Id: <d70b5896-2de8-4417-a149-0fd1c55f4d2d@app.fastmail.com>
In-Reply-To: <20260123062844.GB25786@lst.de>
References: <20260122220401.1143331-1-cel@kernel.org>
 <20260122220401.1143331-3-cel@kernel.org> <20260123062844.GB25786@lst.de>
Subject: Re: [PATCH v3 2/5] RDMA/core: use IOVA-based DMA mapping for bvec RDMA
 operations
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Jan 23, 2026, at 1:28 AM, Christoph Hellwig wrote:
>> +	/* Link all bvecs into the IOVA space */
>> +	link_iter = *iter;
>> +	while (link_iter.bi_size) {
>> +		struct bio_vec bv = mp_bvec_iter_bvec(bvec, link_iter);
>> +
>> +		ret = dma_iova_link(dma_dev, &ctx->iova.state, bvec_phys(&bv),
>> +				    mapped_len, bv.bv_len, dir, 0);
>> +		if (ret)
>> +			goto out_destroy;
>> +
>> +		mapped_len += bv.bv_len;
>> +		bvec_iter_advance(bvec, &link_iter, bv.bv_len);
>> +	}
>
> Why is this using a local link_iter?  We're not using iter later.

I think we don't want to leak a partially-updated iter if the
API call returns an error.


-- 
Chuck Lever
