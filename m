Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.52
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795638172;
	b=m0D1Iwb8DFc5mBTyjYQBBPM6zRb3ns8K9pALLjZGfXMiYUxaOjzumEvZe7ixdzpV4ojo
	 Sl2BgfdwPnRAoCuPdUMVebppGXD5bgiIH5dPKBPjXYWhi9uNnMfLbGKT9yi1yn+gWV0An
	 oRehDLf2IClY6YgQpfPDROM+bMex2egVeoc9zcWhpYDiwgROb5xNCpOcoogWoTCIcQiAT
	 64mNeAR+7T+UmqWRDb97oUVMVOLSrahGoIMbICjtNVdzn/4jAxXdvIQwXp9JPVl/Yexs6
	 ocq4bckRHU6JxFNwpvOjsD1M7yatxgEldTApLInyh4ibJFMXlBEPCvN1FOsnn/JDZVg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795638172;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=fNWZNgc0WrQFHfNJaMklHOXMh0dDISx4ZPchEsw172w=;
	b=nXbSQMkzzfaIHWnpMZS+IH2UGJtzhb82KVXxEleiRgMiwidVtLb5SL5gzuQNoBTfX8Et
	 3H3qM4dZuo1j53mxASACkXSmaujt1MZ8EVAsjAsprzG+gbvHuoeuG1oShE7p10DznVhzf
	 /2Bye0pcMLnNIDDuFRfF/46r8S9TuJhqQhxYKEtvdFvZ1tyXEdyb01SNIjDVVl2LTNlIS
	 IWWeQOOUejQqV+1aB1r8ZhyRIU+eSypmThWvNTTkzlLavh7kC6tJbc8JWbEb1iuKo4Bud
	 fRoi7PIr8Lmnh6HCGuBhxB8HIre5wDAoWBOP+FgiCz+fRt/Ed34hdGFVDlRZfMI9a3Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=i0Ex6MNd;
	arc=none smtp.remote-ip=209.85.128.52
Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com [209.85.128.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 195F1606A321
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 20:22:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 195F1606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=i0Ex6MNd
Received: by mail-wm1-f52.google.com with SMTP id 5b1f17b1804b1-4b79502c27aso62330935e9.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 12:22:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795638170; x=1796242970; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=fNWZNgc0WrQFHfNJaMklHOXMh0dDISx4ZPchEsw172w=;
        b=i0Ex6MNdliAEH+x5mFALHDaiWJdfTAl4IhmXju9fZvF3axpQ3WoM3fmFIsUzzJhRMv
         vvbZkI1tlcBZ7ger0oocOZKJErp/uqzAD03wg0wJpleVC1j8C0AOKYoKiP0d3zvGuR4f
         pSglSdeKO6MnxUAxHod7TcV0r9jTdFLWl+DJZKeEIKNPBUKsniHuv7KYkjwu67cK1hIz
         aRXfHqp6E4st2KecikxHKqcrkZhTqSlTHcm4j1bxvxftqQF1q7waGVnL1UIQneIwMoZc
         2aMQ9jQmyIM3odhg0zkjEtuThTTJoyno2+SvDBP2aBt/Zo/g7Jz6p5oxjl3PG1V6Ao2t
         gl2w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795638170; x=1796242970;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=fNWZNgc0WrQFHfNJaMklHOXMh0dDISx4ZPchEsw172w=;
        b=0hPYLQ9c6BYlXbxfEGkWUUxoDbXKNATNLdF7O7nBZ64EUFVoEatjdF032a+ioc2CKK
         77/vnh4A42WLKybtACuOQ2P++84K14o+y9YH57/wC/mhvn2dUhV9DD+lqttCG3y/tn/T
         ctlparP5jsIu72rc/V1kLVsGvdFCkOoVlD/MsJSEakuAzmIoViPZFeYhC7jk2BmVMWyN
         N9b5oZY1K2n3/lpjPtFCj34+iQHOZeiCJPre9ubAS5TeF4tF5a4qZTIap4h2JMVBJ987
         Asb1E60Rx1OtJf92OioBe/WaJ4YpkwcY6MrxkZb69OEqrlIr/+FN+eeYy+0lfU4Rf9hR
         Pssw==
X-Forwarded-Encrypted: i=1; AL+hErEkjIHnpIACxjt3zHon5tABFMfbULUEKmava1krpQa5HJxYGt0Vql5gzZm/hQB6VKjLzgKs7W04ewo=@vger.kernel.org
X-Gm-Message-State: APuU4Z88dWfDfeNAu+bQMy8r/GUpQ3sgeEsspeoZstf+WMUkC1tCsQpx
	lLsd98M3w9Hnaa15zG5B5M9uzV2g8L0Zazkpt9t0mdgTEgQgy61ayjxD
X-Gm-Gg: AZFdTZdx6HU4qO/gO3rX1GvrD+LZ27Nu16oRSYlWZJcq4RrJZQp7Vq9LEaYk9FewfyE
	yMmbXWvXe05yErWTlc4sSK3TcgTHV8rvWDmzewmQXXQWea5unA//3m/y716nxlPW3mGn/zX9a6X
	rYGoy+LkXNrv3pKWB/bz/uLJn7OqoRbCpLBi9Q3ZBGjYJxliOssl+S5lpzFtvWI6EQeEd+kLxRT
	DNZ1N5uq9oZJg8Pio1Sbb8YFHyqjIwtlZ4G9S1zRidK0usM4wdHqekHdpBvq+3IYsXbGHdkkFAu
	HccGHpDgY95YLIcetHZWvRY8qWVVEj0jYK30zMcQFBBxKwaWXr1OzWshFawqw8SzkQJCPcfK0l/
	oGiEtJqu77bCOIrIcbRwoWhFwuf/80xtmKsDcxc05QYrigKUibk1i6e2qM7ZqUGCSDtvaNRaRFp
	OKoCrfUAWIllf99hw6BiFOti3Q6q5kyXjWVjftBWShLtw2Pu25t0Y3XvDjIJZUZSpw6wuMaM+Am
	tchIWPBNNQ7oafBVz4M9+yYKB6ye2Pgl3u+nxzyphgaErR4oizj7iy8/p1ApS7FD+Jndh6GSWUI
	NnuGhxqJeHLxgfpZUeW+mhOQpKES3oUtt6DUZQhXsXzHscep
X-Received: by 2002:a05:600c:6749:b0:4bb:71c1:3ca6 with SMTP id 5b1f17b1804b1-4bb88819d15mr367467105e9.21.1795638170093;
        Wed, 25 Nov 2026 12:22:50 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:de3b:51f3:e461:c0df])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab6c61f558sm37191611f8f.58.2026.11.25.12.22.47
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 25 Nov 2026 12:22:48 -0800 (PST)
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
 boundary=e8caff26652db83e371b7bbbf1756842a7f68d613d7cadc16719f19bedf2;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Wed, 25 Nov 2026 21:22:44 +0100
Message-Id: <DN4KLSM2OO0K.2C8Q5CPFBVNL6@gmail.com>
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
In-Reply-To: <CAOQ4uxg0g+XkPb3-kQS5ez1-rp7Q=BkYDHW0CGOFhpbcf70yMg@mail.gmail.com>

--e8caff26652db83e371b7bbbf1756842a7f68d613d7cadc16719f19bedf2
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Wed Nov 25, 2026 at 5:51 PM CET, Amir Goldstein wrote:
> On Wed, Nov 25, 2026 at 4:01=E2=80=AFPM koraynilay <koray.fra@gmail.com> =
wrote:
>>
>> On Mon Nov 23, 2026 at 4:29 PM CET, Amir Goldstein wrote:
>> > On Mon, Nov 23, 2026 at 2:58=E2=80=AFPM koraynilay <koray.fra@gmail.co=
m> wrote:
>> >>
>> >> On Mon Nov 23, 2026 at 2:24 PM CET, Amir Goldstein wrote:
>> >> > On Sun, Nov 22, 2026 at 1:09=E2=80=AFAM koraynilay <koray.fra@gmail=
.com> wrote:
>> >> >>
>> >> >> Add fa_xflags_rw_mask and fa_xflags_ro_mask to struct file_attr an=
d
>> >> >> equivalent masks to struct file_kattr.
>> >> >>
>> >> >> Also add has_masks selector to struct file_kattr so we can know wh=
en a
>> >> >> user of this API (userspace or filesystem) supports them.
>> >> >>
>> >> >> This lets filesystems advertise their support for specific xflags,=
 like
>> >> >> statx.stx_attributes_mask does, and userspace can specify only whi=
ch
>> >> >> xflags it wants to change without needing a RMW cycle:
>> >> >> - on GET: each filesystem that wants to support this new API fills=
 the
>> >> >>   masks according to its supported and read-only xflags, then:
>> >> >>   * for boolean xflags: it fills fsx_xflags with the current on-di=
sk value
>> >> >>   * for value xflags: it sets the xflag bit to 1 in fsx_xflags and=
 the
>> >> >>     xflag value in the struct field;
>> >> >> - on SET: userspace fills the rw_mask with the bits of the xflags =
it
>> >> >>   wants to change, then:
>> >> >>   * for boolean xflags: it provides the xflag value as a bit in fa=
_xflags
>> >> >>   * for value xflags: it sets the xflag bit to 1 in fa_xflags and =
then
>> >> >>     provides the value in the struct field; if the xflag bit is se=
t to 0
>> >> >>     instead, this informs the kernel to unset/clear that value.
>> >> >>
>> >> >> Since fa_xflags_rw_mask means "I want to change the xflags specifi=
ed in
>> >> >> here", if userspace specifies fa_xflags_rw_mask =3D 0, only check =
for
>> >> >> permissions and fileattr support without checking any xflags.
>> >> >>
>> >> >> Behaviour of older programs that already use file_[gs]etattr() is
>> >> >> preserved by checking against FILE_ATTR_SIZE_VER*.
>> >> >>
>> >> >> Also add the missing FS_XFLAG_PROJID xflag, to allow userspace to =
set
>> >> >> the projid using file_[gs]etattr() by leveraging the new masks.
>> >> >>
>> >> >> Finally, in order to prevent the legacy FS_IOC_FSSETXATTR from acc=
epting
>> >> >> FS_XFLAG_PROJID, add a FS_FILE_ATTR_XFLAGS_MASK to support new xfl=
ags
>> >> >> and use it to validate/clamp both the _xflags fields and the masks=
.
>> >> >>
>> >> >> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.11
>> >> >> Signed-off-by: koraynilay <koray.fra@gmail.com>
>> >> >> ---
>> > ...
>> >> >>         err =3D fileattr_set_prepare(inode, &old_ma, fa);
>> >> >> @@ -424,6 +504,14 @@ SYSCALL_DEFINE5(file_getattr, int, dfd, const=
 char __user *, filename,
>> >> >>                 return error;
>> >> >>
>> >> >>         fileattr_to_file_attr(&fa, &fattr);
>> >> >> +       /*
>> >> >> +        * Remove xflags added in or after VER1 so userspace progr=
ams compiled
>> >> >> +        * against VER0 don't try to write xflags they don't know =
about (since
>> >> >> +        * they do RMW).
>> >> >> +        */
>> >> >> +       if (usize < FILE_ATTR_SIZE_VER1)
>> >> >> +               fattr.fa_xflags &=3D FS_XFLAGS_MASK;
>> >> >> +
>> >> >
>> >> > This looks odd.
>> >> > old struct size with new flags should be -EINVAL not silently drop =
them
>> >>
>> >> Right, and the GET path should strip any new flags, so old programs
>> >> doing RMW will never see them, correct?
>> >>
>> >
>> > Yes, I think so.
>> >
>> >> >
>> >> >>         error =3D copy_struct_to_user(ufattr, usize, &fattr,
>> >> >>                                     sizeof(struct file_attr), NULL=
);
>> >> >>
>> >> >> @@ -460,10 +548,6 @@ SYSCALL_DEFINE5(file_setattr, int, dfd, const=
 char __user *, filename,
>> >> >>         if (error)
>> >> >>                 return error;
>> >> >>
>> >> >> -       error =3D file_attr_to_fileattr(&fattr, &fa);
>> >> >> -       if (error)
>> >> >> -               return error;
>> >> >> -
>> >> >>         CLASS(filename_maybe_null, name)(filename, at_flags);
>> >> >>         if (!name && dfd >=3D 0) {
>> >> >>                 CLASS(fd, f)(dfd);
>> >> >> @@ -479,6 +563,30 @@ SYSCALL_DEFINE5(file_setattr, int, dfd, const=
 char __user *, filename,
>> >> >>                         return error;
>> >> >>         }
>> >> >>
>> >> >> +       /*
>> >> >> +        * Userspace said "I don't want to change any flag", so be=
 it I guess.
>> >> >> +        * Still check for fileattr support and permissions, also =
in case this
>> >> >> +        * is just a probe.
>> >> >> +        */
>> >> >> +       if (usize >=3D FILE_ATTR_SIZE_VER1 && fattr.fa_xflags_rw_m=
ask =3D=3D 0) {
>> >> >> +               struct inode *inode =3D d_inode(filepath.dentry);
>> >> >
>> >> >
>> >> > No No this is not what this userspace said!
>> >> >
>> >> > This user space is the same old chattr programs recompiled with a n=
ew
>> >> > fs.h header file
>> >> > installed.
>> >>
>> >> Oh, right, I did not think about this case, I hope it doesn't break t=
oo
>> >> much of the new code I changed already for v2 :(
>> >>
>> >> > When userspace does not set anything is masks it means "old API"
>> >>
>> >> And so a modern program using masks that passes rw_mask as 0 should b=
e
>> >> also interpreted as "old API", even if it kinda goes against the
>> >> definition of rw_mask right?
>> >
>> > Yes, but it is not a problem to describe this backward compat exceptio=
n:
>> > When (rw_mask | ro_mask) =3D=3D 0, it means "no mask" "set everything"
>> > but then vfs will not accept new xflags that were not supported in v0
>> > syscall.
>>
>> Uhm, since we have no way to know on the GET path if the caller is mask
>> aware or not, on mask aware filesystems and legacy programs recompiled
>> against VER1, file_getattr() will return rw_mask !=3D 0, when the progra=
m
>> does RMW, so calling file_setattr() with the old struct which has
>> rw_mask !=3D 0, vfs will think that the caller is mask aware.
>>
>
> True. This is a requirement from the design of v1
> that RMW works correctly when the program does not change the masks.
>
>> This causes problems when that legacy program changes the projid, since
>> vfs will see rw_mask =3D PROJID but fsx_xflags will not have PROJID, vfs
>> will clear it even tho the program wanted to set it to some value.
>>
>
> Yes, this is a specific issue with PROJID itself, not with the
> entire masks API.
>
>
>> Unless I'm missing something, there is no way for us to know if a caller
>> of file_getattr() is a new mask aware program or just a recompiled legac=
y
>> program.
>
> Right.
>
>>
>> My robot proposed 2 fixes: either don't introduce FS_XFLAG_PROJID
>> (which, eh, not the best imo)
>
> Me neither. It's inconsistent IMO.
>
> But it is inconsistent in that we want to have a way for chattr -p to say=
 with
> the new API "set only projid", so we must have the flag, but we
> mostly need it for the mask, we don't really care about its value in
> fsx_flags.
>
>> or add a new flag to be used in at_flags,
>> like AT_FILEATTR_MASKS, which would resolve all our legacy vs non-legacy
>> problems, but it would be in *at*_flags, so doesn't really make sense
>> semantically (but it would work well since file_getattr already rejects
>> unknown at_flags, so it wouldn't cause problems for old programs).
>
> I think this is an overkill as well.

Semantics issue aside, I think this shuold be the way to go, because
it's explicit and doesn't rely on guessing based on struct size or mask
values.

> We discussed this before.
>
> Attributes that have X_value like fsx_projid have few types:
> 1. 0 means disabled (all existing values incl. projid)
> 2. 0 is a valid value but cannot be unset (btime)
> 3. 0 is a valid value and NULL/unset is also a valid value
>
> Only for type 3 does can the interpretation of
> (!XFLAG_X && !fsx_X) be considered as an "unset"
> and anyway, this will require support in individual fs.

IMO !(xflags & XFLAG) && (rw_mask & XFLAG) should clear/unset the value
in all cases, ignoring what's in fsx_X.

And all existing values would be of type 1 for VER0, but of type 1 + 3
for VER1.

> fileattr_set_prepare() already treats the existing values as:
> fsx_X =3D=3D 0 =3D> clear XFLAG_X
>
> And xfs returns EINVAL for !!(fsx_X) !=3D !!(XFLAGX)
>
> A simple solution is to fix the flag according to val in fileattr_set_pre=
pare()
(This should be in file_attr_to_fileattr() I think, but yeah)
> if rw_mask contains this flag:
>
> if (fa->fsx_xflags_rw_mask & FS_XFLAG_PROJID) {
>     /* Possibly legacy chattr -p compiled with new headers unaware of PRO=
JID */
>     if (fa->fsx_projid =3D=3D 0)
>           fa->fsx_xflags &=3D ~FS_XFLAG_PROJID;
>     else
>           fa->fsx_xflags |=3D FS_XFLAG_PROJID;
> }

I think this would be a bit too overcomplicated to understand, and
robot says (with the current v2 code at least) it would make e.g. ntfs
return 0 instead of -EOPNOTSUPP for e.g. chattr +S.

It also told me that statx already has AT_STATX_* flags that don't match
the at_flags semantics (and indeed, AT_STATX_FORCE_SYNC/DONT_SYNC don't
really make sense for "at"_flags semantics), so my only blocker for that
solution is gone and I would really prefer that approach since it's way
simpler and way cleaner.

One more thing gemini told me is that if we don't want to use AT_*, we
have to choose between (copy-pasted, "ntfs" meaning any mask-aware fs):
1. Keep clamping fattr->fa_xflags & rw_user_mask (VER1 masked semantics
   are clean, but recompiled VER0 RMW tools setting unsupported
   flags/projid on ntfs silently return 0)
2. Reject unexpected non-zero bits/fields outside rw_user_mask | ro_mask
   (protects recompiled VER0 RMW error reporting on ntfs, at the cost that
   VER1 callers must zero or mask fa_xflags / fa_projid / fa_extsize
   themselves rather than expecting bits outside rw_mask to be ignored).

So I would *really* prefer adding AT_FILEATTR_MASKS and setting
has_masks based only on that.
This way we can keep the whole legacy path frozen and not have to worry
about weird edge cases (well, converters code aside of course).

And personally in this way I can reason about the changes a lot more
clearly and I can finally take a better look at the whole code and maybe
simplify it in some cases (probably not, but I'll have to see).

(Unless there is something equivalent to AT_FILEATTR_MASKS to filter on,
like maybe a FS_XFLAG_MASKS (?), but that would be even worse
semantically I think)

Thanks,
koraynilay

> Does that leave any problematic corner case?
>
> Thanks,
> Amir.

--e8caff26652db83e371b7bbbf1756842a7f68d613d7cadc16719f19bedf2
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQRJ2XvJtXGwULYEerQ0bnTtJTDoOAUCawdDlAAKCRA0bnTtJTDo
ONCrAP4wS19X15Zd1uxiHUaDnK5f93ecvn/xycDO7CK+uvKZdwD9HC9Tplb/KxkJ
8/e31e481B/iXJEnCBIVupaaR1iwxgg=
=abpA
-----END PGP SIGNATURE-----

--e8caff26652db83e371b7bbbf1756842a7f68d613d7cadc16719f19bedf2--
