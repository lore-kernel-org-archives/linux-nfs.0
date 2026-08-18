Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58BE943B6CB
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 08:55:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787043354; cv=none; b=MN2aUtUbohc4DNwGyEbt5FP3y5CXrXGXKWiHNS1VGbaxPysPWhwBn+Mol2i3bxAR96V5Y4VotW0jNWg7rqjACHsZggj1l1isuaGPrH8XNR+tI6ADMSenoAOMlICHeY1VKxaVlXgp9Ri3KHF98ZR2oBqB+kFAOXO1cJKbVD8NRIg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787043354; c=relaxed/simple;
	bh=C286L6tbBFmVSHmpGBeJxiKWhduKtxRV8w7hZXwOZBc=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Fs4/hy5nT9MYxPEAPs9wzOua02WRlI3EWDuVe6l63gY9oN+nEUx8HBPl44UOb0yBi8lhAaWx2HF4axqepF5cTLiB+34s2etG+aJqHsPFZMG20wjrSsVLLrw0Y/B/sTUN1li27AbNWICY1qS2L+I210+6KMyPFeJS7wU2RfUu3dU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=aBKsoiWJ; arc=none smtp.client-ip=209.85.221.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aBKsoiWJ"
Received: by mail-wr1-f46.google.com with SMTP id ffacd0b85a97d-4798bea72f9so2785242f8f.1
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 01:55:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787043351; x=1787648151; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=vCXFaMST6pWHnhL+UrBGfVhFKZlV8sK4DX8oPKUD0UU=;
        b=aBKsoiWJei+kPrAJO7gPNLwQbC8Ikcy8S3fibWbAU5HEibQR/an3/MbqC7zvZRrtL+
         sKif8SDTV8gptA3pLtb5KQ/19a71DWtK4SuV2lAdle5Oqui47K21ErM/fSkxfi7wQc2g
         qGe9rFqeKCR0eVDAGuVP/iPpjoLaS4CyRYKCRJ1gVaJlzU5tc7h7mMmHA8OU827Cajut
         sDM7gTnE88zEVNQVTkITcevY2dyxcHxzMGzk+kV49E6IYG97sUbFnY4/jeRVa0mRVxEy
         YK2v1Qg6LLNazZk5e+JBdyiRokveyeJfjqtzJstJSo5IQtg+Z8FJElEEeDzkNz2LDm1b
         xT4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787043351; x=1787648151;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=vCXFaMST6pWHnhL+UrBGfVhFKZlV8sK4DX8oPKUD0UU=;
        b=FiEI5KTgfpMH1y2azY/ivP/w4jgWSfsoXCYwQbNgtK4bajlOMMS1BRE8yNmomYWV/l
         g5bMFQ0INP1VvRb6GulAAKAcPsWH13J2EEkLvvaxrpxmvamUpYlUTI8iy0cEL/yLO6EG
         T8KCyn+gujZW2FqNgyZeq9eWrtNxsJAaAoQxmOFUyk/FHl5B44ocFq57vEFOS8pEJj0/
         32GY2mGK9L+TvIV/x8vkUP5vhWPPYojd0lCSs4IhtfP2NxL2vXS0Yc+CDXU/Sx/oKo9X
         xByBRQpT1auukyIJUuYa5lTpDtoAcgpufJJ9PSVUhADhQ4MHe0Uc7Stm5ozOj5+MGj1x
         Ez8g==
X-Forwarded-Encrypted: i=1; AHgh+RrNjtPvTDtEzmbOwxacjY5qZjNtjiRfxLvlZSPlqcBiCTlMjCaNwx0haFJFJRcU3aAdoUQHXx0qgW4=@vger.kernel.org
X-Gm-Message-State: AOJu0YzUnCXoWc8r5PPbflUTIg6FBH5NtdLgQ6aOi67LP1iDZ4i+jWLR
	beddcqFsFCCj77NKnpDmBT0VLX125k1z7aYJ585yk3FWMv+u3S2UVbru
X-Gm-Gg: AR+sD12r/jPj2nWiDA3YK2G8v2P6Sg2XhqnSbKXbJH4oXTkaaqMBMo82Lzb/8vruM7P
	zZlh6uU2lENC6xWA27hHlNGf0c83ZU/PipRbkzpTewdw3mbeEdbOlXa+23sP4L5kyGJppTTQSRR
	5xmmXAMWMOwC5+4ZT5/Jix4d+Ch8+VMWxsG+EOBZGJa/gWKTJn+DrcotKwbnxRBSLxfRqo3qAer
	jb5ZCF9FXRCakuZcPQCH7UPlnvzUnb6Os+gAvSYil0VtWL6YBb3p8HgtHwemz2lW6dCKMylxAYy
	xS7Tb/ZyLKUmiWf9PlmUqnK4H8ZKaz6f4y6P9CBHf+PWIom2gWuyj/UEQr5UQtMWpDCt2+zotNR
	NfRmlzlVTKLSjXD483+uKDRIrNhQTCIk87GRQl0TSkgcicG5f4MkM+zC5eouynb0ny/qfrj91TM
	VrPeB+U4lmCbVVXOr7oBUPAZK2CVFPXNfAC/sdVM/Ww2mBzSJuLrxsBKeOt2imh3qVUHEzqsTeW
	7Lq2KDvYeKrFyTuI4FTAVdwqyY=
X-Received: by 2002:adf:f84f:0:b0:47f:eb22:4d9a with SMTP id ffacd0b85a97d-482a90e80aamr8822990f8f.22.1787043350536;
        Tue, 18 Aug 2026 01:55:50 -0700 (PDT)
Received: from pumpkin (82-69-66-36.dsl.in-addr.zen.co.uk. [82.69.66.36])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-482a5b81748sm10409553f8f.37.2026.08.18.01.55.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 18 Aug 2026 01:55:50 -0700 (PDT)
Date: Tue, 18 Aug 2026 09:55:48 +0100
From: David Laight <david.laight.linux@gmail.com>
To: Mariia Nikitash <mariianikitash@google.com>
Cc: trondmy@kernel.org, anna@kernel.org, keescook@google.com,
 justinstitt@google.com, linux-hardening@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 nikitash.mariiaw@gmail.com
Subject: Re: [PATCH] NFS: nfsroot: replace strlcat() with snprintf()
Message-ID: <20260818095548.27e0edb2@pumpkin>
In-Reply-To: <27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com>
References: <27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com>
X-Mailer: Claws Mail 4.1.1 (GTK 3.24.38; arm-unknown-linux-gnueabihf)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 14 Aug 2026 00:28:45 -0700
Mariia Nikitash <mariianikitash@google.com> wrote:

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

I think I'd have gone for:
	size_t len = strlen(dest);
	if (len && dest[len - 1] != ',' && ++len < destlen)
		dest[len - 1] = ',';
	if (strscpy(dest + len, src, destlen - len) < 0)
		return -1;

Although it would be better as an 'add_option()' function.
I suspect the it used to be just strcat().
(similarly for root_nfs_copy() which is a pointless wrapper on strscpy()).

Much more worth while would be fixing the sprintf() for NFS_ROOT.

David

>  	return 0;
>  }

