Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 146193EAC80
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 16:56:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784739410; cv=none; b=mtuRfpOjbJSPEcHzXgi2xTNcXfApu6m3/pVQM+4swW5lZRjAPDJxOwuNCi7dgC7DHptlhc8KKq3x9sYK099aK/tMR4dksjXekDK51Yx8In3d/K+lmRdJmnTNOwho+zM4WIWlCZRKRhDIs3RxGyEE2MUjvSk3IFnnLSD/Z7LaCog=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784739410; c=relaxed/simple;
	bh=lEpZ5mYi0gzacGUSPLAg+0Et0qOSnoywGr+aepokseI=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=MNTZ2pugG+Q5pLgs0MuhTqxzLzZ9QC79lT98OSPpCbM2eBz46oZP788VRVmfXyrGd7rweItUnDl51YrF/0ba8PCToLTy/V8W6IBeILw8jBAoqQiMPGX/SK9X5YYyp9TQ8QDfVwXUuEPe7dx+vb7oP/r0rSp3v3Bsrciy8E+UuF4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SGnwEutg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SGnwEutg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D2FDD1F00A3A
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 16:56:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784739408;
	bh=D3Ja6MqDnVgEe0FBii+nafJwDNldpk18pWW7PwQQnbU=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc;
	b=SGnwEutgRDlfDuSR/HnFKbfqU/gI0ACU3UHiYJdVyIIMMGkHcv1dN2HN/L4c55Deo
	 cUnWoFXm8f5j7pKaRb8rmMo5BmPrYcoilfXz/Fmf+dEIzIvljH4iIKSdYs0lWatyjY
	 ClwHkNUuOzFmHlmEf7xSC1R6DKQcgG/FhiykU7/qRW7PBHaEECUJLMjpjQVQsJPnr9
	 Q8W69kgBvG2hPLZ9eiX8vmA/+W0GWjeA3GBdUXSn5cMC4DwhHGulOv/q1ebg9cAsT6
	 GWdYD8QONQxGyGIBUjcWbtjs9A0KaaA8EWAgPKvpBMkktZQHiXyyTuX2BmIp4N/29n
	 btgS7hYO1IWJQ==
Received: by mail-yw1-f179.google.com with SMTP id 00721157ae682-81f36179dd5so10745817b3.2
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 09:56:48 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AHgh+Ro8ITTyzrylWp8vsDsbjOHwCXaftVgInK31kuvSX/0E5UO2uW1KfVPsP81kt14Ou5QSo3XHwHpQN7A=@vger.kernel.org
X-Gm-Message-State: AOJu0Ywv6toRXgwYrK7B3g/ObRd4z+7xPMrW5A/syWBuhrPdM3DAxNR0
	M8PJHGoyppX25u+Ed20/QovMYpT91pj7fb1muV8yuPRaEanjmNqzKFdN1cR8rdsz4Cbe2Mh6n4m
	U0pmbpgkK+vZfQm5J2tipbi/Q2l0TesTzUeDdjqFEqg==
X-Received: by 2002:a05:690c:b03:b0:813:1001:cf85 with SMTP id
 00721157ae682-81ef2671d1amr80137307b3.37.1784739407191; Wed, 22 Jul 2026
 09:56:47 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260722130615.3163560-1-hch@lst.de> <20260722130615.3163560-3-hch@lst.de>
In-Reply-To: <20260722130615.3163560-3-hch@lst.de>
From: Chris Li <chrisl@kernel.org>
Date: Wed, 22 Jul 2026 09:56:36 -0700
X-Gmail-Original-Message-ID: <CACePvbXCoJQD2xoojv1QtZX6FDim8Ar7Mj7KgtLbZ81J9mk8Kg@mail.gmail.com>
X-Gm-Features: AUfX_mzJfORi8douWKYBIFzga5EzScYpBxWUigLUVgj7zCnBS7ShMqtzqsSmog0
Message-ID: <CACePvbXCoJQD2xoojv1QtZX6FDim8Ar7Mj7KgtLbZ81J9mk8Kg@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/swap: add a new swap_ops.h header to allow for
 pluggable swap ops
To: Christoph Hellwig <hch@lst.de>
Cc: baoquan.he@linux.dev, akpm@linux-foundation.org, usama.arif@linux.dev, 
	kasong@tencent.com, nphamcs@gmail.com, shikemeng@huaweicloud.com, 
	youngjun.park@lge.com, ryncsn@gmail.com, trondmy@kernel.org, anna@kernel.org, 
	sfrench@samba.org, linux-mm@kvack.org, linux-cifs@vger.kernel.org, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 22, 2026 at 6:06=E2=80=AFAM Christoph Hellwig <hch@lst.de> wrot=
e:
>
> Add a new header to declare the swap_iocb, swap_ops and swap_ctx to
> allow for swap_ops implementations outside of mm/page_io.c.  This
> will be used to remove the double indirection for file system-based
> swap.
>
> Note that there already is a swapops.h header, which is totally
> unrelated to struct swap_ops.  The close naming is a bit unfortunate,
> but I could not think of a better name for this header.

Can you please clarify if this commit introduces any functional or API
level change this commit other than moving the code around?
I don't think so, but I just want some clarification. Maybe there is a
minor API change to remove the double indirection that I don't see.
Anyway, it would be better to spell it out in the commit message.

Chris
