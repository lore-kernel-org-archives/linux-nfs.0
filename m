Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.41
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795113145;
	b=BocienH7U0g2Y6D/6E8uqu0HNTkUJCBEjA89GDv6fdTCLIsMDeqIcaJZSoErvzLJK7jj
	 oBc8gU3SjY5GJ+fbfnKX+CJKIAMIy6bo8Rr5f+5s+Da7NAwoVSETcunMUcEut8JTDqgUX
	 WIbXjavbzu8Tmg/vuJsOwFbftXC/2yGpv0WuruJvX2IbDb4gvJSJ2erU0eIGDp8I+a9qs
	 QjAblAfOEWLo2EtRW5eaniQO4aIdl3E4QH3J9pjrhVCvo22Zx5+ZoI3e2haJ0zPr0Hdag
	 SEu8Pvpna4SSk8vWMpBDViTY2B1tVjliHG31VFs2LNnXtkCKC75zjO+iB0Tz27l+b0Q==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795113145;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=do8AhcFcymjyMXuuyLMWkfZBB+M/goVAPJ9PX2rsTSo=;
	b=zDSrhRYOhEdcjcEE2Nt++ZDaKKHnuNSYwg1SZsEYh1C1Yb3sdWhcK4UmSKRKutNLepD8
	 qfK/4k76vMc+RhnHPSK7WRgGRI2RY6il33Vcm6JdOKKw5DjsxUX06qty4/XlAzVO5VCMO
	 rmkuH0cW0vtl2Kzmu6ZTIhPLDnFFtWm71fKmm83IsAJfRQK0DGEuii9ozjecg9HyNW8Tk
	 2GD/xIpdBZMiG1YhwSy6MN47+DU40jT99Ocsf5SObruFPG3Hw/2k2iRd2tvsendKztPd5
	 HIaBmHZTlDRe9Y4LCMk/K4gjit0io6d3Wqjz9eIsyNnrTq+0QJfmrHAGtn7HI5Febug==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=sCxV8h+i;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.41
Received: from mail-ed1-f41.google.com (mail-ed1-f41.google.com [209.85.208.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4AACD60A261E
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 18:32:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4AACD60A261E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=sCxV8h+i
Received: by mail-ed1-f41.google.com with SMTP id 4fb4d7f45d1cf-6ae305e3bd9so110171a12.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 10:32:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795113140; cv=none;
        d=google.com; s=arc-20260327;
        b=Hn0OpNDFnI5aQUQefFQChYyRckoSzz2SV256QCDiETg/udKtasphMGf1pGkLwIg3Wc
         D8plBJNPaIRIuGhSKW+LHfFY3iUll5Oh6P5r5Px4vr7SL/UgH3wJhtCW6EqtZyciCgAO
         eqzzcusKO3gNX+EUnB6m5S0Ayl29kXJETSsyS0Ueul3AA5htKI/Tp7kJWwiZhFKAYoQU
         dgWvAs6jKjrsmHJ/oy5Gsbg3BVxQCxGLExPFU87xJWGWy+yQwoAps5R8EhwVrAjgnDAe
         yfCNa8K28HyRLY1I1p82NmhLG1mPx4WixzoB0u/i1onuV9WNbbjeGUSLbsr2eRfVixrk
         K+qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=do8AhcFcymjyMXuuyLMWkfZBB+M/goVAPJ9PX2rsTSo=;
        fh=MHjXA5m+lslh+7sDHJC8xdHRUS8rxlPLvoMVAtQuMa0=;
        b=mJmdSq314RMZ9g1HI4LsoaHziXbr+bWXp4PI0i1ZsbN+3V/MjKscCS20Wd4iBZjdlY
         6qDTIdTJ6BdIjmLssjL2PE5xAZoO/tzGwd6m63IljJ+BSa085XxOpOwkG8ykEAzdEhTT
         5Qpuj/8QVE35AfciXqKBOff7vckjm+91gBdAcJyw7kFqWigxwGuk47FgqyR5M4sf2T2y
         xa2HaQz8ADhgqvgvzaDL5utV5ORtAAKoxpVLS23qyrOwkKtWJ4RNKeeYOEoHiuVy3/Hw
         eZTJ6HCNl0gRSkBbtzT9pr6b3V7jYKaj5wwAMa/nT3xzlhntsrss9iMohXiP3/wpwoJP
         /S4Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795113140; x=1795717940; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=do8AhcFcymjyMXuuyLMWkfZBB+M/goVAPJ9PX2rsTSo=;
        b=sCxV8h+iiQ7lmYe/IieVIpTSEpxzn/NNB5DcDdyRi6meZiwSTxjzcGONImdywY8fIW
         k4QNFycfeIpinPwB/9E3kYllKP1snyHCthyylaQGBUjOUBzdwFU8D3jZH9OoXTmTI+DD
         OVVJ4LYp5poQoCcnX71WaQgN7gPMvU7HIWTS8Vko4mDFoBV6vwNaedECADbdHm/tM7c0
         Xclcgz/HLOPgA8somrbNHhp32UNMLsZD/ggx7F9UliKBLcAveGG6OWq5scsYUVhkkSU8
         qG3Xej2GEVHk2OStkMmJdQYBrzA1aEw5477u4wQDug1J/3QbfQa/e7A0ULn0Ol5IkohZ
         jdFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795113140; x=1795717940;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=do8AhcFcymjyMXuuyLMWkfZBB+M/goVAPJ9PX2rsTSo=;
        b=iXqWhg2VSiylBFhNUTgM/MW03pEog8ax9A6lk5k5yoUSnBJvo8OcQQ+Dt6dAhu3072
         ODfdM0T+rlhOeV1/6tfSBsVzVBSZMASZgmhTTMC3HYU6aR+9ZGIR+3PJrhI6K3pOjnkE
         PZPL1qf6ZR3eGBuInf2H5DTiyiF6mUJCsd95MLi8oDhAKssXd6j0QdRSuxT3k10j5gfL
         oDImPdHcCvgjn9c4tMz3LthuPC6pir2itkt+PWTyaKgvLFpDLPhLrsPd5xDXR2rOnmV0
         uf3POJUZBuJize2GHAls0kvG5SVuMVeN6JNjAVBSF8RKCVlSgzUTlYTXriB/r61r2ygZ
         Jrbw==
X-Forwarded-Encrypted: i=1; AL+hErElE/5LqpwSq93fQigvMNt6dhSBQVQbJjI/ewXo3xVtmavyGmu3piLXhkQBBUc8lTJh2atGeVqyruY=@vger.kernel.org
X-Gm-Message-State: APuU4Z+iYVlRuZC7nWftluL1KF9tHRrLKM0N2pX3fBXz/go34nb4Ongh
	uylCRRXklFSgvdbwhEOFRib10aGeY534jQ6blikVJUgl3EcTWATvWTatLQ4H2m22iJgpHfDNCfH
	iRW8p+gm5FkrDWdrN4oy++LqfXFFnv/U=
X-Gm-Gg: AYBFou3ByyW2os1Xe93ff2oP4Pbr+vhMZi5bllKGVCdAmHvTCUGpwgM2mXB/fFnLLs6
	PMFTJlfDJfffCSNDauy8YadPdZJBatfG2YzqVR8xx37e0i3qIy+qH5OxDednmaKGDfXfAouLsJ/
	wh1nv5bu+afZMeYnNK0LMJ4dxBdzoWuV0LvW3idFL4VPa4hOpriYwBCEEs7HKIO6XtR3zghz5rL
	/RzvwCnXs6CaWoqqPjCtu8e4zIwOgIIyE51ybUm5XAJc6jq+XSr3uyU57pR8Y70rK+HablXhCj9
	asOZGIpsbY/mpm9FuRiVFazScYqzTc0CWFohSE+S9hdwnLKrJ70o8pJmUKLVZUz7SSKMOUjmvP7
	oDW50n8IR5Je4JrWc8Misx+UOuCiM7HJxyxtKj0ba1snB33S2uOZQB9W5jX810ANLYLQ43g==
X-Received: by 2002:a05:6402:104f:b0:6b4:641:baed with SMTP id
 4fb4d7f45d1cf-6ba37e9568fmr148084a12.30.1795113139463; Thu, 19 Nov 2026
 10:32:19 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <20261115180343.576773-11-koray.fra@gmail.com>
In-Reply-To: <20261115180343.576773-11-koray.fra@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 19 Nov 2026 19:32:08 +0100
X-Gm-Features: Aa3M54o3FyARyR35RQ4tLjj8adRb1WJj3a2qKLwAAXLtUiEUmkOWywN3Z5RLnkA
Message-ID: <CAOQ4uxg2gpC99ohuvKm-SgPzuffJy1fSvXorbuBnYZ=OFSxT3w@mail.gmail.com>
Subject: Re: [RFC PATCH v4 10/10] cifs: add provenance time (ptime) and map it
 to SMB's CreationTime
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
	linux-api@vger.kernel.org, Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Nov 15, 2026 at 7:04=E2=80=AFPM koraynilay <koray.fra@gmail.com> wr=
ote:
>
> Implement provenance time (ptime) in cifs, as introduced in a
> previous commit ("vfs: add provenance time (ptime)").
>
> Map it to SMB's CreationTime, making it settable from userspace and
> propagating it to the SMB server via FILE_BASIC_INFO.
>
> Support reading ptime via statx(2) and fileattr_get() from the cached
> CreationTime.
>
> Update cifs_fileattr_set() to check xflags instead of only legacy flags
> and add the cifs_set_file_crtime() helper to wrap the RPC call to the
> SMB server.
>
> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
> Signed-off-by: koraynilay <koray.fra@gmail.com>
> ---
>  fs/smb/client/cifsfs.c |   8 +++
>  fs/smb/client/inode.c  |   7 ++-
>  fs/smb/client/ioctl.c  | 109 ++++++++++++++++++++++++++++++-----------
>  3 files changed, 94 insertions(+), 30 deletions(-)
>
> diff --git a/fs/smb/client/cifsfs.c b/fs/smb/client/cifsfs.c
> index 8cff7857b450..c2f557e406d3 100644
> --- a/fs/smb/client/cifsfs.c
> +++ b/fs/smb/client/cifsfs.c
> @@ -1307,6 +1307,14 @@ int cifs_fileattr_get(struct dentry *dentry, struc=
t file_kattr *fa)
>         if (READ_ONCE(CIFS_I(inode)->cifsAttrs) & ATTR_COMPRESSED)
>                 fa->flags |=3D FS_COMPR_FL;
>
> +       /* Report provenance time (ptime) to userspace */
> +       if (CIFS_I(inode)->createtime) {
> +               fa->fsx_xflags |=3D FS_XFLAG_PTIME;
> +               fa->fsx_xflags_mask |=3D FS_XFLAG_PTIME;
> +               fa->fsx_ptime =3D
> +                     cifs_NTtimeToUnix(cpu_to_le64(CIFS_I(inode)->create=
time));
> +       }
> +
>         /*
>          * FS_CASEFOLD_FL is defined by UAPI as a folder attribute,
>          * and userspace tools (e.g., lsattr) display it only on
> diff --git a/fs/smb/client/inode.c b/fs/smb/client/inode.c
> index 2647785ec1e4..f0b20a72b9c2 100644
> --- a/fs/smb/client/inode.c
> +++ b/fs/smb/client/inode.c
> @@ -222,6 +222,7 @@ cifs_fattr_to_inode(struct inode *inode, struct cifs_=
fattr *fattr,
>
>         cifs_i->cifsAttrs =3D fattr->cf_cifsattrs;
>         cifs_i->reparse_tag =3D fattr->cf_cifstag;
> +       cifs_i->createtime =3D fattr->cf_createtime;
>
>         if (fattr->cf_flags & CIFS_FATTR_NEED_REVAL)
>                 cifs_i->time =3D 0;
> @@ -2958,7 +2959,8 @@ int cifs_getattr(const struct mnt_idmap *idmap, con=
st struct path *path,
>          * We need to be sure that all dirty pages are written and the se=
rver
>          * has actual ctime, mtime and file length.
>          */
> -       if ((request_mask & (STATX_CTIME | STATX_MTIME | STATX_SIZE | STA=
TX_BLOCKS)) &&
> +       if ((request_mask & (STATX_CTIME | STATX_MTIME | STATX_PTIME
> +                            | STATX_SIZE | STATX_BLOCKS)) &&
>             !CIFS_CACHE_READ(CIFS_I(inode)) &&
>             inode->i_mapping && inode->i_mapping->nrpages !=3D 0) {
>                 rc =3D filemap_fdatawait(inode->i_mapping);
> @@ -2992,6 +2994,9 @@ int cifs_getattr(const struct mnt_idmap *idmap, con=
st struct path *path,
>                 stat->result_mask |=3D STATX_BTIME;
>                 stat->btime =3D
>                       cifs_NTtimeToUnix(cpu_to_le64(CIFS_I(inode)->create=
time));
> +               stat->result_mask |=3D STATX_PTIME;
> +               stat->ptime =3D
> +                     cifs_NTtimeToUnix(cpu_to_le64(CIFS_I(inode)->create=
time));
>         }
>
>         stat->attributes_mask |=3D (STATX_ATTR_COMPRESSED | STATX_ATTR_EN=
CRYPTED);
> diff --git a/fs/smb/client/ioctl.c b/fs/smb/client/ioctl.c
> index bb8808289a46..19a9556d39b4 100644
> --- a/fs/smb/client/ioctl.c
> +++ b/fs/smb/client/ioctl.c
> @@ -181,6 +181,41 @@ static int cifs_set_compression(unsigned int xid, st=
ruct dentry *dentry,
>                                             compression_state);
>  }
>
> +static int cifs_set_file_crtime(unsigned int xid, struct dentry *dentry,
> +                               struct cifs_tcon *tcon, u64 crtime)
> +{
> +       struct inode *inode =3D d_inode(dentry);
> +       struct TCP_Server_Info *server =3D tcon->ses->server;
> +       FILE_BASIC_INFO info_buf =3D {};
> +       const char *full_path;
> +       void *page;
> +       int rc;
> +
> +       if (!server->ops->set_file_info)
> +               return -EOPNOTSUPP;
> +
> +       info_buf.CreationTime =3D cpu_to_le64(crtime);
> +
> +       page =3D alloc_dentry_path();
> +       full_path =3D build_path_from_dentry(dentry, page);
> +       if (IS_ERR(full_path)) {
> +               rc =3D PTR_ERR(full_path);
> +               goto out;
> +       }
> +
> +       rc =3D server->ops->set_file_info(inode, full_path, &info_buf, xi=
d);
> +       if (rc =3D=3D 0) {
> +               CIFS_I(inode)->createtime =3D crtime;
> +               CIFS_I(inode)->time =3D 0;
> +               inode_set_ctime_current(inode);
> +       }
> +
> +out:
> +       free_dentry_path(page);
> +       return rc;
> +}
> +
> +#define CIFS_SUPPORTED_XFLAGS (FS_XFLAG_PTIME)
>  int cifs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dent=
ry,
>                       struct file_kattr *fa)
>  {
> @@ -193,49 +228,65 @@ int cifs_fileattr_set(const struct mnt_idmap *idmap=
, struct dentry *dentry,
>         bool enable_compression;
>         struct cifs_tcon *tcon;
>         unsigned int xid;
> -       int rc;
> +       int rc =3D 0;
>
> -       if (!fa->flags_valid)
> +       if (fileattr_has_fsx_mask(fa, CIFS_SUPPORTED_XFLAGS))
>                 return -EOPNOTSUPP;

What is this supposed to check that is not already checked
explicitly with fsx_xflags_mask below?

>
> -       /*
> -        * chattr writes back all flags returned by fileattr_get(). Accep=
t
> -        * FS_CASEFOLD_FL only when it reflects the share's casefold stat=
e.
> -        */
> -       if (fa->flags & FS_CASEFOLD_FL) {
> -               rc =3D cifs_fileattr_get(dentry, &current_fa);
> -               if (rc)
> -                       return rc;
> -               if (current_fa.flags & FS_CASEFOLD_FL)
> -                       allowed |=3D FS_CASEFOLD_FL;
> -       }
> -       if (fa->flags & ~allowed)
> +       if (fa->fsx_xflags_mask & ~CIFS_SUPPORTED_XFLAGS)
>                 return -EOPNOTSUPP;
>
> -       enable_compression =3D fa->flags & FS_COMPR_FL;
> -       compression_state =3D enable_compression ? COMPRESSION_FORMAT_DEF=
AULT :
> -                                                COMPRESSION_FORMAT_NONE;
> +       if (fa->flags_valid) {
> +               /*
> +                * chattr writes back all flags returned by fileattr_get(=
). Accept
> +                * FS_CASEFOLD_FL only when it reflects the share's casef=
old state.
> +                */
> +               if (fa->flags & FS_CASEFOLD_FL) {
> +                       rc =3D cifs_fileattr_get(dentry, &current_fa);
> +                       if (rc)
> +                               return rc;
> +                       if (current_fa.flags & FS_CASEFOLD_FL)
> +                               allowed |=3D FS_CASEFOLD_FL;
> +               }
> +               if (fa->flags & ~allowed)
> +                       return -EOPNOTSUPP;

This whole mess could be sorted out by switching the cifs
implementation to the new API and implementing a generic vfs
helper which does something like the above code to handle the
old ioctls.

FS_XFLAG_CASEFOLD would then be removed from
FS_XFLAG_RDONLY_MASK and set explicitly in xflags_ro_mask
by fs which don't allow to set if (e.g. nfs) and added to
FS_COMMON_FL/FS_XFLAG_COMMON

cifs would advertise FS_XFLAG_CASEFOLD in its ro_mask
and then the generic helper would mask it and the new syscall
will not allow it.

> +       }
>
>         tlink =3D cifs_sb_tlink(cifs_sb);
>         if (IS_ERR(tlink))
>                 return PTR_ERR(tlink);
>         tcon =3D tlink_tcon(tlink);
> -
>         xid =3D get_xid();
> -       rc =3D cifs_set_compression(xid, dentry, tcon, NULL, compression_=
state);
> -       free_xid(xid);
> -       cifs_put_tlink(tlink);
>
> -       if (!rc) {
> -               spin_lock(&inode->i_lock);
> -               if (enable_compression)
> -                       CIFS_I(inode)->cifsAttrs |=3D FILE_ATTRIBUTE_COMP=
RESSED;
> -               else
> -                       CIFS_I(inode)->cifsAttrs &=3D ~FILE_ATTRIBUTE_COM=
PRESSED;
> -               spin_unlock(&inode->i_lock);
> +       /* modern xflags */
> +       if (fa->fsx_valid) {
> +               if (fa->fsx_xflags_mask & FS_XFLAG_PTIME) {
> +                       rc =3D cifs_set_file_crtime(xid, dentry, tcon,
> +                                                 cifs_UnixTimeToNT(fa->f=
sx_ptime));
> +                       if (rc)
> +                               goto out;
> +               }
> +       } else if (fa->flags_valid) { /* legacy flags */
> +               enable_compression =3D fa->flags & FS_COMPR_FL;
> +               compression_state =3D enable_compression ? COMPRESSION_FO=
RMAT_DEFAULT :
> +                                                        COMPRESSION_FORM=
AT_NONE;
> +
> +               rc =3D cifs_set_compression(xid, dentry, tcon, NULL, comp=
ression_state);
> +
> +               if (!rc) {
> +                       spin_lock(&inode->i_lock);
> +                       if (enable_compression)
> +                               CIFS_I(inode)->cifsAttrs |=3D FILE_ATTRIB=
UTE_COMPRESSED;
> +                       else
> +                               CIFS_I(inode)->cifsAttrs &=3D ~FILE_ATTRI=
BUTE_COMPRESSED;
> +                       spin_unlock(&inode->i_lock);
> +               }
> +               cifs_dbg(FYI, "set compress flag rc %d\n", rc);

I think that the roadmap should be to slowly define all the old FS_*_FL
flags as FS_XFLAGS_* and let the generic helpers deal with the conversion.

No need to do that now, as part of this patch set which is complicated
enough, just need to see the road ahead of us that we have a way
forward out of this messy flags_valid/fsx_valid inside filesystem
implementations.

My understanding is that Miklos introduced those hints to reduce the
work needed per filesystem for the initial implementation of the
vfs methods.

But it is not so hard to convert one filesystem at a time in a way that
fa->fsx_valid will have to be true, because, for example, here
all the relevant flags would be supported by the new xflags API.

Thanks,
Amir.
