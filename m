Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.52
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795440928;
	b=E97B0QvYmXyen0KDhLoCDIw/g56kuL8cRTZGRXqvdbSrFqg50qWDdfTHGWn2arOypwJ1
	 RUx8ToBqR/3YLpv3eQNnEwyKP985UoZNqd5qjvlSnZyAGNmrtBlhUNf7nKxIH/H2HdTKg
	 7OGWNMDIiqihGGDIpMxBa50hP4539FZuYOl6zGcRkrM+uUOuRTzzhW6+IYm9odeFuOJgo
	 xeXXiLqfG/lWKZJxKKvK7s2oRj4Ji9dg4Z0bNHiFwgD0nty1c/1fPaLQt2xJlGxtiNCdA
	 S8Kx0PjSmj0WFTBO2Zjh8zvhlmA47B1DyUpK5yuV9hYJPyVzCxvs+W087T5qyN43TzQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795440928;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=wA48BtGM3vO5100Jfaf4088EYVNimRYHtUBWITFpY8A=;
	b=NlA48e9o8pKSrI79fKuPn9h/zb7tGn6iuui78CcjcDZDuhfUqc4nkRTg5Wewq5ZP7IjI
	 L3V1t8ZkAcyX66aQ+i/T09ROJpPUVvwCeJsncrdUlIWpjq3vUfjbhwD90mvhR2xH88tZr
	 KELSNvoiL+AD/E8hT2AC85+hkyprToEFNSqaG2vjaStUG7feCpDwSmjokjOuYRsKS+sCn
	 Qfmj3aAA7yeSyN/z95yq/6mSPgjp9DFTeoHtqmZiXcIPD0Lab4pzyulK3ZBjuCU6fEcKV
	 G9xDSqUTQTJI8YtNtxOv6gkb/X75N90/PSW4V8Y47q804FPh/5eoNkzfpRp2zFFIRZg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=CUalyFmo;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.52
Received: from mail-ed1-f52.google.com (mail-ed1-f52.google.com [209.85.208.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 37218606A31E
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 13:35:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 37218606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=CUalyFmo
Received: by mail-ed1-f52.google.com with SMTP id 4fb4d7f45d1cf-6b8786bb305so4002412a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 05:35:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795440927; cv=none;
        d=google.com; s=arc-20260327;
        b=Z6WRsZTi94z9POa5CaE2qNfm7r2vYT0fM8vpBTUYy3QQBeZ6QwiGGwCmT1xw46ilt4
         OTGDM2oXNQr8XyGKHCHDwaegU/+9FYY0HwpDFqjC3+RZNwiJ5fgZSNBiOY87iV54Fv3M
         GWEkNzYhBiZfK0KPTthUWmF/3yCZHapF6l0Es56aIexLsv+e75Xq29s/vfto7plEgD9C
         nVG4RklrRFWm/6VVZngIY025557t634xVYcTy3u9L+FgD17B8IwLUJRWbTebVZbGGq8A
         avK8J/S67r/3KZ3UmImVPxWuVtCwW6k3idr3n6LBqQ3BA8qYmROZMCYfJIHpM66mpnji
         Ki0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=wA48BtGM3vO5100Jfaf4088EYVNimRYHtUBWITFpY8A=;
        fh=zKF5+XdM6lMODlP6Y11TvvgdsyTy+66wDpdnBGW/dpw=;
        b=a22gNikiVw8LWd1pAKBmhsar3YV862SzvfDOThsGNwNElInvjvqzwf+qBgr+RGUpn4
         HUyGESkxU99DM1XCTQOfIxdHO6V+kgWNsNB5wSE2A2zBcXyPFXDVkCkE0+I9isjqduOd
         eNRBjfGt9xBrYQ4eURUpy98IraKzF3h0PocxPHxwrrNH77aNSDW2vqQAODz4IKoEgsOM
         TwNqnLSVKNoWNDPSEFIfounO3YsS1B3pFub4GmMkekGwznsr1PZieehuP9kttxzCdezC
         ifFxDByt+OZn16ZxqLadKZlXgRxlF0iYzcjvxkzluhpyV0dLKyV05STqschTmN5rTj10
         6brg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795440927; x=1796045727; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=wA48BtGM3vO5100Jfaf4088EYVNimRYHtUBWITFpY8A=;
        b=CUalyFmoReb/83xqvr2Uap9kVXJPiulZAZ9BuYFqHt3BZvwosq+NJSvwCx7EXaJ61q
         0UImgM/pK6aJnaecMJUvuPZ2cI7g4pQe50qM9Pea8hpjQVdlAcsrhBAjR5pkLoL6krP6
         nRENxUXoYZaxAwVNugh+MZ7YZxx2ccbHZqMsfjTLAWxmMDno9W5bQVXg6ZykzS6zofee
         MuNz4LKoADJSq/Wy8NqZgyRU3Eg71INdz3RDm6YrbcXLD3QD36tPN1Wy8wpv41odHg+C
         B4L+HLWFbiG+tetJRVhqx1bMgUVGiUgvZsZjbnHTLfWPYdIp22KPI7gyBEnpYFSEFiNv
         Y33w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795440927; x=1796045727;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=wA48BtGM3vO5100Jfaf4088EYVNimRYHtUBWITFpY8A=;
        b=cFKt/4tLcYBha5N3RkwhHVgDVBLHD5T46wgN5YoJs5tmfSnIxJulhjAsgQqjcag2SA
         XWAWAJFEJub1xirRjrrIBUfZWdmQQQDj+hu9RnWBhet3rzCA+GzUusGJ1Bn+PCYCfwTq
         vGZErzn2qt2dGIFJ2vzFKONvmJm7gRNJDIy7aNMZrVVKb50Ur+t3aOiYnpDby+WahVeL
         qhAjuGvBUMGsr6NbuvRi0tBcgHl5CE515tnh/riocshhQSLnTWwvDL5WnApg0mPIQWCD
         rOhiOOZ4S4edD5t4oXOU+wsJFlLNEfQzZm3ZB1W+TVlUWJELO/dm5bsBksRX+r2mwD54
         JDkA==
X-Forwarded-Encrypted: i=1; AL+hErE17aD11vXjOI2UF7HyV8npMhZupR4zYgrqhnr+HR0YWETvLO4kw83SrF2EeYxTEB2m0z9h86Xxy1A=@vger.kernel.org
X-Gm-Message-State: APuU4Z8NtKYyf0QN+UMxhZ6+WHUvt3HgkHOHIO3htH8eisYTqT9sdQr2
	YJtpU1pteOg9fSoo/OVw/xW8LXL5QJLpWwIUAEDsNsRsPJPji4zF4xpveKfr/ZXHdQTzImWDRXm
	OhV4S6+Kdjw4AsW1tz+BKW+38SKf9hrM=
X-Gm-Gg: AZFdTZddxl/4EUdFeV/vGvYIrO7Is/LpxI+SLk5L7yFO5D+NDNluMbO2+eZ4EkL0V5f
	rAIXo2sF1JSF9hE8UNbhrxMt6dSuozkEStpIgy7zSxZxBiMVYgd+5QYWfx3omXHdUNea/Krll+3
	ZYfyoNaWrfkPS7T2ZdnVhLQklF23bMMammgOz7IXf/GePxU5fJX1i8mA11JHcncsBxaUDFYoVCv
	5AXel/o/R3ka/VIFVVItUTzsairZDtHt1RdM1xMfj3ObFNBW3gaYo9kF/4spzVOx1bX/mWFi5wg
	jdt3WSFy9k4FhJ7CZ9me8/fLyn5oWUCLyJGVq77Z5peITsU2aQMBkhlYB3s1CjA6EWpFPWfqG6U
	bg/oQiyTg1AvDCf0Kb3W444y4XhNTgxUTu/ldWKJ1ozic7Rp7QUTJvOSxb2Py5Zu1Vvk2YA==
X-Received: by 2002:a05:6402:1ed4:b0:6ba:7e42:d88b with SMTP id
 4fb4d7f45d1cf-6ba7e42da5dmr4190054a12.12.1795440926543; Mon, 23 Nov 2026
 05:35:26 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261122000856.536902-1-koray.fra@gmail.com>
In-Reply-To: <20261122000856.536902-1-koray.fra@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 23 Nov 2026 14:35:15 +0100
X-Gm-Features: Aa3M54oltothA2ZyBgLZ2dfkBmCeGTagh_PAD6Wp2_FkqMP-qy6jOW6gmvjqNlE
Message-ID: <CAOQ4uxgf2KE=Ag13EPAu5=KnrFwt7zRH=im-qmLc8+i10Tjd+Q@mail.gmail.com>
Subject: Re: [PATCH 0/3] Add f*_xflags_{rw,ro}_mask flags to the fileattr API
To: koraynilay <koray.fra@gmail.com>
Cc: Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Jan Kara <jack@suse.cz>, 
	"Darrick J . Wong" <djwong@kernel.org>, Andrey Albershteyn <aalbersh@kernel.org>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	Lauri Gates <lauri.gates@gmail.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <dgc@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	ntfs@lists.linux.dev, linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Nov 22, 2026 at 1:09=E2=80=AFAM koraynilay <koray.fra@gmail.com> wr=
ote:
>
> This is a follow up patch series stemmed from [1] and [2], splitting the
> _mask change for the fileattr API into its own separate patch.
>
> The first patch is a preparatory patch so that the code in the patch
> after can be formatted better.
>
> The second patch is the actual implementation, which introduces:
> - fa_xflags_{rw,ro}_mask fields to struct file_attr
> - fsx_xflags_{rw,ro}_mask fields and has_masks selector to struct file_ka=
ttr
>
> These masks have the following semantics:
> - rw_mask:
>   * for filesystems: advertise which xflags they support changing
>   * for userspace: specify which xflags it wants to modify
> - ro_mask:
>   * for filesystems: advertise which xflags they support only reading
>   * for userspace: ignored

Nice!
I think this API description is very clear and coherent

>
> (ro_mask for userspace was also proposed as a "verification mask"[3] but
> I left out that semantic to keep this patch series more contained, and
> can be added later if needed.)

Not so easily added later.
We cannot change the meaning from ignore to verify without any opt-in
later, but we could use the combination of
rw_mask |=3D X
ro_mask |=3D X

to "verify" (set it as long as it is already set)
all we need to do now is make sure that the API returns -EINVAL
for rw_mask & ro_mask on set.

>
> This allows userspace to not have to do a RMW cycle when using the
> file_[gs]etattr() syscalls, avoiding possible race conditions and
> simplifying their usage.
>
> Patch 2/3 also introduces the missing FS_XFLAG_PROJID flag so that
> programs like chattr can leverage the new mask API.
> FS_XFLAG_PROJID is kept out of the legacy FS_XFLAG_MASK and so it's
> defined as part of a new FS_FILE_ATTR_XFLAGS_MASK group of xflags that
> will be used moving forward for any new xflag (like the one proposed in [=
2]).
>
> Patch 3/3 converts fs/ntfs to this new API, to show how it can benefit
> filesystem drivers too.
>
> The series has been tested across NTFS, ext4 (with project quotas), XFS
> (project quotas and extent size hints), and Btrfs.
>

Judging from the number of bugs reported by Sashiko and by my agent
on the COMMON flags change,
I think this needs test coverage for the old APIs, especially with old bina=
ries
chattt/xfs_io that do the get/set cycle and re-built binaries with new head=
ers
both tested against old and new kernel.
Sorry, but the UAPI issues are fragile...

This is one of the changes that would have been very hard to audit without
the LLM agents. Hopefully with the agents it is doable, but need to guide
them how to review/test for regressions.

Thanks,
Amir.
