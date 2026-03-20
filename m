Received: from mail-ua1-f45.google.com (mail-ua1-f45.google.com [209.85.222.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 201683A7857
	for <linux-nfs@vger.kernel.org>; Fri, 20 Mar 2026 17:40:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.222.45
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774028408; cv=pass; b=n9TADpY/MjQl0sYCS1+5kcVuvSfiFiYtuWiNaHiXO7J3bKVh9Xt/8K7ueThTRkglxdsG48YqeouFMeJYG39x9HeX8oD3Mr2oZUnV9iZzlksbpzOKDCN8ATmfegEagCvZenM5UqA7mhv99qZtBNbtNd7sRxpL3zGLE7EqPOcq9aM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774028408; c=relaxed/simple;
	bh=xDdqDWz0NbxoUFhpzbX/VdkLo1WemrXOdNdtD0UvdEw=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=cawHpu6aI273pJ0sifeD4G2kNPPE/mldB5ZiSTFIphwDfp8ZspzF739+YgoGNlHRx5c6VIs9FERD1AhF17YPxKkEVrEmoqFI6FkH0NsHqaoyBPmxZYNLRARUKLwvk1onVsbPiI0sYJgB5h+deGxSmwo57HJfp7b0ClPwln9ifLA=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=WvjtGTe6; arc=pass smtp.client-ip=209.85.222.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WvjtGTe6"
Received: by mail-ua1-f45.google.com with SMTP id a1e0cc1a2514c-94acd026e45so460698241.3
        for <linux-nfs@vger.kernel.org>; Fri, 20 Mar 2026 10:40:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1774028406; cv=none;
        d=google.com; s=arc-20240605;
        b=WSc+8XHcPcOYQ8hldaytNdYEowoKG1giwIlicdbgfaR+1+cSf5S0Ci3vdsspAbH8i4
         RTAr3wx2PuPlR+XDJ4iBFDwe5kq3oTW12wjF0ECGtKMBDvEWYCtOW2wgrNm8gKHFtYL0
         wzHhSqOMJiz5juESxyrQ40Fbc+DqwIB+4TD5KgQsiQasxXuLfkN5JbM+TSpNot5jIuSA
         ljMKXf1tjci8JG26nuQ3NPTwzhd01nrnseO4Oj4+zDRUf6mtPfM8oBCr8WK0h/yYoRK3
         0rnk4lXSN7MPsOKrX2OkRikU2CkPN7xOGn2BRv0YLIjzpUUl2OtQk7CIRRri+FhPCfgD
         iS3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ygYDsEg+zw9Q+38To0M6wXWLzakoKeK4wI54K+VgabQ=;
        fh=UzmxrSbzwOuOu0w/vn8v1Enjx0xEufTQXnRGcZjPXYQ=;
        b=V1XHWH2UA8xUcJEpINJSarmrbDLmFq6ILd/YVLgVWaDznZSxtZNL+/uXpDhocuqyWo
         WRtgMsWnh5lWI9Biytluy+R9arpg1oKapg1o09BPeZ+GZTGxroCczasgZ3U4jL3mG6tq
         PlXK1pXbXcbGMM48siTEpFBDiEkqZcKL0IXFJ5tOhLlENCkFXApw8ciNyZWgGg8vRYHK
         JdQchjkg3pPWonqGUc3N8LqM/JkhdkUTPwrjQGWYNjk5OXl6lPN9+bluJ5tT++SwOUGT
         KvEFq1OwLjGRiI+KT8Bh8cFpew3J9asKwoqWcVfzPxDksUXbldKKAGg2mxwkqZoNpUc/
         eybA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1774028406; x=1774633206; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=ygYDsEg+zw9Q+38To0M6wXWLzakoKeK4wI54K+VgabQ=;
        b=WvjtGTe6/nbu2ngUlD72pijKQFw1NyZBpn1wVS4v22cZi8SWTsnbcJXSCTNVhwS+jq
         9CKcYDMVzcl3AHg6O54LJzNTTL9UDGUjHsLQsEcgsQDv296TM2PukgNSLfnTHc+DVi19
         5ar4Xhob82lKvuEtAV74oji4lxw2/Yj/TdCc3O+akaG0BJH84jsGBHC+4neJMe7CS5/w
         +fvd1vKuSUGaFL5msFzdgbyHF2sSZ+k8KkZa8+hh0xtlmEBlFU2ZRdHFb3Eirk88d518
         WqOO5VtLxgg/dEY6rtrNnUQty2OT9AKeErwCeAoVbrWLF1mFdlFe26oE5KK/9eE84kXd
         mqow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1774028406; x=1774633206;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=ygYDsEg+zw9Q+38To0M6wXWLzakoKeK4wI54K+VgabQ=;
        b=rHrnu6a7wh9JUhJcYsEsy7EmynOkJJsJQXTS31n29TEJbPKy5SeGUH8DP/N75GALJv
         1nXCoEus/joGNmvP225+G5Y2QTQCAfhmOO1t718lVcw9yhoK8CKmn+F6P7yK3VPWQR9U
         1viX8KmkyjANlWwhpshDpNFmVL3OEnX10c0SDfTbBVSQFU8fvqsMOiWFxDJOm6AWyDRl
         Of7bYPTQqJmaoJwp4mhtPrWtqrEMrJmF30NDl0rockQxPlSSov4g28lrwo9HGMwpOWWT
         Sm6+QOMwmSav6ZBJ0xcIbvXEx4aQQfrxpBHbbfCC9ut/JPtxl62uiMLJMX9v4j6vKwzl
         f4mg==
X-Forwarded-Encrypted: i=1; AJvYcCWfacmzvuZzyvvy/s8RilIqaKQMAq97dyddV4BtkBzkgYUqdHDkORsFLsdbLnHdQWS5X3B7emifeLM=@vger.kernel.org
X-Gm-Message-State: AOJu0YzTF3FEqXD87f3itGWWwuuxuwSK4dBLUWqKOEDWj9i07v8T/Mwf
	ANdZAcdQdWjJILqnKqZgFqLzZORekVzMEGvADw6JW5Ly7L4xqbljdfLU1m11Nouq+EURkHRArhV
	+e+VKjdMOAMZ3FWyJSYRAD5B/n3GGThg=
X-Gm-Gg: ATEYQzxWpr8qURCcoPiYuST4QVg/52vzUbKAVK4yQtT3rVcXoI6rWoajrUbvdqg0M8b
	RGnOmkiw0jk3xnhAb9cGOsAKe5oZUqnjUdhtd0ZBTx+rSmRM5tIc7cMa03YAri7G068h+lCiY7k
	PoLouLPDb4d7R7ImrHAtUUHj+jn3PFGkvHwPnTHPE3nZwpB6pdWpLQ0yqT4TSj2bINkYC9Fp+l9
	YfzFznnuw2Lkq7Wvah7xOoDqr+amdjjad86gSQKJ44GnHuQhkBdPMaDePsNizhbtqFeDpbcGaM4
	TNi+isA=
X-Received: by 2002:a05:6102:c8f:b0:5ff:a16b:93f8 with SMTP id
 ada2fe7eead31-602aea8f384mr1707116137.6.1774028405997; Fri, 20 Mar 2026
 10:40:05 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260319141846.78222-1-seanwascoding@gmail.com>
 <20260319141846.78222-4-seanwascoding@gmail.com> <abwLFk0L_kCZqIiK@ashevche-desk.local>
 <CAAb=EJVCkn9_iO_YHMbLU1VR1OsKqTSg5Jo9jviaT3dEq0k5vQ@mail.gmail.com> <abwbB-AkHH9Syppw@ashevche-desk.local>
In-Reply-To: <abwbB-AkHH9Syppw@ashevche-desk.local>
From: Sean Chang <seanwascoding@gmail.com>
Date: Sat, 21 Mar 2026 01:39:54 +0800
X-Gm-Features: AaiRm519Rj80SD1FrkklLWEP1Cp-ZwIYOKAqklaTPoSVzVD9RJRLOv7YfSE8PCs
Message-ID: <CAAb=EJW-BDmq0yrMu=nGbGN_GsEV6GfZSJPuLz=A+6CdGKhUrQ@mail.gmail.com>
Subject: Re: [PATCH v3 3/3] nfs: refactor nfs_errorf macros and remove unused ones
To: Andy Shevchenko <andriy.shevchenko@intel.com>
Cc: Andrew Lunn <andrew@lunn.ch>, Chuck Lever <chuck.lever@oracle.com>, 
	David Laight <david.laight.linux@gmail.com>, Anna Schumaker <anna@kernel.org>, netdev@vger.kernel.org, 
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	kernel test robot <lkp@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 19, 2026 at 11:49=E2=80=AFPM Andy Shevchenko
<andriy.shevchenko@intel.com> wrote:
>
> > > >  #define nfs_invalf(fc, fmt, ...) ((fc)->log.log ?            \
> > > >       invalf(fc, fmt, ## __VA_ARGS__) :                       \
> > >
> > > >       invalf(fc, fmt, ## __VA_ARGS__) :                       \
> > > >       ({ dfprintk(fac, fmt "\n", ## __VA_ARGS__);  -EINVAL; }))
> > >
> > > Why not all of them?
> >
> > I initially only refactored nfs_errorf because it doesn't return a valu=
e.
> > For nfs_invalf, it will always return -EINVAL. Would you prefer me to
> > refactor it using the ({ ... }) statement expression pattern to keep th=
e
> > return value, or is it better to leave it as is ?
>
> I don't think in this case it improves the situation. Yeah, it's unfortun=
ate.
>
> > #define nfs_invalf(fc, fmt, ...) ({            \
> >     if ((fc)->log.log)                \
> >         invalf(fc, fmt, ## __VA_ARGS__);    \
>
> I believe this already has an error code inside, that's why it's only add=
ed to
> the 'else' branch.
>
> >     else                        \
> >         dfprintk(fac, fmt "\n", ## __VA_ARGS__);\
> >     -EINVAL;                    \
> > })
>
> Okay, let's go with your original approach (ideally these all probably sh=
ould
> be replaced by static inline:s).
>
> Reviewed-by: Andy Shevchenko <andriy.shevchenko@intel.com>
> Tested-by: Andy Shevchenko <andriy.shevchenko@intel.com>
>

Thanks for your review and for providing the tags!
I'll include your Reviewed-by and Tested-by tags in the v4 submission.

> Unrelated to the series, but if you want to address these:
>
> nfs/super.c:1170:49: warning: incorrect type in initializer (different ad=
dress spaces)
> nfs/super.c:1170:49:    expected struct rpc_xprt *xprt1
> nfs/super.c:1170:49:    got struct rpc_xprt [noderef] __rcu *cl_xprt
> nfs/super.c:1171:49: warning: incorrect type in initializer (different ad=
dress spaces)
> nfs/super.c:1171:49:    expected struct rpc_xprt *xprt2
> nfs/super.c:1171:49:    got struct rpc_xprt [noderef] __rcu *cl_xprt
>
> nfs/./nfstrace.h:1488:1: warning: dereference of noderef expression
> nfs/./nfs4trace.h:2168:1: error: too long token expansion
> nfs/./nfs4trace.h:2234:1: error: too long token expansion
>

Regarding the Sparse warnings in super.c and the trace header errors,
I've noted them down. I'll look into them separately and may submit a
follow-up patch to address them later.

Best Regards,
Sean
