Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.160.45
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793172681;
	b=U6BkG/EF6rd3axxL81pCNaE3Cw4JqDQdm7FgeAR7YTx0Hv02eILueDsAoXwoQnkyGQ8P
	 CvZtp6lU3kjpMKjB/dylic0jqB7HVdhtAGHshWnoO7qGZH9hx3Wux8lXr+dOybD7VN2ct
	 gW9l2TBUmXd1vJ1Cbeopv6MOLIin2UTrbBpsgH7ksZVQhGYcVZ63qvG1OKP0Lz2iuv1+5
	 nO1M7sEbKEHAO8GIWo0JGJ5lUYP9+J3DcNayS0rQhgC5cjNwtV7AikzShjctAnzHfMlIy
	 nL9YCVL0fZBT2kznIhUd+68U3nxNj2wP+UPH0kTbcqn7P+I/PiP2z3PJu96lPqpcBYA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793172681;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type;
	bh=iQiRq8EKSN+1zf5BDWbuoLAXrrO/KbsY0yobASx/cqk=;
	b=x72ETam1Ch2c8Qxs0QTxU0xEfauRZW3mRkB2Q5S6G14kY/jvtNfLI7akkygf5zcWFxHV
	 UgkmzTG0Elf/2PFOXh3yl3vc9aW4sJ0P+8GVbZUnwwirBAVM6a2M1tpfmNS3HgHxV5gm0
	 6PqRxRQOS2KUC8bw2r3h6x8OhQ7ueaCRphttNCovOuJk7xAaiSKicSvENi2ot1h1eRxYF
	 Bo7xdiXjj6H2UJHNK0ujtERzT1ItIqxjxRhwr0LUQ2SuZklh3wucsTIuQO1hGb+M4XJWs
	 yVoJhwYQJWUhDmuDmuYGveWsPp+QQSlk0FIxgwUgGHfVjbjog6YZSEOhgQGcwsyKVEQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=FKnU1Sso;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.160.45
Received: from mail-oa1-f45.google.com (mail-oa1-f45.google.com [209.85.160.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD0C9606A31A
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 07:31:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BD0C9606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=FKnU1Sso
Received: by mail-oa1-f45.google.com with SMTP id 586e51a60fabf-483a66818edso341572fac.0
        for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 00:31:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1793172679; cv=none;
        d=google.com; s=arc-20260327;
        b=JPmgIh7sg3hcMLKB626RFyaCIcs46JISiKj/XXjZK0C5b4gT5Dj6AWZK7H6RwjrqWE
         h85MJL/9ADlc9iQyS7c+1kvLjYfTDp5u8RYr90K8Vq1Ve40VasDHe4lehYDOlfnhogFB
         RbZTXP+InAW6WDftsMheW09/YillMNA8vNToYSJDx+gr0jxnTvANBLQm3dIkSezzDywa
         ID0DZLy52s8K8r8mlnUdh1BS8K1qY4YmAITYrKgIMkDhDaCbMfvuRaPbmil/Pqkan8jg
         1Pi5lH1yiuAIO0WkxQJ97rlytfI25kcznlC2ilkvMCga7/rlJnzfY+vmcqymaH/YjDkY
         hV4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iQiRq8EKSN+1zf5BDWbuoLAXrrO/KbsY0yobASx/cqk=;
        fh=9jWxDrj9OtALRb4+koSGJYtpXoEUXCge3LI2OgYNGD0=;
        b=sD43BYVhkwaHGxkuuFu9izSGAqFOwAM31LGbekQZH0kLFG7EaInDUYw/8uqFC2s7DA
         rTFRlwFizDyqOMUkneiHqh1GId3QNl0P82TsfleBikdR3ah7XU3Kp8WsujkR+v/S5r8t
         Ht1XX0wqUwmdVTmuN6L9NP2DMz3yi8+kQ3VE0/ybvGEj+YZkvToFfJHxfySoC5l/2B74
         oUIi8BquKUClpw9xi8ubHkN5gj1hUqfwuk72+Y2H5+/0Rm1jFRvoLMTkevG09qracmlt
         RX+VGRjwkSGfYM4jM+i7jwBXDBjfmsU79Q4ACdUUZ6CzJ6aca7qYXEvqB5mAEX7qHIA6
         zqCA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793172679; x=1793777479; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=iQiRq8EKSN+1zf5BDWbuoLAXrrO/KbsY0yobASx/cqk=;
        b=FKnU1SsoPuGX+StKWmKt7J7HvPblKKLOtilzEO5GTGGePk7/KWpDL30MiKHiqCwoBh
         sMy/HyJf3jtP3bCKvI14IiyrrbZonCfGypiYrmXasI8bjrZkkb1X59TxPKmjKitKmp4v
         33/EiDLw5jAhxVRV/1sKzKoiM/2Mnz5wRigtpEFc2VInjst/az5hRCJpdN2StfZnGIsR
         6IK/HrFtvoYYoptH0QeBfWAS57ywQf94NhFrHbpkmovzSuH7gqyZfyrGccHR3KCNR7NK
         0KwIdRzuYRknvuxWjgHce2hT1vfyS6jxc2cFMlCd3G/FPzmZBMvUNTds8qGDReZdRVBT
         23VA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793172679; x=1793777479;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=iQiRq8EKSN+1zf5BDWbuoLAXrrO/KbsY0yobASx/cqk=;
        b=cBUTRI7cdN6KhaI5FfZMJh/CubZOJVUnfQTxTpHNsIY6LuUryFpiz1IxoGsT8nmHFr
         enEv/HMSvOHtOlUwfFUL2K4tpxUqjhaWhVuqy9NvMRmsgO9H1i3SiEtvGtCrS0MGeobk
         3k+Rlxw7993vyC7v3l4WAS9zyq01B6mOMF31LgBU3Pad61ZrQ2EbVbdtRYYBg5NKILgP
         Lzz2Dt23trPRLL8zM8uJhX3Y7XvotwCCL+Z29fCV8DHZJ1hcGu9XUvHIgwjKdou2ZMWK
         mSsPv38bGJoDKZvCt3WXvXla09scROgpN7KBf30aeYwSk6ZQUuEs7fBV1EbOj7rui3cZ
         ifjg==
X-Forwarded-Encrypted: i=1; AKwUvBzTWOLl1hAxay+bvoHZx8+ugOdIifh5JCT2f5T5FUzlcvXO8hw8f2PemUeuRq+/t4fmPq13wG+U/kg=@vger.kernel.org
X-Gm-Message-State: AFq9FYKJVndh4wiLfaLO8La0hapn4PPP+n6ARO9FXJ2V5IbdfcQABHyN
	DVr6XwGpk3vfXS3wvFYcOUiOs3zoWHkB5xhuTUBp/ICYupAM4bAens54G/MqwiEviVdNy6d6qGP
	UfM0Nmpap21SHwxO3PA/I3YzFff89o4I=
X-Gm-Gg: AYBFou3b+Rp44ptfFUUXkBGkwFA9k0OH+Y1ydmYtRoyaFACPVzhSewkJVoymXYXmKx1
	9Tsl1h68lXCG9W8OJfrg1B50GoZPArtmnOfyAbeEQTGAlQRGxyWTMSOrgiJb8eYxtDbEKqkSc/P
	myEO96dTvv0DZhDYRFmaaTOooRnuxVfOUwSDp4ljA0kVquYPge9OJwuuqVkCzWGlkQxrvYfM1VH
	FwBmW5cQOHacsL8VjZoZonbTuwONsLKHcDKiPkuWjs8Jt2eIG68wkq7BY/cKji4iJ66J2ZAmDRc
	cITckxGxaOQXof5+4ptny5o7A+loXIPSH0+tUQUGCu61Mku9G7X073ujSs4HVzHOIKLoVXH5KGn
	m5nD4dc4b+7O7UJG7GzoZwuWqT9OGBDZu4ulP3lZnH81/M3hzGv23864mTw==
X-Received: by 2002:a05:6870:218e:b0:46a:ce42:d731 with SMTP id
 586e51a60fabf-4a8bb7d77admr1252875fac.9.1793172679566; Wed, 28 Oct 2026
 00:31:19 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <CALXu0UcEbcHbb4F+pKG1vM5XmgTcuHiLn8Y6y_hQJAYjMdZeMg@mail.gmail.com>
 <20261027143533.180820-1-f3lix.dev@gmx.de>
In-Reply-To: <20261027143533.180820-1-f3lix.dev@gmx.de>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Wed, 28 Oct 2026 08:31:00 +0100
X-Gm-Features: AclHuK9UoVaQruvJjCET-Yt7SwQ9SDO36FxYl3cJcTyHOQZwZzOj5cWWTcS4LB0
Message-ID: <CALXu0UcCpGT5n6ou_do4bFB=g8_MzB85724DvPTR68g_RhHkgg@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.2: request mode after CLONE
To: Felix Hoffmann <f3lix.dev@gmx.de>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Tue, 27 Oct 2026 at 15:36, Felix Hoffmann <f3lix.dev@gmx.de> wrote:
>
> Hi Ced,
>
> Thanks for checking. No, I have not reported or submitted this issue to
> FreeBSD, libnfs, or any other NFS client implementation. I only submitted
> it here for the Linux NFS client.
>
> Do you think I should report it to them as well?

Yes, please. How should interoperability over work otherwise? NFSv4.1
is already a pretty fragmented mess, and interoperability is a big
issue.

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur
