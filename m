Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795441832;
	b=vyK9nNR546whY8awcKzerWq/EzHy3Lak0Cqi3NUo5bGm/TfflHXTbDMrrSalTTAFcbN0
	 kCstnnHbJxwoOY0ln0JLmi2QnlWAQwnB5WP1Alkd/xL1Jlio1ZruUrFVRCKliRN28X0vI
	 zkyAZk8YU+DuYUddaFMCXgKBhnsDEQdWM4L9KEgl24PQ1E0SrcLeomVn9RRTsvVrgL3ub
	 aSeohoQhMOSwzcbOS1db1ZGwxkQUJPaEHItVzh1wTSUcHTUm9HS4zdUpmm7YMAE4cCY0q
	 P8MnON2OvuHHKgLBTDJC3IIPDJQpae2Wp5YW7gpEo30M78vzmPcZtk8Eqz/mbd6KEOQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795441832;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=nDVijpGqwKWyH50w8XVucnbg4rdJHZCpEUX0lljvpb8=;
	b=aa0aFlwkiBvfpZD1XfkEmKa/kwbcGO4Rc00+KRKOirEKwSeFJ3f7BMkdj5Pb5G+FOClg
	 bUZ3Ys3QRK1FaIdBjlpT66vQMf+hQWfukfQ8UfwGx6kyv1aaXLbaps6pHfrqO6Ixb7VRz
	 H0baFQi6ib/Jz7jqV+16xSATMazzmGi37xKJwpHFWW5d8y1JXRIWjByLgh31lpd/ocyS5
	 Stq4yu8nBaK+ZfIkFM4udwlRTjvRh7oHRTDe7ezDzr4iIKAQLOOILM0WfKn4QUUy403wT
	 CMLz7YhEXcx9Bd7JHEle/wEH1CnAXcVnw6lBat1U8TQ6MdUIeE7imBigsT82vGMiwSA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=EROWc7oY;
	arc=none smtp.remote-ip=209.85.128.44
Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5B26606A32C
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 13:50:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D5B26606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=EROWc7oY
Received: by mail-wm1-f44.google.com with SMTP id 5b1f17b1804b1-4a214c5c4c0so30788295e9.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 05:50:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795441830; x=1796046630; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=nDVijpGqwKWyH50w8XVucnbg4rdJHZCpEUX0lljvpb8=;
        b=EROWc7oY9HdiuOpsRGUthkHINXiipaSyPMDYzSawxLU5aWqobqcmnFnwToY98OdLXf
         qJfDcB4+A8q++a+EN13WjvAlZeWCaOKo2UsSQJ5+fQ1MlRl/KRNafFwDinnSNxWYPbiw
         VRXPFVDoI4cdf5PnMJEf/NKzywFpZn4lJNqxpoOsYQjBEC6qtplcSoQa7v6tcT2EpGRz
         RHG2vyd9p4eg4I4DRsTf0IhQP79hJaY0pykaI9fujqA9telSKI6p+nDD1LZyoFpMfWjv
         JuzCe0SaA+DkidiGkJTl8r1/CIuJAip5VhrU8jiv+enZEzaWHcx0BJ2R5jDN2AtBxTOH
         fO1g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795441830; x=1796046630;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=nDVijpGqwKWyH50w8XVucnbg4rdJHZCpEUX0lljvpb8=;
        b=yiZH+VjxnrBWqJbvN2LKNq52L3yto4bJMA2wJBQbHw9DGpw+dpekPz3Xazis0Zt1Vy
         yCw7XU2gydPhYoYB+zyvQiJbcLlMt2lp9xWqLCW4U7HzBggL1j9cRi261RtufEkTDkzd
         LRNtAikKmUHewtuUgM+wa0aaSvqePJh7He5fxFCSe6M6hV+y2G7AFfMcrZT8JT2LSSzB
         3JyUcxIYkuMOyMln+5DZ71bV3tJEt1n1Jyg8+EVY50SK+jgkwjklC8wRtB0w8SB/jgIL
         ZHOh8VZS97xQl6E+KbLLqSijDy80XmVm/8BgL4riOodqZd06C+Gy0ag4WYutShvc5Lmo
         q97Q==
X-Forwarded-Encrypted: i=1; AL+hErHSyjs6HyWCzXtObNNwnHFVp5u8Q4kMWQzeK5JbiCUNplcGnc/gEm08LmdiXthAOl5TwzqHF+6lta4=@vger.kernel.org
X-Gm-Message-State: APuU4Z+EYLjVCY4tGB0xu6DSMnWvo+Qv0nTtlTxzS9HWNKkGEK95Tm9x
	fREB6yZYUdlByvZ13hSa/3UD8mIDwW32wtvpHb57JtbbcH7FP4twZ+LKIe2Azqz5yeQ=
X-Gm-Gg: AZFdTZcwgCvWgskIvgmjXXLBs8cpsr5yky4TWm9VKGZppWUKN59fPAj+O1gQjYn9ZjF
	qZYg+x5kgyFW6VlpcyT5N1p2FN+QxXrrJ4Inh8AQYkoVSAYx6ukNz7KbicC2htZ3UciTVKf6AUO
	tP0V1438oBjzeJ/w6WMYHq0CaBPZXOx3pwFYNdrhCDagfndFAxqB/9zsHfPYf/R+PZ6jA5zYNNj
	k13mkDBWX3uCCRAc2RuNScy35NwM1VeWkCT78EC52ZIFEJKqkfuEvnl2gdOtqgdHxHd7urg8qgG
	thySZ9PZC4NvQHgGCzhBIHjmBln50hfi7jE1RLkM0hB3+v+X4YHKHuV1cNAariJKVjsEevz2XT1
	04XVQvfEFakCdgmjz/EwUj2AkzJksMI4P5wMd+C56HtSeVAYn8WOq6n5OFQdRabOLTOhh9DxdDK
	PHhBKDvETX7/Qf8+VVRx4BcFJkMD1GVgE7VNW4RqU19IE4I7uj1ykl4xtIHB31cOx9j3TLbG4tt
	Mwanb6u6MNsPd9A1OHqvKLEgbo/F2V3YeKodBEBeifTStUi0vyX9gU1GQ9YKR6CWCcOAhChUpVu
	uQUBhJvnzEr9HZbH2Lx4QIgwJFWn0N+Lq+umIadyHRv8J5k=
X-Received: by 2002:a05:600c:5493:b0:4a2:8c5:5e5 with SMTP id 5b1f17b1804b1-4bb8881c734mr251533555e9.7.1795441829886;
        Mon, 23 Nov 2026 05:50:29 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb853ca452sm348754825e9.15.2026.11.23.05.50.28
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 23 Nov 2026 05:50:28 -0800 (PST)
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
 boundary=5849192148479b23b3d4c31f6e3ae6158a9ba4dcae3531b8cba6e234b57e;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Mon, 23 Nov 2026 14:50:25 +0100
Message-Id: <DN2N0BY83OY2.1OV3ZAZFSWCDG@gmail.com>
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
In-Reply-To: <CAOQ4uxgc6pP+_xvJMbqj6wOdGzS75Vn6x6i_vUfCJDD46DAA_Q@mail.gmail.com>

--5849192148479b23b3d4c31f6e3ae6158a9ba4dcae3531b8cba6e234b57e
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Mon Nov 23, 2026 at 2:00 PM CET, Amir Goldstein wrote:
> On Sun, Nov 22, 2026 at 1:09=E2=80=AFAM koraynilay <koray.fra@gmail.com> =
wrote:
>>
>> Switch ntfs_fileattr_[gs]et() from the legacy FS_*_FL flags to the
>> modern xflags (FS_XFLAG_*) fileattr API with masks.
>>
>> Introduce FS_XFLAG_COMPR and FS_XFLAG_ENCRYPT and add them to
>> FS_XFLAG_COMMON (and add FS_COMPR_FL and FS_ENCRYPT_FL to FS_COMMON_FL)
>> to be used in this API switch.
>>
>> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.11
>> Signed-off-by: koraynilay <koray.fra@gmail.com>
>> ---
>>  fs/file_attr.c           |  8 +++++
>>  fs/ntfs/file.c           | 63 +++++++++++++++++++---------------------
>>  include/linux/fileattr.h |  6 ++--
>>  include/uapi/linux/fs.h  |  2 ++
>>  4 files changed, 44 insertions(+), 35 deletions(-)
>>
> ...
>
>> diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
>> index 50be49f4c913..fde6fb2fe39c 100644
>> --- a/fs/ntfs/file.c
>> +++ b/fs/ntfs/file.c
>> @@ -155,31 +155,37 @@ int ntfs_file_release(struct inode *vi, struct fil=
e *filp)
>>   * @dentry: dentry to report the flags of
>>   * @fa: filled in with the flags of @dentry
>>   */
>> +#define NTFS_RO_XFLAGS (FS_XFLAG_COMPR | FS_XFLAG_ENCRYPT | FS_XFLAG_CA=
SEFOLD)
>> +#define NTFS_RW_XFLAGS (FS_XFLAG_IMMUTABLE | FS_XFLAG_APPEND | \
>> +                       FS_XFLAG_NOATIME | FS_XFLAG_NODUMP)
>
> Nit: checkpatch may allow 100 chars, but this due formatting is not
> easy on the eyes
> pls break to RO line
It should be 78 and imo it looks fine, but yes, I'll split it in next
patch.

> and indent the broken lines below (

This should be a diff-only problem, in my working tree the file has them
correctly indented using 3 tabs (wide 8) and 0 space, probably same
problem as the PROJID line being unaligned here:
>>  #define FS_XFLAG_PROJID                0x00100000      /* project ID */
>> +#define FS_XFLAG_COMPR         0x00200000      /* Compress file */

>
>> diff --git a/include/linux/fileattr.h b/include/linux/fileattr.h
>> index 4faa40febf11..219e7c8eb601 100644
>> --- a/include/linux/fileattr.h
>> +++ b/include/linux/fileattr.h
>> @@ -7,12 +7,14 @@
>>  #define FS_COMMON_FL \
>>         (FS_SYNC_FL | FS_IMMUTABLE_FL | FS_APPEND_FL | \
>>          FS_NODUMP_FL | FS_NOATIME_FL | FS_DAX_FL | \
>> -        FS_PROJINHERIT_FL | FS_VERITY_FL)
>> +        FS_PROJINHERIT_FL | FS_VERITY_FL | FS_COMPR_FL | \
>> +        FS_ENCRYPT_FL)
>>
>>  #define FS_XFLAG_COMMON \
>>         (FS_XFLAG_SYNC | FS_XFLAG_IMMUTABLE | FS_XFLAG_APPEND | \
>>          FS_XFLAG_NODUMP | FS_XFLAG_NOATIME | FS_XFLAG_DAX | \
>> -        FS_XFLAG_PROJINHERIT | FS_XFLAG_VERITY)
>> +        FS_XFLAG_PROJINHERIT | FS_XFLAG_VERITY | FS_XFLAG_COMPR | \
>> +        FS_XFLAG_ENCRYPT)
>
>
> Rule:
>
> You cannot add a flag to common without carefully auditing all
> filesystems that support the legacy flag.

Yeah, sashiko pointed out a problem in f2fs, and I could reproduce it in
testing, where adding COMPR to COMMON makes f2fs crash, it also needs
NOCOMP in COMMON.

> FS_XFLAG_ENCRYPT can go into common but must also
> go to FS_XFLAG_RDONLY_MASK because it's read-only for
> all existing fs.
>
> COMPR is rw for some fs and ro for others.
> As with CASEFOLD, you cannot make it COMMON before
> converting all casefold fs to new API so that each can say
> whether it wants RO or RW.

How's CASEFOLD currently handled? in the v2 I'm drafting, I added
fileattr_mask_to_legacy() and fileattr_legacy_to_mask(), which convert
between the old format (filtering by FS_XFLAGS_MASK) and the new mask
format.

> I think there may be a way to deal with this easily since
> ntfs doesn't need to set either but not sure.

We could export the 2 other helpers I added for v2 (xflags_to_flags and
flags_to_xflags) and make NTFS use them?
Though adding the fileattr_ prefix will make the current (v2) vfs code
maybe too verbose.

>>
>>  /* Read-only inode flags */
>>  #define FS_XFLAG_RDONLY_MASK \
>> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
>> index e40806b3a69c..09fc7e066485 100644
>> --- a/include/uapi/linux/fs.h
>> +++ b/include/uapi/linux/fs.h
>> @@ -275,6 +275,8 @@ struct file_attr {
>>  #define FS_XFLAG_CASENONPRESERVING 0x00080000  /* case not preserved */
>>
>>  #define FS_XFLAG_PROJID                0x00100000      /* project ID */
>> +#define FS_XFLAG_COMPR         0x00200000      /* Compress file */
>> +#define FS_XFLAG_ENCRYPT       0x00400000      /* Encrypted file */
>
> This is a mistake of patch 1. the newline should remain above HASATTR
> which is allocated from the end.

Right, fixed (and removed the blank line between CASENONPRESERVING and
PROJID).

Thanks,
koraynilay

>
>>  #define FS_XFLAG_HASATTR       0x80000000      /* no DIFLAG for this   =
*/
>>
>>  /* the read-only stuff doesn't really belong here, but any other place =
is
>
> Thanks,
> Amir.
>>



--5849192148479b23b3d4c31f6e3ae6158a9ba4dcae3531b8cba6e234b57e
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQSgVimKafU5DQMcjcDmj22qf5IGXAUCawREoQAKCRDmj22qf5IG
XPikAQDShiHwdlBzVhBmmlaSOjx657TCRAUhtq5TpU0jWZ2HUwEAqm4ENGadEir3
5R98mqEdCF353Ii7LkdpHNEHYRGrkQE=
=QROX
-----END PGP SIGNATURE-----

--5849192148479b23b3d4c31f6e3ae6158a9ba4dcae3531b8cba6e234b57e--
