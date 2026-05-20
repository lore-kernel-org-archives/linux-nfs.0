Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C81E73546D1
	for <linux-nfs@vger.kernel.org>; Wed, 20 May 2026 19:47:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779306460; cv=none; b=XkQDye1fak/yGcUPtjiM1wIy/g1yJjjiBTLSbXyh6yNmrPt/yS1d0WrSMTl3TN/XsSNcwUU0Lz4ZDqNauXaRcyqRIoV4S/lBPmU6yEsM6L2FoPvzoXfrRSjQijUEbjI9L1D5tDe0e3ureQKhYFxs8rp//CNy2bqOMOevztwmw3k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779306460; c=relaxed/simple;
	bh=JIiCUGYOz3z1DNwuT/spCGR/gTYjHmC3nMNV2nLFLmU=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=uDZKpuMSHPFowOxvz8tCxNIctE/6UQn61h+MvD1+cPglyq6GE5FYFfdxMZkpFJ+oxjiUoe0ZnYbism/jZUfowT9tPumNrH7/TnPhtPVGa5r5UsXQhOhpiylFDFepVJ61GzSzXWOaYeVTNqBn4I6TeG619A73fIg70Hh3Qaphwzk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lBzBQ3YC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lBzBQ3YC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3232D1F00894;
	Wed, 20 May 2026 19:47:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779306458;
	bh=2roGTEf2fjp1DIxVD9aurqq9OEFaDkYMkVYhH8uQXD0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=lBzBQ3YCNmAC3XYCLK8jeqvvI0T5tPG+InR0ZDf/N4EP2nWUvrxjg8vbiz1wZh987
	 2n0ZEEGjsUeNOKyOJZfikob6x3E/S/9iqejBql/I3rVtHVP2wDGbt+C5hzYGD//WHq
	 GqSVzOVxQDTGpsBY5Ft1TpQTO14J/W3nWxfZmaX53JwrIbUmxQPLWXHWzL0EwoW+QO
	 0tpQ20snxAsf3n9Bxxta1oGoqVeC8RAWLwW76PRjRuj4T6OidB9E3kzaUj2UuaHqzL
	 DnxdKi0kJ+zMIDrxT140CZyjkyZT8FlqasirSysB27NVJ1pITIeim4g5wlu5suD8hP
	 LADojbRtx9Xxw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 605E0F40068;
	Wed, 20 May 2026 15:47:37 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 20 May 2026 15:47:37 -0400
X-ME-Sender: <xms:2Q8OaiGlClZE7j8gnfCrHuDVkRTgz31DNUvP48lnbgER3NIc-pKixQ>
    <xme:2Q8OauLI3uZPjmV5OrBPZKe57anxYpmnMBnkEKxqEul-vIvZBb1isFpPGUGXYdnYA
    seYMM6I2vTlA6pl-XCNayyZvroham7wZ_MmzIAnhElq4xiVgPt04A>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgddugeehheduucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpefhffekffeftdfgheeiveekudeuhfdvjedvfedvueduvdegleekgeetgfduhfefleen
    ucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutg
    hklhgvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleel
    leehledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrg
    hilhdrtghomhdpnhgspghrtghpthhtohepudejpdhmohguvgepshhmthhpohhuthdprhgt
    phhtthhopehnvghilhessghrohifnhdrnhgrmhgvpdhrtghpthhtohepuggrvhgvmhesug
    grvhgvmhhlohhfthdrnhgvthdprhgtphhtthhopegvughumhgriigvthesghhoohhglhgv
    rdgtohhmpdhrtghpthhtoheprghnnhgrsehkvghrnhgvlhdrohhrghdprhgtphhtthhope
    hhohhrmhhssehkvghrnhgvlhdrohhrghdprhgtphhtthhopehjlhgrhihtohhnsehkvghr
    nhgvlhdrohhrghdprhgtphhtthhopehkuhgsrgeskhgvrhhnvghlrdhorhhgpdhrtghpth
    htohepthhrohhnughmhieskhgvrhhnvghlrdhorhhgpdhrtghpthhtoheptghlmhesmhgv
    thgrrdgtohhm
X-ME-Proxy: <xmx:2Q8OaindjVfDO4S35mKR4P78xyZCIU1cJC0E69FhlMPU7Q3bIkRKKQ>
    <xmx:2Q8OamLKZ9l4JRPeyqvWNg094Ea5QKc7_I-vCaVuYmNcw8XhBuCp9Q>
    <xmx:2Q8OaiTaUhmxXP2xxR3bDuF4yh75CdNSHUQyKcf_pqJLi09H7NtxsQ>
    <xmx:2Q8Oajv4t9I0PLL-IZBokJwfr9IgbrvRwkizaE_e70Us8JZy-GN58g>
    <xmx:2Q8Oal9Pn8Qj9BVtxA5hnoZDd45xxsCxUBVvtVBmUlmXM0qKcPol7MQo>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 37AA4780070; Wed, 20 May 2026 15:47:37 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: APqNl0G3TauZ
Date: Wed, 20 May 2026 15:47:16 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Chuck Lever" <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>
Cc: "Chris Mason" <clm@meta.com>, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <42fc0eda-111c-43ec-9413-53d42bf758c7@app.fastmail.com>
In-Reply-To: <20260520-nfsd-fixes-v1-1-664ba702d698@kernel.org>
References: <20260520-nfsd-fixes-v1-1-664ba702d698@kernel.org>
Subject: Re: [PATCH] sunrpc: use kref_get_unless_zero in auth_domain_lookup
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, May 20, 2026, at 2:10 PM, Jeff Layton wrote:
> auth_domain_put() uses kref_put_lock(), which atomically decrements the
> refcount before acquiring auth_domain_lock. This creates a window where
> an auth_domain entry is still linked on the hash list with refcount == 0.
>
> auth_domain_lookup() walks the hash under auth_domain_lock but uses plain
> kref_get() to acquire a reference. If it finds an entry in this transient
> zero-refcount state, refcount_inc() triggers a WARN and refuses to
> increment (saturating refcount_t semantics), but the function returns the
> pointer anyway. The caller then holds a dangling reference: when the
> concurrent auth_domain_put() finally acquires the lock and runs
> auth_domain_release(), the object is freed while the lookup caller still
> has a pointer to it.
>
> The sibling function auth_domain_find() already handles this correctly
> using kref_get_unless_zero(). Apply the same pattern in
> auth_domain_lookup(): treat a zero-refcount entry as absent and continue
> searching. The loop then either finds another live entry or falls through
> to insert the new domain, preserving existing semantics.
>
> Reported-by: Chris Mason <clm@meta.com>
> Assisted-by: kres:claude-opus-4-6
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  net/sunrpc/svcauth.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/svcauth.c b/net/sunrpc/svcauth.c
> index 55b4d2874188..8e01f0626759 100644
> --- a/net/sunrpc/svcauth.c
> +++ b/net/sunrpc/svcauth.c
> @@ -245,8 +245,10 @@ auth_domain_lookup(char *name, struct auth_domain *new)
>  	spin_lock(&auth_domain_lock);
> 
>  	hlist_for_each_entry(hp, head, hash) {
> -		if (strcmp(hp->name, name)==0) {
> -			kref_get(&hp->ref);
> +		if (strcmp(hp->name, name) == 0) {
> +			if (!kref_get_unless_zero(&hp->ref))
> +				continue;
> +
>  			spin_unlock(&auth_domain_lock);
>  			return hp;
>  		}
>
> ---
> base-commit: 508c9eaa7e0b952c4fe019880796e6207e3cd201
> change-id: 20260520-nfsd-fixes-f137572d0480
>
> Best regards,
> -- 
> Jeff Layton <jlayton@kernel.org>

Forwarding sashiko review results:

> auth_domain_put() uses kref_put_lock(), which atomically decrements the
> refcount before acquiring auth_domain_lock. This creates a window where
> an auth_domain entry is still linked on the hash list with refcount == 0.

[Severity: High]
Is this description of kref_put_lock() accurate?

Looking at kref_put_lock(), it uses refcount_dec_and_lock() which acquires
the spinlock before the 1->0 transition is completed. Since
auth_domain_lookup() holds the same auth_domain_lock, is it actually possible
for it to encounter a 0-refcount entry under normal conditions?

> diff --git a/net/sunrpc/svcauth.c b/net/sunrpc/svcauth.c
> index 55b4d2874188..8e01f0626759 100644
> --- a/net/sunrpc/svcauth.c
> +++ b/net/sunrpc/svcauth.c
> @@ -245,8 +245,10 @@ auth_domain_lookup(char *name, struct auth_domain *new)
>  	spin_lock(&auth_domain_lock);
>  
>  	hlist_for_each_entry(hp, head, hash) {
> -		if (strcmp(hp->name, name)==0) {
> -			kref_get(&hp->ref);
> +		if (strcmp(hp->name, name) == 0) {
> +			if (!kref_get_unless_zero(&hp->ref))
> +				continue;
> +
>  			spin_unlock(&auth_domain_lock);
>  			return hp;
>  		}

[Severity: High]
If a 0-refcount entry is encountered here, wouldn't it indicate a severe
underlying refcount imbalance or use-after-free rather than a normal race?

By using kref_get_unless_zero() and continuing the search, might this silently
mask the root cause of the WARN instead of resolving it?

Furthermore, if the loop skips the 0-refcount entry and falls through to the
end of the function, won't it insert a duplicate auth_domain with the same
name into the hash list?


-- 
Chuck Lever
