Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.46
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794837181;
	b=q5+yxDbVYJDyxGlI3L5dWILjBNQqRHnV2C2DNuf846pgG5ecmu2uc1B7dXsxBUOeyYBq
	 TGFtDzBBPYqGO5jyadKHTm7DQ1Tte8IFt41A3AVXnRlI8b2lUwAapR94u+ozCfloEH77q
	 92PXcejAAqb+bzMG/Icg3ICiAuCNBZdDMOT5/J5fp8sF8DYzwxYQdszCfBogtdmkcUEVv
	 f6kE65rdqV7ryXrC47eZmRhAF+5rBiMCfhpM3reWtXwfnPzk9mPl5C1NVI7lisACagc0F
	 g5Jr/ADzMtt5BMixgksgC9DOn/aX5KhpDbmH/z6uTeSvkccd7Gh0cWxMg+Solz12tqA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794837181;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=yjMfJPlhmwgFldHvOAN6a+VpaF8LquFmHlpLZaL46tQ=;
	b=SG4IRwgGmFc4hZ6MqVMlapwPCcKtJwSG4y2xDl6n5y5HtT6qxEMUE4wrB7MGWUzldZGJ
	 N2rVX4j6tXgNP0ps+i5hl7kjv9zyceLBKIg6+wTU1Kfhw7K+Meq+AleS7ySO7/uSylPOn
	 g1NN6QK+Fuc2O2pLEyp8+HwENMJ/i3KtwdhPOJ+pm53VQ2DAAZEmeh+asmQFmTy+C1DaV
	 rU271eg3eflE0WEWUQkh4uH/7Xbx8WU1nkop5FTbIoQwCaE/2091uizNX9UxunA7Npimj
	 Oz8qrMicWeWgoerpd6W+T7tTnY8i0w/IqvOwYnqpfbYTClKpFfHK590Z12x2KW7v7WA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="dK/KA/kv";
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.46
Received: from mail-ed1-f46.google.com (mail-ed1-f46.google.com [209.85.208.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A8E5606A330
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 13:53:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8A8E5606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=dK/KA/kv
Received: by mail-ed1-f46.google.com with SMTP id 4fb4d7f45d1cf-6ae305e3bd9so6182139a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 05:53:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794837179; cv=none;
        d=google.com; s=arc-20260327;
        b=oVvFB35U0kl0+Esm8lxalR3iF2DxfwC/Tx+N2tcIpgk00hxrQJppGBHs/zyCrOZiz5
         Wy5BvPJY6ZjI3T5jSx4/jr14G9tklCujVKn9TtvcKGFdqIVFHMMwa+BOgd/vRaQ+FW3q
         Rlyd7rmEOoaK7ANbWSVaAijY1ONCR4o9SNwuTUiBCPkouH0oke430blefdj0CU7dtBa3
         b1x++55G4hF9sYOa8R9zfv8rgDNnKdG8tQe0hD4usAJaUYRwOrndiBL3xRP6c4FdwDVA
         ZExMUltKWOalbXFNPsJxWuM7G7WYJ7TvJBuftbo/wpfIIDHJHKFp5vdcSJ62Nwv3FpG7
         1ofQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=yjMfJPlhmwgFldHvOAN6a+VpaF8LquFmHlpLZaL46tQ=;
        fh=MaCvtliU0nmBIvns9VzEtHIVbsM9TUsjDV/cT/V2osI=;
        b=Y512VAICZ/Jc1jnrdz8DHW3CT7yb16q6TltJ41tecCVuJCAvMeEJMpNWaot4ccGC1z
         zS7lt9Q6YlTuR+SVfeo/UoWJ2vuZ28cLysGOFU/iGr4xmp3XI1+bQJxAs5hBTGoVMw9u
         LqXLiE7KjW+Hr8eihkjb0caQXnQgOdrkxspaIUAFgFHucwpkSXUx/mZNAeOo/rik5di7
         u1qzqLmxtgQ1LzSJ2PEOnDVMWoIFXWHvIjatFBNIGzCi2EN2ZKlexVvDGMao+Lw/kXPq
         SalD5ml/z4soHqyclIRdtgL0m76PG+O3MdpsomCwUZlP0SYD5mzCGmhMxH09sZQWjIGt
         QjaA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794837179; x=1795441979; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=yjMfJPlhmwgFldHvOAN6a+VpaF8LquFmHlpLZaL46tQ=;
        b=dK/KA/kvNf02H9lgvhJ9SX+K6MYeWK9M1fnYgWdH0M9139sPFVZ2MSJBb+KvARkYDp
         +llJl5308g7eiJ577RRpidL75pEbAwYLzuKEfLU8jiwVJitm0j1keV+ZnLweDyDJqGiw
         o+h0sgYST7P6Klkrz/KNkKuiOQJ2W0H/+1nWjuTpkbE9Sa4OhHYjpGZRCW97CHyOQO/o
         d47FcrMXj6zFKTboDVyKDCq5AQh6sy/dr41qvT2En5S0oLxlZ0d6ROvg8WuKj3Sum1JE
         0/iDbhFDfPBrZWJzc9jA6TIgZkrc51YDcHlH5luO/i1DVaM1PScPohVfeo9sxhJKe6Er
         X+TA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794837179; x=1795441979;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=yjMfJPlhmwgFldHvOAN6a+VpaF8LquFmHlpLZaL46tQ=;
        b=p03UCSB4VTq6naHbnfnECaDiRIUm25mHfwSEnV5th0m7gg1riqqB4+IEvBDgGoouUS
         BilTeTAN9B+Ua9rA6GPV3/siR2l02Hif3QW9wIV5Vpj/gz8Wc+qP/0/AudJVg2v7Kf+u
         42nisytZkINl+jV78pvSNPAENRfaFXAOSwTFcjDNDClnWwhmbSET3DMPhCUxK+EQburX
         zDMIv+Zv6oHpRmb1PCO93Ixd1IzV9ygnOsv6Zly/jWjX/AGmyExsYFdbU/4ZXByrP7bs
         8crqEHMtWUz/jL/sg9UDvzV8d/4t4bbFZiSZIvSED9U7+3XWItjVi2UM2bzHiE4J19Ch
         AiTA==
X-Forwarded-Encrypted: i=1; AL+hErGevI++b3S12ud6Mk6lAI+hFqyZlcl64AQqt1L4WEzBhAFpK7dy17t1gRdi8SE8D3H7U7ZFiOU7WcA=@vger.kernel.org
X-Gm-Message-State: APuU4Z/fN5UoeZXzGFnNhNJVf9h1rEPk3EWSFp26C4xGU0sggiXcUnfn
	84ynE8S7UbjmYWj0uUou5+92NT86pTiL1zUJaYVvUtWWVGhkERZA4knMqEZO7guUdnz6FLTwS+4
	Vuo8YnMVSNI4LKfDqIB2nqqaieWVGooE=
X-Gm-Gg: AYBFou1BfwT510NBy+sJ9v7Z8swQLJy9+IG001Wiz6e0+jcQqlRrDvXtwruKh1sX2dO
	G1Z6QywEzfXgF8uMngXOlc0ZqD7cSnBMQCSqojO6J1KAOAOpMqqCs90c3B0roQG6J8JhYtDCKmo
	61Wvnlx8RCuVOZImwh/+8uExZrCrk5TqKdjuSQfJtJjICp0L88KCeWWPr16iRtp/sg/89F3POLD
	bkVmHM0G+d5zFAltwECl8l8uBlS40h7bsTzERFuthJ0SwCT43EMjza/5/oykaM6LbBfvjPhNrs4
	EdfLDRDQu9PhEVTuk13U3ZimXFrS5kswBwAQdfhTZIMm5N5CfhvnjQX7lOGthqk1NOKSp9pwxF7
	FvAQs0DheWyuB6x2hWv9oWrS1UoNTdjkI6LMQuBxHTEBRVjB8HalYfWcAGGsdj4mGfu/HuIeZI1
	u2VLMvvOCQH3OLhsE=
X-Received: by 2002:a05:6402:1948:b0:6b7:a180:61da with SMTP id
 4fb4d7f45d1cf-6b7c0c6fc36mr8419375a12.28.1794837178579; Mon, 16 Nov 2026
 05:52:58 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <20261115180343.576773-7-koray.fra@gmail.com>
In-Reply-To: <20261115180343.576773-7-koray.fra@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 16 Nov 2026 14:52:46 +0100
X-Gm-Features: AclHuK-FBjjEu-Z1sMzcEnpiCJ9rezp8HfxV_QrUdctxQDdJI-5IhWzN560a-40
Message-ID: <CAOQ4uxgm+JEu2MGnqQrJ00nTJ45S2ECQ7CBOC2QrgniOfkLYAQ@mail.gmail.com>
Subject: Re: [RFC PATCH v4 06/10] vfs: add __vfs_fileattr_set_locked() for
 inode_lock()'d callers
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
> Currently there is no way for a caller to invoke vfs_fileattr_set()
> while holding an inode lock without having the kernel go into deadlock.
>
> Fix this by moving the vfs_fileattr_set() logic into
> __vfs_fileattr_set_locked() and making vfs_fileattr_set() a simple
> wrapper that only handles the inode lock.
>
> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
> Signed-off-by: koraynilay <koray.fra@gmail.com>
> ---
>  fs/file_attr.c           | 139 +++++++++++++++++++++++----------------
>  include/linux/fileattr.h |   2 +
>  2 files changed, 86 insertions(+), 55 deletions(-)
>
> diff --git a/fs/file_attr.c b/fs/file_attr.c
> index 12610fb6a751..063c81fbfa6a 100644
> --- a/fs/file_attr.c
> +++ b/fs/file_attr.c
> @@ -288,6 +288,89 @@ static int fileattr_set_prepare(struct inode *inode,
>         return 0;
>  }
>
> +/**
> + * __vfs_fileattr_set_locked - change miscellaneous file attributes whil=
e
> + * holding the inode lock
> + *
> + * @idmap:     idmap of the mount
> + * @dentry:    the object to change
> + * @fa:                fileattr pointer
> + *
> + * Same as vfs_fileattr_set(), but caller must hold the inode lock.
> + *
> + * Return: 0 on success, or a negative error on failure.
> + */
> +int __vfs_fileattr_set_locked(const struct mnt_idmap *idmap, struct dent=
ry *dentry,
> +                             struct file_kattr *fa)
> +{
> +       struct inode *inode =3D d_inode(dentry);
> +       struct file_kattr old_ma =3D {};
> +       int err;
> +
> +       if (!inode->i_op->fileattr_set)
> +               return -ENOIOCTLCMD;
> +
> +       if (!inode_owner_or_capable(idmap, inode))
> +               return -EPERM;
> +
> +       err =3D vfs_fileattr_get(dentry, &old_ma);
> +       if (err)
> +               return err;
> +
> +       /* initialize missing bits from old_ma */
> +       if (fa->flags_valid) {
> +               /* FS_IOC_SETFLAGS */
> +               fa->fsx_xflags |=3D (old_ma.fsx_xflags & FS_XFLAGS_MASK) =
&
> +                                 ~FS_XFLAG_COMMON;
> +               fa->fsx_extsize =3D old_ma.fsx_extsize;
> +               fa->fsx_nextents =3D old_ma.fsx_nextents;
> +               fa->fsx_projid =3D old_ma.fsx_projid;
> +               fa->fsx_cowextsize =3D old_ma.fsx_cowextsize;
> +               fa->fsx_ptime =3D old_ma.fsx_ptime;
> +       } else {
> +               /*
> +                * Preserve unmasked xflags when running file_setattr()
> +                * with a mask, which doesn't need a read-modify-write
> +                * so these attributes would be set to 0.
> +                *
> +                * With FS_IOC_FSSETXATTR or mask =3D=3D 0 (legacy mode)
> +                * this is not needed as userspace does
> +                * read-modify-write already.
> +                */
> +               if (fa->fsx_xflags_mask) {
> +                       fa->fsx_xflags |=3D old_ma.fsx_xflags &
> +                                         ~fa->fsx_xflags_mask;
> +                       fileattr_fill_xflags(fa, fa->fsx_xflags &
> +                                            ~FS_XFLAG_RDONLY_MASK);
> +                       if (!(fa->fsx_xflags_mask & FS_XFLAG_EXTSIZE))
> +                               fa->fsx_extsize =3D old_ma.fsx_extsize;
> +                       if (!(fa->fsx_xflags_mask & FS_XFLAG_PROJID))
> +                               fa->fsx_projid =3D old_ma.fsx_projid;
> +                       if (!(fa->fsx_xflags_mask & FS_XFLAG_COWEXTSIZE))
> +                               fa->fsx_cowextsize =3D old_ma.fsx_cowexts=
ize;
> +               }
> +               fa->flags |=3D old_ma.flags & ~FS_COMMON_FL;
> +
> +               /* xflags not present in fsxattr */
> +               if (!(fa->fsx_xflags_mask & FS_XFLAG_PTIME))
> +                       fa->fsx_ptime =3D old_ma.fsx_ptime;
> +       }
> +
> +       err =3D fileattr_set_prepare(inode, &old_ma, fa);
> +       if (err)
> +               return err;
> +       err =3D security_inode_file_setattr(dentry, fa);
> +       if (err)
> +               return err;
> +       err =3D inode->i_op->fileattr_set(idmap, dentry, fa);
> +       if (err)
> +               return err;
> +       fsnotify_xattr(dentry);
> +
> +       return 0;
> +}
> +EXPORT_SYMBOL(__vfs_fileattr_set_locked);
> +
>  /**
>   * vfs_fileattr_set - change miscellaneous file attributes
>   * @idmap:     idmap of the mount
> @@ -308,7 +391,6 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap, s=
truct dentry *dentry,
>                      struct file_kattr *fa)
>  {
>         struct inode *inode =3D d_inode(dentry);
> -       struct file_kattr old_ma =3D {};
>         int err;
>
>         if (!inode->i_op->fileattr_set)
> @@ -318,60 +400,7 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap, =
struct dentry *dentry,
>                 return -EPERM;
>
>         inode_lock(inode);
> -       err =3D vfs_fileattr_get(dentry, &old_ma);
> -       if (!err) {
> -               /* initialize missing bits from old_ma */
> -               if (fa->flags_valid) {
> -                       /* FS_IOC_SETFLAGS */
> -                       fa->fsx_xflags |=3D (old_ma.fsx_xflags & FS_XFLAG=
S_MASK) &
> -                                         ~FS_XFLAG_COMMON;
> -                       fa->fsx_extsize =3D old_ma.fsx_extsize;
> -                       fa->fsx_nextents =3D old_ma.fsx_nextents;
> -                       fa->fsx_projid =3D old_ma.fsx_projid;
> -                       fa->fsx_cowextsize =3D old_ma.fsx_cowextsize;
> -                       fa->fsx_ptime =3D old_ma.fsx_ptime;
> -               } else {
> -                       /*
> -                        * Preserve unmasked xflags when running file_set=
attr()
> -                        * with a mask, which doesn't need a read-modify-=
write
> -                        * so these attributes would be set to 0.
> -                        *
> -                        * With FS_IOC_FSSETXATTR or mask =3D=3D 0 (legac=
y mode)
> -                        * this is not needed as userspace does
> -                        * read-modify-write already.
> -                        */
> -                       if (fa->fsx_xflags_mask) {
> -                               fa->fsx_xflags |=3D old_ma.fsx_xflags &
> -                                                 ~fa->fsx_xflags_mask;
> -                               fileattr_fill_xflags(fa, fa->fsx_xflags &
> -                                                    ~FS_XFLAG_RDONLY_MAS=
K);
> -                               if (!(fa->fsx_xflags_mask & FS_XFLAG_EXTS=
IZE))
> -                                       fa->fsx_extsize =3D old_ma.fsx_ex=
tsize;
> -                               if (!(fa->fsx_xflags_mask & FS_XFLAG_PROJ=
ID))
> -                                       fa->fsx_projid =3D old_ma.fsx_pro=
jid;
> -                               if (!(fa->fsx_xflags_mask & FS_XFLAG_COWE=
XTSIZE))
> -                                       fa->fsx_cowextsize =3D old_ma.fsx=
_cowextsize;
> -                       }
> -                       fa->flags |=3D old_ma.flags & ~FS_COMMON_FL;
> -
> -                       /* xflags not present in fsxattr */
> -                       if (!(fa->fsx_xflags_mask & FS_XFLAG_PTIME))
> -                               fa->fsx_ptime =3D old_ma.fsx_ptime;
> -               }
> -
> -               err =3D fileattr_set_prepare(inode, &old_ma, fa);
> -               if (err)
> -                       goto out;
> -               err =3D security_inode_file_setattr(dentry, fa);
> -               if (err)
> -                       goto out;
> -               err =3D inode->i_op->fileattr_set(idmap, dentry, fa);
> -               if (err)
> -                       goto out;
> -               fsnotify_xattr(dentry);
> -       }
> -
> -out:
> +       err =3D __vfs_fileattr_set_locked(idmap, dentry, fa);
>         inode_unlock(inode);
>         return err;
>  }
> diff --git a/include/linux/fileattr.h b/include/linux/fileattr.h
> index ba7ed3b387d8..7ff62ee27e58 100644
> --- a/include/linux/fileattr.h
> +++ b/include/linux/fileattr.h
> @@ -97,6 +97,8 @@ static inline bool fileattr_has_fsx(const struct file_k=
attr *fa)
>  int vfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa);
>  int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentr=
y,
>                      struct file_kattr *fa);
> +int __vfs_fileattr_set_locked(const struct mnt_idmap *idmap, struct dent=
ry *dentry,
> +                             struct file_kattr *fa);

There is no reason for __ prefix here and I think it should be discouraged =
for
global scope if possible.

Thanks,
Amir.
