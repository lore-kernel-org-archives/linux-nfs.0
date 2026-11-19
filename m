Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.128.52
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795111617;
	b=0gv3MRhDMLhcVtFzbRHjLITow5keLqglIgrTEAFH+VZaW/3Bo8dxfriWR1loXK9aLcmu
	 c0nkfU4SZ9tGmFagMuPq7gOzxbXaANQ1giTn/XaotKBQI1QgyQghf/NIq5d2iG4uvFCDw
	 lVttqAQmNz8qQ0X1xkJGnbtLlDFur3BAsJPFEaSyOrJx/sGq1KM7iZmgJw2+0HBcFBmSP
	 fSpzKVHr6rdyFZjSreLv+KWBPrf1bnmo0b9mBPRm7Fplss0kMBOkpYEiSs6H8cZMaE6y4
	 4kkHuGq6vtewe4q+7cQ6XX5aIcGxalaPgOS1qB1fOR+gi1T89H4uvXZszyic9dhZiBw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795111617;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=ObnXvHw01FLs5EHu4no1ShmsB4TgAFFzQVkarBuzIGU=;
	b=guC979gcXnqgngGxVKfVKhDIsPDJwzBhDJt5D5Cl78MrBAi8iX9FxTKTfOm33nz9fpq1
	 HUjazxOLJ8ZVliGFxE0OY5G0WkDgBfleMBJChtUdc0I7UhKPDCvHNeoMvW7MVGuJ+mxZn
	 j8DxGdX7oBu6Mepksw/LT4ZqN0sebIJgSrnIsdt64UB2+XDsLnotX0SsjV9vYqfqQsHyR
	 dO06wq9vwZLDs7qw07qVLXWC0QSqObTAACaDntJ+IQd3WguYOUqtwXVVs/f83AivCHWCM
	 Nhi4e9KnxSdv4cu7A87/YQBuZ5UsgIuwKJGX+DWTSRRljSEmCNJlCDwdW9i1PyEoM3Q==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=jMRG+8bV;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.128.52
Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com [209.85.128.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E718A606A326
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 18:06:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E718A606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=jMRG+8bV
Received: by mail-wm1-f52.google.com with SMTP id 5b1f17b1804b1-4a2153c8525so19565365e9.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 10:06:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795111615; cv=none;
        d=google.com; s=arc-20260327;
        b=igalP+Oz6euVizFT8MA4QXAM66sLKOlHaRS8zdJVdXwi4snDoWpqoULd/WSieITq6s
         2H7/efK62W9rL+LhHcTeI6NO/MYOOWJNtJS474Xrst56dUuQnpLVZlME2Ze1JuaiEptX
         xdgEAyLJvz+e52MQ4bcKqhTOXEg1tOaPbr0x4nbNJF5VjiZcZVfsKyVe9lriConyau9D
         F2M6Aoe5vvfwTyMG9bYQp5OCmPOB3pKu94+oIMFeVdBJ9cTvCmwwbP+EpjcpF/It6VTu
         VsVVAdu2Z3IoHg4kj/uwujfZ0Z7j7DAS/AZbMXAAWq4Gn9xYw8YZyBKhXYMSRHJz0S7V
         TxgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ObnXvHw01FLs5EHu4no1ShmsB4TgAFFzQVkarBuzIGU=;
        fh=HPjPUx1ityB1eyFctmzOCmT+kHOQXsWRbAYAyYE6SBc=;
        b=gfeNaKbIpf9MSMiokYoCWxoaFDhqOrKdCX6Sa73DK3cF49Lzhxs0afpzc3xT7BN/X+
         EPhvePwXlrM5GyFmnoA6Agiq1/QyOu2QEXkWObomNH5cKHuRXC/P2UaO+tc8GdYieRmp
         0tN9rXgnJAexQCmbjNOtcIBwYcGxAcicY/+NfcDQfi0mLYZwq2XRqpzWSK5MMfVBy0qz
         FKGAZrYmilolIuDuWFpv6rpziO7yeGz9QoImgWFSzVhENLpXXZbl2ZJd87C6LzoZAMPN
         kdNlw4SjFNSlhmSvXWDMVEfuyXubJehhbTywHiroElf/7TDz9taDpYwqsOuItWDptLyR
         84Pw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795111615; x=1795716415; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=ObnXvHw01FLs5EHu4no1ShmsB4TgAFFzQVkarBuzIGU=;
        b=jMRG+8bV6XGK9Uey9QqEqe5bcMT+hKbhRovdBqjHrCkXoEuGHsqn4DJJxR2fd5+Q1q
         MsVup0c6RFFiGNyFsFiDfZvi5BWsEJ58+0ufWEGNb0NriCU3OM08bxLP2iNDVKiYApkU
         GCdaZURRiMOLPbaN1fats+MU2kytIkxyEnbHnOd/V9tHE3Ki/wqTmd5/W6sWxzkgSbI+
         MJ5zbtSMWyjV9JnHHP76pvEH8iigl0ASCDaaNUAuLLhkO9fTtbz4qdes+NJBJ5jKOF42
         bT2NDsoC6/Ozi6kN8sF1/k++G/yhfeH7FUWGS8q19MIp4P3SvSjjc8cdD6j+1hr03IKP
         1LJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795111615; x=1795716415;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ObnXvHw01FLs5EHu4no1ShmsB4TgAFFzQVkarBuzIGU=;
        b=LS/s2O6GRhOpHLTbwnMcoQvLxJoWBA3zPAFz9X74ccnCWvMuwIowbb+liAHNViO4qX
         WxtXPaGhHldb0N0r1ADLeAlKA3hdqhsSs+832Bg+iSaCZZRtQ6rb1eINqr7QJ+GDFAxt
         iJ88hngkePgBS3btn/Tz/gsl8SQh1bUfGL95lR8cfqD3sYlzRJsl67d5hvp74ky1oGk8
         rny092l0Io3XxpCGIyirGDVmhbplamOfmznHHmWktpFGpZiQiamT+/dcQ3xTbDarrZpE
         KswHXAzsM5vtV0g5FMNjgoK5vrbtFnb4sQIbEYZG0DTqcMV3ehosXpR4amUQw5dT9b/b
         jP6A==
X-Forwarded-Encrypted: i=1; AL+hErHzDleKjHv/GQZkKQox4jvsSAUJLQeLCx8icykb/DUvBzTbOKB3bDnpkkbB4CaYzhfY2l/dXhJ7Xj0=@vger.kernel.org
X-Gm-Message-State: APuU4Z8e6LUmOd8UYRLxJwGmvhNvOZP6ihUu2mVE9EbxGXXVGFIlzFaP
	LPi5nVZTImTZAgPedchGG7+ee9jmx633F6dttJ03SeDNd39XcxkZ7q2aQJ6lWtHSQPuiyuWvEkw
	uwN/v+LiwD/RwZE66KX3YbKa1PUvJ2zM=
X-Gm-Gg: AYBFou1OUdhfZ8ei062ROPiTuO0xpnsxRLzP0udJuXfGB6cIQCqC6LOzmnNmncmQExz
	WMFWsejOlInZgSGS3mwDLQJgURqR+elNsQm1imNoEqHT3GXgXxuIG+ldP1kYYOXl9mZGrJ1Yt+d
	E2Oa1bod0uM4h7i/97YT/8VwWlaLvR1Tien+pLiK3Kw3dJxSsccPzJhOhF8jBWzM3UChL3Uevn9
	eOQspnIprp0J/qsA20/Dp7weD85yJL10xj9WHnuAmpNsbNBls2pLjSmX0rioNdjMF/5zepXjlkf
	QontPAZmCuErvVnG5gIWRSwKINvtSYdgVhyuk94uL3nt843YTPNgrIPjjUEff9Pw17ddb3gC5HD
	P7E4ZrabimTqvSXNm4VGCf7dAIuzlK4P2Yji1dvp2nlzm3s9DPy1ZIaendjNXiHhTbLyr/w==
X-Received: by 2002:a05:600c:530e:b0:4ba:eb:eb9b with SMTP id
 5b1f17b1804b1-4bb8880aba2mr8190825e9.8.1795111615117; Thu, 19 Nov 2026
 10:06:55 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <20261115180343.576773-9-koray.fra@gmail.com>
In-Reply-To: <20261115180343.576773-9-koray.fra@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 19 Nov 2026 19:06:42 +0100
X-Gm-Features: Aa3M54qbdATp_X7SLUdff3sB6NxOmi50uv-_rvsMnMsvWT2Myuz318P-7T1jC6c
Message-ID: <CAOQ4uxgoNsOH82FyrCxc+qSoid_CFmbmpL0qgWFw-e8E689fFA@mail.gmail.com>
Subject: Re: [RFC PATCH v4 08/10] nfs: add provenance time (ptime) via FATTR4_TIME_CREATE
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
> Implement provenance time (ptime) in the NFS client, as introduced in a
> previous commit ("vfs: add provenance time (ptime)").
>
> Support reading ptime via statx(2) and file_getattr(), returning the
> cached creation time when the server advertises NFS_ATTR_FATTR_BTIME.
>
> Implement sending FATTR4_TIME_CREATE, asking the server to persist the
> file creation time using ptime on the underlying filesystem.
>
> Also add .fileattr_set to struct nfs_rpc_ops and set it to
> nfs4_fileattr_set() in nfs_v4_clientops. Provide a generic
> nfs_fileattr_set() dispatcher so even symlinks can update ptime under
> NFSv4 while cleanly returning -EOPNOTSUPP on NFSv2/v3.
>
> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
> Signed-off-by: koraynilay <koray.fra@gmail.com>
> ---
>  fs/nfs/inode.c          | 27 ++++++++++++++++----
>  fs/nfs/internal.h       |  2 ++
>  fs/nfs/nfs4proc.c       | 56 ++++++++++++++++++++++++++++++++++++++---
>  fs/nfs/nfs4xdr.c        | 19 +++++++++-----
>  fs/nfs/symlink.c        |  1 +
>  include/linux/nfs_xdr.h |  3 +++
>  6 files changed, 93 insertions(+), 15 deletions(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index e0a2e92952af..2ddcfd872616 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -955,7 +955,7 @@ static u32 nfs_get_valid_attrmask(struct inode *inode=
)
>                 reply_mask |=3D STATX_BLOCKS;
>         if (!(cache_validity & NFS_INO_INVALID_BTIME) &&
>             (fattr_valid & NFS_ATTR_FATTR_BTIME))
> -               reply_mask |=3D STATX_BTIME;
> +               reply_mask |=3D STATX_BTIME | STATX_PTIME;
>         if (!(cache_validity & NFS_INO_INVALID_CHANGE))
>                 reply_mask |=3D STATX_CHANGE_COOKIE;
>         return reply_mask;
> @@ -978,10 +978,10 @@ int nfs_getattr(const struct mnt_idmap *idmap, cons=
t struct path *path,
>         request_mask &=3D STATX_TYPE | STATX_MODE | STATX_NLINK | STATX_U=
ID |
>                         STATX_GID | STATX_ATIME | STATX_MTIME | STATX_CTI=
ME |
>                         STATX_INO | STATX_SIZE | STATX_BLOCKS | STATX_BTI=
ME |
> -                       STATX_CHANGE_COOKIE;
> +                       STATX_PTIME | STATX_CHANGE_COOKIE;
>
>         if (!(fattr_valid & NFS_ATTR_FATTR_BTIME))
> -               request_mask &=3D ~STATX_BTIME;
> +               request_mask &=3D ~(STATX_BTIME | STATX_PTIME);
>
>         if ((query_flags & AT_STATX_DONT_SYNC) && !force_sync) {
>                 if (readdirplus_enabled)
> @@ -1015,7 +1015,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, cons=
t struct path *path,
>         if (!(request_mask & (STATX_MODE|STATX_NLINK|STATX_ATIME|STATX_CT=
IME|
>                                         STATX_MTIME|STATX_UID|STATX_GID|
>                                         STATX_SIZE|STATX_BLOCKS|STATX_BTI=
ME|
> -                                       STATX_CHANGE_COOKIE)))
> +                                       STATX_PTIME|STATX_CHANGE_COOKIE))=
)
>                 goto out_no_revalidate;
>
>         /* Check whether the cached attributes are stale */
> @@ -1038,7 +1038,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, cons=
t struct path *path,
>                 do_update |=3D cache_validity & NFS_INO_INVALID_OTHER;
>         if (request_mask & STATX_BLOCKS)
>                 do_update |=3D cache_validity & NFS_INO_INVALID_BLOCKS;
> -       if (request_mask & STATX_BTIME)
> +       if (request_mask & (STATX_BTIME | STATX_PTIME))
>                 do_update |=3D cache_validity & NFS_INO_INVALID_BTIME;
>
>         if (do_update) {
> @@ -1061,6 +1061,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, cons=
t struct path *path,
>         if (S_ISDIR(inode->i_mode))
>                 stat->blksize =3D NFS_SERVER(inode)->dtsize;
>         stat->btime =3D NFS_I(inode)->btime;
> +       stat->ptime =3D NFS_I(inode)->btime;
>

As an example of what would be needed per the mutable btime proposal,
adding stat->ptime and STATX_PTIME will not be needed...

>         /* Special handling for STATX_DIOALIGN and STATX_DIO_READ_ALIGN
>          * - NFS doesn't have DIO alignment constraints, avoid getting
> @@ -1092,10 +1093,26 @@ int nfs_fileattr_get(struct dentry *dentry, struc=
t file_kattr *fa)
>         }
>         if (nfs_server_capable(inode, NFS_CAP_CASE_NONPRESERVING))
>                 fa->fsx_xflags |=3D FS_XFLAG_CASENONPRESERVING;

This would need:
                  fa->fsx_xflags |=3D FS_XFLAG_CASEFOLD;
+                fa->fsx_xflags_mask |=3D FS_XFLAG_CASEFOLD;
+                fa->fsx_xflags_ro_mask |=3D FS_XFLAG_CASEFOLD;
+                /* unlink other fs FS_CASEFOLD_FL is read-only */
                  fa->flags |=3D FS_CASEFOLD_FL;
        }
                   fa->fsx_xflags |=3D FS_XFLAG_CASENONPRESERVING;
+                 fa->fsx_xflags_mask |=3D FS_XFLAG_CASENONPRESERVING;
+                 fa->fsx_xflags_ro_mask |=3D FS_XFLAG_CASENONPRESERVING;

> +       if (NFS_SERVER(inode)->fattr_valid & NFS_ATTR_FATTR_BTIME) {
> +               fa->fsx_xflags |=3D FS_XFLAG_PTIME;
> +               fa->fsx_xflags_mask |=3D FS_XFLAG_PTIME;
> +               fa->fsx_ptime =3D NFS_I(inode)->btime;
> +       }

+               fa->fsx_xflags |=3D FS_XFLAG_BTIME;
+               fa->fsx_xflags_mask |=3D FS_XFLAG_BTIME;
+               fa->fsx_btime =3D NFS_I(inode)->btime;

Fs with immutable btime could either not advertise the BTIME flag
in xflags/xflags_mask or advertise the flag also in xflags_ro_mask.

>         return 0;
>  }
>  EXPORT_SYMBOL_GPL(nfs_fileattr_get);
>
> +int nfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentr=
y,
> +                    struct file_kattr *fa)
> +{
> +       const struct nfs_rpc_ops *ops =3D NFS_PROTO(d_inode(dentry));
> +
> +       if (ops->fileattr_set)
> +               return ops->fileattr_set(idmap, dentry, fa);
> +       return -EOPNOTSUPP;
> +}
> +EXPORT_SYMBOL_GPL(nfs_fileattr_set);
> +
>  static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
>  {
>         refcount_set(&l_ctx->count, 1);
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 5af6a032f145..0e47fad944de 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -458,6 +458,8 @@ extern int nfs_wait_bit_killable(struct wait_bit_key =
*key, int mode);
>
>  struct file_kattr;
>  int nfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa);
> +int nfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentr=
y,
> +                    struct file_kattr *fa);
>
>  #if IS_ENABLED(CONFIG_NFS_LOCALIO)
>  /* localio.c */
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index e1018b03c1cb..31d58ceb4dc0 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -55,6 +55,7 @@
>  #include <linux/utsname.h>
>  #include <linux/freezer.h>
>  #include <linux/iversion.h>
> +#include <linux/fileattr.h>
>
>  #include "nfs4_fs.h"
>  #include "delegation.h"
> @@ -98,7 +99,8 @@ static int _nfs4_proc_getattr(struct nfs_server *server=
, struct nfs_fh *fhandle,
>                               struct nfs_fattr *fattr, struct inode *inod=
e);
>  static int nfs4_do_setattr(struct inode *inode, const struct cred *cred,
>                             struct nfs_fattr *fattr, struct iattr *sattr,
> -                           struct nfs_open_context *ctx, struct nfs4_lab=
el *ilabel);
> +                           struct nfs_open_context *ctx, struct nfs4_lab=
el *ilabel,
> +                           const struct timespec64 *time_create);
>  static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
>                 const struct cred *cred,
>                 struct nfs4_slot *slot,
> @@ -3216,7 +3218,7 @@ static int _nfs4_do_open(struct inode *dir,
>                         nfs_fattr_init(opendata->o_res.f_attr);
>                         status =3D nfs4_do_setattr(state->inode, cred,
>                                         opendata->o_res.f_attr, sattr,
> -                                       ctx, label);
> +                                       ctx, label, NULL);
>                         if (status =3D=3D 0) {
>                                 nfs_setattr_update_inode(state->inode, sa=
ttr,
>                                                 opendata->o_res.f_attr);
> @@ -3380,7 +3382,8 @@ static int _nfs4_do_setattr(struct inode *inode,
>
>  static int nfs4_do_setattr(struct inode *inode, const struct cred *cred,
>                            struct nfs_fattr *fattr, struct iattr *sattr,
> -                          struct nfs_open_context *ctx, struct nfs4_labe=
l *ilabel)
> +                          struct nfs_open_context *ctx, struct nfs4_labe=
l *ilabel,
> +                          const struct timespec64 *time_create)
>  {
>         struct nfs_server *server =3D NFS_SERVER(inode);
>         __u32 bitmask[NFS4_BITMASK_SZ];
> @@ -3391,6 +3394,7 @@ static int nfs4_do_setattr(struct inode *inode, con=
st struct cred *cred,
>                 .server         =3D server,
>                 .bitmask =3D bitmask,
>                 .label          =3D ilabel,
> +               .time_create    =3D time_create,
>         };
>         struct nfs_setattrres  res =3D {
>                 .fattr          =3D fattr,
> @@ -3414,6 +3418,9 @@ static int nfs4_do_setattr(struct inode *inode, con=
st struct cred *cred,
>         if (sattr->ia_valid & ATTR_MTIME)
>                 adjust_flags |=3D NFS_INO_INVALID_MTIME;
>
> +       if (time_create)
> +               adjust_flags |=3D NFS_INO_INVALID_BTIME;
> +
>         do {
>                 nfs4_bitmap_copy_adjust(bitmask, nfs4_bitmask(server, fat=
tr->label),
>                                         inode, adjust_flags);
> @@ -4587,7 +4594,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs=
_fattr *fattr,
>         if ((sattr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) !=3D 0)
>                 nfs4_inode_make_writeable(inode);
>
> -       status =3D nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NULL);
> +       status =3D nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NULL, =
NULL);
>         if (status =3D=3D 0) {
>                 nfs_setattr_update_inode(inode, sattr, fattr);
>                 nfs_setsecurity(inode, fattr);
> @@ -10845,6 +10852,44 @@ static void nfs4_disable_swap(struct inode *inod=
e)
>         wake_up_var(&clp->cl_state);
>  }
>
> +#define NFS4_SUPPORTED_XFLAGS  (FS_XFLAG_PTIME)
> +static int nfs4_fileattr_set(const struct mnt_idmap *idmap, struct dentr=
y *dentry,
> +                            struct file_kattr *fa)
> +{
> +       struct inode *inode =3D d_inode(dentry);
> +       struct nfs_server *server =3D NFS_SERVER(inode);
> +       struct nfs_fattr *fattr;
> +       struct iattr sattr =3D { .ia_valid =3D 0 };
> +       const struct timespec64 *time_create =3D NULL;
> +       int error;
> +
> +       if (!(server->fattr_valid & NFS_ATTR_FATTR_BTIME))
> +               return -EOPNOTSUPP;
> +
> +       if (fa->flags_valid)
> +               return -EOPNOTSUPP;
> +
> +       if (fileattr_has_fsx_mask(fa, NFS4_SUPPORTED_XFLAGS))
> +               return -EOPNOTSUPP;
> +
> +       if (fa->fsx_xflags_mask & ~NFS4_SUPPORTED_XFLAGS)
> +               return -EOPNOTSUPP;
> +

These two checks look semantically identical.
I am not sure yet what you intention was with the
fileattr_has_fsx_mask() helper - I know you had reservations about it
but at least in this code, it doesn't look like it is needed at all.

> +       if (fa->fsx_xflags_mask & FS_XFLAG_PTIME)
> +               time_create =3D &fa->fsx_ptime;

This would be BTIME/btime but otherwise the same.

Thanks,
Amir.
