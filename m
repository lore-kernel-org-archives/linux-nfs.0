Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E135450917
	for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2026 15:48:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782834491; cv=none; b=iBzazsVVOBaITNrd1LCI+d2l2oa/4H69DRWHD9uUeimSWzjrySeuOkQW5hKqQdM8+b8/wdWcWwpJ+ED9RjZQ0VyWM9wbg67YnDoadmROOZcBrl5l6KfwAekpIM+mUxCizgirUiavGwAxqUBaV9I6oj3OPPsDogLD++prm4IkjoQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782834491; c=relaxed/simple;
	bh=V/wtEIoaxRGdkuhrnAEyaCIEPW8Wtbo13Dm2b+StlJE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=QaJwBFtLU16uCg7o1IQ+1LrfQgOAB7RzG2fyx23xGUH8AMzW5M+7zTSyYNfqOyz2zXJAanQfri28SxHco9+sAcGIdQHdMWIHRC9f9lRXWzB28JYcN7oCg1h+4ZlQWs6oShG+nOS+qUknT15fUS0AyBLfKcdgr4XcPzlv9ZZlqqM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=l9lh5/3a; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="l9lh5/3a"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F2CDE1F00A3A;
	Tue, 30 Jun 2026 15:48:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782834490;
	bh=I37OL6EnCY/61NHR9mkFvB+neu5ifz72N8QJZ99NtK8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=l9lh5/3acSSZ281btpTKVqCVz0zR5B9Zru290oFklF9mPci0KgH+gQnktoVvkpfRJ
	 o8JTjE7sKv4Zsjanjaljedc1ROUkkGGz/D+lFRdbTyR0wQ2pjpml/KQeiQywn4MuFK
	 Aj+Ff5ppboKGqT2+4IvPokP6k7Ibi6xnoT2C8PpN41+gC6+iLbhJezQvrWFIuybGgf
	 qJYKtuSbCgPsuz/7+cJbqfm5yNe76jscmsImS0xE2sGhJtCxCFhvs4mN9Hb6ffWJRL
	 eDS4jtMY+KGbegcD6Qcjsxrop5eyp3K0ND1euTt0GEl3qrL3yezXf8t8SLDQ3Wdv5L
	 2k7ESXyug30Tg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3150AF40069;
	Tue, 30 Jun 2026 11:48:09 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 30 Jun 2026 11:48:09 -0400
X-ME-Sender: <xms:OeVDarBKPMZABKh8npCoXdTl4r5voK25ZXsZvhreEfmbK8RsFbYzXw>
    <xme:OeVDasXAlOilY8uqM84YAKcNGTlATcTwgeUylTvOf_jbK8FJr-qI_LNb5b8-1GUP9
    VJY5w6UHFNIKlnuVcmnsmTSe4lx752Vy1rr5i8Vv6WHUi-m0Ec7P_wb>
X-ME-Proxy-Cause: dmFkZTFLBB5ANlRbjmh2RlDmTP5+XF8r1gD7ABeuuxknVhw5zFl5f5oMgbh0q++D3Rcw1I
    +1EE+GuOXtpatuZyouSuysNKd2hKM2maM3SxHvmyayCzSl7thqlvgEfGTGkXCJc2JNjpxp
    uyh6cdssDiuXK5+SXpadgTvqTvmffVnQ9C/Qc+HXr3bAUTeG1lflHPasgQ7gD2lqp5UJis
    H2zvlmc8i2h/HZECirP88WX+5usgPSTUuqebC5izzlch7esBEBwkRduJlT+bId9x3XX4uy
    VMj3oJjCeruQxRkc/xqbSEoRfq+HkPEg+EsCQYwRJhP4iWF0ATxI9FaSEW3jSMktG4auLf
    AKchXZzFF6KzGm/O//xwo+zR1GDwARHE5UX5EceKVvNRAyxXi5cuF9TFC/rAiwE7hVuUrt
    WsxUve8tctEg4yTrpWXVn2sIXNNl/TR2CGj6JKP3gJ3HupWfskcqn7EN+9n18lbBYfxngN
    k4KtcMIPDy7DkBex8ESaYkYRNEbqjh9A8rOjF7SnFJBG6gx6b4CYrllJwqtepyYAsAHKEN
    lspxaaOWmeRvj7i4cZ/exygqpQK2+DsFrZqmlD9zIXki/oE7b7QB2YtJ8UwNH5TRP7QyjJ
    +aXbyjlp7Y1YzRfRAv96eapWyOL74Ld4cUZjw4JAGbCvUj7eUbsmNH2pz8Vw
X-ME-Proxy: <xmx:OeVDaoeO-eJYobFjDtxhLfWr1KSys4ykrIiLXDRmV5dj5h74xjYKnA>
    <xmx:OeVDah99jTlRjst-RyakRI_3KTiDSR6p5Iu1n5ycZyYtiLcmC87YWQ>
    <xmx:OeVDasmbnUTWoN3txI-o6txg71y4neXlR_lIjZ2MFhFcNpPllOyrqA>
    <xmx:OeVDar9r78aecZSW8e7u26QP2l5TxiIk6g1kuZPQ23G5QmbY4jQa-w>
    <xmx:OeVDaimEpTLYDXLPi8mNjF5NQ0jCdw2Q3G-foTBADLlyTH0dpaXp1YR8>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0EC4E780ABA; Tue, 30 Jun 2026 11:48:09 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AXywqv_4gqb-
Date: Tue, 30 Jun 2026 11:47:48 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Oscar Ou" <oscarou@synology.com>, "Jeff Layton" <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Message-Id: <d8c309bb-37f8-4465-8abf-ba34db499ae1@app.fastmail.com>
In-Reply-To: <20260630093820.2162344-1-oscarou@synology.com>
References: <20260630093820.2162344-1-oscarou@synology.com>
Subject: Re: [PATCH] lockd: refcount NLM_SHARE access/deny modes
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Tue, Jun 30, 2026, at 5:38 AM, Oscar Ou wrote:
> When an NFSv3/NLM client issues multiple NLM_SHARE calls from a single
> host for the same (file, owner) tuple, the current implementation
> overwrites the recorded access and deny modes with the latest pair.
> A subsequent NLM_UNSHARE then drops the entire entry, even if other
> grants were implicitly subsumed by the most recent SHARE.  This is
> particularly visible to Windows-style clients that map each open of
> a file to a distinct NLM_SHARE, all carrying the same NLM owner
> handle.

> diff --git a/fs/lockd/svcshare.c b/fs/lockd/svcshare.c
> index 5ac0ec25d62d..4a1a09c209ea 100644
> --- a/fs/lockd/svcshare.c
> +++ b/fs/lockd/svcshare.c
> @@ -25,6 +25,24 @@ nlm_cmp_owner(struct lockd_share *share, struct 
> xdr_netobj *oh)
>  	    && !memcmp(share->s_owner.data, oh->data, oh->len);
>  }
> 
> +/*
> + * Recompute s_access / s_mode as the union of all positive refcount
> + * buckets.  Caller must hold the per-file f_mutex.
> + */

Is the f_mutex statement here accurate, and the matching sentence in the
commit message:

  The per-file f_mutex held by callers in fs/lockd/svcsubs.c continues
  to serialise share manipulation, so the new arrays do not require
  their own locking.

nlm_lookup_file() in fs/lockd/svcsubs.c takes file->f_mutex only around
nlm_do_fopen() and drops it before returning:

  fs/lockd/svcsubs.c:nlm_lookup_file() {
        ...
                mutex_lock(&file->f_mutex);
                nfserr = nlm_do_fopen(rqstp, file, mode);
                mutex_unlock(&file->f_mutex);
        ...
  }

By the time nlmsvc_proc_share() / nlmsvc_proc_unshare() call into
nlmsvc_share_file() / nlmsvc_unshare_file(), f_mutex is no longer held.
What actually serialises these requests is that lockd runs a single
service thread (svc_set_num_threads(serv, 0, 1) in fs/lockd/svc.c), so
the conclusion that the arrays need no extra locking holds.  Would it be
worth pointing the comment and commit message at the single-threaded
service rather than f_mutex?

The loop starts at v = 1, so s_access_counts[0] and s_mode_counts[0] are
incremented and decremented but never read.  That is fine for computing
the union, since index 0 (fsa_NONE / fsm_DN) contributes no bits.  It
does mean the free decision keys on the recomputed s_access / s_mode
rather than on every bucket, so the commit message wording

  the entry is freed only when every bucket has reached zero.

is slightly stronger than the code: an entry can be freed while
s_access_counts[0] or s_mode_counts[0] is still non-zero.  Harmless
given NONE/DN enforce nothing, but the stated invariant and the bucket-0
storage do not quite line up.


> +static void nlm_recompute_share(struct lockd_share *share)
> +{
> +	u32 new_access = 0, new_mode = 0, v;
> +
> +	for (v = 1; v < LOCKD_FSH_NR; v++) {
> +		if (share->s_access_counts[v])
> +			new_access |= v;
> +		if (share->s_mode_counts[v])
> +			new_mode |= v;
> +	}
> +	share->s_access = new_access;
> +	share->s_mode = new_mode;
> +}
> +
>  /**
>   * nlmsvc_share_file - create a share
>   * @host: Network client peer
> @@ -64,12 +82,15 @@ nlmsvc_share_file(struct nlm_host *host, struct 
> nlm_file *file,
>  	share->s_host       = host;
>  	share->s_owner.data = ohdata;
>  	share->s_owner.len  = oh->len;
> +	memset(share->s_access_counts, 0, sizeof(share->s_access_counts));
> +	memset(share->s_mode_counts, 0, sizeof(share->s_mode_counts));
>  	share->s_next       = file->f_shares;
>  	file->f_shares      = share;
> 
>  update:
> -	share->s_access = access;
> -	share->s_mode = mode;
> +	share->s_access_counts[access]++;
> +	share->s_mode_counts[mode]++;
> +	nlm_recompute_share(share);
>  	return nlm_granted;
>  }
> 

A remote NLMv4 client can drive access or mode out of {0..3} here
and write past s_access_counts[] / s_mode_counts[]. There are one
or two other spots with the same issue.

Thus your patch can't be applied as written.

However, today is your lucky day: I have a patch that regenerates
the XDR decoders to prevent exactly this issue, which I will post
forthwith.

I'm wondering about a Fixes tag. This issue has been around since
1da177e4c3f4 ("Linux-2.6.12-rc2"), but the fix depends mechanically
on the xdrgen conversion, so it certainly will not apply cleanly to
kernels earlier than v7.1, and a proper fix will need both the
regeneration patch and this one to be applied.


-- 
Chuck Lever
