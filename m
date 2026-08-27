Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B358420C029
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 19:25:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787858738; cv=none; b=QU+c6bR32qy9FV05ZQgaZaFXsVA8k9NepFZtGJlKBqblblGCDyB6eMdkPaqwsm2gZ5SUX3hKJH0s5xq82M/V6tr12vVm7QQfMIBKc+lGoFjvLqmBF4FVLQ15Afh+hm4LxNdgZGFNt0PlEMKXyBIygSNGR3xQ8W6VT93TfAfVoi0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787858738; c=relaxed/simple;
	bh=QDEUSSyUcGlxQ3Ty3oT5/XdIzCZf4N3WPBJjxlaG6zE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Lz7z2MIsuxlXp5NLzLPEjGEFh+Yn36RWERn+48ufQPbUg0JRS6Ww/TorvRRZMDCVhOFFmsZ5tiZ7jlgy0eg0760Z/h1URDH5W22XubM598w4KzEvPrPljTgQ7J3y2GhVglWYAPmjxJdPemS+p2BEpH6GwOGrT+WnuYPl2fOPVho=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FFw+ubGx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FFw+ubGx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 616B31F000E9;
	Thu, 27 Aug 2026 19:25:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787858733;
	bh=Hc4atoNuzwYVkBcmO8TAu7lmfTrgCimyXvmRIvsMhwI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=FFw+ubGxM9gPLeEy7yytuSq2s39474vKBrGf68yGZDKHy48njgIi5rVYiOrl+PHz6
	 HwH7tNm6buP3xP1zqtK3d7skcvI0aTDEOHGTdEpjBtkqu+L/rv2tA/ObgJ+9NAUUda
	 SkV/Y5YmGpVtiDPFtlpKFtjmRVoG3WmNEN5ybEoX7IibTUPOIpbgw6SxdoOrACigTB
	 tmgGITAIXR82kuOJWJ9YkkUgVgqmQ2l3I1YTmacp5jAp9XUrjqAkXPOhGjagTu+qe9
	 Z5eHsQDBcNgOKyj3Z2ZPTq0izQ9RS4FFOh5IXU+tTYxINUecm4q4g9z5KSk1YAakdM
	 /5u25FKUn4AOg==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5752DF40066;
	Thu, 27 Aug 2026 15:25:32 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 27 Aug 2026 15:25:32 -0400
X-ME-Sender: <xms:LI-QaoDwmOb9JZmE169Z6Y1rnjV-h9U1ujHDLykBQ6Jkoc8QrFujSQ>
    <xme:LI-QalU6wCgHNN8nSWnFOheDXy2OlB89lTspy6AzAmWpRGoQGTDImAnE8HSlaQad4
    zFXuZoNgcXZ8g9HgGFA1fFNE9ZZkFeG3vbS91NcCaGU8ugZuGgc950>
X-ME-Proxy-Cause: dmFkZTFQrFT3OvjzcihN9WjygV05ZfHe+dTanBSxq9Wy8i38cCCLbXdlYDAGn+93sHy07Q
    dv08XhVUCijazgaw2MyOSYZQMdGlV0NA070wNrUzl6x3fiHNWC+cFwkzAGjUMm85JifLVD
    +S991ORXMUz8oQobF0vaWC633b9t6+IZOM3/pQXwZEGVsu6G2FumMFLss52UZTaxlGYtvi
    cdJdR9Q9oNIxFVvXeJs38KKSBbBO+YxuDINLjRjQ7+8El0qM0XRAo/D56+1c7IJAAuu/YL
    RB+4VHDWKhl3fNZv8+oE7eDI1spd52594hnKsU30XPsq9CgRoPjGNEno7TxJ3DN2CCLUf4
    NmIU2ezVJAbD1fpZdvqq95Z8qACeZk3oOpeSRVGAX/nvvQi5pq1qyJWIzHskGMnObkG086
    zLEFEFikw0xdEUsCHK73KWLH256G11yguuU6j5SXXOerwmmbnNQ1ypQWR78ZTbozhiyljx
    SwjsY+rxqbBEVoC1+O/xDl0b0zUwkn/olG2+xWdCmJ035gUMw0HBGo1TyNA1vQ7GfD077a
    GVxVBFLf6Bz80DkqJsAf+SPhHc8QY2/vCcDf/a73lRXGH8SKLJJTehPYLrDegFbYoTZ9ZL
    HhzBHype0OjVuKoitjmF/6EUTLujEc/nbktLt3yZ0Eg5ezt0oO3MrIHkiy6w
X-ME-Proxy: <xmx:LI-QajtlfK29FcRYsNDvE9ERjJAepWgegkGPvKEqmUNDEZPFltG-qQ>
    <xmx:LI-QatyLOwGIb1bBgZ2WDgB0CtSzDNn6pJ1JSR1hcvCdlxoAmHwrPw>
    <xmx:LI-QauADSCNV5vQwHGydLSK8LmLZrUbqFfmSvZQ6jYOTYW3vir19Qg>
    <xmx:LI-QajcF1Ro5zVVNB_2Jh-EV1HypcDkl2Be-bULBupZeD48K5hCarg>
    <xmx:LI-QagkZH16BqzNsd25BMhTr2pP_BmoFyi8HXr5DE2h7A3N0BYtq7WXm>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 313D8B6006E; Thu, 27 Aug 2026 15:25:32 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A9ObTMN-7aCV
Date: Thu, 27 Aug 2026 15:25:11 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, "Jonathan Curley" <jcurley@purestorage.com>,
 "Mike Snitzer" <snitzer@kernel.org>, "Jeff Layton" <jlayton@kernel.org>
Message-Id: <59de74d2-e2bf-457d-a0cc-b3dfedc5b8c8@app.fastmail.com>
In-Reply-To: 
 <09f50acb9f481b3a9c3716e8f70b9b3dbe81888c.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
 <09f50acb9f481b3a9c3716e8f70b9b3dbe81888c.1787327939.git.bcodding@hammerspace.com>
Subject: Re: [PATCH v2 01/23] NFSv4/flexfiles: reject a stripe_unit that does not fit
 32 bits
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Ben,

On Fri, Aug 21, 2026, at 12:29 PM, Benjamin Coddington wrote:
> ff_layout_alloc_lseg() decodes stripe_unit as the 64-bit value the
> protocol defines, but every consumer treats it as a u32:
> nfs4_ff_layout_calc_dss_id() divides by it with do_div(), which casts
> the divisor, and ff_layout_pg_test() copies it into a u32 first.  A
> value that does not fit is silently truncated, so the client stripes on
> a unit the server did not specify -- or divides by zero, if the low 32
> bits happen to be clear.

I've been thinking on this. What would it take to update the users
of stripe_unit that you mention above to treat it as a u64 instead of
a u32? The calls to do_div() could be replaced with div64_u64() for
example. It just feels a little more robust to me than artificially
limiting ourselves to a 32-bit value.

Thoughts?
Anna

>
> Reject it where the existing zero check already is, using -EINVAL so
> the layout is discarded and I/O falls back to the MDS, as the fh_count
> check below does.  That also moves the existing stripe_unit == 0 case
> off the -EIO exit it shared, which fails the I/O instead.
>
> Fixes: 20b1d75fb840 ("NFSv4/flexfiles: Add support for striped layouts")
> Cc: stable@vger.kernel.org
> Assisted-by: Claude:claude-fable-5
> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index c4aa995026f6..74b75d061c6f 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -515,8 +515,11 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
>  		    dss_count == 0)
>  			goto out_err_free;
> 
> -		if (dss_count > 1 && stripe_unit == 0)
> +		if (dss_count > 1 &&
> +		    (stripe_unit == 0 || stripe_unit > U32_MAX)) {
> +			rc = -EINVAL;
>  			goto out_err_free;
> +		}
> 
>  		fls->mirror_array[i] = ff_layout_alloc_mirror(dss_count, gfp_flags);
>  		if (fls->mirror_array[i] == NULL) {
> -- 
> 2.53.0
