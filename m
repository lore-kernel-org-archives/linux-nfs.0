Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BDA5134028B;
	Wed, 20 May 2026 19:20:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779304811; cv=none; b=tI2Tqcs6Hgd2G7yEXtHWR+bWwTxdE2ths3xEAFkQWfc3BHsQkd39CdpCAFGSv20MBLFVbTJKzuUyBHneJjMEkWublmO8fwMfLRrV4K8dfMLCmhXOVHx48IMVLlGYwy2U+rO91lZ7B6EMUw4icQHfd5kHigTKZl/jCh+8k1n8HQM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779304811; c=relaxed/simple;
	bh=gwacEdUhs77BEy4QbzjQAkuA37XzahhPLdem0tbo37Y=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=FsUrRwKXoxzolAjHJ1fDFjsVCy2ORytGXePR+D7quWISvV5xfk3twtR2EdsjlZy8OWVYOIeNpXhvJKzFOeLWwXXjVG8Gsid98kKrgjaur75Ss+xjQWa10DONPaz/GFk6V32eT1K/EETWGJ7wJIYNKrnocceC4TYvIF/R/53SUBo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VrjPhi7L; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VrjPhi7L"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 025441F00894;
	Wed, 20 May 2026 19:20:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779304810;
	bh=uszsWvuAZ6M6xUfgGnCC0pT8mmX0CeQTTsRE9lXyJwo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=VrjPhi7LeRCtyCjTMTxWraDVtgYXhh69rA8fablim2NqzGCtTGgAXR0KTI0X1KO2s
	 t+yRMqhvUk2Vdpo92cs1VjedlXQcZhlkoyi/6GYPAJX3KROyX4yec4H4tFwOncRtY+
	 UlxoWqJ+mNpAWgvSxt6xUuxrMxlIyJ+oOiqYAMkuwVot6CGwDZvzAjKmVw1GF8b+6C
	 7b8nhLksZdiE+SY3vDwNrd1lOCkqpqrkYc002HYHiehW0pIGzd2vVLWoWTgl6tYmwC
	 aXrUapeISOXLV0/8ytWrCeHol9qlOnUy7roL7nBtdFUuqhS2O4xUFGOMP6qfKA8nPY
	 Dy1MIIvGKEv7w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3A6B3F4006F;
	Wed, 20 May 2026 15:20:09 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 20 May 2026 15:20:09 -0400
X-ME-Sender: <xms:aQkOauONLHApcMHrDSGWJphoiRBgNUr4oOnhU38BTFqGViju9NnzTQ>
    <xme:aQkOanwvRU0utdS_j_gbzRIuEKPsU-vYKKOCF-cCi7rHQlXNzXClLGRSQO1KrU_MF
    ToygFpQ5okMpTfWkJzhPn1Mv5GcyId4sy4z3wfqeeGAwEr1Q18A2Pg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgddugeehgeehucetufdoteggodetrf
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
X-ME-Proxy: <xmx:aQkOahtX9bBB6s7hvihxMbe_iQ88WgDTTiBEJzwtVkebnAqJYQc5Sw>
    <xmx:aQkOamwiHinJ2M7Y5VPdDX9VUeo0fHjFhNP-M6UEj0GZiUwQXoVR5Q>
    <xmx:aQkOamZSR7KtcOBUf6SSKLXkBR-jr6k4VVr6PzWOITBWRKfSnWRyAw>
    <xmx:aQkOalV4sq95EknlIph0TxkaDU-R8yd9SWQ1r-6rs_weptjt8_r5Zg>
    <xmx:aQkOanE2V45h8kuL_JU6eFRZ6RbsJSU4UcMJzGCFf9qO_yYSFyXChMA3>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0F692780070; Wed, 20 May 2026 15:20:09 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: APqNl0G3TauZ
Date: Wed, 20 May 2026 15:19:48 -0400
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
Message-Id: <cd159ccb-f1e6-4af0-96a3-3902dac86c58@app.fastmail.com>
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

Fixes: 608a0ab2f54a ("SUNRPC: Add lockless lookup of the server's auth domain")


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

-- 
Chuck Lever
