Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794844510;
	b=gAj6sG1lDxvNQDpF+L9tiRmvHSyCFZW9jvLuuRiFgNCrPLCxMShzLq0WjtbxawsHpacX
	 wuVrlIkDnJhH+vb2+aQoDaAxf8Pw/wTJcWWoqxnczhFjSvD34aHVBPIRwwKHUauDP4Jk8
	 yfO+DkXFI9wPF3+qOU6XR6TTngIBFsmlNfeEmWbt5RbG5JqGFMVHuqnnT5jMYM2KOZwrr
	 FMc2HJ+L05UTOIPKP2wMkrelk8AfvK+r4d57cYReDQ6BUjhcvvc8lkPm441253FHtguN8
	 iZ9pNdJZvCedmp9MgVU2V3PnrgdYh7mNm1lj6CWkowCppQiHR0ufV1zqCc+P8Tc0qiA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794844510;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Subject:From:To:Cc:X-Mailer:
	 References:In-Reply-To;
	bh=040W0WtrDSqyLSlnE1PnGtn4Yj+G8VjPGcb4tUhpFSw=;
	b=4ZWlsD2ziq0rA/Not/XKI6I8jf6qr4XNjgLd3XKlSpEX2FN51diYZgCBipgzrR4v4E9k
	 4ci1RzT5MRpBCuTJ0LgKBapk37XGT1pyKVnnC4a8fmnkbdAHfUiy9TeG6mxuLjVmsa/ka
	 1k2WIbnayO5uKx5a8IKgiYl5xJaGiQwNSIWp/xZuU/U601QSExIyhRS5V1HH/BTApxqXJ
	 uyKUiop4ZOjzMuWT72b4Yeke0UVDfgL7vzayvj4AosUIcAu5EpnMT356drTZt1/Y9CuLd
	 hOB3jvpsIQACCmzJkYUagWFLdT6h+6oal/P4NF2PQIlz/IMDXUKAEEcXyHzLoN433gA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="pzw1LYv/";
	arc=none smtp.remote-ip=209.85.128.49
Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 439A0606A330
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 15:55:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 439A0606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=pzw1LYv/
Received: by mail-wm1-f49.google.com with SMTP id 5b1f17b1804b1-4a9a8d6cea8so38419865e9.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 07:55:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794844507; x=1795449307; darn=vger.kernel.org;
        h=in-reply-to:references:cc:to:from:subject:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=040W0WtrDSqyLSlnE1PnGtn4Yj+G8VjPGcb4tUhpFSw=;
        b=pzw1LYv/GrIlyi119CS5O4dqTEojMh2PPNb0YLcVL7AgRpRPj91hUHUDLzwGHiIkuC
         5ghAwsq0A9srRmVkNB8Ix2AZMHzK2FSmwfF1fpVV6wSxAgjHZbG1qbtI/8JNO2HgW+r3
         XgDVOXvb5VVxNKCsylQTXVTZZnpIc/RC1U9X4IdocD0LsekYcooCdMYN+Ye/PIugulrR
         bsLdCqNRm/HCjdSVlog5UWaUqIdJSeiekv7v0ydQZt8YByVGiL3lGc9Lkhi/TNtQ+1ll
         hw9b6NezzwKImWenA2JKyQoRtyOhZw4ZVaZluabORLOPZCH4hh4orZFsxIpsVOaBSg97
         1eRQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794844508; x=1795449308;
        h=in-reply-to:references:cc:to:from:subject:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=040W0WtrDSqyLSlnE1PnGtn4Yj+G8VjPGcb4tUhpFSw=;
        b=nM0OVXEbzktBL3d5Gp/ZWbclAbmNYktyGbWxDQ8B8LEOejVHyWSt56kRo0rYkithxA
         tlzF3YoyWayA+TO29W2OdKlwtzwDho7sVs0Aaudza9xbEgill8ZatoqzAJWCGxnpv04Y
         OqxnyuvFyB42fG2VLRDiOvbmBwF8EYgAP+XfD0Z2Cs9mnKpvWiyBajpXLKTe7MrB2aJU
         bCgkE8jOZl7SAezSae1Ssczv0pFp9i2ibnYhH+1I4xz2uUJK1BlKgreQ6h0s5CjbsMZi
         xle3SqIsHZWF6uJihLpvmiTkFMrxHsIlqNagqTW6B8V2e2UE+c5tiNSVMNRPga5Y13DZ
         VdZg==
X-Forwarded-Encrypted: i=1; AL+hErG4MoNQnEiUxRt2iAOSnqluC8opEVCQuo2fVdHhzbpCwye6mMMttdf2s6/W7LR4xdgvVXN3WJcAQIY=@vger.kernel.org
X-Gm-Message-State: APuU4Z8/BhKjtOgaCwGxTmPE5vEcrhW441y98WZ56zdZBt9YRIvbCjcH
	8XVfNnNG1zCTLf51b7waQvO3DR2rti6BKFo/f2QIXmDSKNfIwCumnBKj
X-Gm-Gg: AYBFou2NZraEtU794uD9jdYTvwBpeqK8Zi9jyo862BdpL7/xpFm88awKMmQV5VNLx6V
	+TiiY+SzvigvzAGE+KXu/LhH2nSB/j7lFY/Ubk4QO0XQRtXdPCyzX3R9uwP7KDseIEb5OHpJLnc
	Ftmfk/PXCYHG5Ar0nRPpeiHI+FuGJTG7g03w2yRbv3ElIohhJxUm8oEgZTV9KBG7md81+dgoDCA
	qO/yRmK9cfc6QkMGk0N0iUYGhXg52XV0010/kALHiIxosf321/Sc3x9EAwKLoC3LgiW9s2jXMLr
	p2Ps6qo6x8ik4wqic2kGUflmAONwTjnH+aSDkSnQ5jkIunOp5SWWCO7vh07le5LtzJD3YOWcU4N
	2JkMbS1+oZ1jWSqzlrwJpHjW3SQlwJDhKkpOX6IZxkCfrPR8cNd47Sdd1U+jbD3n7SaLEJrlbht
	lQdU/60NGL9QaxvmrIaRpBnSs3LG9QL6385J4x9GdU3+ypZM3VQoh59ObAsQJs2W5M4ZbnX+ovH
	/QD4xbkfzA/neTRyLL3a9aPCCwgfIrZIjjrSvpHCFqEUpKokgJV8aMmAd3ruA/RZTTqZj+Qzphb
	E6Kq2uscyG6vliOzT/P3pwm7pQ==
X-Received: by 2002:a05:600c:1906:b0:4a1:c6f5:2450 with SMTP id 5b1f17b1804b1-4bb55ac2a34mr244783135e9.17.1794844507334;
        Mon, 16 Nov 2026 07:55:07 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb55ae501bsm321476945e9.10.2026.11.16.07.55.03
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 16 Nov 2026 07:55:05 -0800 (PST)
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
 boundary=f93caca3b757f4039ce5a884d522f788c6958abee5364c6a1026cc96907d;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Mon, 16 Nov 2026 16:55:02 +0100
Message-Id: <DMWR9XOQTPOK.3IDTXWG0BB6CG@gmail.com>
Subject: Re: [RFC PATCH v4 06/10] vfs: add __vfs_fileattr_set_locked() for
 inode_lock()'d callers
From: "koraynilay" <koray.fra@gmail.com>
To: "Amir Goldstein" <amir73il@gmail.com>, "koraynilay"
 <koray.fra@gmail.com>
Cc: "David Sterba" <dsterba@suse.com>, "Namjae Jeon"
 <linkinjeon@kernel.org>, "Sungjong Seo" <sj1557.seo@samsung.com>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>, "Christian Brauner"
 <brauner@kernel.org>, "Trond Myklebust" <trondmy@kernel.org>, "Anna
 Schumaker" <anna@kernel.org>, "Chuck Lever" <cel@kernel.org>, "Jeff Layton"
 <jlayton@kernel.org>, "Konstantin Komarov"
 <almaz.alexandrovich@paragon-software.com>, "Paulo Alcantara"
 <pc@manguebit.org>, "Chris Mason" <mason@kernel.org>, "Yuezhang Mo"
 <yuezhang.mo@sony.com>, "Jan Kara" <jack@suse.cz>, "NeilBrown"
 <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo"
 <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>, "Ronnie Sahlberg"
 <ronniesahlberg@gmail.com>, "Shyam Prasad N" <sprasad@microsoft.com>,
 "Bharath SM" <bharathsm@microsoft.com>, "Sergey Senozhatsky"
 <senozhatsky@chromium.org>, "ChenXiaoSong" <chenxiaosong@chenxiaosong.com>,
 "Darrick J . Wong" <djwong@kernel.org>, "Sean Smith"
 <defendthedisabled@gmail.com>, "Andrey Albershteyn" <aalbersh@kernel.org>,
 "Pedro Falcato" <pfalcato@suse.de>, =?utf-8?q?Pali_Roh=C3=A1r?=
 <pali@kernel.org>, <linux-btrfs@vger.kernel.org>,
 <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
 <exfat@lists.linux.dev>, <ntfs3@lists.linux.dev>,
 <linux-cifs@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
 <linux-api@vger.kernel.org>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261115180343.576773-7-koray.fra@gmail.com>
 <CAOQ4uxgm+JEu2MGnqQrJ00nTJ45S2ECQ7CBOC2QrgniOfkLYAQ@mail.gmail.com>
In-Reply-To: <CAOQ4uxgm+JEu2MGnqQrJ00nTJ45S2ECQ7CBOC2QrgniOfkLYAQ@mail.gmail.com>

--f93caca3b757f4039ce5a884d522f788c6958abee5364c6a1026cc96907d
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Mon Nov 16, 2026 at 2:52 PM CET, Amir Goldstein wrote:
> On Sun, Nov 15, 2026 at 7:04=E2=80=AFPM koraynilay <koray.fra@gmail.com> =
wrote:
>>
>> Currently there is no way for a caller to invoke vfs_fileattr_set()
>> while holding an inode lock without having the kernel go into deadlock.
>>
>> Fix this by moving the vfs_fileattr_set() logic into
>> __vfs_fileattr_set_locked() and making vfs_fileattr_set() a simple
>> wrapper that only handles the inode lock.
>>
>> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
>> Signed-off-by: koraynilay <koray.fra@gmail.com>
>> ---
>>  fs/file_attr.c           | 139 +++++++++++++++++++++++----------------
>>  include/linux/fileattr.h |   2 +
>>  2 files changed, 86 insertions(+), 55 deletions(-)
>>
>> diff --git a/fs/file_attr.c b/fs/file_attr.c
>> index 12610fb6a751..063c81fbfa6a 100644
>> --- a/fs/file_attr.c
>> +++ b/fs/file_attr.c
>> @@ -288,6 +288,89 @@ static int fileattr_set_prepare(struct inode *inode=
,
>>         return 0;
>>  }
>>
>> +/**
>> + * __vfs_fileattr_set_locked - change miscellaneous file attributes whi=
le
>> + * holding the inode lock
>> + *
>> + * @idmap:     idmap of the mount
>> + * @dentry:    the object to change
>> + * @fa:                fileattr pointer
>> + *
>> + * Same as vfs_fileattr_set(), but caller must hold the inode lock.
>> + *
>> + * Return: 0 on success, or a negative error on failure.
>> + */
>> +int __vfs_fileattr_set_locked(const struct mnt_idmap *idmap, struct den=
try *dentry,
>> +                             struct file_kattr *fa)
>> +{
>> +       struct inode *inode =3D d_inode(dentry);
>> +       struct file_kattr old_ma =3D {};
>> +       int err;
>> +
>> +       if (!inode->i_op->fileattr_set)
>> +               return -ENOIOCTLCMD;
>> +
>> +       if (!inode_owner_or_capable(idmap, inode))
>> +               return -EPERM;
>> +
>> +       err =3D vfs_fileattr_get(dentry, &old_ma);
>> +       if (err)
>> +               return err;
>> +
>> +       /* initialize missing bits from old_ma */
>> +       if (fa->flags_valid) {
>> +               /* FS_IOC_SETFLAGS */
>> +               fa->fsx_xflags |=3D (old_ma.fsx_xflags & FS_XFLAGS_MASK)=
 &
>> +                                 ~FS_XFLAG_COMMON;
>> +               fa->fsx_extsize =3D old_ma.fsx_extsize;
>> +               fa->fsx_nextents =3D old_ma.fsx_nextents;
>> +               fa->fsx_projid =3D old_ma.fsx_projid;
>> +               fa->fsx_cowextsize =3D old_ma.fsx_cowextsize;
>> +               fa->fsx_ptime =3D old_ma.fsx_ptime;
>> +       } else {
>> +               /*
>> +                * Preserve unmasked xflags when running file_setattr()
>> +                * with a mask, which doesn't need a read-modify-write
>> +                * so these attributes would be set to 0.
>> +                *
>> +                * With FS_IOC_FSSETXATTR or mask =3D=3D 0 (legacy mode)
>> +                * this is not needed as userspace does
>> +                * read-modify-write already.
>> +                */
>> +               if (fa->fsx_xflags_mask) {
>> +                       fa->fsx_xflags |=3D old_ma.fsx_xflags &
>> +                                         ~fa->fsx_xflags_mask;
>> +                       fileattr_fill_xflags(fa, fa->fsx_xflags &
>> +                                            ~FS_XFLAG_RDONLY_MASK);
>> +                       if (!(fa->fsx_xflags_mask & FS_XFLAG_EXTSIZE))
>> +                               fa->fsx_extsize =3D old_ma.fsx_extsize;
>> +                       if (!(fa->fsx_xflags_mask & FS_XFLAG_PROJID))
>> +                               fa->fsx_projid =3D old_ma.fsx_projid;
>> +                       if (!(fa->fsx_xflags_mask & FS_XFLAG_COWEXTSIZE)=
)
>> +                               fa->fsx_cowextsize =3D old_ma.fsx_cowext=
size;
>> +               }
>> +               fa->flags |=3D old_ma.flags & ~FS_COMMON_FL;
>> +
>> +               /* xflags not present in fsxattr */
>> +               if (!(fa->fsx_xflags_mask & FS_XFLAG_PTIME))
>> +                       fa->fsx_ptime =3D old_ma.fsx_ptime;
>> +       }
>> +
>> +       err =3D fileattr_set_prepare(inode, &old_ma, fa);
>> +       if (err)
>> +               return err;
>> +       err =3D security_inode_file_setattr(dentry, fa);
>> +       if (err)
>> +               return err;
>> +       err =3D inode->i_op->fileattr_set(idmap, dentry, fa);
>> +       if (err)
>> +               return err;
>> +       fsnotify_xattr(dentry);
>> +
>> +       return 0;
>> +}
>> +EXPORT_SYMBOL(__vfs_fileattr_set_locked);
>> +
>>  /**
>>   * vfs_fileattr_set - change miscellaneous file attributes
>>   * @idmap:     idmap of the mount
>> @@ -308,7 +391,6 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap, =
struct dentry *dentry,
>>                      struct file_kattr *fa)
>>  {
>>         struct inode *inode =3D d_inode(dentry);
>> -       struct file_kattr old_ma =3D {};
>>         int err;
>>
>>         if (!inode->i_op->fileattr_set)
>> @@ -318,60 +400,7 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap,=
 struct dentry *dentry,
>>                 return -EPERM;
>>
>>         inode_lock(inode);
>> -       err =3D vfs_fileattr_get(dentry, &old_ma);
>> -       if (!err) {
>> -               /* initialize missing bits from old_ma */
>> -               if (fa->flags_valid) {
>> -                       /* FS_IOC_SETFLAGS */
>> -                       fa->fsx_xflags |=3D (old_ma.fsx_xflags & FS_XFLA=
GS_MASK) &
>> -                                         ~FS_XFLAG_COMMON;
>> -                       fa->fsx_extsize =3D old_ma.fsx_extsize;
>> -                       fa->fsx_nextents =3D old_ma.fsx_nextents;
>> -                       fa->fsx_projid =3D old_ma.fsx_projid;
>> -                       fa->fsx_cowextsize =3D old_ma.fsx_cowextsize;
>> -                       fa->fsx_ptime =3D old_ma.fsx_ptime;
>> -               } else {
>> -                       /*
>> -                        * Preserve unmasked xflags when running file_se=
tattr()
>> -                        * with a mask, which doesn't need a read-modify=
-write
>> -                        * so these attributes would be set to 0.
>> -                        *
>> -                        * With FS_IOC_FSSETXATTR or mask =3D=3D 0 (lega=
cy mode)
>> -                        * this is not needed as userspace does
>> -                        * read-modify-write already.
>> -                        */
>> -                       if (fa->fsx_xflags_mask) {
>> -                               fa->fsx_xflags |=3D old_ma.fsx_xflags &
>> -                                                 ~fa->fsx_xflags_mask;
>> -                               fileattr_fill_xflags(fa, fa->fsx_xflags =
&
>> -                                                    ~FS_XFLAG_RDONLY_MA=
SK);
>> -                               if (!(fa->fsx_xflags_mask & FS_XFLAG_EXT=
SIZE))
>> -                                       fa->fsx_extsize =3D old_ma.fsx_e=
xtsize;
>> -                               if (!(fa->fsx_xflags_mask & FS_XFLAG_PRO=
JID))
>> -                                       fa->fsx_projid =3D old_ma.fsx_pr=
ojid;
>> -                               if (!(fa->fsx_xflags_mask & FS_XFLAG_COW=
EXTSIZE))
>> -                                       fa->fsx_cowextsize =3D old_ma.fs=
x_cowextsize;
>> -                       }
>> -                       fa->flags |=3D old_ma.flags & ~FS_COMMON_FL;
>> -
>> -                       /* xflags not present in fsxattr */
>> -                       if (!(fa->fsx_xflags_mask & FS_XFLAG_PTIME))
>> -                               fa->fsx_ptime =3D old_ma.fsx_ptime;
>> -               }
>> -
>> -               err =3D fileattr_set_prepare(inode, &old_ma, fa);
>> -               if (err)
>> -                       goto out;
>> -               err =3D security_inode_file_setattr(dentry, fa);
>> -               if (err)
>> -                       goto out;
>> -               err =3D inode->i_op->fileattr_set(idmap, dentry, fa);
>> -               if (err)
>> -                       goto out;
>> -               fsnotify_xattr(dentry);
>> -       }
>> -
>> -out:
>> +       err =3D __vfs_fileattr_set_locked(idmap, dentry, fa);
>>         inode_unlock(inode);
>>         return err;
>>  }
>> diff --git a/include/linux/fileattr.h b/include/linux/fileattr.h
>> index ba7ed3b387d8..7ff62ee27e58 100644
>> --- a/include/linux/fileattr.h
>> +++ b/include/linux/fileattr.h
>> @@ -97,6 +97,8 @@ static inline bool fileattr_has_fsx(const struct file_=
kattr *fa)
>>  int vfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa);
>>  int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dent=
ry,
>>                      struct file_kattr *fa);
>> +int __vfs_fileattr_set_locked(const struct mnt_idmap *idmap, struct den=
try *dentry,
>> +                             struct file_kattr *fa);
>
> There is no reason for __ prefix here and I think it should be discourage=
d for
> global scope if possible.

Ah ok, I copied what had been done for __vfs_setxattr_locked() /
vfs_setxattr() and __vfs_removexattr_locked() / vfs_removexattr(), but I
agree that __ makes it more "internal", I'll change it for v5.

Thanks,
koraynilay

> Thanks,
> Amir.



--f93caca3b757f4039ce5a884d522f788c6958abee5364c6a1026cc96907d
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQSgVimKafU5DQMcjcDmj22qf5IGXAUCavsnVgAKCRDmj22qf5IG
XC40APwLpgC2qCi2ygC417CAeeBgnvIyXQNVw3WOnFMBGg8tUQEAsuqI0c//BtxD
+1WkW5Y6mUri16pC/bv/iBr7lSbFFAs=
=Rkz6
-----END PGP SIGNATURE-----

--f93caca3b757f4039ce5a884d522f788c6958abee5364c6a1026cc96907d--
