Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.43
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795190318;
	b=lmhq4CYTpZYptgjI6DjOEpGfrDS95SPM4Bx5sSQGAOpef6IB2oKPowKcQ4yDj03/pU1V
	 4XmuczKlDjLmNhwt0I9cqixHiQurUKf8UCo+tveE5LGuLli70FfV+ronUohynqqrXUqot
	 IMljHQg1G92P3y8PDvw4p9j53OrbiWTk+TTd731PSNDtGzbyvcklcuwrqnYdbvdyrx2ZE
	 xuUlLQ7tyb4jUEqsMqouwc9JvOTq5K0UdSF/Fpyml6g/beqAGEoHkiMB311GH0lAq7dXf
	 it4BPI8zwtn0XRZakJjqAGyaUt1zG6MvZEZgQW8VdzcWdJBCSOa8Z/n7nOAnL72pJOg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795190318;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=6kM0KOtHeHKXYurgzFZtJQepqztK7z7Hv0tSSDFAXAE=;
	b=nXqScdwKB/9W/yWKxFej7bQUaVZDwsCE471eCp7Vx2IhN66dB3lS11aG30aF6dznBHag
	 ZPWpWVu6WEAc/ZkTGkmXjf9tmJL40F7fueEwysbk4MifS9IUUAB+KL0wBPnoA1sOa3ZGl
	 VskS1fygf0u8xahh1x8Y4fLYZjoNuEAcolnGH3IHaUmg5x8WMWPGBfBGfTlxxayIetIbg
	 nm/Sfs2x32+6AC8b5QehNAoyIdWbjPVwLe+WYZW098AFy69tUzZBJAtdLWCHboJVOUYhi
	 vnDfGaoGtxHXtjcFcf82oz6ZvQxhF+tchFcYMXXSY1Kyy2TKiFvE9oGrrOM2po5uNmA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=eTc+eMp4;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.43
Received: from mail-ed1-f43.google.com (mail-ed1-f43.google.com [209.85.208.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B2B4E60A2611
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 15:58:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B2B4E60A2611
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=eTc+eMp4
Received: by mail-ed1-f43.google.com with SMTP id 4fb4d7f45d1cf-6ba38c41804so1125107a12.3
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 07:58:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795190316; cv=none;
        d=google.com; s=arc-20260327;
        b=mzxtgD4SYiuJFYwb5cGPKRqKu9sKWfUgSUadKCegMyblPGjp7/RPLb8V0zESLqdqY2
         dYqdumvZVs7l+dBjjORwCD+obINB2eBG7cftDrl5OiO9wC1mbE1xcno9wff3W4YOyXRO
         gLG9DTH4XuPhuwkB18bgX0/lCTzKWsJW+KQEf1tmr55CjMqeIj5GGHauxKvJQmgVLr5o
         CY55uChi1AaXN4tRzVhpIm0+j3gfET7PpxbODP27HA5vfWAWdTHSsk0mk4M5umWRsK0b
         0dOPy5cfiRC6LsaRhCMDfmr+MeY8HKG9TkJRLBLjJpoBR0fJN8k/d7IHU1yfEWcO/nZ7
         ClgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=6kM0KOtHeHKXYurgzFZtJQepqztK7z7Hv0tSSDFAXAE=;
        fh=73vGdWSf1v88RJwFr/Lryf7qFhVDz1SyDXTQglAt1EU=;
        b=TH41C0AJihgYjXnd2ZEnANVN85MZ+OoVO5+d4S1aRtmPpNr+zxFstYT2vPVjvsxVkG
         RlDO0hg+ED5qiS3w3vm3z9ZCXzzrTiachWPwxnxTzl0FL/PqhBKQGygZZOdA2PwJXIoG
         iUQ+Bcf+Q7skQYkozA5UCoz4NGIYlrjk/fVOMQ6VWSZdlZVR20IzTiRbF6bIMNiGmtcP
         Flf0iyY/Ihd3JPrLVYSyI7q4fhGs2L/lVAtN2QPb4UgbLWrWEy/IN9jeB/1RUFa3AIxk
         kPWY4P4307aQVKppDJYigVb2t/tc/FBwqCz7eCTiuFuVlzubbCNcBMgooX7OhtzVj+tX
         4EzA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795190316; x=1795795116; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=6kM0KOtHeHKXYurgzFZtJQepqztK7z7Hv0tSSDFAXAE=;
        b=eTc+eMp4bITMI7jgx5jM4l7NyEFh1c9lTC1VxvFXF9G+vcYBoZB53yLQdKfrQOpf6F
         Mtz8FTmSSTw6Ei7un/2M30yiLReetEhAe/lO4dm/xLE7CcivvqjbhlK/KCKhN5ARxijZ
         ChezPcoSYPSGA4dYvVLO7Yd9kb7uDyVuUiuKTqgzbCAKx1XbYJKzxg+Mx7ccVg34Vcwt
         Sq2087h5YZQNFE89KJ0Ys4A0dIfGzwnygs4zE++uxupxXjpFy9vZB08cycp+xBcweq9+
         96UTqALXMzvyeJr5t/bjHIhkmiHd4xvEUtcz6apgxXUf6gRVWrykVKb8LpEbPe+pU8hS
         b+2g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795190316; x=1795795116;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=6kM0KOtHeHKXYurgzFZtJQepqztK7z7Hv0tSSDFAXAE=;
        b=kp/6+EUI9ZYTBNNTY/pBbEXa1nIx0hRQhmW+8nhYmzXELGeeIHqvDwuIqnOZCHnSKy
         ehsXMBCn/az74fr7Lbj7fps1mztc0I7i6ifGbnVtC2D7n8S6QwVlTmnI/bqsbGXhTyg0
         Qx2d9GI7oPZrtmq7k2/+15GkIj5/lqWH+u2+2t+C23FBUHsrQ8/cMWWz4mk5plTwIBk7
         urn2mpoiCLGEhqsj6qKMu5RtATzt5S0bsl170jNfm8i2E4kO5sG1cs47C/pa59Mp7MAy
         s0VOXVnzmVwKs7+cdAtf9cZ5W+KgYkzeXV+ZSY6S43wqQlaKlixjfwC4z5UlIb63jaTx
         ja9Q==
X-Forwarded-Encrypted: i=1; AL+hErH6tA448zvkYSBtIZ1hii7XJVJn9E6J4wN4ra+f2krB77LrCZ777rlpcZ1rFQzby+AmkL3gxHmATHc=@vger.kernel.org
X-Gm-Message-State: APuU4Z/2/fl/0bJ2kWJt2zjdu8wWhgJCBbBjjhiI2ZvlSArKsipioIki
	dixS7CYeOcyWezRLVHcGCKz1SwEiOj80ozWWESL1Swgur0uIquT8B4H/LfQs8XWgNBrjZWQmWsT
	PIPaBB7Ho3tF5W6NDhfpp8kdsJSJbMs4=
X-Gm-Gg: AZFdTZd+8fqkMK4KeBzOTIFEOHXkwn/yHmgMMuNTzcedPN0IbJwjW4lcqySOvh5Q3M3
	mwMWcAmWxYIrdC5Rjw6LRXt8TLUkKEn76C1BxYNXEXtp3Xo/R0gfKrgf+YrE911VPczOgbKIDVt
	F/O5F/7Te0Pf3N9ZW5c8U+VViwBUgDXsJXqMrfALS/mktYsSIq6HrqWh2VTV6u0cqbVCK4uj+m/
	ZKpnAARUNmMZ4e0SiH9om9numnqInfMxr1y0l2WvtKQup7bzgsMTlqnqKCoKBJBxYEv0t38+d8f
	ZouV1t2XbWrKKHy4dAcAq0EY3r9GCJ4ZYnl5qIcYQm5FqfjXRG59E82DIk8coIb4NMdO7NnKDDJ
	d7rh18z4ChM3Jm6LM+i2s73Jj5zhZ3FoE+SSpCpgcdaiPKG7/o6LbjMT72mLqjDmXrlJlwg==
X-Received: by 2002:a05:6402:52c8:b0:6b8:5aba:6c06 with SMTP id
 4fb4d7f45d1cf-6ba37d652f3mr2090064a12.14.1795190315774; Fri, 20 Nov 2026
 07:58:35 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <20261115180343.576773-4-koray.fra@gmail.com>
In-Reply-To: <20261115180343.576773-4-koray.fra@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 20 Nov 2026 16:58:24 +0100
X-Gm-Features: Aa3M54pideZA7GJITw5PojgxjktVU6GBxKullq4dSyaJ0XYgg1VLGv1zO6-iMnU
Message-ID: <CAOQ4uxjdEiuJMQxtSL8XrPYHSamtfMh+BM8kS1wj_PVME4JynQ@mail.gmail.com>
Subject: Re: [RFC PATCH v4 03/10] ntfs3: make crtime user-settable using ptime
To: koraynilay <koray.fra@gmail.com>
Cc: David Sterba <dsterba@suse.com>, Namjae Jeon <linkinjeon@kernel.org>, 
	Sungjong Seo <sj1557.seo@samsung.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>, 
	Paulo Alcantara <pc@manguebit.org>, Chris Mason <mason@kernel.org>, Yuezhang Mo <yuezhang.mo@sony.com>, 
	Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Ronnie Sahlberg <ronniesahlberg@gmail.com>, Shyam Prasad N <sprasad@microsoft.com>, 
	Bharath SM <bharathsm@microsoft.com>, Sergey Senozhatsky <senozhatsky@chromium.org>, 
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>, "Darrick J . Wong" <djwong@kernel.org>, 
	Sean Smith <defendthedisabled@gmail.com>, Andrey Albershteyn <aalbersh@kernel.org>, 
	Pedro Falcato <pfalcato@suse.de>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, exfat@lists.linux.dev, ntfs3@lists.linux.dev, 
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Nov 15, 2026 at 7:04=E2=80=AFPM koraynilay <koray.fra@gmail.com> wr=
ote:
>
> Since NTFS supports user-settable file creation timestamps, map
> provenance time (ptime) to NTFS file creation time (crtime) by using the
> newly introduced ptime API (in commit "vfs: add provenance time
> (ptime)").
>
> To do this, update ntfs_fileattr_[gs]et(), ntfs_getattr() and make it
> persist to disk in ni_write_inode().
>
> The timestamp is now retrievable by using file_getattr() or statx(), and
> is settable by using file_setattr() with the FS_XFLAG_PTIME flag.
>
> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.4.7
> Signed-off-by: koraynilay <koray.fra@gmail.com>
> ---
>  fs/ntfs3/file.c    | 20 ++++++++++++++++++--
>  fs/ntfs3/frecord.c |  8 +++++++-
>  2 files changed, 25 insertions(+), 3 deletions(-)

Please don't change the unmaintained ntfs3 driver.

If you want to include an ntfs patch work on the new fs/ntfs driver.

Thanks,
Amir.
