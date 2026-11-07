Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.210.181
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794026348;
	b=Zeug2MsXLl2oFtXehB8EfKvF9gThEE4glXWecmto2+JsGInM3hwgsZ5R5TqwPnBdDD3B
	 W6R1Hv9UlynlBcmZYeEL8C2J8RMkOEpO2jzdW90Q+vq9CIwI850Kb76xGC9oBlO+H/ywD
	 TmQD/A5FItu+FsReBoCGKfUTtblyEKm1Z4dDiHTkQg++Jlcnt+bLDsHH5ZkOTokFhtkj+
	 a1Z0BL3scuOMpRR8Z5TEG/oPl8eNqLOg31x4kuNkEDGluXlyVrRrPWeDibaUIzOOliTBD
	 70WX2/QVCsq8hJ0NrO2y0OuAi/97nfxJdkK2K4YZ/kNhIWHEC3SvYykQoVzeioRJt4w==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794026348;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type;
	bh=fWABTxQt0TPDz25XXDUzvz1pdSuFM0l8HegkYoRHLLM=;
	b=MWsobAKXatfH56FlU6JVfw1PsLjv7uGZP9F2Rs/ukAFDi3nOXWyAlrG4/24EMSOqmqV5
	 akpD+CuZFHVxcVQAWSuwYcFMpYo9MGCexiO/d4AppO7+B0288uOa97N9axP15zWhkGa4C
	 MsN6L8RgAPANoe5O8L8mL6FypEkNmZdoSinKrMOhGoGKo0ug3rolngg3L18n2hR2nmW4F
	 D0EM8jCl+O79nJvRbjKvPZ5w79QAU2K30Hb+mIW1LXSENuWDG1SVo0LH4jz5GovXamEI0
	 Zg7whIEeqZsrQHZxbxQlMT0Vn5kdOV8RFktJcMl9/1GVy6zvcGYBfRPXQZUlardjuBw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=YemYGyiJ;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.210.181
Received: from mail-pf1-f181.google.com (mail-pf1-f181.google.com [209.85.210.181])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E7EEE606A333
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 04:39:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E7EEE606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=YemYGyiJ
Received: by mail-pf1-f181.google.com with SMTP id d2e1a72fcca58-8a5a5dda930so42251b3a.3
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 20:39:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794026347; cv=none;
        d=google.com; s=arc-20260327;
        b=IIqe4flhaG/7HjQpuFTsmyUlYW3DyD4pYCPQVf291di6A7zUZskytDXLD46Qh6Qexo
         TRE85MXsXxSXcSSacAIwOVzU94JTGIisN3/GoMb9NlYWObXD3mLa20Jm0vc2D2rEZmXn
         oKpz5GiKQ3+fu3ZTQmL8fa0FawT4Ch5Q5Uhg/I5vW6IQfaFOA6bHY6wrT6H3HKJKpQqN
         XLZDrb6uUccPbPzGWvUX2CstwnmNlCQUXiVdcQn5RiEQcVsGlNSXxvrlZj//LJR6ojL8
         1IGyOZTWAOMWq2CbeT0mSw8ulOD1SahhRGMm7EQBB9I4pLBUNJjMhVV/WFIV5+BSvbN0
         4LaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fWABTxQt0TPDz25XXDUzvz1pdSuFM0l8HegkYoRHLLM=;
        fh=PBC1bxm6P77H2h8bVL0Lhn3W5lFpwhdjt+jdyOQjt6Y=;
        b=EQGJYAv53MBo4mPmAm5nQDKDVUjc25r46thSFVKuzlgyOaBdecy1oTxrfM0+TEaWiV
         9Fxxw8LDR8sqZwNaUkhiLtJAhSnrFOmZ8udBUJeYczGRj3AizY3yISFAT+2D/NUBPY7N
         j4pUB8vHOkLlzUpAdQ5ZsudDitXEMRzWzUXys6nbGG7+FEqeg30+hHFAl6l1ERc+OoUY
         sqFDNGDR+dRMntwPjRLgiM6cfG+Evlqv4Y6hy/6Ue+F2SN+qHzbVKEYPjrypgq3covMv
         BK0G6/XKrPgGbJS1DYqu+jPbP1OAEI5hRTzhMveNdM4lLFEn6PNjWwXll9nFuVyETbzi
         Eqog==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794026347; x=1794631147; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=fWABTxQt0TPDz25XXDUzvz1pdSuFM0l8HegkYoRHLLM=;
        b=YemYGyiJJ3tiwh7MrSfXGj8B2O5GNYI4E3GWdlW2UXtMZ6xvecJnOMnwtd9YXsOch1
         otmae5sq1LQ9Nk9AfSb7QcyGoGkyUdSIpuVp01uVzFJNYTqGr3hKeEiHdsJEgbLgwWqQ
         6ZCGC2Rf0BlCvZxOvAsRKjIz4QsDgNUZleuR03fgX5sz1evxJ0Rni1sIxtXbzzoefwZB
         gEfGVKI2ueaEEYRDu7jDnmCFy7yK6zwUd+m6f0IHDVufRGMaT9s6CrIeHOTP9OCv44//
         GyzKxQ++yzEQfRBwCVFKHDhQUflRCAIDRx4gWELcwW1IYbn0LCLFQhsRp5R0ZpNhCevr
         SwtA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794026347; x=1794631147;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=fWABTxQt0TPDz25XXDUzvz1pdSuFM0l8HegkYoRHLLM=;
        b=wC58dAr5PD9VZVruj9cxLm5TBfC03Wswb0tgrvwjtW0b1uFbIDpylq/yqsA55C7+gQ
         r2n7K/v+XGs+YvEFuUrJVYrolXS2feqk7t6ew4MuNgjimEwdw0Mc6TiyJTDuAjeSCEED
         4ksUAUzWIdvZSKEobf2Kcd9k91AbDHGJltvYUGpiqkUI7ImeLKqefI77CpiTerAapnbx
         S2ntqA4uobN+9zaUmOwZot5tcow+ep9AtbQ4U3yvPFEfEo+hCrJVHtvd7+XmhRxwMYWW
         gMLovwbV2nQQLMa2bHjGy29ySbNS4xDj1rUkJPW2SnYk0mV6WaApe2ZD4cINuyQnJzCG
         Noiw==
X-Forwarded-Encrypted: i=1; AL+hErF7emlXhLCa7G8HfmBeHb5qva3iXA7+y5AFVeaUFPv7iN68hIxLhWwlWBVo60/AlH5xYBjGZdeQ4dw=@vger.kernel.org
X-Gm-Message-State: APuU4Z8wONoAFLSK6dlyieqbZtfhtTEAA2A+9Byx5HRfBg+p5ARtp2ud
	2bSH7jBUWEwULPhI5MeXD8wvXvA89BV94uYqvqF+cgLIUG2DYaL7daNBnBy7/qXrAAdql576yXl
	mcZTAHkVRAj8VuoHFLDMIJW1Nmo6ixKs=
X-Gm-Gg: AYBFou0jqsA+r5XbqSg10As6hNsomI8tHmMjN9BCZFfWrwAfL4E+AugwzZvoKOIaI9H
	ZdHbbPEJVCKJ5WChpensPsULNav9QvfT/mEgQLZWuAlVQXu9VYtUbtB6Mhh0u66orTuZzwBS6QR
	UB4AqdkfsL29aGtTOpIk6SoF4xjiLlZaSayJUh/kOpJ4NlUpRFtCosmoBDAzyubCuOfS6hQ5NrM
	pjRxtrGYFi4TFPpEOk4wDlDQfSFRA1/9AxHx30RDG63DCtnDIftSUgiz913MuwtNUv7GZXPMMp9
	GBiYovpWjVk06hE7gm6mqNoUOHkbtW+R0+mZxY8FArHe23+PpIbNDnjM/nQfag0iNavq5y3tJxQ
	3nGHLBvjvSXxHSv9juejBnAA+oiF7yFBLZNGE2g==
X-Received: by 2002:a05:6a00:c4d2:b0:8a0:89f2:3340 with SMTP id
 d2e1a72fcca58-8b374e61e12mr4346500b3a.0.1794026347305; Fri, 06 Nov 2026
 20:39:07 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261103181410.1601083-1-lui2012qwq@gmail.com>
In-Reply-To: <20261103181410.1601083-1-lui2012qwq@gmail.com>
From: Chengyu Liu <lui2012qwq@gmail.com>
Date: Sat, 7 Nov 2026 12:38:53 +0800
X-Gm-Features: AclHuK_HAFgI5V9CnrqbzbHWRtWchBIBPDLlothsK4mysUxnFrG0CyAz6a0eG48
Message-ID: <CAE=Q7=7Ct5pPrT+HLG6PgWKW0z__WDZ0LtRJWQs00SYfFJjQ6Q@mail.gmail.com>
Subject: Re: [PATCH] nfs_common: release decoded ACL on nfsacl_decode() error
To: trondmy@kernel.org, anna@kernel.org
Cc: cel@kernel.org, jlayton@kernel.org, linux-nfs@vger.kernel.org, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Hi,

I noticed that the Patchwork status of my patch has changed to
"Handled Elsewhere". I'm not sure how to interpret this status. Has
the patch been picked up by another maintainer, or is there anything I
need to do on my end, such as resubmitting it to another mailing list?

Any clarification would be appreciated.

Thanks!
