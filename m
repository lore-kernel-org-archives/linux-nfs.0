Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7695544C4F0
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 15:41:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.50
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787586079; cv=pass; b=qnqReqzj14JPAcdgNNNkgC+6Dw3I9WCCXR3QYhM8gyF4ltxQ2U0Md8/PKkt4KCWJWrDc6Nv5Dmp51eXZ68OVSG4MRxDFfbAVj+gBOWUt+5TxIE6p7Ajc1OTAX7datnszL6JwYKwwyHZdRJIaqqMGLEb7MK0IqU/8v445trJbles=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787586079; c=relaxed/simple;
	bh=6eFduSW2fO2Sy5afFzlHLVITY21DcRfgOT7bgRiIIOQ=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Content-Type; b=r7+oww6iXMlseBmmVe1Mj1IwNDHPQ52R+QHhgImxLilhG/Izo5zLnQSKXoyoj8wzgUNe9YOZ9Tcxjd2ozpy1CtRzOq2ktyU2U1+NcAXQdEo9BZYWSlmTI3N3R0oKaFa0NC+5gWYR4PuplbHjDrV2zqKT1czMYz0POOTWfIj+f4M=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=HR7vSUUD; arc=pass smtp.client-ip=209.85.208.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HR7vSUUD"
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-6a3819e8be8so68174a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 08:41:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787586067; cv=none;
        d=google.com; s=arc-20260327;
        b=pYYG+MJnL6AdUdSZmEj0gKufJSkDI+AGqvf/tZ74vXtFCpReAHeGfKk1bHyMpHkSCD
         CSiY9NMIxXtIJf9klKrV4SmbgNV7jvs2oUdxRM+F3VpKljwnfhD7zlKc+8RxtvvyUghT
         wQbFgWITreaUpxYJw/ahF9Nhczja0z1RATa2R6xSXgr0YwGhiyFVS6+A0fAVOhSwWjAG
         NvKUGSwSONGERk1yW6OumtBJJwbKLIpoUEOYlUJoeflCoAFuzknNejrOnn7aMlSTnKpT
         kWWJk8LPmgcLWVLpyypgAbWrokWgZOZt851M6jBW7obJoIMXVMGvy/aInbWyLKJ+SY2O
         BIVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=6eFduSW2fO2Sy5afFzlHLVITY21DcRfgOT7bgRiIIOQ=;
        fh=Mys3y4MwsHRytUQMpdfGBn3oGRYLcLloxNwkFYMYMmg=;
        b=RDMuyWZ/+DDGXrbR6Fb9QToVVN53pvq7rMa3IwV6SwY2qUZSMfjQrmcQksT79wPHhN
         8vtBEwaBX4VFbycU8Ny6aBu/GNx+tyDh3n1QnfBUcHHZq0QDC1AjLHNlGW5xnoZJQ+wh
         FX5MhGfBrbN8YR5pFbb8XF7pToIoh3CZ3paRUaqgFsb3ldnvwgI7RNiA2mSRxXYZO5s6
         hR/cNCYMc87omrbsN8Ovq4oQ1E+ecrXCG4cH/H0kouCUmrz7yj/sCwwUNiYUo0YwA80I
         sS2r59pjXoiuG0N4VFaKJG4hPKoqYEaNBtlzO0NvrTqjpTtS0cHH5+ARCNY9Nd/7I0je
         larw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787586067; x=1788190867; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6eFduSW2fO2Sy5afFzlHLVITY21DcRfgOT7bgRiIIOQ=;
        b=HR7vSUUDqEC1fzxmqaEpHDauN85kROLD5sg+cZ6d5C/3dD3tNRwq2JsDpmVkPqvh4F
         lUvEbRssvm4u1rJQnz0WfMBY9r+iTbYeAbvNX+IfMyIrfKFOODwEwgEUQfQQGSvQXyS8
         m2GPJT41P+43hkIf1cJY48p2GdGdrQZBpVzShymu9NGVrGoDbeHX2zVbemNP3yaEZl1k
         eqWPFf2nkMFmlCfv91D52PCa/HiAPCV5cfDO/VJVaZ0eUgg2VvdAkDBQi7fgNJUg2hOU
         2Lk84IPGi478OJo2mD5Vmgy8mDJgCCeMxQRu9l+vUH0fttKTubvbM7G4zrM+z4RkY9Dv
         WJ6w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787586067; x=1788190867;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=6eFduSW2fO2Sy5afFzlHLVITY21DcRfgOT7bgRiIIOQ=;
        b=jjYaqAgx2QQ4+lj3zlSdsCyA2R1jC8PRj/fzKzf7PlGZ+SgMGCwuz6mAlz/d4K0/Ag
         88444h4agq0tMamBC3jlGFzcvag28wpV2QzcsCl1spS3WxA90PLt4a5xLy/+1KwNFPuF
         95dmkSbvlX4bBrR6jaLtAYLallS05ErEGuiabzucEzwrxyIvOvJMiwjGA8ntcdiaqNtH
         Um9wJKKQjiquiN1k3g7/jSr74DV714PtearcHwBVRiUt72QGsozMigBENUviIjPsCkf+
         JoFZw3NynXzVCUjoK683juNxWxQnUfBFA1S5VYkNP7O7m6a6MsMl6NKsC76JBV1ACnHZ
         2gIQ==
X-Gm-Message-State: AFuF++mQTwgyu/iFeBD07Y1PpS2eNe7rmDmQQjjCsa2qp5Si/m+33h1S
	99GWgP3NrhFmmtgpu+dvDu2s37cYdA+RWhcGrhYrCBhScYyuv7X/jsrSHD0euQvLAUgtIC5f143
	xzGLxeOObZlzxBzB0YK8rVKNGtn1om81mJ+RFiFc=
X-Gm-Gg: AR+sD127VfNuUJYraHnOd6Wgb32Cw2HaQJ/lN4hmzlFAKYSbOHGWo586foLw0NZBsus
	v7bEYyqfwwDObHaatQ8hDk1w3aEo8jdg/vmJ5gWiqKuUBp2yJw9x66OaulOcWQNUK+K3TaRs4sn
	+PRjcZf6hMsZFvp+qdIJLbVy98DCLzEyZHoRbCwpCjSmJrR2w+kAU6auFiglN88vNFaznWDG9mj
	W9MB+vEwtRuSG3AFvElXs4GY8dnk9ElxBvz4bPwt1JIS6yg/6dji1X3uWbmjugFcYtmRYIV9otQ
	e+S7cktLHHXxchLEf1Z9E6ES41T1djok7AHV6eTsCrG21nDFrk89nlSDnQMCXDxrdCUG8uI3J8u
	O
X-Received: by 2002:a05:6402:4510:b0:6a0:a46b:ad3c with SMTP id
 4fb4d7f45d1cf-6a5c3b36ddamr90299a12.1.1787586066714; Mon, 24 Aug 2026
 08:41:06 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <1759357733-64526-1-git-send-email-dai.ngo@oracle.com> <CA+1jF5rAMkb44Pu8XGDnu9WUE54sHVf5TurMsQXfrUrmu0Ojjw@mail.gmail.com>
In-Reply-To: <CA+1jF5rAMkb44Pu8XGDnu9WUE54sHVf5TurMsQXfrUrmu0Ojjw@mail.gmail.com>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Mon, 24 Aug 2026 17:40:30 +0200
X-Gm-Features: AcwNN1Uef3KotuAiXbcubs1E05d9kkenhKpAVQxvLPw7xeb_hppQdtTYaTioyJE
Message-ID: <CA+1jF5qAbz2pMSAnSdJVo0P1d=jM5ysDsUi6BpW_+v9LgaLsPQ@mail.gmail.com>
Subject: Re: READ_PLUS broken in Linux 6.12, worked in Linux 5.10! Re: [PATCH
 1/1] DIO: add NFSv4.2 READ_PLUS support for nfstest_dio
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Reminder: This is still broken in Linux 7.2.

Aur=C3=A9lien

On Thu, Oct 2, 2025 at 10:22=E2=80=AFAM Aur=C3=A9lien Couderc
<aurelien.couderc2002@gmail.com> wrote:
>
> On Thu, Oct 2, 2025 at 12:29=E2=80=AFAM Dai Ngo <dai.ngo@oracle.com> wrot=
e:
> >
> > From: Oracle Public Cloud User <opc@dngo-nfstest-client.allregionaliads=
.osdevelopmeniad.oraclevcn.com>
> >
> > Check for nfs_version >=3D 4.2 and use READ_PLUS instead of READ.
>
> FYI READ_PLUS is **BROKEN** for sparse files. It was working in Linux
> 5.10, but as soon as we switched to Linux 6.12 it reported only data
> and no holes in sparse files. We're back to Linux 5.10 and cannot
> upgrade because of this.
>
> Aur=C3=A9lien
> --
> Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
> Big Data/Data mining expert, chess enthusiast



--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
