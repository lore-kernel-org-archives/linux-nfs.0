Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F41D30E837
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2026 02:46:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776826019; cv=none; b=BPwoS3DkaM8H8ROIuZSf4WkwYji117TSlJl4GgqgwJ0enAuNP+hBbp1aDSyA0GKkqIp67NfGabn5d0syhXhUNNzGmUUmeWlrJKHUjqPDoa9oEqviXPUTjK0Htg8RpaLrqCXLQ2RhEwWeAKuAdrlIb9TG85ohaOPRmVdekFFUcfA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776826019; c=relaxed/simple;
	bh=/wWQueEieNTrF02h0+osHu8XAVJsKpP/LMvkfNN6x1M=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=cw1+Xsb+K4SDPjh3nuwwnXQOJ4n2P3VM5NV3x3OBT2XsXUO3xOeR7Vb7hhbKstS0ZHaLNfgoElDnk4dD0kzXpV+h0ongZlxyhoMXS9BQiDHGWAJ+mBV0ze93MJOXNC6bTXdfIcN2Om5xmmCEnLH/Os2nsJeibxHOgmj7TvSZEMI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=misWOl/Y; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=RpEuKhjP; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="misWOl/Y";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="RpEuKhjP"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id D9D377A005F;
	Tue, 21 Apr 2026 22:46:42 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Tue, 21 Apr 2026 22:46:43 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1776826002; x=1776912402; bh=argyXE/vybjmkH8vMVjPzKMwasoZEMrtSRg
	QilBDCT0=; b=misWOl/YIG3BxC1YlQTB3BWcVBDLcTU6IcLpNQSoM0F4hWgVDex
	fpYPbDbPwjtA0JPnbFb/ESmDE7AZV9am4b4MZNCVjYeFkXMH6k95cgtgaaQtvQBf
	9/kF2lK7jTrukn8YjBg2LtJFbtfzH41hzmy2YusbWCRXRm/Kp4ttu4KEXcq1ORju
	sZsoU0iebw5S4zE4RjQVtXazaAUtVozfgMbEkJ64CUD8o8h+1xbcZgzjh7B6Aiay
	2iBSXgjEEQ43aOqHlgFrVZihTfkmppbGDlUC4Y22X8Qw5X0sP+m7KoTLezZFwGkL
	pXBnIweZKttM+Dzd+0ghJUBkUwtQ8IQrVmQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1776826002; x=
	1776912402; bh=argyXE/vybjmkH8vMVjPzKMwasoZEMrtSRgQilBDCT0=; b=R
	pEuKhjPxh1GzTF27dxkzSxmAMokIr11gUxsWuUdtuOBQ1ykzNLVqiSmHdfZgoOOT
	2TvliRbj1zRD65+dwtH48hqUlCLKg7nz8Mxm6ZxfuKVKQjnoPGgXsbeqlOUUJaeJ
	rgmd2lQ1gIvgpkjtPVcuxPIeDM0V9SKUjpZBSRfkoKOlaZcVOEw3bT5b+6QBydfS
	cftGzG75neD8WNAci+Zh0uN88Jrxz5/+THdpuZsAtU8B2dM2goSIKzRxK/XRicGX
	Fe4XJzSmc8jVHzyQ7J6AVVWD0qrhQsrBuHIq0ayt5I8MjX82aNbeQCDpxT2itTT/
	T10bTSqs8UsALSkeExCyQ==
X-ME-Sender: <xms:kjboabcZUStYNEjA8NU_es5i_Vxa00uxcxx1FejEFzpwswa29IB10w>
    <xme:kjboabN6PyqR1aXZ9cBdFqRVT5NcejjO7Oye043mgCkK6C5D39MfZEqP_ks4rBig5
    r0OtgZLm6WMSWls2Rte2b3AQiOvn-c0F7DSo2W8wn0wBOlW>
X-ME-Received: <xmr:kjboabKehoSSEmHS-N9dHFBNlyHlZpNAZCGC0ZBqR51EhXFsg6Qj8Dxz7Bqbjv9ylRlHPzZ5rTZHasQvQCRouBQt4dCOqZU>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdeifedutdcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpegtgfgghffvvefujghffffkrhesthhqredttddtjeenucfhrhhomheppfgvihhluehr
    ohifnhcuoehnvghilhgssehofihnmhgrihhlrdhnvghtqeenucggtffrrghtthgvrhhnpe
    ehvefggffgueefvdeuieefhfdtteeufeeuffduudeuffetveefveehhffhhfegkeenucff
    ohhmrghinhepshihiihkrghllhgvrhdrrghpphhsphhothdrtghomhenucevlhhushhtvg
    hrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehnvghilhgssehofihnmhgr
    ihhlrdhnvghtpdhnsggprhgtphhtthhopeekpdhmohguvgepshhmthhpohhuthdprhgtph
    htthhopehlihhnuhigqdhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhgpdhrtghpthht
    ohepthhomhesthgrlhhpvgihrdgtohhmpdhrtghpthhtohepshihiigsohhtodeitdgtfh
    grtdekkedvvdegjedtsggsvggsvgeggeesshihiihkrghllhgvrhdrrghpphhsphhothhm
    rghilhdrtghomhdprhgtphhtthhopehokhhorhhnihgvvhesrhgvughhrghtrdgtohhmpd
    hrtghpthhtohepuggrihdrnhhgohesohhrrggtlhgvrdgtohhmpdhrtghpthhtoheptghh
    uhgtkhdrlhgvvhgvrhesohhrrggtlhgvrdgtohhmpdhrtghpthhtohepjhhlrgihthhonh
    eskhgvrhhnvghlrdhorhhgpdhrtghpthhtoheptggvlheskhgvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:kjboabJ7tei99S6hteXYh4mpLoRBTn_6X2Mb3RAejtQQcAERWi9yxQ>
    <xmx:kjboaV7nQgmxFOpr0uJPHa4d0IZBPexT5dOZMzPE3nX1hFEnCS3tUw>
    <xmx:kjboaVfXtg6ojPM9F74aKZTdn5dzBoodn6uRMqy4ivHLBNpQdOLygA>
    <xmx:kjboaQGvowZ6Lygf5Jz9MVpgM301F-tRSwl6eLqNEG2UH5ScO6ed-Q>
    <xmx:kjboaUznvW8f5fD9bYomNmkwaEFVcn0n9DnsnX2Bg61r52f5cvQttEKF>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 21 Apr 2026 22:46:39 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Chuck Lever" <chuck.lever@oracle.com>,
 syzbot+60cfa08822470bbebe44@syzkaller.appspotmail.com
Subject: Re: [PATCH] sunrpc: prevent out-of-bounds read in __cache_seq_start()
In-reply-to: <20260421161126.129533-1-cel@kernel.org>
References: <20260421161126.129533-1-cel@kernel.org>
Date: Wed, 22 Apr 2026 12:46:36 +1000
Message-id: <177682599675.1474915.15004300765582458400@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 22 Apr 2026, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
>=20
> Commit 7b546bd89975 ("sunrpc/cache: improve RCU safety in
> cache_list walking.") changed the tail of __cache_seq_start()
> to unconditionally store
>=20
> 	*pos =3D ((long long)hash << 32) + 1
>=20
> before returning, dropping a prior "hash >=3D cd->hash_size"
> guard. When the while loop exits because every remaining
> bucket was empty, hash equals cd->hash_size, so the stored
> *pos is one position past the table's last valid bucket.
> seq_read_iter() caches that index in m->index. A subsequent
> pread(2) at the same file offset skips traverse() and hands
> the stored index back to __cache_seq_start(), which decodes
> hash =3D cd->hash_size and dereferences
> cd->hash_table[cd->hash_size] -- one hlist_head past the end
> of the kzalloc'd table.
>=20
> KASAN reports an eight-byte slab-out-of-bounds read at the
> tail of the 2048-byte hash_table allocation for the NFSD
> export cache (EXPORT_HASHMAX * sizeof(struct hlist_head) =3D=3D
> 256 * 8).
>=20
> Reject an input hash that is out of range before touching the
> hash table. cache_seq_next() already bounds-checks its own
> loop; the start routine needs to be symmetric.
>=20
> Reported-by: syzbot+60cfa08822470bbebe44@syzkaller.appspotmail.com
> Closes: https://syzkaller.appspot.com/bug?extid=3D60cfa08822470bbebe44
> Fixes: 7b546bd89975 ("sunrpc/cache: improve RCU safety in cache_list walkin=
g.")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Reviewed-by: NeilBrown <neil@brown.name>

Thanks for finding and fixing this.
We could of course avoid ever storing a too-large pos but adding
back a test for hash at the end of __cache_seq_start() but I prefer
the approach you took as it is more robust.

Thanks,
NeilBrown


> ---
>  net/sunrpc/cache.c | 3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 305c6e67f052..391037f15292 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1352,6 +1352,9 @@ static void *__cache_seq_start(struct seq_file *m, lo=
ff_t *pos)
>  	hash =3D n >> 32;
>  	entry =3D n & ((1LL<<32) - 1);
> =20
> +	if (hash >=3D cd->hash_size)
> +		return NULL;
> +
>  	hlist_for_each_entry_rcu(ch, &cd->hash_table[hash], cache_list)
>  		if (!entry--)
>  			return ch;
> --=20
> 2.53.0
>=20
>=20

