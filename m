Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.47
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795507450;
	b=W95c3utJYwayX9EG710e1/xaLYljkkby0qWaHpphLEb3+EV8eIQRJQbJ9ILh3jYW1i12
	 oZoBjZ4ctxe8OntTb4EcoKbbpyouUH3y5WhUqh2asmYW3yD3gMl/kh81iDKioq8lwpDCP
	 TFhFe4tHlseV8Tr9xCx48PJVhjGbD75nCro5SziYv6nBkdDnjpyws8h5B5E2sBZtnOR2n
	 LLIrNY65UVRvw/9icGCGXqIzTOWWFgVa+Bw49Q8M0iqwKQ6Z+aiKdXHbZn1P1xU0xS8MR
	 NlJckCYI8pMnrA4KyaSz/NEDltzmhrxCOCKFIkcnQJpZsT7FzEzeEi6rTd2TxkfJmfw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795507450;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:References:
	 In-Reply-To:From:Date:X-Gm-Features:Message-ID:Subject:To:
	 Content-Type:Content-Transfer-Encoding;
	bh=KKJotujUbHzNVevv6d0v/lsn+q2PmmxE6ACPggTd8Bk=;
	b=bG6Y4ZbrmkJTuml768iTvgjs6EC+35wOrBuDJdVGNI6okqpkX+zm83TGgzp1aVxUrgdM
	 NASdnJA1iaXM8mf5S/y9NfF9dNyCzgqw/1/8h2+DG08mBP70Yi6ekoeLpmnfCvPr7EcNr
	 S2O5jPc7j7Ji5lluHa0o7VeTgkmf/QLD6GEvdoOpCYicD1GuVXj7dhy1kifxS7z8g0KpQ
	 C78928Xg+abJgfpfXbvbRhjYtNfyrboPVVLsh9pOAvNaSOPZj7iG8K7Xrgx+dDw1CiN32
	 j0MWto58833prTcHjksDJrV8Zwh0O3Tb696U8xdmw6gv7KFt82BoYiycThdQ/VD2/ig==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=m9pUl7b6;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.47
Received: from mail-ed1-f47.google.com (mail-ed1-f47.google.com [209.85.208.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1654606A321
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 08:04:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D1654606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=m9pUl7b6
Received: by mail-ed1-f47.google.com with SMTP id 4fb4d7f45d1cf-6bab10844b5so3160749a12.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 00:04:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795507448; cv=none;
        d=google.com; s=arc-20260327;
        b=TW/djyPrlA4ZZu7fG4z4r6H5g/A/ZQHbouZFXqDEukZMwGLxrBJhLh0P7taTGkuoSY
         ZIQDLGDHYDtOd3mmjzICC64u2bUL2x8OS0V7yJfOvkaXwacr4yg8qcXOD++0r0bIdUMo
         Ifstj3gLveMByQHFag+mTq/uENjAGBx9eW0KJyg4gF1USDp5vutkPOwNJc/LE8VjqNHl
         ZCfl5GvbBecFxgnA/o4sDhQ7vt9xgzFJwUdXYywAu9fEeIg0ovFnVRKjtT45vAbyyq74
         7hLxfWQHEmI+V26YyAxpFwn2yqcGMGhITpbLFzsbB4in+T8sYsXVNU2HbXxmtGkDd2fZ
         YRqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=KKJotujUbHzNVevv6d0v/lsn+q2PmmxE6ACPggTd8Bk=;
        fh=Mys3y4MwsHRytUQMpdfGBn3oGRYLcLloxNwkFYMYMmg=;
        b=PzNIWJJkhIUShhf6tWoS/XxTTCW040Je/GHzj5CW2SDCtVLsvyt3+kDArZesPn7jyt
         +tV7QtKw4kgJn4Njgf68FjmeTTyyuMrPTgRh5jzPPGPvYduCHKr0kqh8jSR+SxZtDeDD
         DJeEN4GFgPzL15SFK2bjTLCLga6JxRBWJNlqhmXK1mIqa/BJ8znrw4o+6GepiK+n57pU
         pdvVG4wioRVfrNb6PrvkDoBHXTR4RwkNbzT7NFv2Uo7nLSPiMtouh4pd+owLXIkZQZSN
         6XM3V7rZ4MCKA/4y6jbcGB3NvAcoYmnxJwr+58ft5xkgMu/9Eovh+4zmWEleridvAhwc
         6sBg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795507448; x=1796112248; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=KKJotujUbHzNVevv6d0v/lsn+q2PmmxE6ACPggTd8Bk=;
        b=m9pUl7b6lZYzf9tbnSkRvIt+Tymt4LIhwsNSpb+//6uI7OiP8f2JT+7QWQhqTGrF1v
         72LPkeNPpmLSQ8jwVlShZXzZNh6YTK7UNuN1H4RWM81oR8IeFwAkT70wPFMaO8uFzzim
         yoJo+EZta74AOYRPF6UUf6oH88xpBV2yr9vY2anL+uDXpzAQMzMwAuk1+zDbP2hBu9SJ
         rpISeyocMbtnnZnThoKKzOqsYAX1qsf8YdvLXkO+NE/xsAFEW1ZH/y+hsSQSueHviWdE
         +YJ0LUee3NWmKsNgi519rgY6nOsRkzQjv1gryeeZPYO1FopQJB8Pzu542jmQs8/G0nDV
         fd3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795507448; x=1796112248;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=KKJotujUbHzNVevv6d0v/lsn+q2PmmxE6ACPggTd8Bk=;
        b=fv+aC5Y5MnRi3agNOC2NVUVsPGMA76cLcrys79c7xAWBIvB0gpswMrNvKMjo3gYMeC
         Jg0104Io76MNi4o6zzm7+WWfDx2ms6z+sPRk7yntvKInfdci+9MquMOLMPxCRlmmKj+y
         XLjVL1AGHweykhTgTTCtmHkEnW3M4V1eMnQoxSKEAb3Y7eeQE1S+JKeEH7/8/CMByQyF
         IDp2WzvNx2woJ3NPOSmuMoyhIkAuzEAZwvLfWVj5MkXv3iRasW+lvwq3mFX+msOxjp/k
         jxWF8ZqESTsUt9zUpNI/rmhM2sFjiUxWPamInQ9gCGBiMo4w9TGqBwmP0X33TJiaX+Rv
         spsA==
X-Gm-Message-State: APuU4Z81ltSa+dtHkfSK/apSXXguzUYjqejZ8v4bWsOII6sm5AJn4Qsn
	WumyXKoFfp0SHvdPNxSyr+JKKkxovfHxxYHzyFbI+XqToOxV9R3SuR/w/dbqGVDNgX7VWzyxyA6
	fgJQuuhrFXS1s61+Vmpmi0gHI5yF4KbFQtTDe
X-Gm-Gg: AZFdTZdq6LPmCO9yJz4ZjTohu677D43vMvxXQrJ7CXS6+xtMYF+smy2prYvrjZZ5I3Y
	v1gw1chMDVRZ6HoZIQXMdF44hU9dPuIQoxEfuTGLsQefuUNiK5afQW/SWqf6Zyz4nJH8KnGbMDL
	AdQ8cAJ8sfrNDGOHTFC3GqUSSZSu0VQVSz0jHgP4xiBq7RrXreOuZ6tOCJOPckOxPvQWHgDsxoa
	npXJGrPI1OAPK0Se/M/VhLHJESrneUFxggky6VlznB7fktKvZtnaMp8twrZslTu9743VBgaJ3AN
	TNS3bnS5bk6M6aXj0JZPHhlkOIezqVl4v8Jn10sjJ8dY2xrFAozQazH0xE0WhqMSLWMgL3a4QHw
	/KAZ4z4TxnXNOJKJ6XEQDtgarKbOjGERctfvWYtFT2pzsy1g8V5hrwfrgCU1EreAnQTK4gT4=
X-Received: by 2002:a05:6402:3131:b0:6b8:968e:a07b with SMTP id
 4fb4d7f45d1cf-6ba1fafd50cmr8964745a12.10.1795507448008; Tue, 24 Nov 2026
 00:04:08 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <CA+1jF5pNXvipBz8Hh3LWn=H07JJGEJPVH_hWZYCE8GhB96kvgg@mail.gmail.com>
 <6bf939ae-c29e-475c-9261-0cddfc31805a@app.fastmail.com>
In-Reply-To: <6bf939ae-c29e-475c-9261-0cddfc31805a@app.fastmail.com>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Tue, 24 Nov 2026 09:04:00 +0100
X-Gm-Features: Aa3M54od1dkbrfcjG5b0SvUUI4sWUX7UAatB40WdcfcfMVFv2Ar0CQQ02U7A9n4
Message-ID: <CA+1jF5roNowGUBSAS-v7uC2GzZTgrLzXD_h_HLVuKOsb1qMu_A@mail.gmail.com>
Subject: Re: Which Debian version has working krb5p support in NFS server?
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 23, 2026 at 3:28=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
>
>
> On Mon, Nov 23, 2026, at 5:03 AM, Aur=C3=A9lien Couderc wrote:
> > Which Debian version has working krb5p support in NFS server? We tried
> > to start a test campaign with krb5p, but that project stalled in
> > September because neither Debian 12 or Debian 13 seem to have working
> > krb5p support.
>
> Have you reported this to Debian?

Funny thing is, the Debian people suggested asking in
linux-nfs@vger.kernel.org, to get a list of known "safe" kernel
versions and "known" broken kernel versions.
Also, regular (Debian) testing for client/server krb5p appears to be
outsourced to whatever people use krb5. The whole situation looks
pretty bad.

> The status of krb5p is "supported"
> so if you find that it isn't working, the right thing to do is work
> with your distributor.

That bounced back.

Aur=C3=A9lien
--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
