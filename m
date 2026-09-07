Received: from mail-oa1-f46.google.com (mail-oa1-f46.google.com [209.85.160.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAA2E3A3E88
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 06:24:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.46
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788762304; cv=pass; b=SkgOJID1tz0oOO3qi9gIMGHJslez6TvGlH2Z6ikWjVrBn+LlKU1Im88Xd3f5lm/TN4/XT37RF7MIytP0qCRYWFFTGtcodiOsJa0Skzqoqbb5Wb1kc3v1EubdjbLkgiqqdbY8BlP9BbZxpgYg3OCaz+uoybeKmHWEir0/sYmx9KI=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788762304; c=relaxed/simple;
	bh=MdsdBUsDhf5aTWX2O8HoUCr1+cAZBa6BE2RS4oGDGCs=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Content-Type; b=lRQa50vX4FXLzu0oKuIJZx8FvcwFIx/2SX05AnZK1yGQgGgCgYGs4EF4koOzxlrfSDxfKnso9huWdiRkS7arW8UjvnQIPi0M86bSgjz/akWk6vjYuUU8kfjoAS6qhSjO2o626mv47gwDl9WTEBTd3Qgf5b/6S424E5j6GkOO1Ms=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=UwyXikwN; arc=pass smtp.client-ip=209.85.160.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UwyXikwN"
Received: by mail-oa1-f46.google.com with SMTP id 586e51a60fabf-476ef1870a1so755061fac.0
        for <linux-nfs@vger.kernel.org>; Sun, 06 Sep 2026 23:24:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1788762295; cv=none;
        d=google.com; s=arc-20260327;
        b=lPTPmxLb9jymrRAAOp0VeGssisMsMf38tfkvwWDQj4O2GzBCGYntlcdaXOx+Go+d8E
         VOa63a6qaDwmTweqFTdyaQvIr8kHPYuwdP47Hy6gZTJLAZMRIeYo/VZ6Fbg2VKeMhSUB
         atYWePW5TQ8YTS/mSZzSZsJgHzG2qZgBzqrDYL2fAwTiibCzzNGqvKnijY7gH66bXp9x
         Dz5eGBY5Uwm1Y+qssjijWLNhzUr/nCu9COr5lyAdx2yxo/cyf0p49hA+tld/aqKVOR+9
         Qug+0LPoheV+neG8tQGkqoCymOATBagAWyfPXkuRnbvFWlAXHcmrfGf7PWYFHBDUqY6G
         ngKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=hx7jggmKybVj+OOLmKakwLti2He5E8fSm4mMZ3lacqQ=;
        fh=A3pMOUK00huGibGCZBFsLekFLVbB5hHGKjUNNKwO+5E=;
        b=bGNoHZjbnxIUpjxtt+XGGwHAs9Gi2rswfG2iZnppFZPo5AS0WpJ7oaPomA2d5CrRIU
         nZbdOW0YaI7WHtj1Bnn80F1hCN0VZ0J/uOWtOt9MWu/KaZPVvjXJngKdqQBZfM/MUkr8
         QRgnSjEMvwy5xFcbhVbIlRY5Ch/PCXhKaZ+Kwhgaq8TU+AQK0gaKlByTFu0R35KNZikm
         kxIKh0sdnGfoN+ITfRVrZ7DAcMWrE7OipKxM7GxSKdw6TAk24gWG/ZdhiN+lokKyx9XB
         iB5Cjo34dTTN/6va0Y4GrCnEzyW4Zz1nSajEu3dQEE40Dvq6EvlWLh76wxO80TGG5h1l
         +FpA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788762295; x=1789367095; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=hx7jggmKybVj+OOLmKakwLti2He5E8fSm4mMZ3lacqQ=;
        b=UwyXikwNBZCxyBvaoEUsd3qXs/aZk22wlTUztEzySeRJ5ODN5jEJQ/YZhs5BSgCafb
         9xtHBV3NAs7zNysaqMQ7eSSgh8vlXP0UAhCGU9Z072aUd0qteAN7o9ylUAJNcgJV8LEc
         PoyNWixfK7K6bD9sntJWKa5tLdcc4Rv7giZyTKzGYw3lRPIT/7WVyy0KoMgxXook4EDH
         HShHPgWQlm93ga3UfETsTU9JiIe45hjw3jHZXv1pzRQiO8LSZ7AuM2rONZIsPp5hS4kd
         AyjntayDk5UgeLHMerDSw5MHrmYht0kFEAH8QkE1qm6Kyyx88mwhf8tI5Wa/oRjq3Yqf
         Rdgw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788762295; x=1789367095;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=hx7jggmKybVj+OOLmKakwLti2He5E8fSm4mMZ3lacqQ=;
        b=TXVDAxiRuBtZEJBT1iNAY1OTiocRNaZUy1lda9HBkwoMWgwhN2M2dgzJDkmkRZPC9C
         NIEDOLuU9i9p1BEUETGy5XElT/Jk0sQq+EbLk05wvdNZSAjBTpH+Z/g437c9JGAi1jXR
         VvX35K01/PqDxzApC9596sTTGrlEMjAtTht3PR1JhdW3JayzUHArirOHzr2YwlnRego1
         +RqepCm1AfscrsjBzSiMVNFo6vaEFBjfA1VxMbcluHwFRFtd9LcGcbic80iGx8n6gDeh
         at0zSRpPCqXD+SDzo7M5pRpZyMY1fV5vtzfq659QrLi2+NOa3gFXNbJ7Sxv82SHQssqY
         mScg==
X-Gm-Message-State: AFuF++nTtThnkUY4fTFF2UWUEnf8UxZ+axRG6T8UpczhsQfDruUwkzGu
	gUa5NdofcopeDu6qSR35WUcg9d0P9G1MQF+M3AmBY81f/hxYagedB4aVz3/SLhw6gcULuhPEOgo
	e+sQbm6yjK8YqlmKPIyuGW5WbRBWMKGFwAw==
X-Gm-Gg: AYBFou0M6ttmJIuOe1Uyp9gsCQolt7S4u35ARb6XvIh9VAA2nka0gIpeZaCZqILJPj8
	ouqtMNRGpSVK0y0VbZArOXhXnY8qXpL8YMlppnc1M+SerUmMPnp0TbykEYVCCju0VInRDFbM59P
	Sm0SAtHq+LrUNnD+NOqQ4KwgA4Nqpl2UFdrwHzHWOGus9lLOz6EJeDmh85m3B3tfeqVVm/Hw1sU
	/ave/4Z68p97xBVrsvz3wQx/FU0T2N26hkYZSypENtU/y3fOlCKhkNpZ1KtcGvDb4P9mTSo1UV5
	RUpFv5ful4h9jsLMmI0aWQRgok4Hjg3WfL/8w9YsRV5QglU=
X-Received: by 2002:a05:6871:3401:b0:428:27a4:ada with SMTP id
 586e51a60fabf-475513525e1mr21561895fac.10.1788762295497; Sun, 06 Sep 2026
 23:24:55 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAHvsQGNj4UxG3YWk6JZeuAFfnYPEBZHHhjxA81g-Ko3vStryPw@mail.gmail.com>
In-Reply-To: <CAHvsQGNj4UxG3YWk6JZeuAFfnYPEBZHHhjxA81g-Ko3vStryPw@mail.gmail.com>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Mon, 7 Sep 2026 08:23:00 +0200
X-Gm-Features: AcwNN1WqRLoVGyACWaAhfbYcIs8Vwx0v1CiA9Ldfc63IfX-Ie92zPZMJbDBtDxg
Message-ID: <CALXu0Ue5YXWWhTuUhtWx-ZA87YRiFE6mtg3pqsPRkU+se1VgmA@mail.gmail.com>
Subject: Linux /bin/getconf test whether filesystem is case-insensitive or case-sensitive?
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

Good morning!

Below is a FreeBSD question, but I think this applies to Linux too:
How can a Linux shell script find out whether a filesystem is
case-insensitive or case-sensitve?

Ced

---------- Forwarded message ---------
From: Jasmin Dave <jasmin.dave.math@gmail.com>
Date: Mon, 7 Sept 2026 at 00:01
Subject: FreeBSD /bin/getconf test whether filesystem is
case-insensitive or case-sensitive?
To: <freebsd-hackers@freebsd.org>


Hello,

I recall that filesystem properties can be queried with POSIX
/bin/getconf if you provide the "key" to the query and a path.

Does FreeBSD /bin/getconf have a test whether the filesystem for a
provided path is case-insensitive or case-sensitive?

Thanks, Jasmin
--
Jasmin Dave - Math (Quaternions!), Coding, Simulations



-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur
