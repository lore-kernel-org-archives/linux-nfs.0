Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.50
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795427844;
	b=c9Ex9M7/PpMPsxiFb1peB5rag2lHbcQdpgKFJR9JgDLL6xe87GiQRQAWPY4XJfh9y1av
	 uhlF6LKgDeNAy5IPlu0dJ4quhsTNE/rUUdmztGV1Iejk8L5jupqzzESZ6lZq+eGIwO0s+
	 oD/cSbDHqjNfIvFSryfqwLmgKQ2Tr+Q1KFFRiuMNpsd93ekmZlCKOHNSE7aggIu7N8Ajm
	 Lq8XkMu6OO1xNvh0ftPJ6NsGGUJDSFIe7Y/KLQbwArjR0D0zNIML6XSFnQ/7VYz2PqQfS
	 h1AEKqJ99je3ljbn1Ut7q4Cgp+1rZHx+GNtAE4nNlPFZgWHtQFu+nw45QbZCCjBLUmA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795427844;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=QFDdV2dYbCjEWzswwkXh0IW+691RkqIfqbbTZeZPlTk=;
	b=TdFI2zU0B0uBLFoYgLkYJstxUWZ7+s+Uju/Si5cjXJu1LZIaoFzzB9snXAicpNE0VLbp
	 /ACtNiSx6VRwNhYbT+j/h8XZsPiNAqwCXjPRLs0fCZDAQfjFLFOw2X48UTTTo8MeSM+/5
	 AZ1SAH9FevA1TSreZO9vqLqEr22U0t2m246XDTVYvmWOs/20z0fMH4K0ZZO5dxIeC3Gz/
	 rhUaJsMNfRnK1UKEuNg9VAPpidiQaP+jlrcoE57i2/pE3e5ABXIDvHTfByjVzx/JG4FoC
	 94XgXCAoNsdCm7RUAR+NaU17SHiccvBrey1xQwNZNdAqA+Tnv9gJeCaW3WPR0EN0YAA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=o7V9LG91;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.50
Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BF107606A31F
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 09:57:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BF107606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=o7V9LG91
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-6ba380cd8dbso3906643a12.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 01:57:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795427842; cv=none;
        d=google.com; s=arc-20260327;
        b=TjOBZRT725YEgc8vtGAt3DEHDnvs/JIdiCMALbIiIEMb77qXz13DuK6lFr/0+CAtNi
         9Vv7AnLCQP7f/2+475Fw1bnI3JZls0ljNZDYhvRz4AhAThfPBIx/T6HLtA84Jt63TOkD
         QkeW191DHs6uMHgqLb4sYZTHC+5XcsG3DQQjorYowDlxIH1ekkjILTMD13oCQhEwD9ll
         oG0uJsld/8W4cRfEq0mt39TXPZzav1lPlDeQ8DoNXZwwkQDsk0AJ5e3jMP11AyOSgYmh
         Yz2ov50WxObVkzoV38KqWGDOcRElW6CmvbOGqqRY1dstsn7aBU/xk9h0jntbLqBntGKb
         q1MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=QFDdV2dYbCjEWzswwkXh0IW+691RkqIfqbbTZeZPlTk=;
        fh=Z26C/4ovbP/DmWrglzp651TXEGJL0To4WBXk85ENsD4=;
        b=Q/9Dwcz9w20kGzOlrAgWYU1XnGvJsUkTxAcbTWJSJmZEkLM3YJzFKyDwkH6SO5Tgo6
         VTgs4cIIQcBUNhZ6D7fufFRCxvHLX5NX3sd8xvp4RgBRgFsX++W+cAt2dR0/13Gk6wwW
         IKgQ6L0bopgk39PpYr1fpc+8LyJWNOk2sYSSpb/0+o6LrAa1/YQooDohtB2IOmD8U6VB
         WWjp9HbuihPyiqddblDCe3t/XsXaWSRtNvSvd0S7MGgvV+zFARn+lKvqX83abdJNyukg
         AkW4ciWJNsD/uJQq1QKteNEuj9k55lOYJlp0RogxG81nQprLz+blOZjUeYHHp7x816RQ
         KEGg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795427842; x=1796032642; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=QFDdV2dYbCjEWzswwkXh0IW+691RkqIfqbbTZeZPlTk=;
        b=o7V9LG9118mmMF61ZW9FZ447+UE64jXuOMNteCfl8aN10L0wvEU7UlPJ+VuneqSJBF
         6hcsOJV+ZRMhkxAsxN8Grkc0KdGvQiuYr3iRl6RT+FssRJaJ3WlNxT3VwNyod6I0nOZE
         v2lsDGlSfpaXBB3m2PYTdfcOyEHoRxZHfZyKclosAnwtA4OtOkpM5zkX1onY1Ey/BPXS
         +qifY3lRU/aKdyRhxTZRwlf0leHYIhmmUZCRZq+Q8c520NMwAqxO8Epl7E9wapykj+o/
         K9+1r0QmrkhIsmIbYdPhZY50uk/Hd4JXlH+IPf3FXyrO9Hmx+FPgBk4xyHL3PauPv1dK
         1mZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795427842; x=1796032642;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=QFDdV2dYbCjEWzswwkXh0IW+691RkqIfqbbTZeZPlTk=;
        b=bceE0XZlolNzPVRP2NY7LMAhf5bLbDASWTENN8g4jeOm98UN4FOIfmBk2Xv9oyzoQ+
         aMmThd38lyU+dTbaXFIxjNrWi6/gAEr4kZOqFsawp+Sno6JPTt3+8uc/+jI3zcWp/cym
         Q86tU9dvvcJhr+MsBAFErRw1kYkmfoiQdhAl4/tBeLi/pWbHmKuARupDJfQYkzimd4LN
         whj/p8vnJ3mByZtrBhwB4szRglCHcIc5GL/nm3IPabzoKQEsYs1vt6D7GucU/1kHL1er
         NYvtljLYmS8PS+2RSEbTUZc1rsHvwvElOOSuxSXIKBt0qeS/ZyuaCPTbeVYmh6j9x5cK
         DV2w==
X-Forwarded-Encrypted: i=1; AL+hErH3/hOAKK7vxsggMdo/I7aMGd+Af1eGknF9yvMmrQNRAbnUAqpbBOyGu6mEdrGq24hyYsn9Z+LfwR8=@vger.kernel.org
X-Gm-Message-State: APuU4Z+1NlEQL4iFivubxvFRcvyTCpNsyo0QXOZ/0CCcKG0mY0s/GP27
	NEE3j3xTYebnhSdTZiBdwywXBvfq6TntHDv9KTEV6Oyy0qEFhAYh/4FyyjfOPpKeqppvRZ0mBrB
	5g3V6PR22nV6L5qs2XgeknW/Gff06qWw=
X-Gm-Gg: AZFdTZf5EQOTcgu6BvT2XIctQa+UQK8Mz704N4MZ0OdFryLoOupIllCMJyO0Yky+RaL
	Ti+un5Y89BByChoJ22uQHkMhCWD/bVEYISkrL4E//3A6NuHhFVXWRbMgZItoXkY+7hP/9yAEdOJ
	oz9lOAx+XEJUtMaaWmE8irAnCvluMhPWkAxBZfzKfhgoltfu9Qa3K7dlKoCFf8AmrPsH8Nk9fMM
	KO6n/pW8Abn4MIcf2CVeO7EiJ96sS09qZJGgCcstvpjHxmfNILIgiyIOQLq8Bf08hTHY7o7lPOi
	zdUO8ryrlafQlnHgh4b9QwLxhmrcLR+yZuWsdZb4mRNJ6LET3lIfUlXSBdTFPbaSbGAizRCcePj
	4W7O87Kzat0PgcVqjl1A6fjP5YAodFIKdjPpxcjrOuyqhQs4kOIXC9zo2dJ52fVZPxOehNxvT5f
	vyaCiOXbpkBw93bXVC
X-Received: by 2002:a05:6402:2812:b0:6ba:9d0c:cc6a with SMTP id
 4fb4d7f45d1cf-6ba9d0cce2amr2233996a12.30.1795427842036; Mon, 23 Nov 2026
 01:57:22 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org> <20261120-delegts-fixes-v1-4-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-4-c89b37d2d462@kernel.org>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Mon, 23 Nov 2026 10:56:43 +0100
X-Gm-Features: Aa3M54rEUl7dme-dlmWVgPXMQ44sOZrIbSYWOBGskMIHOzyu71Lp3fDlp4HcD60
Message-ID: <CA+1jF5qBbQ9dgW3gGaCj98Si59uHzc6KouQKZL0sHkn9rv8SbQ@mail.gmail.com>
Subject: Re: [PATCH 04/11] nfsd: don't grant write delegations to NFSv4.0
 clients on CLAIM_PREVIOUS
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Christian Brauner <brauner@kernel.org>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 20, 2026 at 6:00=E2=80=AFPM Jeff Layton <jlayton@kernel.org> wr=
ote:
>
> nfs4_open_delegation() refuses delegations for NFSv4.0 write opens on
> CLAIM_NULL and CLAIM_FH, as its comment explains, but CLAIM_PREVIOUS
> skips the check. An NFSv4.0 client reclaiming a write open during grace
> can therefore get a write delegation, and a GETATTR it sends before
> DELEGRETURN in the same compound can never be answered.
>
> Apply the same check to CLAIM_PREVIOUS.
>
> Fixes: 1d3dd1d56ce8 ("NFSD: Enable write delegation support")
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/nfs4state.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 490fefaef52a..64bf2e96dc7b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -7532,6 +7532,9 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct=
 nfsd4_open *open,
>         open->op_recall =3D false;
>         switch (open->op_claim_type) {
>                 case NFS4_OPEN_CLAIM_PREVIOUS:
> +                       if (open->op_share_access & NFS4_SHARE_ACCESS_WRI=
TE &&
> +                                       !clp->cl_minorversion)

The ! operator should only be used for boolean operations. Please use
an explicit (clp->cl_minorversion =3D=3D 0) to make the intention clear.


Aur=C3=A9lien
--
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
