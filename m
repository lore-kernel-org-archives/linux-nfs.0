Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795443230;
	b=Ayvr6ywqhGcrcCqFw89KH+AIwiNcIF56XUMt400YXAukUkrm2Qy5DdqrGexx+ncJT4js
	 +VYxZZ/N5qRIVNRhXOwFzxMreJG7sUVzWfFpURrqdNw7DFuIZYQ5nFZf1zgy6wOyaKOoJ
	 193Ry4wXyF8nF2IABIAMJDsqGyNzJr889tuWSqTdBHcDc6J52exxL9dL9LFMZcyFFSBPX
	 ao+7zdQPfmbhAlQKayyZ7rDO0d7xEAmJEjQkJ3IHT3gnqTbhqm0MoFdfYFWsS1ul8LtEH
	 bcNZVfmC4tkqbzgNZ9rAYfloE698B4/m7rRpcnf9XltW6UqrPKUHjqHGOeMrj2XTP/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795443230;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:To:Cc:Subject:From:X-Mailer:
	 References:In-Reply-To;
	bh=AdNUiZw6fAyIiVF2nciH0mXPq/Qr5P0Rz9tmmIcTAgM=;
	b=SCm7VLNsAPJAsUAk0P4LNfjGn6KFCSm+H1xTKY1r5vjSTpOa8uxzFOB8Eter81TKcaI/
	 d7Vv1CpLs9VOe2IVQ1prkevGM+hfdqHM5YL/IrD1ABkGBRjPF10Nenr9t3n1ryw/kab8j
	 YuVJ3rCBfXZaBIs/xW5kvPpfYqitvKldQfqkPublFyFYDFKqP9VPpEPJOiS1EbPcyz6bS
	 0+n9L446wMqRVrRf4EotFMPUMVuBY8zquHA4+d1PEtV6HxQfFnkUUQglaDvFGRXIgyzD9
	 NRnBEoYyOjQR2ZpXTMHA4exISYGotCDF0Hvbv+Xbkdz0/coXGDpKL866LK7qtmgOD3A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=ebffeTco;
	arc=none smtp.remote-ip=209.85.128.46
Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com [209.85.128.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A327F606A31A
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 14:13:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A327F606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=ebffeTco
Received: by mail-wm1-f46.google.com with SMTP id 5b1f17b1804b1-49d05d51553so24050315e9.2
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 06:13:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795443228; x=1796048028; darn=vger.kernel.org;
        h=in-reply-to:references:from:subject:cc:to:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=AdNUiZw6fAyIiVF2nciH0mXPq/Qr5P0Rz9tmmIcTAgM=;
        b=ebffeTcoM2kGd9tyJYwdkn0BAhKP3teX0NXVi/OtrrM9NfH6b7J/w0Q4IUirzPqgIX
         Vvu7exd430ieby8Ta08hExTCJAN8zp9SjmimaV45LlnMUx+NoYdslogXx2QgwOiYpnXy
         f0B5KYuDkYvgeCRA+uTerXqmCPXicY7jQWHZk3TttfS2u3aZrSCGvaSLtaKyEJ/pz4n7
         8BwcNYaX8ZpWPBApW/Eljbv9l9lsDXZk/KF6+vp4q9M4p3a0p4+/kc+5tL6F8lR9uTdW
         ygXtU6TBlMdsTfuseBs71kC+rNVYRElnzC0ZnA6zDhUg4LtydOk0mgEcsXkBy/fhNQ8X
         2vBQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795443228; x=1796048028;
        h=in-reply-to:references:from:subject:cc:to:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=AdNUiZw6fAyIiVF2nciH0mXPq/Qr5P0Rz9tmmIcTAgM=;
        b=KMVFaaIjZRR4jpRyPlBqr9XrsLL6M6iUsbRTWiDdyqcRtoRoRYmmA71XKbPQJ4/VxA
         LQyamMnlTcEddKE/CjRCx3QfYb0dwilin/xcHN3VrWJllctLbnFT9GiTRslhLRuXQfDy
         ttnpPwakd/o2uMYwyfyyQyO1/pSZ+6vs/fhjPvx0UJiQ5nxdxYQrCxCyELtefRe94X6b
         N56ntde3NeOPj1oXy5NTsBwcGw5q8frBIRSNr7rrw52K9MjKKeyerJRde+RSO9IIiVvc
         LMMQySAJdwW9CD2gqkPDRAjMtgkcMD27ChMsHF3CcS1oRVSnFGGh5DffVBaaZrgBJnTg
         DK0w==
X-Forwarded-Encrypted: i=1; AL+hErHcLMie2wf1nIPz2F5ZL5n/H4ipDtj0azQlNShVQG9uckSL4w+4d6CccCzxYVHzmMCKLLd563jXxm8=@vger.kernel.org
X-Gm-Message-State: APuU4Z9T3gqVZ0O1meJys1CIgERGDSUALUn1LEP0RrYG4i7EQF1k7BJP
	0BwPx99GeiOzu7lEhC7ErM56wLAIsY8CVEGX9073f58TBRQzyNcA4uCZ
X-Gm-Gg: AZFdTZfkfC7KhtJrCmopCoLTQfy/uJzDo+tO2mIplAZYJCMOz5jK2OnF5pGLKyWIt9b
	CAomQX4VszNlQq7dJOLArfZZCzQ4fgZa8TeN7Zjm24f42YZeCwMEOnRoTyyqhtbC81RKCZGtt+H
	wka7siWd1NqzFZ87Ag4BKQyChKFqmxvxahNHOS4kgOwX2osZrrS5mn/y2CwVVYaeuczbiJlNfqX
	+0FORS/wbm/S7dhL62EbGaAzpwY5RrJNj/DC7B6ij0SArtAr1imomEmOhaZ18RhqDNWcir/dsDJ
	PzxbcQCFRSOrjLLwMFYW6mz39GZobe5LeetghxPTkT/g2NJvReezfhd5fqR9RY7d2xpMB5j7vqd
	I1A+xR6avccY0X+Db08b8eD+7gypjiiWHDYvvgfghN9xkLI6V6QT5/C65urb5FzriM3UPKZ4xI7
	CUww6YbUOl7u99s7Hq6gci5/r6JxbPKmQOutKuhev/T/Uj8AclmNoZ3Pxd+wRRznc8JywZv/ijR
	pWgipYyfDy8RJm6ONvzGCk3SwR8uTsGYZSsllr4WgJodcxKv/vDlGz0zMVER3hGSYJ6w0YcUKxr
	UJM8FZ2Cof6hAyWOreDrVYrVGA==
X-Received: by 2002:a05:600c:848a:b0:4a1:fbd2:f689 with SMTP id 5b1f17b1804b1-4bb8880993amr234005065e9.7.1795443228027;
        Mon, 23 Nov 2026 06:13:48 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb884ab091sm508419575e9.11.2026.11.23.06.13.46
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 23 Nov 2026 06:13:47 -0800 (PST)
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
 boundary=c485377c3c583edb24864dcca5dc2a3b0d7251ed0f88e601a300289ca66a;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Mon, 23 Nov 2026 15:13:45 +0100
Message-Id: <DN2NI744M9OC.CYZFL8XSU7UP@gmail.com>
To: "liubaolin" <liubaolin12138@163.com>, "koraynilay"
 <koray.fra@gmail.com>, "Namjae Jeon" <linkinjeon@kernel.org>, "Hyunchul
 Lee" <hyc.lee@gmail.com>, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>
Cc: "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>, "Jan
 Kara" <jack@suse.cz>, "Darrick J . Wong" <djwong@kernel.org>, "Andrey
 Albershteyn" <aalbersh@kernel.org>, "Amir Goldstein" <amir73il@gmail.com>,
 =?utf-8?q?Pali_Roh=C3=A1r?= <pali@kernel.org>, "Lauri Gates"
 <lauri.gates@gmail.com>, "Christoph Hellwig" <hch@infradead.org>, "Dave
 Chinner" <dgc@kernel.org>, <linux-btrfs@vger.kernel.org>,
 <linux-xfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-fsdevel@vger.kernel.org>, <ntfs@lists.linux.dev>,
 <linux-nfs@vger.kernel.org>, <linux-api@vger.kernel.org>
Subject: Re: [PATCH 3/3] ntfs: switch to the new xflags fileattr API
From: "koraynilay" <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261122000856.536902-1-koray.fra@gmail.com>
 <20261122000856.536902-4-koray.fra@gmail.com>
 <1ebbb85f-3515-4c45-a850-8039aad93800@163.com>
 <DN265Y2EAGQV.1ZD49JSIDMME5@gmail.com>
 <6d054adc-5b6d-4a1c-b9e5-b32916e06abe@163.com>
In-Reply-To: <6d054adc-5b6d-4a1c-b9e5-b32916e06abe@163.com>

--c485377c3c583edb24864dcca5dc2a3b0d7251ed0f88e601a300289ca66a
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Mon Nov 23, 2026 at 4:06 AM CET, liubaolin wrote:
>
>
> =E5=9C=A8 2026/11/23 08:38, koraynilay =E5=86=99=E9=81=93:
>> On Sun Nov 22, 2026 at 1:49 PM CET, liubaolin wrote:
>>>
>>>
>>> =E5=9C=A8 2026/11/22 08:08, koraynilay =E5=86=99=E9=81=93:
>>>> Switch ntfs_fileattr_[gs]et() from the legacy FS_*_FL flags to the
>>>> modern xflags (FS_XFLAG_*) fileattr API with masks.
>>>>
>>>> Introduce FS_XFLAG_COMPR and FS_XFLAG_ENCRYPT and add them to
>>>> FS_XFLAG_COMMON (and add FS_COMPR_FL and FS_ENCRYPT_FL to FS_COMMON_FL=
)
>>>> to be used in this API switch.
>>>>
>>>> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.11
>>>> Signed-off-by: koraynilay <koray.fra@gmail.com>
>>>> ---
>>>>    fs/file_attr.c           |  8 +++++
>>>>    fs/ntfs/file.c           | 63 +++++++++++++++++++------------------=
---
>>>>    include/linux/fileattr.h |  6 ++--
>>>>    include/uapi/linux/fs.h  |  2 ++
>>>
>>> Hi koraynilay,
>>>      One suggestion on the patch split: would it make sense to put the
>>> new COMPR/ENCRYPT xflags and their VFS handling in a separate patch
>>> before the NTFS conversion?
>>>      The changes to include/uapi/linux/fs.h, include/linux/fileattr.h
>>> and fs/file_attr.c introduce generic fileattr support, and the
>>> COMMON mask changes also affect other filesystems.
>>>      Keeping those changes together in a VFS patch would make the API
>>> and compatibility aspects easier to review.
>>>      The following NTFS patch could then focus on using the new flags
>>> while preserving the existing NTFS behaviour.
>>=20
>> Hi Baolin and thanks for the feedback,
>> for now I put them in the same patch since they're not many lines of
>> code changes, but I now also had to add NOCOMP, maybe I'll split it in
>> the next version.
>>=20
>>> Thanks,
>>> Baolin.
>>>
>>>>    4 files changed, 44 insertions(+), 35 deletions(-)
>>>> [...]
>>>>    	if (err)
>>>>    		return err;
>>>>   =20
>>>> -	if (fileattr_has_fsx(fa))
>>>> -		return -EOPNOTSUPP;
>>>> -
>>>> -	/* chattr passes the unchanged read-only flags back to us too. */
>>>> -	if (NInoCompressed(ni) || NInoWofCompressed(ni))
>>>> -		readonly |=3D FS_COMPR_FL;
>>>> -	if (NInoEncrypted(ni))
>>>> -		readonly |=3D FS_ENCRYPT_FL;
>>>> -	if ((fa->flags ^ readonly) & (FS_COMPR_FL | FS_ENCRYPT_FL))
>>>> -		return -EOPNOTSUPP;
>>>> -	allowed |=3D readonly;
>>>> -
>>>> -	/* Case folding is a read-only, mount-wide property. */
>>>> -	if (!NVolCaseSensitive(ni->vol))
>>>> -		allowed |=3D FS_CASEFOLD_FL;
>>>> -	if (fa->flags & ~allowed)
>>> Hi koraynilay,
>>>      There is another case worth keeping in mind when replacing this ch=
eck:
>>>      fileattr_fill_flags() only translates a subset of FS_*_FL bits,
>>> so some unsupported flags will not appear in fsx_xflags.
>>>     For example, a direct SETFLAGS request containing only FS_NOCOW_FL
>>> produces fsx_xflags =3D=3D 0. On a normal file on a case-sensitive moun=
t,
>>> the new check would accept that request.
>>>     If the file already has persistent NODUMP set, the request would al=
so
>>> clear it, since the setter rebuilds linuxflags without NODUMP and write=
s
>>> it back to the EA. The current code rejects the request and leaves the
>>> existing attributes unchanged.
>>>
>>>     Would it be possible to keep validating fa->flags when flags_valid =
is
>>> set, in addition to the xflags check?
>>=20
>> We could, but the objective is to have filesystems that implement the
>> new _masks API use only xflags.
>
> Hi koraynilay,
>     That makes sense, and I'm fine with NTFS using only xflags.
> Could we still make sure that legacy SETFLAGS requests with flags=20
> unsupported by NTFS are rejected rather than silently accepted after=20
> conversion?

Hi,
yes, my current (v2) code, in the new fileattr_legacy_to_mask() helper,
does this:

if (fa->flags_valid) {
	/*
	 * Assume that if the filesystem supports masks it also added
	 * its supported FS_*_FL flags to FS_XFLAG_* and to the COMMON
	 * masks.
	 */
	changed =3D fa->flags ^ old_ma->flags;
	if (changed & ~FS_COMMON_FL)
		return -EOPNOTSUPP;

	changed =3D flags_to_xflags(changed);
}

so they should be correctly rejected.

Thanks,
koraynilay

> Thanks,
> Baolin.
>
>>=20
>>> Thanks,
>>> Baolin.
>>>
>>>
>>>> +	/*
>>>> +	 * When userspace uses file_[gs]etattr(), VFS already checks and fai=
ls
>>>> +	 * with -EOPNOTSUPP if rw_mask & ro_mask !=3D 0 and rw_mask & ~allow=
ed,
>>>> +	 * but for FS_IOC_SETFLAGS and FS_IOC_FSSETXATTR VFS can't check for
>>>> +	 * allowed flags as these ioctls don't support fsx_xflags_{rw,ro}_ma=
sk,
>>>> +	 * so we need to check for unsupported flags anyway.
>>>> +	 */
>>>> +	if (!fa->has_masks &&
>>>> +	    ((fa->fsx_xflags & ~NTFS_RW_XFLAGS) ||
>>>> +	     fa->fsx_extsize || fa->fsx_projid || fa->fsx_cowextsize))
>>>>    		return -EOPNOTSUPP;
>>>
>>> Hi koraynilay,
>>>      Could we keep the existing handling of read-only attributes
>>> for legacy SETFLAGS callers here?
>>>      On a case-insensitive NTFS mount, the VFS carries over
>>> FS_XFLAG_CASEFOLD from the current attributes, since it is not in
>>> FS_XFLAG_COMMON.
>>> This check would then reject it because CASEFOLD is not in
>>> NTFS_RW_XFLAGS, so even chattr +d would fail with EOPNOTSUPP.
>>>      The unchanged COMPR/ENCRYPT bits that chattr reads with GETFLAGS a=
nd
>>> passes back with SETFLAGS would also be rejected on compressed/encrypte=
d
>>> files.
>>>      Allowing those existing read-only attributes to be passed back
>>> unchanged  would let users continue setting and clearing the persistent
>>> flags through chattr,as they can today.
>>>
>>> Thanks,
>>> Baolin.
>>=20
>> Since I wasn't quite satisfied with this version, I'm working on a
>> revisited v2, that is hopefully cleaner and fixes these bugs and the
>> ones reported by sashiko.
>>=20
>> Thanks,
>> koraynilay
>>=20
>>=20
>>>>   =20
>>>>    	forced_immutable =3D ntfs_is_forced_immutable(vi);
>>>> -	if (!(fa->flags & FS_IMMUTABLE_FL) && forced_immutable)
>>>> +	if (!(fa->fsx_xflags & FS_XFLAG_IMMUTABLE) && forced_immutable)
>>>>    		return -EPERM;
>>>>   =20
>>>> -	if (fa->flags & FS_IMMUTABLE_FL) {
>>>> +	if (fa->fsx_xflags & FS_XFLAG_IMMUTABLE) {
>>>>    		new_fl |=3D S_IMMUTABLE;
>>>>    		/* Do not persist an immutable bit derived from the mount. */
>>>>    		if (!forced_immutable ||
>>>>    		    (ni->linuxflags & NTFS_LINUXFLAGS_IMMUTABLE))
>>>>    			linuxflags |=3D NTFS_LINUXFLAGS_IMMUTABLE;
>>>>    	}
>>>> -	if (fa->flags & FS_APPEND_FL) {
>>>> +	if (fa->fsx_xflags & FS_XFLAG_APPEND) {
>>>>    		new_fl |=3D S_APPEND;
>>>>    		linuxflags |=3D NTFS_LINUXFLAGS_APPEND;
>>>>    	}
>>>> -	if (fa->flags & FS_NODUMP_FL)
>>>> +	if (fa->fsx_xflags & FS_XFLAG_NODUMP)
>>>>    		linuxflags |=3D NTFS_LINUXFLAGS_NODUMP;
>>>> -	if (fa->flags & FS_NOATIME_FL) {
>>>> +	if (fa->fsx_xflags & FS_XFLAG_NOATIME) {
>>>>    		new_fl |=3D S_NOATIME;
>>>>    		linuxflags |=3D NTFS_LINUXFLAGS_NOATIME;
>>>>    	}
>>>> diff --git a/include/linux/fileattr.h b/include/linux/fileattr.h
>>>> index 4faa40febf11..219e7c8eb601 100644
>>>> --- a/include/linux/fileattr.h
>>>> +++ b/include/linux/fileattr.h
>>>> @@ -7,12 +7,14 @@
>>>>    #define FS_COMMON_FL \
>>>>    	(FS_SYNC_FL | FS_IMMUTABLE_FL | FS_APPEND_FL | \
>>>>    	 FS_NODUMP_FL |	FS_NOATIME_FL | FS_DAX_FL | \
>>>> -	 FS_PROJINHERIT_FL | FS_VERITY_FL)
>>>> +	 FS_PROJINHERIT_FL | FS_VERITY_FL | FS_COMPR_FL | \
>>>> +	 FS_ENCRYPT_FL)
>>>>   =20
>>>>    #define FS_XFLAG_COMMON \
>>>>    	(FS_XFLAG_SYNC | FS_XFLAG_IMMUTABLE | FS_XFLAG_APPEND | \
>>>>    	 FS_XFLAG_NODUMP | FS_XFLAG_NOATIME | FS_XFLAG_DAX | \
>>>> -	 FS_XFLAG_PROJINHERIT | FS_XFLAG_VERITY)
>>>> +	 FS_XFLAG_PROJINHERIT | FS_XFLAG_VERITY | FS_XFLAG_COMPR | \
>>>> +	 FS_XFLAG_ENCRYPT)
>>>>   =20
>>>>    /* Read-only inode flags */
>>>>    #define FS_XFLAG_RDONLY_MASK \
>>>> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
>>>> index e40806b3a69c..09fc7e066485 100644
>>>> --- a/include/uapi/linux/fs.h
>>>> +++ b/include/uapi/linux/fs.h
>>>> @@ -275,6 +275,8 @@ struct file_attr {
>>>>    #define FS_XFLAG_CASENONPRESERVING 0x00080000	/* case not preserved=
 */
>>>>   =20
>>>>    #define FS_XFLAG_PROJID		0x00100000	/* project ID */
>>>> +#define FS_XFLAG_COMPR		0x00200000	/* Compress file */
>>>> +#define FS_XFLAG_ENCRYPT	0x00400000	/* Encrypted file */
>>>>    #define FS_XFLAG_HASATTR	0x80000000	/* no DIFLAG for this	*/
>>>>   =20
>>>>    /* the read-only stuff doesn't really belong here, but any other pl=
ace is
>>=20



--c485377c3c583edb24864dcca5dc2a3b0d7251ed0f88e601a300289ca66a
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQSgVimKafU5DQMcjcDmj22qf5IGXAUCawRKGQAKCRDmj22qf5IG
XPWcAP49AViSerRvoyJ97sqTIiiJSLMsgNe7vK+zEVAAQFM2oAEA1KcvCk741zB+
V7RldREforG/ieOp41N4vF9RjqR5gAo=
=IGHV
-----END PGP SIGNATURE-----

--c485377c3c583edb24864dcca5dc2a3b0d7251ed0f88e601a300289ca66a--
