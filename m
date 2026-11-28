Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.44
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795853839;
	b=PnJV17BZPwgURgVEMjaUn+txCY1xjvCek78T5QRu8caz5qGXo3lUsxHmfyIWE5lTwbGy
	 r7lBA5bNA03qyw2BjwpWqh42EWMnqUOfpq1sSsht+Ikvx9sO4H9nxdoEl0+5YnQEhy0aM
	 fnQDhgmQKckVpXGdnG4dQXc+wFmex1FVTY+FYs0lEqWyFSVOgRRvFxaeBM+GATtBkyOUl
	 96AHgFDhh90LmbfZM0g6rThw8Z4c9zO2nYjn2cem2LwNx7HrCrQ+JVpSbC+eBo4Q/FPPB
	 dp2yWHmvf7e8ENqooFVo7Ja86pZhUcmI9gCl4uDrygHYE7RAD4K/eTOBFlryxExnWkA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795853839;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:References:
	 In-Reply-To:From:Date:X-Gm-Features:Message-ID:Subject:To:
	 Content-Type:Content-Transfer-Encoding;
	bh=JUPSemrMM7a7y8Sb6uEiclgKXCr6E/9IRNtd5rKs3yQ=;
	b=dhbK8lgjnlSZOHgUM5TpP66JXh1sCmFd6pWjQzj32cycYpFGruRhlbnXaQyOiycbNc0T
	 Cqzvo4ZphOWigQcZ+y3cpz1k4qmz5dDQHKbHWpSLBR5ro4QcR25v8O5eAQMwLJdvkF1ih
	 fqaWkr9cAw6FNu+Yv2t+LAJBPhXX0VIyWfV+fpfZnc3+Lxb1la1RRgWEoA2qqdG+eDGoc
	 lny7cc5UhRFA3k7bswjj2e9At9arC3KJEcFdeEjtsx8eqgbKMIFpiMZ9pJoIrE3ry5O/N
	 z/k9IFXSzV2FVpEGsV29VwHBZlCrZ6LDF0JaPz4eMfobTZ/KKX9CH2V41p/741FCQSA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="sD21/WfR";
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.44
Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F40E606A31C
	for <linux-nfs@vger.kernel.org>; Sat, 28 Nov 2026 08:17:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0F40E606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=sD21/WfR
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-6b47c1a3c74so3149290a12.3
        for <linux-nfs@vger.kernel.org>; Sat, 28 Nov 2026 00:17:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795853837; cv=none;
        d=google.com; s=arc-20260327;
        b=GxTKNHkjBVByu7odrwofNqAjmUf1nPmmEi7qta09Ri1kVjbNRtoVF8BcbGN4t6qhZd
         sShF0ts16Tc9VZ1TkEkojiHfTKFM1Ucz+gc9lmjjWxjity0HSyBSKOFswxGL7K4LdM2F
         p8b9glAchPVVz8QK7uZhrSL6fEWMgUj0me/tZ5HWr5vCVmxN/nZGuk1mJON4ki75n7sw
         tdNrcGsUGgvuX81tbhBncSBl5x9xNo7y5Qd3nLGsn6UL5dq3YF03u6Jky9aIgsVS0Cmr
         glzwKz3kLEjMEXjd5x5BJ04O+MkxHOgoltaQ11sZ4RcECtQaGWutGnJPDvyks8emlWCz
         kzyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=JUPSemrMM7a7y8Sb6uEiclgKXCr6E/9IRNtd5rKs3yQ=;
        fh=A3pMOUK00huGibGCZBFsLekFLVbB5hHGKjUNNKwO+5E=;
        b=cXyWgNDEoRSyYHnTjbTjRVy0JPG4d0I7gVSRgVRcgS8VJhdDv98HEOxxcxfq29t8eU
         54U2ohVWPERLgJD9T3ZqBW3/UllGXFVRIY80Wg1TBGkAiHnFprvcpsHzHhMApmrur8co
         GmWSRqUdpUlqAFEWoReBsgZE/hEp6Kdg9rWvib/uOzQxf3EOD+uuF92l/H1n05xp1tLW
         esz6aE7AgJVioHb4qJQ/Viirz1rfXGAjKhCog9AkMuyoQwmdHIYyd4iqeMCFHhWE1EYs
         ElSHWGE3+Mxrg0Fick67YaGDTzgeonKBFj7RhdkgGKG6fUigoCCxHnORtY6Z72+cIuY3
         hplQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795853837; x=1796458637; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=JUPSemrMM7a7y8Sb6uEiclgKXCr6E/9IRNtd5rKs3yQ=;
        b=sD21/WfROIJwB//KOU+81rJQLzTt1cid5Jkvd9GERP9P3dMtMxoAm9HP6TrtbggV+h
         5qr92UoWsbvBYEpo/NA8l/+ZBTUX0J93EyJprJM5w0aev83ONeYRUAnTNhMOi39FJmTW
         vTB5M3IC4XLGps1nR26IlMT3605MrH+P1GfGL5M8WzbWCAdPyOl4DmoAmAhInuwz7kIE
         STrtoimYa1ZqfjurddYwcbJ/3mEsm43yyFsuhfVrJWk2N/r9zIjYFJf44Gw684WGRJa7
         YAVapqu1OiDOLq5gOhsg6Zy2TxUrtw5XrIzYOnlKnxg+glr6PjKHKuYIdCAeO8WRA/Pw
         2e4g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795853837; x=1796458637;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=JUPSemrMM7a7y8Sb6uEiclgKXCr6E/9IRNtd5rKs3yQ=;
        b=kWyCWvgSUqXoWQun1pW2NbQKYFOFAPj2uD3GcikpXyQM6kIpna/DXqux01YbK/RI0a
         lZdwoyE/zEnQBYPfzHijBpHYRNaZmfQf/pM3bLqcXBXx5l5BsWTETO4jUlKKlTYcPLuE
         PnXcXzxzu+Lk6OHbb4MC0a9NAdvrcqdWtw6q7iXBWPT1Ya83ci1s7wn4O0vBNeevP//g
         ROd8RX39LLPD/uT+r9cbf4Ta7u7bKMZJLVLHNTUYx+FpfyVFGETseAzMQq9uOObCM4H+
         iuKuKkyiQZFXPhgASVVdK+NEuNgH7ykyEmw329/opftgWqf9BNQwVGNy3sB8CJ4s4SDH
         Kraw==
X-Gm-Message-State: APuU4Z8M1X6CqWDzwt2cKHDuUW7In/XOIujwjM+xo5XVqjVXnok0dITb
	Z++X6JLE51bGAGRDnOBAqqrb8xHwOHA7O9aND3JKbF9uJokI+2TZ5gBxEPphuVudPVA5E+VpxfD
	LjkbhwXEoCYYfrBNQXBATXVNpKTdlQNcojPqG
X-Gm-Gg: AZFdTZfryRwg+zIY9zfLhI/SBEcKRUHI6mq91yenaZZzTK/1QToLdz/LPmSl/Sz1fSY
	eTRQMyBmgoxISAY+mdWQPeHu6BiHU11aAIJmH1lgQN/Pva0mHpaLd0LeErQj6NEIeQROXNB5oL4
	C7J95aL7DUGCoSpLFsfIKqyK9vclhwD/tP0Ita4Rb02i+/5p7kax+gwfg+bQjKftf3ChiIqaYyk
	enFQ4dWfD/0yEFZ3mudsBABqwquydreJgcQuEuvewCS0ecE5zBca6maB5UK7Z5jj4TtlLKPIRFX
	LTdNIhtpl+v3UXD8E1FFTRhl07H16mAKBAeKrfQPzgh+l4EOBFdXAd7xZGnrk3BpBw/Oi17ykdk
	YMJju8Lsn2Uo0e41Ja0Via0cGnnI5NgX8xWbWE+Pns3QMX3k6TNOTM90D//C+foqiEkxvpw==
X-Received: by 2002:aa7:df08:0:b0:6b7:1c:eae6 with SMTP id 4fb4d7f45d1cf-6ba37d63d91mr14541835a12.10.1795853837246;
 Sat, 28 Nov 2026 00:17:17 -0800 (PST)
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
 <6bf939ae-c29e-475c-9261-0cddfc31805a@app.fastmail.com> <CA+1jF5roNowGUBSAS-v7uC2GzZTgrLzXD_h_HLVuKOsb1qMu_A@mail.gmail.com>
 <7c0d12cb-4483-4a67-a8a5-5ae75c9f1e32@app.fastmail.com>
In-Reply-To: <7c0d12cb-4483-4a67-a8a5-5ae75c9f1e32@app.fastmail.com>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Sat, 28 Nov 2026 09:17:00 +0100
X-Gm-Features: Aa3M54rZJ23nU7KCYdbCeoJhK_POV1NUY4yrnDhLsAFZ91y9DpI6PW3TQ6dlayQ
Message-ID: <CA+1jF5rXRcOV+8iY4q0YpZY3cET3C=syTX8Jd1Sq8ygu3VTfdQ@mail.gmail.com>
Subject: Re: Which Debian version has working krb5p support in NFS server?
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 24, 2026 at 3:37=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
>
> On Tue, Nov 24, 2026, at 3:04 AM, Aur=C3=A9lien Couderc wrote:
> > On Mon, Nov 23, 2026 at 3:28=E2=80=AFPM Chuck Lever <cel@kernel.org> wr=
ote:
> >> On Mon, Nov 23, 2026, at 5:03 AM, Aur=C3=A9lien Couderc wrote:
> >> > Which Debian version has working krb5p support in NFS server? We tri=
ed
> >> > to start a test campaign with krb5p, but that project stalled in
> >> > September because neither Debian 12 or Debian 13 seem to have workin=
g
> >> > krb5p support.
> >>
> >> Have you reported this to Debian?
> >
> > Funny thing is, the Debian people suggested asking in
> > linux-nfs@vger.kernel.org, to get a list of known "safe" kernel
> > versions and "known" broken kernel versions.
>
> Nothing you've said so far indicates whether the problem is in the
> kernel or in user space (nfs-utils, libkrb5, or a configuration
> issue).
>
> krb5p is working on my Fedora systems just fine. Please pursue
> this more aggressively with Debian to rule out a distribution-
> specific problem. You can tell them that we aren't aware of
> open kernel issues with krb5p.

Let me rephrase the question into two questions:
- Is there a list of kernel versions where krb5p works
- Is there a list of specific kernel version ranges where krb5p is
known to be broken?

Aur=C3=A9lien
--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
