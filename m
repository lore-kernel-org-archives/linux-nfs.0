Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.52
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795161378;
	b=F5Vkf2DzCJO2gzfTFfcvRi6B0VtvrRXPmWB9aESEnkRaNFKEdgFql51WT+D/AuqvdTXL
	 YFArtjxVVhgD55Pf/dp2ZJqN47M8BJLuwqgEH0v6sS3fwlOmWJuRVjm+qUiAUyUmyh8Qm
	 LbRsuD0XkAGGRoGWsG7/0brzkeTZlxjeECeBKzmh/Nb7gq4bbykdL/JaKh31IsfjSy1ur
	 IsUAGekuHNJHFAqIa0BKdyfLIAZkMs6UB+olIhevheSlfh7cC1W9ngPjnlFgsGX4YRCXZ
	 cNSwZm5Qw5SW2b2TTolL7KL4ffKIikGCTZ6ZAomjux27AtC+BjGmwNRo6bAl6cWysEQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795161378;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=D6D46AsAqBpehZlFwumznPvfnW8E6n53WMjbxwAnW40=;
	b=1Ed+JZi8rjGetlQGCf6jETR5Umr1c2n3D63xuXsdFx1bbuB3CLyPbqDeqYkIjfQ4uoAU
	 sf5qoYcvrl+iBUdi0htc4ElB3Bd6SYwkDEisCTHgVfzupLiGMXSGfRldcJ5v166j+n/l0
	 2NWU1j4knm+8IfcRKnb3In3M/CWb4l2VjGS3E/T2sSLN9QjlK4owk644wbhNdl0h7w16I
	 o2oR27h28a/vuGB0sSEdVP+fXH1BythR4W/7hQEHfOiiT71kfVF81Tco1ThtnV1HTkNjq
	 xwFSA8oJNSaes5xbpTLjCQQDX5FBBPXLN+28iQW2KyL09STZY1Fi09t4Tq94TscQmGQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Ygo7u8hh;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.52
Received: from mail-ed1-f52.google.com (mail-ed1-f52.google.com [209.85.208.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3EAD606A320
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 07:56:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E3EAD606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Ygo7u8hh
Received: by mail-ed1-f52.google.com with SMTP id 4fb4d7f45d1cf-6b88bc47e23so757541a12.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 23:56:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795161376; cv=none;
        d=google.com; s=arc-20260327;
        b=DAXZhMcdZP2RJ8XtPzbqpytHwTyk+85nMNHqlmlMH7Xi+2UiEyXuf/zOnsL1fyuWHK
         xSTGnvg9L1ZH1oxQDMnLc4g3+nNVeKO7nShtVJljZJK7iGiUNIGnIFZ0ywvzCx/6nRdw
         /6A9lM4lwJZL4mELjHce4ZcgG70k4cwr9Y91yOlOxNYwcmArZ9h1R1Hg8/L1w3K27j1M
         AQiICDE2X5xcN/gYXgLnXj+6sWwlUfY0JmQF5WNZWF58v15mkCEVoG7lUohNH4d8Xcrn
         YVD4YvWAyEqtMZPTC/L2NDCv15Fhktk7cGWBXUqtwYIF0mAun9EPCxDe6Cy3IL5cYS6l
         qm7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=D6D46AsAqBpehZlFwumznPvfnW8E6n53WMjbxwAnW40=;
        fh=Q/RK3z+rHJYWshofqInodN1m3aHo+/M1YqvU1Wbl0hE=;
        b=OE6wWz7rsI4GD1W8jMD1ze09E43k/VHpSqXexWVqQEvUN4XkSJkXPse9K/qc4+bjdT
         wIf92nJdcj0Ruar9vHPqdRRrEDPu4Qn5QAdiT2zyC1XtwJsw0BnoZD/OxFw5qirhfUKe
         KXdheJy6KWmBTzDqTb/OafPIzCb2ppEMjHEJUp78cZxYCvVmn44YAxLgUmPsp+WDhFKw
         szLiInTBmxOEDzuin7/wH1/T4KbvImjHkbVNpJPAzQAnffneMS6k+dVYuCeSDCzXdEnF
         hxShvzRit8hdAFxD5KWWIKwYf9RlMBJIukNJ5Xp6DKxMjl1MZ5yIyCiQXNjnD8CL8QwW
         aP1w==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795161376; x=1795766176; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=D6D46AsAqBpehZlFwumznPvfnW8E6n53WMjbxwAnW40=;
        b=Ygo7u8hhmT8ZRlQdmS0vOD0LtKqCRvNQy8jKtH4jKR6rqYRw55nOxHH49oSqwd7310
         tqh0K6hEP33VvvjziZCuo3m8QswhaN3kPeoSMEm0e3vamqxNJYSzr1ogjhjwG8x5kgoA
         O6hNEcPAPWKodC+kQWJklTSqcn8hda7Sja3R2uUvsbTtUVBI27nqXzheiNBf38ERo3NX
         ey6XMfzoNtmgqw/zJqTMOnp03ljHQz5A4Y4uXTPodouzp1/HYxnKXzq3R0cHZrICpabx
         ixSDKTsTv3sotbbXlaJs4vwkgaS8TSHoUl8mw0inid7Y0tkejNrg13cwdskBxffkK1Jq
         GO/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795161376; x=1795766176;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=D6D46AsAqBpehZlFwumznPvfnW8E6n53WMjbxwAnW40=;
        b=FFtgSvZVEtVJpgCr6jV3yhhIaeYmFZEyMbmZuz+exvDgifA+LQcrmLWZIs9xPqeZrr
         9kVOJXiWQYhSZgvNoGJ9ml3xum7qNCxG/b4th4Fd8a0lpSGY1LJOW2C62l+fZCgGTaXh
         e+P4M033IIT9oEG+oecA+ljzeysfwEM1FX4yuBp91EtuPT/nz5aSzTTyR4/4nfl5tujK
         SV+NhhOOk2vWNHSgDA3tFjai08g+svBaO2D1XNPCk0JT/vAo4GfjeIpGkugIQcMhy3de
         lMfYkRPx/H5XvCrzc4AiqVxfA8eGxld4F8S26LLuYa9BzufEAOXlMWEg5/+jvMoEXqcS
         wx/Q==
X-Forwarded-Encrypted: i=1; AL+hErEQMcO0OYHaPa/LnBr8yUdT2SeO8nnwwgpxUQjqUFgCiFIzCzGMvM4QqQY0LfcyT3YH68w/KD/vPfQ=@vger.kernel.org
X-Gm-Message-State: APuU4Z+8nIYZkl1ZRH/duejAytHkYqRy/+6eCfZdLmFYWpZICX3Jeo95
	Yp6aZApW3bUt5cwhHSUWXm3yqe0yrS1LbvMUz1QfoQfJXF+0/42jDUfjDlasFu5gggMsbazFM2t
	ljkNGgpwgjNDQ0IJiNA7Ixe5wFFp5Hu0=
X-Gm-Gg: AZFdTZddM8fSJFxdHnxViqMe0OFTMGfk0uuExouqvKcqq5+feH5vTiCeWfrhkofzpjS
	ovJW/VeWdRD3cMMrIg+gMVrBMZFN9i8/aDOII7kzo1cK3mPWW2YWGcmqO1o54ffcCKYdOYvcxqU
	E1ZMJroGwORJDJFibymlS1THVqjWNGQqkQN/g/q+tJx1ZD3QtupwrJdPr5q3bds3gRHER56Xj1a
	4aeQwTozFFTqAMoauYxyZ+rRbfYrWko7djoW7QM+NwLOn1vsFWxVO8V5Pa87fzDnISnW3M9C+ZE
	zsK1JxfAoa2FkdiuAeVj091l5JelrkBHN/JdmMLtP8tzpa353vFVEYnizYpdj3aSN1Sj1UTo69w
	7JU58HYVnoBpQCiWXAX+cJyKLtGBa2HmggTdCuZhgiude2cW8M2xiYspsj43DC6B10P7M
X-Received: by 2002:a05:6402:c6c8:20b0:6b4:1037:2bb1 with SMTP id
 4fb4d7f45d1cf-6ba37e90658mr958557a12.22.1795161376138; Thu, 19 Nov 2026
 23:56:16 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261119-nfsd-copy-same-file-v1-1-ef18e53a00d0@kernel.org>
In-Reply-To: <20261119-nfsd-copy-same-file-v1-1-ef18e53a00d0@kernel.org>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Fri, 20 Nov 2026 08:55:00 +0100
X-Gm-Features: AclHuK8gGGskXGfFPzME8Y_v-1TiWdShNUYoz4-qwshh3EGdWiYpATvAHeQokQw
Message-ID: <CA+1jF5rurDObkiP0pg3Kp1vgB+sdxU6FYBaUUPWLJoHsoJ_6oQ@mail.gmail.com>
Subject: Re: [PATCH] NFSD: Reject a COPY whose source and destination are the
 same file
To: Jeff Layton <jlayton@kernel.org>, nfsv4@ietf.org
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 19, 2026 at 6:44=E2=80=AFPM Jeff Layton <jlayton@kernel.org> wr=
ote:
>
> RFC 7862 Section 15.2.3 says that COPY MUST fail with NFS4ERR_INVAL
> when SAVED_FH and CURRENT_FH refer to the same file, whatever the
> ranges. NFSD never checks for this. A same-file COPY with
> non-overlapping ranges succeeds, and one with overlapping ranges fails
> only because the VFS rejects it.
>
> The overlap-only rule applies to CLONE (Section 15.13.3), so leave
> nfsd4_verify_copy() alone. Instead, check in nfsd4_setup_intra_ssc(),
> after both stateids are verified. For an inter-server copy, SAVED_FH
> names a file on another server, so that path is not affected.
>
> The Linux client never sends a same-file COPY, so this does not change
> its behaviour. Found by pynfs COPY11.

Why should COPY within the same file be blocked?

For example: Windows FSCTL_OFFLOAD_READ+FSCTL_OFFLOAD_WRITE is used
exactly like that by databases like Oracle. Even advertised as a
"database accelerator" feature...

Better tix the NFSv4.2 COPY spec at RFC level then...

Aur=C3=A9lien
--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
