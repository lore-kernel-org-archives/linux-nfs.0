Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795686456;
	b=iUkuD+3WtDpn1q33PliQMTvyRfDslyaW71gihuN/0Ab9R/U4AGRDeeSdTymjUvQEoeOu
	 Sbp7akB/KILrKFwGPSqq6xBGxnuLuRk92xagJ1TX/H4Ivo1loGclZfwHBg+cwBFbmAYmM
	 CEUvSI/VH6D9odCOTW6HmKa2L+KhVAmIkX9snLYO2CkonU+SO17v3SSliSkPrYsMYZcf6
	 flULZDIv7dS70NK6K93xYYRG4t8WjRwZfQm8uruBOk1kjMdGvc8mrtuuoB5c+73vi/UPh
	 WCjcDe+AiBwFoti3ZSIjLNVk2VUk/+tF5aYFLftBiAS2QTYJMGZx/9Cq5eEuKyy327A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795686456;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=vftivs/ZcwAXfWGGaHfjRVFbQTh5u76KaVfGvH0yVJc=;
	b=36H5RmRLgpGPwlHunmooGB1J6rkhGAs0b83Uze4F5K4/Ic+uag+O84CY/X65tk2MdEJW
	 gspfB7xRMgxoOZSK75CGrbWfG5HJX7wYO9qMw4bz7LCgrAgt6feDG1HGgkze0ktS2wGDL
	 oFCeO6SSmoh8FokZQR1YhohcFt0Ig3I6BnVsYp3ZCZn4g+taEbsK0HM09yPHnFX+0/l+a
	 zTKFQC/X8MoI6JRf1olujMjOYQCf+rGQPFh2/TDIrpwlFfkjIK9c6hrpWb1tQ7sjvfJb5
	 SQnhCjVdjp0hOSQb5GS1W4YyazbCWh6+4MX/Zc6KHvUtJJi7hlyJ6P/k8x4Q88GO6nQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="a/5cpDpb";
	arc=none smtp.remote-ip=209.85.221.49
Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com [209.85.221.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7DD44606A334
	for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2026 09:47:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7DD44606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=a/5cpDpb
Received: by mail-wr1-f49.google.com with SMTP id ffacd0b85a97d-48e09aa5264so3943252f8f.2
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2026 01:47:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795686455; x=1796291255; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=vftivs/ZcwAXfWGGaHfjRVFbQTh5u76KaVfGvH0yVJc=;
        b=a/5cpDpb4UOZipYKNI+uIXwTGnwMpDyDDiuIOac83Ij/fGM7n1D1hX3JwUZLHTV7rr
         tHqOdlSSrhKY8JV8uudY2iqFf9L6VT7cdHMgFu9+GR/JdDvvVXbNr0TXOFq+lJOZ6/QW
         VuWSGZIKw8x+7SZfh34i8wJ5HafX2i5rtrNkiYURX0JT+Lr0KmbdhM//KPdfbRLIF/TV
         V4HbKu5TjPb4L4qhSwOpVRJVDLPXz831BjgUBEd8RGK5gw3+zSbqLtXJ3pN7WcryOOg+
         QAm9ty+qn0FkD3euxIMOpvh/2oLe71LJgexEnm0EDqIbCkPI/hBfL1V4dDs82F+O9jiN
         +WJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795686455; x=1796291255;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=vftivs/ZcwAXfWGGaHfjRVFbQTh5u76KaVfGvH0yVJc=;
        b=Q997CHFGZ7Qs2nbR9B65Ec1s/OOBWcX+pEp38ZGbzchH4TW4zGuWOgw8QJjg0jtqBW
         RHePZH2yrYFNj2525i35ygqF+8ghZ2iXGAe+AbPw38KAuw2rDcd5zCewarUMOO7tan/F
         XE/1qwhq0F88GakrQlrnTn4N/wZUvcIiro8caA4tzn1Eq+EeGvqGndrUZdAZYJwyk51M
         rFF0nTuiLtUlGEPG9Svu0HoJ4j3sHRM9gLbUJo63pOLZrfPusWB5925lXPotvbYtBwNf
         NSbEOIsYM5bCeanwr46jrxSjXmT+6R4qpQzJwyvWhQSNPOCYZOkr20Yy6Ni+3Do0BYwL
         DmEw==
X-Forwarded-Encrypted: i=1; AL+hErETbdGR4qihJM8Qr7PsxKxkmtXP5DDA/J20iSU3OpJ37CHii7rI8/eNQMrs+V+qtWcxGzfgC9cDPyQ=@vger.kernel.org
X-Gm-Message-State: APuU4Z+6MBdvGjseNWK+T00YNpQ8fIsHe4AY3TGKsH+9qlZPyAdHHjnO
	xLCJgQhhXdTg9HdeaBP9YzQ9OW04f6jZtWgV5aowDfVQvLRenhY6fidt
X-Gm-Gg: AZFdTZcbREJo2rToYPfB7VtQKeTITqOSzSHv/JY/Y5eMSfB2ryJF+MbxYtypk8468xF
	ZZOsp82MUZ8NKQYN68NCQko+pF/F/bkLg1BY7LUbKtNTYrIQbYyoFF/kmZQttIEghbf6c4csqs8
	6kZEAcFH5LrHMtncdFpZmRRrwfZlA8q0IiY9KAmtpg2QYtnu9aL0D1o6M+GCgOcsfwVs5E57EdE
	BtOLWVE+a2sdDfxNyAm7SWtI0zemh0vOxPptxinqFmmfT1ElgyQ/b6CrqRN+JbcNECgwJcImo3E
	2cOtH4KL6LZZf0MjmGSMQsp8OHD1jgxjKn1nE8E8CcyXEciSFQgSaALZTlhCxky6g5faM07NmGH
	6uNkGug67pBgYEOfVV8WQvgCEC2EZ16ZZsd1iVlffMFhmxKnEnb9KYSBioYSfiqa6ByafvRMA+S
	FWr0qdVSlJtqFSphy5oA6U7y1h6WjCeH7jDHFqfX3QrllKN7eobeFe0rodrbJ6RFuRxslohAWsj
	xK7Hm0fmjeyZ5HX0g9vMOW/M5yFsLi3hKCo/utG/XDOZa0C1vnrCEcgH5hsZ15CENXfgKnB1aTB
	kDML5/SkQdCIUOscGK6LCi0APm9V+MLmQar7GvRFjToyPW+a8mzZ0w73JvE1Wig=
X-Received: by 2002:a05:6000:200e:b0:4aa:76ce:4b9f with SMTP id ffacd0b85a97d-4abb6746af3mr40052013f8f.56.1795686454572;
        Thu, 26 Nov 2026 01:47:34 -0800 (PST)
Received: from localhost (mob-176-246-236-25.net.vodafone.it. [176.246.236.25])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab6a67f281sm37241600f8f.22.2026.11.26.01.47.30
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 26 Nov 2026 01:47:33 -0800 (PST)
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
 boundary=79d3767db7994af79d385e900d46b036c798a71ba18599848e4679aadf0e;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Thu, 26 Nov 2026 10:47:26 +0100
Message-Id: <DN51PX8IPQRE.120Q2U9RLZZ7B@gmail.com>
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
Subject: Re: [PATCH 2/3] vfs: add xflags mask to fileattr API
From: "koraynilay" <koray.fra@gmail.com>
To: "Amir Goldstein" <amir73il@gmail.com>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261122000856.536902-1-koray.fra@gmail.com>
 <20261122000856.536902-3-koray.fra@gmail.com>
 <CAOQ4uxhegn1z=41_MHL1Zu2hXuPtzNhC=x4gd371oaeJE4-weQ@mail.gmail.com>
 <DN2N6A68PBO1.2QT8ZOARF4I6L@gmail.com>
 <CAOQ4uxhDQqEQ3T9NveBFpUmSU032BxrNV5D+_zHj8u9LOQY+qg@mail.gmail.com>
 <DN4DRUYPHYMP.20U4DYV5VBN7P@gmail.com>
 <CAOQ4uxg0g+XkPb3-kQS5ez1-rp7Q=BkYDHW0CGOFhpbcf70yMg@mail.gmail.com>
 <DN4KLSM2OO0K.2C8Q5CPFBVNL6@gmail.com>
 <CAOQ4uxhpJygZH-arLFSUYEEfqFG96Sr3_6CWakfSkdWxEsOxMg@mail.gmail.com>
 <DN50PH7HHSWZ.3H4T25JFPQECY@gmail.com>
 <CAOQ4uxgJTSspRJqRFaSJxKUShVULaJpMv8UhBFR-DV2kUe1sXw@mail.gmail.com>
In-Reply-To: <CAOQ4uxgJTSspRJqRFaSJxKUShVULaJpMv8UhBFR-DV2kUe1sXw@mail.gmail.com>

--79d3767db7994af79d385e900d46b036c798a71ba18599848e4679aadf0e
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Thu Nov 26, 2026 at 10:23 AM CET, Amir Goldstein wrote:
> On Thu, Nov 26, 2026 at 9:59=E2=80=AFAM koraynilay <koray.fra@gmail.com> =
wrote:
>>
> ...
>> >> > Attributes that have X_value like fsx_projid have few types:
>> >> > 1. 0 means disabled (all existing values incl. projid)
>> >> > 2. 0 is a valid value but cannot be unset (btime)
>> >> > 3. 0 is a valid value and NULL/unset is also a valid value
>> >> >
>> >> > Only for type 3 does can the interpretation of
>> >> > (!XFLAG_X && !fsx_X) be considered as an "unset"
>> >> > and anyway, this will require support in individual fs.
>> >>
>> >> IMO !(xflags & XFLAG) && (rw_mask & XFLAG) should clear/unset the val=
ue
>> >> in all cases, ignoring what's in fsx_X.
>> >>
>> >> And all existing values would be of type 1 for VER0, but of type 1 + =
3
>> >> for VER1.
>> >>
>> >
>> > I agree that this will be more consistent.
>> >
>> > With explicit opt-in to FILEATTR_MASKS API
>> > vfs can determine that
>> > (!XFLAG_X && !!fsx_X) is alway -EINVAL
>> >
>> > When fsx_X =3D=3D 0, the value of XFLAG_X does not really matter
>> > so filesystems can decide themselves if they want to act on
>> > an "unset" flag or not.
>>
>> Hmm, I think fsx_xflags should have priority over the value in this
>> _masks API.
>>
>> In my mind, to clear PROJID a userspace program would only need to do:
>>
>>   struct file_attr fa =3D {
>>         .fsx_xflags =3D 0,
>>         .fsx_xflags_rw_mask =3D FS_XFLAG_PROJID
>>   };
>>   file_setattr(&fa, AT_FILE_ATTR_MASKS);
>
> If the program (e.g. chattr -p) internationally sets rw_mask =3D FS_XFLAG=
_PROJID
> what do we gain from not requiring the program to also set fsx_projid =3D=
 0?
> I just don't see any wins for anyone from this design choice.
>
> Maybe I am missing something.

I don't think we gain something, but I think it wouldn't make sense
semantically to require it.

At least personally, I wouldn't expect to be required to also 0 the
value if I'm already saying "I want to change PROJID and I want to unset
it" (rw mask =3D PROJID, xflags =3D 0).
Also for maybe future attributes belonging to type 3, the value should
be ignored when unsetting, since there would be no "invalid value" like
0 for projid.

>>
>> and have projid cleared (same for EXTSIZE/EXTSZINHERIT/COWEXTESIZE),
>> while to set/change it:
>>
>>   struct file_attr fa =3D {
>>         .fsx_xflags =3D FS_XFLAG_PROJID,
>>         .fsx_xflags_rw_mask =3D FS_XFLAG_PROJID,
>>         .fsx_projid =3D 67,
>>   };
>>   file_setattr(&fa, AT_FILE_ATTR_MASKS);
>>
>> and this:
>>
>>   struct file_attr fa =3D {
>>         .fsx_xflags =3D FS_XFLAG_PROJID,
>>         .fsx_xflags_rw_mask =3D FS_XFLAG_PROJID,
>>         .fsx_projid =3D 0,
>>   };
>>   file_setattr(&fa, AT_FILE_ATTR_MASKS);
>>
>> would have the same result as the first snippet, but not the same
>> meaning, since this would mean "set projid to 0" while the first snippet
>> means "clear/unset projid" (but in this case, for projid and all the
>> other already existing fsx_* it would have the same result).
>>
>
> As I wrote it could matter per attribute and per filesystem
> whether set to 0 or unset is different.

Yes, then filesystems could handle them however they want, maybe even
use the fsx_* value (if it's not 0) in the reset case above.

> The man page language should be flexible enough about this point.
>
> It only needs to document the invalid combinations.
>
> When proposing an UAPI change I often included a man-page draft
> as a proof that the UAPI can make sense to human readers.

Yes, I think I'll write the explanation in the cover letter to have the
ideas written down, then I can add man-pages and docs in v3.

Thanks,
koraynilay

> Thanks,
> Amir.



--79d3767db7994af79d385e900d46b036c798a71ba18599848e4679aadf0e
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQRJ2XvJtXGwULYEerQ0bnTtJTDoOAUCawgALgAKCRA0bnTtJTDo
OEQ/AP9wDjyrdFJEEzzmJJCrvCFrjxBqlkeNnNjqPWC/hJRgXgEA49DY4UXyB1Kj
wKwdt2yo0aESyGLzlPUZRwD8RmhwnQQ=
=UumB
-----END PGP SIGNATURE-----

--79d3767db7994af79d385e900d46b036c798a71ba18599848e4679aadf0e--
