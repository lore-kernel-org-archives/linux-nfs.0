Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2EC1E260580
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 20:33:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.70
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786998791; cv=none; b=fN6uy8RBRY50XR3SZ3pMFq7X8/9cq4cYUq3qCc87tl2Jqc0Q29DLNfoqEQ+XYlfNF348jOqqjSKtihsAiaO4yEiByr4EnPYwpi6XlMcm1svuioiIse0x3kQiTrRjiKNFve6HtNik0QhKxNhz/A74ukesH4V0WFu1wZnsky/EG98=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786998791; c=relaxed/simple;
	bh=62mvJf3WvOZtRlyN48SZrZg1DyDipbX+PZ/49rl1Hjo=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=cPEi7HxCw8KwJaGK0De2BX5L9lzmi/pPS7gYLbuRszhPj+SLDffb3DiwfI2H5KogPRJB4nrY1502LbKfJ3szc1KvV8i2kof3e8pldmr1ql3s2OApQyeBky9wZu35MJCg18nSxBL31G449/hXmQeli/cAiHmcXfkVycyrF0IeZdM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--justinstitt.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=evc9YGzm; arc=none smtp.client-ip=209.85.210.70
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--justinstitt.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="evc9YGzm"
Received: by mail-ot1-f70.google.com with SMTP id 46e09a7af769-7eb89852728so2888271a34.3
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 13:33:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1786998789; x=1787603589; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=lAVl+NhQY8DNi7sjHIPAU1qvka7Rp9cjT1Z4/qhVby4=;
        b=evc9YGzmiYUpe/ZFzeCe9WqVznc8D0U56PTj5HKKAuNSpf9gXZLBBWPiRH4YglDcjH
         1z9zR9GEONZQZMx3AiDWjjBRRhWpgqiL1n5jFfjDuhsIvykwtnhUTCrna1XNHruCefVc
         JQsIPAVhvOMTis/J2KzUKhko2YL83pGV0rQzBlQ78iZUsPajV2W+CgMrmCXgjRlx7wPR
         aEkQ2QGwKC4isUiFuZEUz7x6ZqcazWnrlbOSqMvIsatIFXzbHhrnUMdaGMtKBxXJwFi6
         A60g7yqGDznxoGIdc7hs3TSQ//q8g3GK+IpkFzVkWyKX+apP5gCC6ot/xrM994sntD39
         KQPA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786998789; x=1787603589;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=lAVl+NhQY8DNi7sjHIPAU1qvka7Rp9cjT1Z4/qhVby4=;
        b=EUBXn6h2LieJo7UpGE1x+/X1VP09ooT78jptNm8cnsXd2v1F3yg9n7s+PrhKUUNyRe
         w6D2lVlpef3o5cNFMVLqAiRhlf84qHzWFOB6Ny6R5C81bGwA6ElBbJJbM7P00wNFFooa
         KT085h6xsCqqHY0A2hR1A/5lMC0tGa4vtefd1aJUL57gMOA7CgqlhQcdumCC0i0uxMZZ
         lp8P8SopXuVKfSqjkPVrvannlKerQ/hb5w7fYT5sN53DfKMhil6RXEomu2jeXdkUYF9T
         Ic0RUttGpJmkekKNOz60ggK27t3lOl8HRBIXVDLtk0ZZ0nLYybCSTddY7D8Za9dhQcfT
         KnZA==
X-Forwarded-Encrypted: i=1; AHgh+Rq39TrH2D7bXsEy/wIJcXNqxDMKPxTCD3uKOCuM1WjTu0Ubi5VYmo+vdEtCP66aBkUdeWjsjXBgEtM=@vger.kernel.org
X-Gm-Message-State: AOJu0Yz6xSOXsMe+cIRH16eOWJD52I4568/xkRUt/cj+5zxg6dT2IQVS
	iRJ7xuCtGagzWms0NhSErUH23tDsCDYpPJUsIqre3xse6Ano4f312EY+eWUvr6cAxeD3A1qxdRr
	0rv5Tn6deRM2BAGsqXZeHhTzMGA==
X-Received: from ilbda7.prod.google.com ([2002:a05:6e02:3cc7:b0:508:27c6:a6d7])
 (user=justinstitt job=prod-delivery.src-stubby-dispatcher) by
 2002:a05:6820:178b:b0:6ae:4475:bc48 with SMTP id 006d021491bc7-6b0d6245b8bmr24430765eaf.22.1786998788813;
 Mon, 17 Aug 2026 13:33:08 -0700 (PDT)
Date: Mon, 17 Aug 2026 13:33:08 -0700
In-Reply-To: <27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com>
Message-ID: <aoNuOD6CLopCgxtU@google.com>
Subject: Re: [PATCH] NFS: nfsroot: replace strlcat() with snprintf()
From: Justin Stitt <justinstitt@google.com>
To: Mariia Nikitash <mariianikitash@google.com>
Cc: trondmy@kernel.org, anna@kernel.org, keescook@google.com, 
	linux-hardening@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, nikitash.mariiaw@gmail.com
Content-Type: text/plain; charset="us-ascii"

Hi,

On Fri, Aug 14, 2026 at 12:28:45AM -0700, Mariia Nikitash wrote:
> In preparation for removing the deprecated strlcat() API[1], replace its
> uses in root_nfs_cat() with snprintf().
> 
> Build the separator and source string in a single call using the
> remaining space in the destination buffer. snprintf() returns the length
> it would have written excluding the terminating NUL, so comparing the
> return value against the remaining buffer space preserves the existing
> truncation check.
> 
> Link: https://github.com/KSPP/linux/issues/370 [1]
> Signed-off-by: Mariia Nikitash <mariianikitash@google.com>


Reviewed-by: Justin Stitt <justinstitt@google.com>

> ---
>  fs/nfs/nfsroot.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
> index 432612d22437..e951fe731679 100644
> --- a/fs/nfs/nfsroot.c
> +++ b/fs/nfs/nfsroot.c
> @@ -173,12 +173,12 @@ static int __init root_nfs_cat(char *dest, const char *src,
>  			       const size_t destlen)
>  {
>  	size_t len = strlen(dest);
> +	size_t remaining = destlen - len;
> +	const char *sep = "";
>  
>  	if (len && dest[len - 1] != ',')
> -		if (strlcat(dest, ",", destlen) >= destlen)
> -			return -1;
> -
> -	if (strlcat(dest, src, destlen) >= destlen)
> +		sep = ",";
> +	if (snprintf(dest + len, remaining, "%s%s", sep, src) >= remaining)
>  		return -1;
>  	return 0;
>  }
> -- 
> 2.55.0.679.g6767b8d81c-goog
> 
>

Thanks
Justin
