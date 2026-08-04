Received: from mail-ej1-f46.google.com (mail-ej1-f46.google.com [209.85.218.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D13B440A12
	for <linux-nfs@vger.kernel.org>; Tue,  4 Aug 2026 09:46:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.46
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785836790; cv=pass; b=ZNKMHIwSQSnnU1mZsb4sd8ti/IP0aFvT654HaEAoayHhuDLLu1kuwaWFfCUiZ8iReHr/w3exd6vtBYBXnjZnprDxtdDpkhHMGuHF2QMQuQsDxZmcOlV8Geq3QbtcNlnWbmB/8X42HLoxxOjCyh+E3jkCvT2q1sGzlwcZyWwKApc=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785836790; c=relaxed/simple;
	bh=PEN1V4gYMrIG8mQW1ocW3sHXBSWnpiMkEA1GVc+/iq8=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=copk4dBy1Q9JwakJ7h8/0yvOe7e8ajakfM3fglC9aBT0p843sXVxZBm8BQ2YSPpvcl616SEqk2p2v0PR7EcrBjo+GPtRZBuqdBVeQltgbCld1O5mVu5zsTZrJ/cvHKuson87OmX5+IdQYCDRuskEAztH2JGnqYJ/L5NKkOiEbLI=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ZKZ1TTHg; arc=pass smtp.client-ip=209.85.218.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZKZ1TTHg"
Received: by mail-ej1-f46.google.com with SMTP id a640c23a62f3a-c1f5208b38dso784980666b.0
        for <linux-nfs@vger.kernel.org>; Tue, 04 Aug 2026 02:46:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1785836787; cv=none;
        d=google.com; s=arc-20260327;
        b=Z2KD6CbZ2zb5QSww6SWjlwWUotzEMHccae3kEbDm4x1n+HSXmwj4ddsH1LkntGuHOU
         zcLXFx4N5IRYT9nRMM7nSQx2BOZoX8CfCnZ0IUgKjKvoJJ2HCRtrPveAnlIeeoEQ6vB/
         zGU/Rx5LRknOOc79Q6FsfuSlQil7027iofk7WavcMrnhXWDBh4qzhcIuOwzC1wkC8wS1
         eeBZ0WyyKQee9tItwIeRo6xWRcbkACV5lHpoSNjwsVWnctJQQXzbbuqfZWTbkQ0MiJP0
         7f7vASagde2ocnPQfSrs3ugQA2ZC6R1F2wxKDHoE4H9LZwYTESEOGKae7w/980vwleQQ
         LqKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=IX4fVkIN5+nK1Hk81Rim9BcgOd9k0T6Q7nzuk0EdT+o=;
        fh=pBRPDbYA/exCUVrQ0nCUFek0xNx5wY/TX467i7QUaZg=;
        b=AZHTI/8q0AAJCf638M1g9/XlqYs9zha98DAWCXGftcExGGOHp3jDWNpcPX86s+YYQO
         USFFfJ95170oBY6sjjIQetsYMD01ynG8rANb1YXWDogmej0CEkTrJhGZyszKMWVNAiGt
         5ZGrTbfca/jPJkZKBVrrlUrzgh4y3tf/78M29/IFWIcxY5dTFzUgK2iUO+FBXUOloM33
         1a0/La/4S+fxMzmK3hAb04R9iXp7+tprbs8FoQG8JzzRD2y8rbb+WGa65T9LEWYDcH1U
         E2ZJhy9UVks1B8goZOocN1t4u7MWjwWjHmOkL+NR3r+11ICIlwQ81lfda/0r6WKfHGO3
         RHnA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1785836787; x=1786441587; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=IX4fVkIN5+nK1Hk81Rim9BcgOd9k0T6Q7nzuk0EdT+o=;
        b=ZKZ1TTHgr9C364Vyf0BvDzJ1YaAlEPHdgkp8DYdjcXuAxgxo6/8+dVB7XV7XpfK6wp
         By+Te6KE9ltAxl/yP9ga6K76ekvrf9LZlGPdriry3pMsJeBEnrcU0rPk2jthIqD8h+1N
         mJf9x4Mrl70dJTqtqKMrA/+9Mr9NfTrCL5IhW7PWccP9CtNnJMDBfGZH6DNT1K0I4aJg
         exxjl1ySqeEUg12+NGZqBd4qVruq/bEA0cqZKVtBh5zDqEPHHWp+Lx+RjRlgXSaVrINm
         I/KLEU9pkZ6UZHeFTPtYrUShNCGMMQv0c3MmmKbnasdAFqPhUJV+HO5BhNjg8+8ck/YE
         fpUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785836787; x=1786441587;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=IX4fVkIN5+nK1Hk81Rim9BcgOd9k0T6Q7nzuk0EdT+o=;
        b=UB4BVLOrio1drBodJrc4AIFyNXM73q3l7LBnJLtmbzXWUSa5a0kTZQ0ubNiD+O4LCo
         RRH9CdX9clRMF67O2GMSaXDCJUTbFxUhYs5TiTR/i+5/2VtGgrit9gINMDJCITImT7KH
         5q8kn0NHDPGQC4QQ9Zs6b8wr1vWy9KeK1ZYh0+N5GGPzUjDL10dS2wiafEDmSb9R0mGU
         5Zbx+Faho/Vq9jglQwrq9mCss/fuRwR+TBS+3dJW+g4rGhBOB411poneG6JxzsoqGuF6
         sW7TaKa9bTqBTfCmpc3Xz/Gp2nT8/IKSnOXWXPV1kVURpnWCVewwrXWvbato8zE6L2Je
         fWlQ==
X-Forwarded-Encrypted: i=1; AHgh+RpakJtLnPatpgyFpPXMn02VWF5FAYTbIchXgIWl+kbJmLrUufi9APKYxjxmE3yC9gma+Yp3LphOfN4=@vger.kernel.org
X-Gm-Message-State: AOJu0Yx4Lk833T2EWrBOi1ug9xk2yP5+HZE2JhdYQOeKkPcEGYnpNA3B
	8leDa0d2ZNIt4B9khkLYknU1bfkNhmz/t+w00tEw/25qdghBcLX1tcZxX4XBSc2sQX1Ojm6YgjZ
	9jQeJizG+lBvDW3TzHbf2o7K7ELxMO38=
X-Gm-Gg: AR+sD11T0KebLs7dmzR5sF/VfIN9N+9np9pN8payw9duYPhIcJZcZZd265uGpP+Kdne
	2eHIA6gu9/lIfnN0qPtI1/Y2e1B3yG77gONfcV+WWHeZJQsZ9uZ4bobFZ26LFH6uP/ZIyn40Uyw
	BFQ6wfw0p9OiOhqPfIX+JbTqo9elcVuhC82OvO694jW1clvmVIoxsT1t4WNSuNC0J9oJ7/R4u4E
	u4TqxB6i7mMmGbZSCOSvo2JHZRN3NiCvYqhzb9IyHwiNfjoJ90a/7DHY9Zp2dJKLZGH12EFe7i7
	k0rYb3tilKoobmeAaB4IaV7t14ggJiownarsR41bDowO/Z75F7MkKrzKpUSEa0K53nbVPW86Jdy
	9ug==
X-Received: by 2002:a17:906:c10a:b0:c12:5e3d:4023 with SMTP id
 a640c23a62f3a-c1fe7ecadb9mr1028413766b.10.1785836787058; Tue, 04 Aug 2026
 02:46:27 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260723054622.3460249-1-hch@lst.de>
In-Reply-To: <20260723054622.3460249-1-hch@lst.de>
From: Kairui Song <ryncsn@gmail.com>
Date: Tue, 4 Aug 2026 17:45:50 +0800
X-Gm-Features: AUfX_mwVprYE5GeT6dtkefeYHJT07YC4B0Cgdou_icFsYRHG5cHdT3v1g46bWAg
Message-ID: <CAMgjq7AYZhTYR-U5DmxoabdKMuD3AeMrY4yqnkNiEdJ=NGwRKQ@mail.gmail.com>
Subject: Re: swap_ops updates v2
To: Christoph Hellwig <hch@lst.de>
Cc: baoquan.he@linux.dev, akpm@linux-foundation.org, chrisl@kernel.org, 
	usama.arif@linux.dev, nphamcs@gmail.com, shikemeng@huaweicloud.com, 
	youngjun.park@lge.com, trondmy@kernel.org, anna@kernel.org, sfrench@samba.org, 
	linux-mm@kvack.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 23, 2026 at 1:46=E2=80=AFPM Christoph Hellwig <hch@lst.de> wrot=
e:
>
> Hi all,
>
> this series is a follow on to the swap ops series now in mm-unstable.
>
> The first patch reintroduces direct folio writes for synchronous
> swap files, the other two remove the double indirect for file
> system based swap.
>
> Changes since v1:
>  - include swap_ops.h in zswap.c
>  - fix a commit message typo
>  - add a commit log blurb to mention there are not functional changes in
>    patch 2

This series looks good to me and we should have them, especially patch
1 to ensure existing workloads won't hit a regression, minor conflict
in patch 2 for unstable or new, due to
https://lore.kernel.org/all/20260723032434.2016749-2-ridong.chen@linux.dev/=
,
but should be easy to fix. And for the series:

Acked-by: Kairui Song <kasong@tencent.com>
