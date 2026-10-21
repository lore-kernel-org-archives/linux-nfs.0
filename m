Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.42
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792584446;
	b=mZIhyP1rJAnjU7jGbAX7pvITHWc/dACdKOM3767Kmz4UL7n5izdl4Yf78AfTAIL4gPC7
	 lzi0t7LHhZauifsDGH9T8zMRZGYrlbOxVm8WX3798cUxaY0zgLnTFKzAFR6hlfUY1LKcW
	 XrkowL3qWOYK2tmYQBXiQx5tXGl2xXie7vDbMMOt76t41Eq5iQem+cc15XBVkEKBcXNML
	 7vNa8fjUnfn121vKHu+KPfeHS2OAXT9A3dL63dEN0Z5dHab2SI4wiHergFAAngicJbiJQ
	 HLvBbDifE5LWm1JjzXWghgyEl5OQQAhEU/Ak3PfNQsyrU5aVZdhT4ujJP1AgQ9YSK6g==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792584446;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:References:
	 In-Reply-To:From:Date:X-Gm-Features:Message-ID:Subject:To:
	 Content-Type:Content-Transfer-Encoding;
	bh=moyPdxn8zj/smNrr+FxblO0aPnWxU4cBZgv7T2Yooqo=;
	b=ASjXERPCQ8g60W299T3/YU2e6GiHCcmvyJKBR5pqC1uth6kBH0K0BTQuHf6zwh5FuK1j
	 E0yIMp+Mpin04nQKf/StGA7hEt0y7LxpQmTnNXemqLy5bb9GSo2E8QE3KeIjpo//UzopG
	 ROuwGipj52FY/R/25AKy2ATHOOy5AGe+qI3VM1wk8orkrpED9D93Qdt6lTx/y6ZruzkCO
	 q5BQyn1f0jvpiz3ORvLMtrWldyAGIQkbCPXNdCo6TMk+CJQM0fDKSK9o0QuPGqBRQ0mRM
	 kvhyFQiHdirFZOVY3V6NWuJtM33I8EUDS4yN/NmMsjhPfzrSj5/G7sxmZGbi9JcVdFQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=UuX0vZgc;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.42
Received: from mail-ej1-f42.google.com (mail-ej1-f42.google.com [209.85.218.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 45644606A319
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 12:07:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 45644606A319
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=UuX0vZgc
Received: by mail-ej1-f42.google.com with SMTP id a640c23a62f3a-c411e139259so46945366b.2
        for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 05:07:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792584445; cv=none;
        d=google.com; s=arc-20260327;
        b=PmWAA+AXiuXOPzRwpUp1p9lMziaaLqfsdxPmnoVP2Nk3CsWFeWr3TEB276bAKHY2Z/
         oT7tRxsBFstnUlC1s1f+KiU9CiYdDIdxHWsF9WoYNlBYM1lmCdbTsHDTmYvvX4VU6gxD
         JnoSqdRAEzvcBJ6eD3N3+yDiAVmn2d8WSF0YE6E3TnYaaDxDzCxECCx8Gh+X3ylZ4EzU
         kSAZHVgtBUAqXVWQjQBm6ACzPK7+AckCtbsLg8DFOyEGh4Qw7yj9frFOROFKDoK2z3oK
         IvtN+Y7j/DOaRsFiZJg3R4EwC8J/yy64cYQE6YdcuNQLF0jkOHYgAhiY+GH7lPwB9MyX
         HJMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=moyPdxn8zj/smNrr+FxblO0aPnWxU4cBZgv7T2Yooqo=;
        fh=A3pMOUK00huGibGCZBFsLekFLVbB5hHGKjUNNKwO+5E=;
        b=SB9J1d17+4R1E5nI/4xv7AoS7WuxWnQlm4dKd5vYzfLhvNZeRhCyRTO/4nglQff2qh
         7NZ2wRS/35n46Q8ZTz2/kbpHKR0SLg64Yb9ebZat7z3kBidq41MQVZWv9r7pi3wRirfN
         HF/JX/rWMdV20at5ih9YdO4D4iYad78s6vpD2o2PzkcUe+LEPGxcOBS560eEEldp5T76
         m8+aviuQQnWPVrSBlEszSqRZA0gKIW1h0tTtHj9VryqWe8IzT0mvbBWOl81qDYownJaH
         SLmyNpfTgR/gOO96XZaFoCgd/5AwSdS0eq+O6I0PA31/2IZ2EKLhmq0dMDFEDX6eeT6h
         CbAQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792584445; x=1793189245; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=moyPdxn8zj/smNrr+FxblO0aPnWxU4cBZgv7T2Yooqo=;
        b=UuX0vZgccRTV2tAZFI380Be02I+kH9eimcJiEUX8kPcbpWqC3MzP3a+blDAecP+0Nl
         p8P7HUCn5n17OFG0ruqXKo2EOCyklqehF20A8g3Ws4j6qVjenLiRIM+x3jTbTAUzE8N7
         pcw9KHypUXlyxUq4kbr2m5+KddYHrxGFJr1f5RkYHMUX9ukwnbIVLyG0RVuo47UgxWqH
         ftVxVpGiE8chlJ73PARA+CXP6WrouH0lU08WVr7wERHsyoMrJ+EqWpyJOvhVhYiiXSyv
         /CBbRcDhALb+amkZkXu/JO5m11xXYkrIIIAeRaBtW6fjiv0G45ED4WNkWX2SFOHPvJzk
         fMBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792584445; x=1793189245;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=moyPdxn8zj/smNrr+FxblO0aPnWxU4cBZgv7T2Yooqo=;
        b=nUToc9JSJ7j7dBTPf80WjiyAq3ZGO5DJJwa0oXHbFN/DW/NOK3aNhUWCTfKTQApX5T
         bOCPPyMeKKe+qky9IokjsOoBnOMQuUu6Wr2u1tEwtT06nglLOGjh11IDzQ7O39pFSC7M
         5KP42KEDtXCmSEzUARj+qn51VBecaqkMOUj8LFAD07HXn5ZcamlhtZ2PGhJJqmgK5Ls4
         LzT7NuBXxP7lU57avuW22uI2pau+karXAG0nWy7ReFF/Jn2m8zNZf0c/nmpWQIghaHv4
         QEDbdwsfC/AVdNBzUa+HKA5WThMpDOJu80l82/JbIUaXsHB4kkSoDJHnJm85baFCMRHS
         xogA==
X-Gm-Message-State: AFq9FYJI4hLQEdVpNK0ARIQuZeMe1ZgeTufsp7xhJ9XtR62OUThnvWCc
	Rp4vzr/idhTmAH+M29JtMVFhqXaY8SJeG6YRyido37Ukv+jzNXRj6gbJQoRXssFWqmMNhfCYqDo
	3MBGjFyA5G9JskM1yMw/UFLbGjgC3ZfvhUw==
X-Gm-Gg: AYBFou3Ga8bcFf8LScpTli2kkixtcPSV+kJ7ihptgY/vq2g6P882hhooeeRz5a2TM2S
	kZKZ+k8WAm+kVtenh56OZxgC2PsmR9QSt1vyejyHqki+QKLsrTej/3jlaZwFxDXjYzlC3AqxNaX
	GsjAKNX1A8YpDFUJDfEzf7xz4+1j1tjJahGFsCxWTz2Q/vMdUMOB7FTKgRERpZqKXOAd2c8ph9v
	F3dmh2vTn1/Yfr/MtrvQkv3JUdC6YfLs3k8mmsEn3CmmaFTZkLhEL/jvirKd1rvwVODBE3XVeCl
	/+BEhrjT6P+Z4vBcE2T80BfYASTby0e+qiDl0PR9ILTp/jDPq5rrxAbVjWZ7qP8MuowkAjqarM4
	I45S6fI9n8mBbFRUqQD1S1CX6a+mG1ElR5prO
X-Received: by 2002:a17:906:dc93:b0:c2a:ad55:b3fa with SMTP id
 a640c23a62f3a-c467916d30cmr165736666b.7.1792584444566; Wed, 21 Oct 2026
 05:07:24 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <CALWcw=HsVbqgnBE+fW=qO9ULPww8_0amGjgw-f11FuoV2=ftOA@mail.gmail.com>
 <CALWcw=HMhCU_-UX7mHPwX9jqu-r7y7XBBrhg66UNjxYZaiO9Ew@mail.gmail.com>
In-Reply-To: <CALWcw=HMhCU_-UX7mHPwX9jqu-r7y7XBBrhg66UNjxYZaiO9Ew@mail.gmail.com>
From: Takeshi Nishimura <takeshi.nishimura.linux@gmail.com>
Date: Wed, 21 Oct 2026 14:06:46 +0200
X-Gm-Features: AclHuK9r-DKkGBJ012fHbs2zPAAuad5p7zSnYDe2pTf4xC8Mf2k2Wse6htGfvTg
Message-ID: <CALWcw=G+PE2Xen-YsVdTOB2Rjwbh784-WasGzqnCp5mVs83Vwg@mail.gmail.com>
Subject: Re: NFS swap with RDMA?
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

?

On Tue, Jul 7, 2026 at 1:22=E2=80=AFPM Takeshi Nishimura
<takeshi.nishimura.linux@gmail.com> wrote:
>
> ?
>
> On Thu, Jun 11, 2026 at 6:01=E2=80=AFPM Takeshi Nishimura
> <takeshi.nishimura.linux@gmail.com> wrote:
> >
> > Dear list,
> >
> > does Linux swap over NFS file work with RDMA transports?
> > --
> > Internationalization&localization dev / =E5=A4=A7=E9=98=AA=E5=A4=A7=E5=
=AD=A6
> > Takeshi Nishimura <takeshi.nishimura.linux@gmail.com>
>
>
>
> --
> Internationalization&localization dev / =E5=A4=A7=E9=98=AA=E5=A4=A7=E5=AD=
=A6
> Takeshi Nishimura <takeshi.nishimura.linux@gmail.com>



--=20
Internationalization&localization dev / =E5=A4=A7=E9=98=AA=E5=A4=A7=E5=AD=
=A6
Takeshi Nishimura <takeshi.nishimura.linux@gmail.com>
