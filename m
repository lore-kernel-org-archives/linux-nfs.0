Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795444270;
	b=PskKrGr9p4EihO+Vn56UPB8fmtZuNwslGBZiE2FJ231gwQZWDTCnqXGJQLqTqXGFXIJx
	 xM6Nu206dbMj8VbNPrnHyIspRCx7ugdJQC7eEbUZ7rLdNjm7ApzgVK3cizmyN/3cyQpDW
	 5Djk1jB3xfynjiAc1I8zZlcFsoXMoHcHJhmLgZ4D5pobCaTohcdTi8jeVQq9+6DjBkoCt
	 hK9hMSWQHOBf5sJT8FKa1naLuCQGvvv8yYas05GFGfgjaBpvsc9zoPkJKBNqYDJ2FoVqB
	 eB63yvjyikRgQPXl7LH1E2RzsoITW1tP2a0WrN6fTCsOqTdSBcOXgVuc9zKH7/ffJnQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795444270;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=Q4jTJ4I7+4H3U2t4gGtedRgvTT6Hqn+CljxWSv/Jr1w=;
	b=UqtFsc+OwfBi7vbWkDSRmJW9dufYwgTKRnaCumTsmVBPHKFIZBln1ApC9edWGQ2neZ7z
	 q+UdUK57jOTtTkFPOFNjhy6hz88Z1csurdT8FHVnwgCjvmiU7gPTDgUW6fdulS+d/q+zC
	 vef4KDEGIY+ejMHxUAbXjJ3DqDgimDFjlM9m+qzM1heA/K37KLO1efdBkSQMhuYJLqt6c
	 KS4Z9/ae/+CN5uw2RzFrHIOD2XHgoGoJxRsO1F4Jdv6uRzmArv+g3A4DSXZG9IbL85zfD
	 lUXJ3tKMSxYFa+4LcKgz2K0CuYjy57GUkqhpeinM86HNiRmoV72om7iMECQY065S+5g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=VETaX+Oc;
	arc=none smtp.remote-ip=209.85.221.46
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCB0C606A32C
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 14:31:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BCB0C606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=VETaX+Oc
Received: by mail-wr1-f46.google.com with SMTP id ffacd0b85a97d-4a68190a2a7so2802419f8f.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 06:31:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795444268; x=1796049068; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=Q4jTJ4I7+4H3U2t4gGtedRgvTT6Hqn+CljxWSv/Jr1w=;
        b=VETaX+OczrckAdA40CS7vxCZvBrG7y727OkscWpuPH8NoqiwvNXiRk+iJHMiEnyahS
         RBfZSEAqPImQAgWzcD9CuB7TFbHgO7sTwpuUTArl1ERE2IPVFTM73x6AvLE8XuR2BQtI
         NfM/EDLchi7RpmRnIOG/fzpQ1VgdnuEYs56uKDFZJTocpt3Rphhzad1vr6ivfPvQfs7q
         zDPLeOj/0veY/zCOvit2isQTXe6V7TaBZ+m/Npv6BE32nGK/+xrI7JVkEb55IXUlhXV2
         5UmV9Fzv40OpemFZElWoQEjVt/wI5iQduzGzqM2a2l/IFqmMlSFsl3sDpjo6ExZub6aC
         DrRA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795444268; x=1796049068;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=Q4jTJ4I7+4H3U2t4gGtedRgvTT6Hqn+CljxWSv/Jr1w=;
        b=MY+zy6NsIg4/vOXqmb33WkclBBBvdNSmrXs8id5vU44w0SVEcg32qsEqEkexjA4n2B
         YLAFclKrkM1EyVFqTO/xAJSal2A99Cwh/WZfHk/4qhRv72oqQBjruz5LKhLj7QV6vUmG
         iSnixZAUaRTOGXFdgmKMdqgBUMYj3s5xawJOns9+AnnBjFXx9ABWwmAbmGKOkiAFQb8W
         O3UXPQ0EtqbNmRzFzNbEoynw+T0th0oagoJEs3e05d3e2BxRVzjH8qtq6yxyeOkhC2rN
         4csQOM7VOXoDJw3ccIquOFs2Py3T0qsZXmXsaylNvMxrmUAHHuwLGegQAyFE67NZkfHb
         KmQw==
X-Forwarded-Encrypted: i=1; AL+hErHvy+m4QRKYAsYYgyGVShgF4lbmA7Th+eVSSOjWNGxLDMsAJc+inLS5kXHjkDO9SrfHq4BdCnqvbHA=@vger.kernel.org
X-Gm-Message-State: APuU4Z/cW/43zuGPLqCJncO5PYmw6L/7MS6CIJUrmmr2BEhcWcHvH1yn
	aisUvcl60F8ZTnjb+nY4pYM8DC43piGjsNbdgOQrRq7N6wq3DnHVdHzR
X-Gm-Gg: AZFdTZebB2X2unPxLkoFoK7BAQp2LFw1Jnlj/lM1D4YBvyKPGjoBbMlHaUKbgvGgGwj
	w/Nyoqrnb0if9fvhyXPkte52JNrr7Shg3YF+eA7KiqHCxGt+usv92aFDSF9bvsd/3iKVsVulVa2
	VLgi9UIsfFzQZfh7ECQ7e/KyU6/wxnOa9+/m1X0tKPO9odxrf3HA/rG8WU1kuD3C5Vn1N5y7BH8
	k0EsATyMntLoDqJXDIlWPyYisEFWFj52YKsALJY9nOVrT+lVHZJr+/9Gx6eEegqNXxMLOsl3P2v
	wY6vAFdKUu7ykPr4u3io/FRtuxlfCtPG+xdn96x4ESrSIG4UxPZa6fu+cUFhtu52b2cfNwHbi3Y
	XG8UPWfXMcUYOie2DAQoqkQ/K/vmS551faXvJeFM9hvxaE1fApScoSvyB+wE5GVBb/+HIn7uSbX
	UeJXas9Y976KGX635DjK9j9VyhZC0JosruFZrFAf6jurg727W1wQO5WIpFH5kuDmQ1asHqwPW8W
	54uP3BzD5JQtBeF7zdv6oJf4fGSHabKBlumG8lv++ZB+UUicNPZQKrHLpVIvYfH7NwJBy34HuW3
	MYqsHd/P/pL0eYpCcanI5dyO3A==
X-Received: by 2002:a05:6000:4616:b0:491:8286:5f0e with SMTP id ffacd0b85a97d-4abb514609amr20025380f8f.55.1795444267943;
        Mon, 23 Nov 2026 06:31:07 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab6b205443sm23631206f8f.39.2026.11.23.06.31.06
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 23 Nov 2026 06:31:07 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Content-Type: multipart/signed;
 boundary=dc84db75a66914bb784f1de9596eb2f7bc5819cd207268d8e5d18dd76353;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Mon, 23 Nov 2026 15:31:05 +0100
Message-Id: <DN2NVGUNO0GA.89JAB2PVI0LA@gmail.com>
Cc: "Namjae Jeon" <linkinjeon@kernel.org>, "Hyunchul Lee"
 <hyc.lee@gmail.com>, "Alexander Viro" <viro@zeniv.linux.org.uk>, "Christian
 Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>, "Jeff
 Layton" <jlayton@kernel.org>, "Jan Kara" <jack@suse.cz>, "Darrick J . Wong"
 <djwong@kernel.org>, "Andrey Albershteyn" <aalbersh@kernel.org>,
 =?utf-8?q?Pali_Roh=C3=A1r?= <pali@kernel.org>, "Lauri Gates"
 <lauri.gates@gmail.com>, "Christoph Hellwig" <hch@infradead.org>, "Dave
 Chinner" <dgc@kernel.org>, <linux-btrfs@vger.kernel.org>,
 <linux-xfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-fsdevel@vger.kernel.org>, <ntfs@lists.linux.dev>,
 <linux-nfs@vger.kernel.org>, <linux-api@vger.kernel.org>
Subject: Re: [PATCH 3/3] ntfs: switch to the new xflags fileattr API
From: "koraynilay" <koray.fra@gmail.com>
To: "Amir Goldstein" <amir73il@gmail.com>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261122000856.536902-1-koray.fra@gmail.com>
 <20261122000856.536902-4-koray.fra@gmail.com>
 <CAOQ4uxgc6pP+_xvJMbqj6wOdGzS75Vn6x6i_vUfCJDD46DAA_Q@mail.gmail.com>
 <DN2N0BY83OY2.1OV3ZAZFSWCDG@gmail.com>
 <CAOQ4uxg9O-R_SUPAZ75ESGB99-4Z4EEUKGMkCF2f-sXkGPq1GA@mail.gmail.com>
In-Reply-To: <CAOQ4uxg9O-R_SUPAZ75ESGB99-4Z4EEUKGMkCF2f-sXkGPq1GA@mail.gmail.com>

--dc84db75a66914bb784f1de9596eb2f7bc5819cd207268d8e5d18dd76353
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Mon Nov 23, 2026 at 3:14 PM CET, Amir Goldstein wrote:
> On Mon, Nov 23, 2026 at 2:50=E2=80=AFPM koraynilay <koray.fra@gmail.com> =
wrote:
>>
>> On Mon Nov 23, 2026 at 2:00 PM CET, Amir Goldstein wrote:
>> > On Sun, Nov 22, 2026 at 1:09=E2=80=AFAM koraynilay <koray.fra@gmail.co=
m> wrote:
>> >>
[...]
>> > Rule:
>> >
>> > You cannot add a flag to common without carefully auditing all
>> > filesystems that support the legacy flag.
>>
>> Yeah, sashiko pointed out a problem in f2fs, and I could reproduce it in
>> testing, where adding COMPR to COMMON makes f2fs crash, it also needs
>> NOCOMP in COMMON.
>>
>
> I don't think this is correct, or at least not enough.
> My agent said that this breaks or changes things on  f2fs/ext4/ubifs
> I didn't bother to check if all of them are true - I doubt it
> bottom line - need careful audit and good testing.

Yes, definitely.

>
>> > FS_XFLAG_ENCRYPT can go into common but must also
>> > go to FS_XFLAG_RDONLY_MASK because it's read-only for
>> > all existing fs.
>> >
>> > COMPR is rw for some fs and ro for others.
>> > As with CASEFOLD, you cannot make it COMMON before
>> > converting all casefold fs to new API so that each can say
>> > whether it wants RO or RW.
>>
>> How's CASEFOLD currently handled? in the v2 I'm drafting, I added
>> fileattr_mask_to_legacy() and fileattr_legacy_to_mask(), which convert
>> between the old format (filtering by FS_XFLAGS_MASK) and the new mask
>> format.
>>
>
> Good question.
> Need to check this.

Can you do that? If not, I'll check tonight, no problem.

>> > I think there may be a way to deal with this easily since
>> > ntfs doesn't need to set either but not sure.
>>
>> We could export the 2 other helpers I added for v2 (xflags_to_flags and
>> flags_to_xflags) and make NTFS use them?
>> Though adding the fileattr_ prefix will make the current (v2) vfs code
>> maybe too verbose.
>>
>
> Honestly, I can't say for sure - you can try
>
> I think you may need a different set of helpers fileattr_prep_ used by th=
e
> filesystsems that are converted to xflags_mask, which may be different fr=
om
> the set of helpers used by the user facing ioctls but I'm not sure.
>

I guess I'll think about it when I move NTFS's impl to the updated vfs
code.

> The thing is - this is all hard to wrap our heads around
Yes.
> You and I have parts of the design in our heads w.r.t backward
> compat with legacy API, both UAPI and vfs internal api.
>
> I think you should put it in writing to see that you and I have
> not left anything out because this v1 surely does get it wrong
> in several places both wrt legacy UAPI breakage and internal
> API correctness.

I agree, now the version in my head is not finalized yet, so I'll do
that in the v2 patch/cover letter.

TLDR is "use the legacy to/from mask converters whenever needed, so:
- user legacy -> fs legacy: keep as the old code did
- user legacy -> fs mask: fileattr_legacy_to_mask()
- user mask -> fs legacy: fileattr_mask_to_legacy()
- user mask -> fs mask: pass it through

(before finalizing the GET path I want to finish the SET path).

Thanks,
koraynilay

> Thanks,
> Amir.

--dc84db75a66914bb784f1de9596eb2f7bc5819cd207268d8e5d18dd76353
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQSgVimKafU5DQMcjcDmj22qf5IGXAUCawROKQAKCRDmj22qf5IG
XIluAQCkRERpwhiWlAG1vnH4LLTLbZOFc6HLeE1vttoO1MkJnAEAs/LzOmQQYKAR
R7lCcHjWSuolpqeVgvCGo0f1qKCRTw0=
=50n4
-----END PGP SIGNATURE-----

--dc84db75a66914bb784f1de9596eb2f7bc5819cd207268d8e5d18dd76353--
