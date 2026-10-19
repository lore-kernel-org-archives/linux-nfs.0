Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792422871;
	b=vqwuFRkuLbKEZfeqqQ9mwMr4h3buXqi8BQwoYrLr42usa9adyktn3WTRXz0B7UgkS6QM
	 aDykZBPJSoP4gpBLya4RGyJGnY0Krw7QN6OFC4KWEfFcU+yeZBwh+0q6M9Ds+m5zNNrsn
	 3iTIt64t1tVrxP1BdPo5Cxyys73V3ptuHtW+8Kv1nsMwZTvb7UylMdqIz2H2A6VuMD5DO
	 KqHlQBsGAM3QagsVpKCSbJQxFicZ5rmcYUk/xcI+IdboJtJb8Tfd8KhWpD2pryDVo6i6+
	 pgyj9eGiAq7Y0x42TJm3QlcR9dIF34XSqsvAwz5eLVxVCcHQ2qkaaoTWibEQRBe6shA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792422871;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=80EtpdVDdwo9wKnZFJQeT1iQ7dsKuP3ZzDVfRulgDQQ=;
	b=YDtFdBXEM5gtnv2QIYr3Rdw8ltOliieJliMeeg50a0IOitEKeRfc786Lf7S0DgSsVQ24
	 zGvdbwCOjHmvQWXP9OJv81ph7b8I/Sn/r9p2+sdYchfuH/oAgfeD/VRxZFZSNVFX2Es6k
	 cyi/dRaXkeatqP0plZ5/HbHZZktfKpZqDiqmmpjJWPkUoe/sUm111wu47pVbVHyzuk9LZ
	 MhLairiiLm4njc7JAhEbbQYynid30lJVOKGg1a2P6n66LcoitPcB66T/41xbU5668awxr
	 qC9lohYjUo4Xj5RuU5paSw+aPjMXGThxWtSH1LBNmSrU4ENPHVT+Idaxhtk4tFi0NVA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WVLVPBtv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4425609CEC0;
	Mon, 19 Oct 2026 15:14:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WVLVPBtv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C50C01F000C5;
	Mon, 19 Oct 2026 15:14:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792422870;
	bh=80EtpdVDdwo9wKnZFJQeT1iQ7dsKuP3ZzDVfRulgDQQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=WVLVPBtvuDYvooSX3aytg9/zskV+QECbtCIZ3FtIPIZUwkcAeQ4KnXr8ALqAIRXoP
	 XT2Bnhj+XYfvJjlYhI+RlDHGCEUeeZCUJG5MVqMtThDnvJfgErSlYu70W26iNIMhFn
	 RcaDSkDlQjA/3fksCB/P5R83yJF1USiYTjXOENSyqPYPeK342MdyX1bI5p3bqrS1aA
	 8vZiMJ/WdBSrX97upqwtcIHK5VHEh/2boXdpAjO9Lf69ascp/YH38Dk/woz2Phqn9E
	 ZGC5FIszipVD1f+7niy6auu8PnI0wq+JeN4tlHqPL5MZ5QgOT6z23DwjLshVUQVtJh
	 2XBItIH/D3W/A==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id EB370F4006B;
	Mon, 19 Oct 2026 11:14:28 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 19 Oct 2026 11:14:28 -0400
X-ME-Sender: <xms:1DPWaogwgLSKSy-OlP0O_lOI1SPmRVkUeAzWZym5GjMeeqbpwVPexw>
    <xme:1DPWar2tHY_ldW5nGJh7r8rfX9iV6nmlVm1_kHSN5mdDmYsCL8EWz5smO-hVnY4Cu
    -NhIfZChyroW3P0wQBUWI2Nn0zc2QRcQSrIz_CjwZbFSNJQLVqL5lpQ>
X-ME-Proxy-Cause: dmFkZTFD3iB6Fi9wEihA3a+/aoG1DIdu4gKSsQ+2y1bIXEoaqdBebrGrcnUodJXcKgkR5q
    YBO0xaHkPiOP5d9uzGN45wzhr5LWUB3Qw59jbaNjBanA5VfH3AvHYZ7/278q0OhLO5nQB/
    utcjleP0cxbocTWzcTmSdKFCwDeM4waXpzQ0te7oaxf9qSGQVFMbRARxJUvCfX/CgK4d7j
    fmOigay9TLvP09zXKX/hqOjtmGRunPaDOwCkXazQMTSK2RpBWwEUwoymiB5mV4jExn08jt
    gksfwM9AM0D+/P4YxP8YD7rd12BC4o9pNCiIypgrVh8eDskaCplPQFPZRj4eGErvJNxjcz
    jw/sfRxkv0avpE7gxDPo0olAGrldZx6BbIfOx7Yyww9odeXpRwYyP5eASW5lz8nCrbWHtM
    Yzquq7EHm4mtIRPVv+SBGBDinjCUBs7p94Qh8Ov6zN/kAaBJTVRB7ZSpzgt5lkWdHL1kiP
    UVMGhZahw9psbRryQn6SoSzTMV4gis14mmDozEi430hQMuIVe+bxnYmDcBiSeMWcD3uFaS
    OWACcGRNfSxxIRgFFi2zq33FiopOdYIQAI5yXo+kT3RAEHW+KwavZ/QjFw412Kh7mM1zac
    bdEC99ADli4sUIa1WkOtLnfszKzKvoJhasWO7cVKjdvrNhN4UWA292i2rUcQ
X-ME-Proxy: <xmx:1DPWatjqVKDPiGAwnO3rChM9-X8-mIQKikwjCAt09Hj9I99Wr02qWg>
    <xmx:1DPWascb3yfMl713G-sdeGRQqfVL7wDbjIp2M4czwj5g-Sc1aYuPHA>
    <xmx:1DPWakkc0uy4gzKO6JBAjThFYal7p5I1U9PROppUBCajAM9uXGvq2Q>
    <xmx:1DPWapzCG3knP9IXOzxIfSucmlgzAh5cHwkTcvaOxZSJ5WYDTJzLOA>
    <xmx:1DPWavyj55aJqTYV7jh83GbaEowjMFyW8bKyAj5-7p3mR0Pdv3fw1rNn>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id CD0FE782738; Mon, 19 Oct 2026 11:14:28 -0400 (EDT)
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
X-ThreadId: AS6kSLE8WzSk
Date: Mon, 19 Oct 2026 11:14:08 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>, "Jeff Layton" <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Christoph Hellwig" <hch@lst.de>,
 "Jens Axboe" <axboe@kernel.dk>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>, linux-mm@kvack.org,
 linux-fsdevel@vger.kernel.org
Message-Id: <78b61d82-8f19-442e-8e0d-6cce861e49af@app.fastmail.com>
In-Reply-To: <20261019150725.1507-2-snitzer@kernel.org>
References: <20261019150725.1507-1-snitzer@kernel.org>
 <20261019150725.1507-2-snitzer@kernel.org>
Subject: Re: [PATCH v5 1/6] NFSD: add tracing for how direct-mode READ and WRITE are
 serviced
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Oct 19, 2026, at 11:07 AM, Mike Snitzer wrote:
> When io_cache_read or io_cache_write selects a direct I/O mode, a
> request may still be serviced with DONTCACHE buffered or normal
> buffered I/O, and a WRITE may be split into up to three segments that
> each take a different path depending on the request's offset/length
> alignment, the payload's memory alignment, the filesystem's
> FOP_DONTCACHE support, direct_misaligned_min_bytes and
> direct_misaligned_dontcache.  Until now the only visibility was
> nfsd_{read,write}_direct for O_DIRECT and nfsd_{read,write}_vector for
> everything else, so the DONTCACHE and cached buffered cases were
> indistinguishable and the reason a WRITE was not issued as direct I/O
> was not recorded at all.
>
> Add:
>
>  - nfsd_write_dio_split, emitted once per direct-mode WRITE before any
>    segment is issued.  It records the advertised offset and memory
>    alignments, the payload's offset within its first page, the start,
>    middle and end segment sizes, a disposition naming the path taken
>    (direct, no_alignment, too_small, no_middle, mem_misaligned), and
>    whether buffered segments are issued IOCB_DONTCACHE.
>
>  - nfsd_write_dontcache and nfsd_read_dontcache, emitted for WRITE
>    segments and READs serviced with IOCB_DONTCACHE.  nfsd_write_vector
>    and nfsd_read_vector now fire only for normal buffered I/O.
>
> The disposition enum lives in vfs.h, which trace.h already includes.
>
> Document the new events in nfsd-io-modes.rst, together with iomap's
> iomap_dio_invalidate_fail event, which reports an O_DIRECT segment that
> the filesystem serviced with buffered I/O instead.
>
> Assisted-by: LLM
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>

Thanks for sinking this one to the bottom of the series. That was on
my to-do list for today.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
