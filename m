Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.48
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794859828;
	b=CZt8iRKDLYRT+pYfBud2Zra7uDMt2Fy4rKPso8BoAGEqcs/B63EObxjNRYdAdZImOeTK
	 CpQV/JBkZOKcZ/ra+Ti2WpIvq4G0HO4S5acvZd8l1C11l+mV9ufKcHjHjT+jHeKF9e2vs
	 KQ9DcGZVIqVaTtuRAoLw3iNJdt0MNtOaNwEuwLQf/nYv1wlARZQKdAyFeDC6AnYIxEuq+
	 3fV+aBMnB8IRhb1ke9Dr2AjpUIl+M2147+Cxs+jSq2jzsSsdTbAWDd2bmIkJOgYTRM99B
	 wZI+rqo7R1n2gkwx2Wb1g1Hn0D1SEIZ9NyYX9muhshrMiYLhvgY+ke/mslzaeYVVPjA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794859828;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=ysm1ObvRHi8QkErB3cHCKWgyx+Xhy7Q4KWF6rBHGU1o=;
	b=N38AmnROh+oET6yFykWxMdocP5u8QUeXBvaYnH6gPQGyNyA9WCs6pwZg3ZiJA8DvtZ25
	 s3SGZOfvf25TGETcZc0DUqT9YkMIackhu2NsDMeNo9kDm7nSNqlPIu3zgZRC7yI/Vsu6G
	 KLuBpCXF/kRy2eSLIbarFhWcG2FZ1q+1irJntbmqfGdM4U9PsVDimwqYjsWuGs2AlGY0U
	 SjGAGSul/7X++92Fh5wkeRnt32yF0mt4aF7Rs0PLdq4APhUeFiiKjuRYaHgeRLC8nzWd4
	 difkJh5nhMYk5Jmwcf3vohplcrJU3F96N5G3KhwKn/DfPR/bHEbX53rYU9RRssbuIbg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=WOxtFWMy;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.48
Received: from mail-ed1-f48.google.com (mail-ed1-f48.google.com [209.85.208.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D3B2F606A33B
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 20:10:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D3B2F606A33B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=WOxtFWMy
Received: by mail-ed1-f48.google.com with SMTP id 4fb4d7f45d1cf-6b408f2d936so5953872a12.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 12:10:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794859823; cv=none;
        d=google.com; s=arc-20260327;
        b=Z1b/1Emb41zLdJvUp+VFCjewOdnDG+LQ0zD15QdpUNXlxxGrTT3/WgwqCXEv9UOUlE
         XJEw4l1BWCCztsxHBCiswFr1dRU61hTIVQDnLsTomZbSsSHe/DqVNpQfW90DVXmc9571
         RJ4v1AbW6O3WaKzOx5fzRN8Fvdl4bKMXIn4OLaaUZQ6gzvCDIXN8tAizJUz1cLoJGDrC
         ZL9O2UOj1aEf+ydMTPyrRX4Y7BCYSom3knKZp3tkBylLwMoBKgZcYvrvBD5IvzPLfI5w
         f+MIHDgOO/CxCsq+5HKpvtRujbssDso+XxZjtd9lQMLc1fPlA6RWR4mERwOqVNTgZz3L
         rIxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ysm1ObvRHi8QkErB3cHCKWgyx+Xhy7Q4KWF6rBHGU1o=;
        fh=+d4oAo/V8iCXYdGcDoBPNmILOSS1ZdxFAz0wHr+isV8=;
        b=jbnm8Ya379NrYmJSXBgS85j1FlXsbv4h+6GPFDVOP3hImGiqBWMkAejwMLL9a/AadA
         yZ+jgm/cI6JluaGkBtBPXYjqi0MKLKzuGYl3+lK7yIjmXar4gmI+sya9G1N3V27B0kUr
         UylZP8InjarP52YgZ60haq+BY/XydA7ewps+3T1C6NwVwaY2nLmVTheZIUZs8xGlUfuJ
         0RNzduX4VR/HdTMZn1DIphnOATnyenolmEm4Qxhr+yZCBam/hoRlVPWVccv5++dRIOl/
         xY5xAnPGKRvHxLPM2OFGcTWR7YM3g1R2Q6BU3qIFDpdYWzVl5c+lLFiIWk8ln6N7nF9i
         E/Kw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794859823; x=1795464623; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=ysm1ObvRHi8QkErB3cHCKWgyx+Xhy7Q4KWF6rBHGU1o=;
        b=WOxtFWMyKSPKodrqO+mGvFaJ85nCUDAL1UbckpoCKdZZSDr6KLP1X3+k/+dUDOnHsz
         Liv0XREDYRmthCicNGPv20LYm7ELc2RuwqA4Qa7jKGzmBys8KG0igoBS5BLir3B/I5Oi
         /bgRuIn+89jEfgoRFFsF4kxmgi+DuU8n5fJ3Rg4LrQkfy2rePKI3IipY7ZyCU5oGLJVq
         PSha1QRCep6BbWSr4yXUqyOX3gDVTapQFi10/X2ht30305k3ESrBvJ7NkpVVSXa6XAsH
         nbsd+tFu6FNI6TlqkTQduwEBjohtbx6EC8CpwweOUWlftKpCXtgRzKyhkQ87oy+TaMVf
         TxdQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794859823; x=1795464623;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ysm1ObvRHi8QkErB3cHCKWgyx+Xhy7Q4KWF6rBHGU1o=;
        b=rOQF1baDJ+qDpGLoY8t8HWyI/eqVlE5JL1ygq6SLngq53pKIiXl8kWKTSCAlrxjzo5
         RPOu0T9e+69tzJM+Bxl3Uporj0/LUzu7JvgENqnBDmHRQITnwrSh0FFo5vZHJ1GrAqoF
         5yxHefSPGUZD3MI6qsJxZrvQDxtzjrtchuybhQBUUDaWUmP3K+4Tarc4rY0MxvMGw6jj
         IsorANabUyVPEJxthwK6lfd3dhHHunP+GSnRevoSO8q5XLswNTktAyjqF41utEfX/6nR
         v5FJQt3aOVvbB8xiiiZc/TKruFpcIrrAtbooG1ZBHTD5Wj1s7fnYzmVUx7izFeelzndE
         WhBg==
X-Forwarded-Encrypted: i=1; AL+hErGd72RsJTtV61nOKP3JZeT9udQptXkZQgTLwhRXnMJmC4YR0spSuq5C4X0dT1JR9YQRmsHLImlndx4=@vger.kernel.org
X-Gm-Message-State: APuU4Z+SDVkZvnLfKr5we+ZsA3OyzQwVTz08tEDSuaYuemCihxg7PeK3
	vlSkbWkEGIi48NGI1H1+u8DLuV17sUCOFvji42z3WPaJgag0EWC4jULealRtfXE2qmWkO3lBbyB
	tpbG5VILnyJgb8sW44eZ3/4iQomduAaA=
X-Gm-Gg: AYBFou0fP7zUIpxLvGuKrQMYv9i2ZTF9a6HvQxFmI2KeeCWkxM2XVxTqSkg8QA7EFiA
	bf3WM1m3sswtZsCO9S/ZDmCZy4pj6hmp+RoB1UeVIEMfI3rq5aDO2cb9PAsqVXg813y4+zSUvnH
	JbgZBRBQhJV+IFLhpUHJU1vj6p+ZgYBT7Ps6wMm1e/7H0ztqbZ0bB6wc21kuYvaHsnrReScZhVr
	3+o0Aq8BxRexKFc4l0RXxWcFitiV8SV0jt58fC3YVmuBiRRgTsVQvN8agtMCapEWtJ5h5e7BQWO
	CMhDrNxNcLd31TpFPvb8XSBfe/P3fTnYwwzz/fMCcLS2w14IrdEYiwHKeod5nfDH44ripj06ANz
	x878N1Q0b+C7Wr+lTN5DqNbjzQOGNTeM3r99dwqd0vLVCkdrKRZ918jqcluz4CX+gJVXygA==
X-Received: by 2002:a17:907:802:b0:c29:5172:6151 with SMTP id
 a640c23a62f3a-c5096415a37mr947928266b.45.1794859823120; Mon, 16 Nov 2026
 12:10:23 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <20261115180343.576773-2-koray.fra@gmail.com>
In-Reply-To: <20261115180343.576773-2-koray.fra@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 16 Nov 2026 21:10:11 +0100
X-Gm-Features: AclHuK8HNkwAKAuOh7lYPiqcrySU8WxcW1gHG_-7Ti6IFMhOniGdmSp4CPwzuwg
Message-ID: <CAOQ4uxi+50NU8qzg+Owvr8gFZ4vYF5FqWg4Hr9vB6ONUpPsFwg@mail.gmail.com>
Subject: Re: [RFC PATCH v4 01/10] vfs: add provenance time (ptime)
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
> Add provenance time (ptime), indicating the time when a file or
> directory was created. This is user-settable via file_setattr() and
> retrievable via statx(2) (using STATX_PTIME) or file_getattr().
>
> The semantics of when to preserve this new timestamp are the same as
> mtime, the idea being that there is a correspondence like this:
>
> ctime <-> btime
> mtime <-> ptime
>
> so every operation (copying, moving, ...) that currently preserves mtime
> should also preserve ptime.
>
> Also add fa_xflags_mask to struct file_attr (and equivalent

That is a very big "Also" part
This is a significant UAPI change that needs to be delivered and
explained with a patch on its own.

> fsx_xflags_mask to struct file_kattr) to let the filesystems advertise
> their support for specific xflags and users advertise what they want to
> change, behaving like statx.stx_attributes_mask:
> - on GET (file_getattr): each filesystem fills the mask according to
>   their supported xflags, e.g. FS_XFLAG_PTIME or FS_XFLAG_COWEXTSIZE,
>   and provides the values in the corresponding struct fields;
> - on SET (file_setattr): userspace fills the mask according to which
>   xflags it wants to change, VFS validates this and preserves xflags
>   that were not specified in the mask;
> - if xflags_mask =3D=3D 0, use legacy full-struct replacement to keep
>   compatibility with older programs.
>
> Furthermore, in order to avoid the legacy FS_IOC_FSSETXATTR accepting
> FS_XFLAG_PTIME, add an FS_FILE_ATTR_XFLAGS_MASK mask to support new
> xflags and use it in fileattr_to_file_attr()/file_attr_to_fileattr() to
> validate that the xflags passed in xflags and xflags_mask fields are
> valid.
>
> Finally, add the missing FS_XFLAG_PROJID flag, to allow userspace to set
> the projid using file_[sg]etattr().

This part also belongs with the xflags_mask patch

>
> [ This is a re-implementation of the initial patch[1] by Sean Smith
>   <defendthedisabled@gmail.com>, following the advice[2] from Darrick J.
>   Wong <djwong@kernel.org> of using file_setattr() instead of updating
>   utimensat() ]
>
> [1]: https://lore.kernel.org/20260405195007.1306-2-DefendTheDisabled@gmai=
l.com
> [2]: https://lore.kernel.org/20260407014129.GC6192@frogsfrogsfrogs
>
> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.4.7
> Signed-off-by: koraynilay <koray.fra@gmail.com>
> ---
>  fs/file_attr.c            | 75 +++++++++++++++++++++++++++++++++++++--
>  fs/stat.c                 |  2 ++
>  include/linux/fileattr.h  |  6 ++++
>  include/linux/stat.h      |  1 +
>  include/uapi/linux/fs.h   |  9 ++++-
>  include/uapi/linux/stat.h |  7 +++-
>  6 files changed, 95 insertions(+), 5 deletions(-)
>
> diff --git a/fs/file_attr.c b/fs/file_attr.c
> index 833e03810b24..12610fb6a751 100644
> --- a/fs/file_attr.c
> +++ b/fs/file_attr.c
> @@ -102,14 +102,23 @@ EXPORT_SYMBOL(vfs_fileattr_get);
>  static void fileattr_to_file_attr(const struct file_kattr *fa,
>                                   struct file_attr *fattr)
>  {
> -       __u32 mask =3D FS_XFLAGS_MASK;
> +       /*
> +        * fsx_xflags_mask contains only flags added after the
> +        * file_[gs]etattr() API, so we need to tell userspace the filesy=
stem
> +        * actually supports all legacy and new advertised flags
> +        */
> +       __u32 mask =3D (FS_XFLAGS_MASK | fa->fsx_xflags_mask) &
> +                    FS_FILE_ATTR_XFLAGS_MASK;
>
>         memset(fattr, 0, sizeof(struct file_attr));
>         fattr->fa_xflags =3D fa->fsx_xflags & mask;
> +       fattr->fa_xflags_mask =3D mask;
>         fattr->fa_extsize =3D fa->fsx_extsize;
>         fattr->fa_nextents =3D fa->fsx_nextents;
>         fattr->fa_projid =3D fa->fsx_projid;
>         fattr->fa_cowextsize =3D fa->fsx_cowextsize;
> +       fattr->fa_ptime_sec =3D fa->fsx_ptime.tv_sec;
> +       fattr->fa_ptime_nsec =3D fa->fsx_ptime.tv_nsec;
>  }
>
>  /**
> @@ -141,15 +150,23 @@ EXPORT_SYMBOL(copy_fsxattr_to_user);
>  static int file_attr_to_fileattr(const struct file_attr *fattr,
>                                  struct file_kattr *fa)
>  {
> -       __u64 mask =3D FS_XFLAGS_MASK;
> +       __u64 mask =3D fattr->fa_xflags_mask ?: FS_XFLAGS_MASK;
> +
> +       if (fattr->fa_xflags_mask & ~FS_FILE_ATTR_XFLAGS_MASK)
> +               return -EINVAL;
>
>         if (fattr->fa_xflags & ~mask)
>                 return -EINVAL;
>
>         fileattr_fill_xflags(fa, fattr->fa_xflags & ~FS_XFLAG_RDONLY_MASK=
);
> +       fa->fsx_xflags_mask =3D fattr->fa_xflags_mask;
>         fa->fsx_extsize =3D fattr->fa_extsize;
>         fa->fsx_projid =3D fattr->fa_projid;
>         fa->fsx_cowextsize =3D fattr->fa_cowextsize;
> +       if (fattr->fa_xflags_mask & FS_XFLAG_PTIME) {
> +               fa->fsx_ptime.tv_sec =3D fattr->fa_ptime_sec;
> +               fa->fsx_ptime.tv_nsec =3D fattr->fa_ptime_nsec;
> +       }
>
>         return 0;
>  }
> @@ -232,6 +249,23 @@ static int fileattr_set_prepare(struct inode *inode,
>             !S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
>                 return -EINVAL;
>
> +       if (fa->fsx_xflags_mask & FS_XFLAG_PTIME) {
> +               if (!(old_ma->fsx_xflags_mask & FS_XFLAG_PTIME))
> +                       return -EOPNOTSUPP;
> +
> +               if (!(fa->fsx_xflags & FS_XFLAG_PTIME))
> +                       return -EINVAL;
> +
> +               if ((unsigned long)fa->fsx_ptime.tv_nsec >=3D NSEC_PER_SE=
C)
> +                       return -EINVAL;
> +
> +               fa->fsx_ptime =3D timestamp_truncate(fa->fsx_ptime, inode=
);
> +
> +               if (!timespec64_equal(&old_ma->fsx_ptime, &fa->fsx_ptime)=
 &&
> +                   (fa->flags & old_ma->flags) & (FS_APPEND_FL | FS_IMMU=
TABLE_FL))
> +                       return -EPERM;

I don't know what this is but it looks strange.


> +       }
> +
>         /*
>          * It is only valid to set the DAX flag on regular files and
>          * directories on filesystems.
> @@ -288,13 +322,41 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap,=
 struct dentry *dentry,
>         if (!err) {
>                 /* initialize missing bits from old_ma */
>                 if (fa->flags_valid) {
> -                       fa->fsx_xflags |=3D old_ma.fsx_xflags & ~FS_XFLAG=
_COMMON;
> +                       /* FS_IOC_SETFLAGS */
> +                       fa->fsx_xflags |=3D (old_ma.fsx_xflags & FS_XFLAG=
S_MASK) &
> +                                         ~FS_XFLAG_COMMON;
>                         fa->fsx_extsize =3D old_ma.fsx_extsize;
>                         fa->fsx_nextents =3D old_ma.fsx_nextents;
>                         fa->fsx_projid =3D old_ma.fsx_projid;
>                         fa->fsx_cowextsize =3D old_ma.fsx_cowextsize;
> +                       fa->fsx_ptime =3D old_ma.fsx_ptime;
>                 } else {
> +                       /*
> +                        * Preserve unmasked xflags when running file_set=
attr()
> +                        * with a mask, which doesn't need a read-modify-=
write
> +                        * so these attributes would be set to 0.
> +                        *
> +                        * With FS_IOC_FSSETXATTR or mask =3D=3D 0 (legac=
y mode)
> +                        * this is not needed as userspace does
> +                        * read-modify-write already.
> +                        */
> +                       if (fa->fsx_xflags_mask) {
> +                               fa->fsx_xflags |=3D old_ma.fsx_xflags &
> +                                                 ~fa->fsx_xflags_mask;
> +                               fileattr_fill_xflags(fa, fa->fsx_xflags &
> +                                                    ~FS_XFLAG_RDONLY_MAS=
K);
> +                               if (!(fa->fsx_xflags_mask & FS_XFLAG_EXTS=
IZE))
> +                                       fa->fsx_extsize =3D old_ma.fsx_ex=
tsize;
> +                               if (!(fa->fsx_xflags_mask & FS_XFLAG_PROJ=
ID))
> +                                       fa->fsx_projid =3D old_ma.fsx_pro=
jid;
> +                               if (!(fa->fsx_xflags_mask & FS_XFLAG_COWE=
XTSIZE))
> +                                       fa->fsx_cowextsize =3D old_ma.fsx=
_cowextsize;
> +                       }
>                         fa->flags |=3D old_ma.flags & ~FS_COMMON_FL;
> +
> +                       /* xflags not present in fsxattr */
> +                       if (!(fa->fsx_xflags_mask & FS_XFLAG_PTIME))
> +                               fa->fsx_ptime =3D old_ma.fsx_ptime;
>                 }
>

This whole flags/xflags duality needs a closer look
This looks a bit too complicated right now.

I don't have time to do the full review so wanted to give you the
main feedback first.

I'll try to get to it this week.

Thanks,
Amir.
