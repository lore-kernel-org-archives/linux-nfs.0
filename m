Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795126211;
	b=iLm1t3zjE9RRlwexJ2hXtrmxq3lQjld9zVhhLBg+lcW0yWlVJoWiAsRup/Im3oJlTmgs
	 DJHP08NcPEN6EITfjBHa7lfu26okovCOmK3RDdNsoihgXQ6lCWkx31RkgZavK7cCXoVq1
	 MdGDFUTJR+Pp9KvyW+uZNVZd2+qtQ+09utboeRHL/ra8AOPO4k7VwLlIGurkTpBg2Si6S
	 ygHwax5kNFZd3l2SwXsjc/5VE8Auqfoziy45G+irI9jBq2zU9O0KafqpYtaArv4c/tPbL
	 8Mh8DwGrNH5HFQ2mHYdluoqzc37+dF1+4HmvK8Dz/WvtbeZBtrex60x2XaK/4R4TBig==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795126211;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=XrQlXENkswmdOJaF0OEDBush4tY7hFip+Dmv215gdyM=;
	b=BJBXF9VHiwSwoHBQQZvuBl3DF3WUvjGaEg4tLsI77JnbX988sThUey9Oz2jxt8DGIT8M
	 MKMfe4xuaobtmIyO9xk0Q2and5I6xS0A57r2U/5ZTvcvO3CEx35/m7AUkw9wHwjm1livk
	 Rz7zMOygx4dfjFeG11pAqS1l3AGuU6+NqXGJCxQjIt8nTyg2UCJjPR/p/Liuj71a0PAqV
	 tL01lL70Ts1J9awanmNjgns0yMwP1l2prhAQB/XBG+aeF5atuPVKr8rype1B/H1yaqLwE
	 nhjRyInEYtuiXcnaiilqpp4xnxfxFPk2xGzPx/DpNrVO7rVl9xVFA+NBIlz/mw2b0sw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=xtUBIJ29;
	arc=none smtp.remote-ip=209.85.128.51
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 029BA60A2619
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 22:10:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 029BA60A2619
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=xtUBIJ29
Received: by mail-wm1-f51.google.com with SMTP id 5b1f17b1804b1-49d05d51553so1481675e9.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 14:10:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795126207; x=1795731007; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=XrQlXENkswmdOJaF0OEDBush4tY7hFip+Dmv215gdyM=;
        b=xtUBIJ29oXmT3fjfopm3egaeNyVokeFHzGOW0CI+5zft7Q7cl9Yoz9f6Ie+jh6DjfK
         ceUxZ7jBcWsHyO1ACk1FMnrI8Bfq5eN4tYmVFPHumuU14uLbehBJ4GyxVc7LjDd4FCHj
         jZOXZgvWGYiQNRXS4pFtD6dkNari6rdPtF8cTfgmfuwhfDwjoTeOwZHNX2jqL+/cPzzQ
         OzHxuWgytEa2a1cXQfiejxRIxpzIeG5DYYX/BNWmGiX6s3N4LgoV1AePKP5Dyvu/XyUg
         fk0UKJ2CKqYWOlTSU4l6XfV7IxrrAwj5OpILl4eG8ydFPjVfHad6YcVmQnfxEQfYQVf/
         dl2A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795126207; x=1795731007;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=XrQlXENkswmdOJaF0OEDBush4tY7hFip+Dmv215gdyM=;
        b=h91lm7fMALak1VcatQKo1RrhXiBjbMs2FU6YN+fkeUjx7XGHh9RrWbI+D0RKdGY+Pb
         yDPKlWnpiqEu0ZuKJyIj5Qmaa/ywgradDlWwYT9ijn4DFTBGjnX1tmt2t+dXx33QBZ3B
         Gx5ZsD9Q7BxM1ZP1Lfp3t67A6kThJriPK7qb07nAjYQ10Xj34c8JQlx9yn0G5f9oo2br
         usiqTIV9HzGB3dhXjmtjpShgTLe+CpvIpbZwEA+VOEwpj0F5GQ6l77me9ClhU7K1/Sqm
         kvSU1+jELhC36Ii4U5jb6nlHjEiW8o/OFdwBDMgjB0afbGWuRC7CiHnr9nJwRqOQ6VXd
         jTzg==
X-Forwarded-Encrypted: i=1; AL+hErFCdiOmjFG+scWVK8nXhhTcJ5Nerhpkbq1mltTUs0YbtTgbwzj0wqXlfYJsbTMkSR5nrnyikoECEQ8=@vger.kernel.org
X-Gm-Message-State: APuU4Z8P1pq0QqaTgFyh+T7+0cJ7/RTg8cveHoemcQM/WDUwok9HbRMJ
	+bdf3AkG70hxqLRin067LUo/ZsJCohwh1xJl0MR/eYYPKMb2ul83Sf9y
X-Gm-Gg: AYBFou2DemjTcI9yHIQyU7A9L/TIjq7KkTxFaWNxSsgc5a6ns70wh/IRsi3k58nlSgd
	y8cqEjn9DMSsjKnaT5VuXqLg3eBkB3w+Xdw8my5GY4O+zZ4+tWy8BzKTpUO1yZPRWZlWCD9OJOH
	ps0Shi0j0C3EKtTAZdbZYUv6VPIoHCIheaLT5IJp7ipKopCwt6aWbev0SqCmTVp8zAfCPBTR4hu
	IdsrVQ4vrHy1H7QKNVloHq+UQizdvaXOsLs/l/ajsweFKJWTK2JKlW8aygN4nhpuoKO0ILglMPc
	0ffQeFrPfuOcQMiAexWhbHbCXfjO3ymZlRrwCdLMce3tfOQugLuvU/FH1VeLEeFq7qBKbWHqDew
	6Vf45qRt2tKLm/yE9MR4zIQzE1/I6X/GwO6gKs+RjO4PwxXT8xCfJJ+Wb17QhcrHsg25ghgUU/e
	mlQs4TQZK2vMWUu/D29zIovGuJoEgY/j3bxhi0qPnZljugv/y8lKmVpjARmUMq/pwESsYwX2KJ3
	vJMv+hV0tcM1f9PEdMVj89EDx5d/lIC5Gdzf1U5gZAhZ33Cz2UlGqq6cz2pF9qC2gdQh8cHpzPA
	OGFZ2KVoHAiOjGA/UHMOGY3J0Q==
X-Received: by 2002:a05:600c:46d3:b0:4bb:6687:5394 with SMTP id 5b1f17b1804b1-4bb888097b0mr22161085e9.9.1795126207129;
        Thu, 19 Nov 2026 14:10:07 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb8538b2c5sm64509225e9.5.2026.11.19.14.10.04
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 19 Nov 2026 14:10:06 -0800 (PST)
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
 boundary=3d15f75e39637138c31b5eb6b42e208a295fb1f9999d6996307de0cb3004;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Thu, 19 Nov 2026 23:10:04 +0100
Message-Id: <DMZJ4PL1JVA4.2YEB7EPYJR5Q7@gmail.com>
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
Subject: Re: [RFC PATCH v4 08/10] nfs: add provenance time (ptime) via
 FATTR4_TIME_CREATE
From: "koraynilay" <koray.fra@gmail.com>
To: "Amir Goldstein" <amir73il@gmail.com>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261115180343.576773-9-koray.fra@gmail.com>
 <CAOQ4uxgoNsOH82FyrCxc+qSoid_CFmbmpL0qgWFw-e8E689fFA@mail.gmail.com>
In-Reply-To: <CAOQ4uxgoNsOH82FyrCxc+qSoid_CFmbmpL0qgWFw-e8E689fFA@mail.gmail.com>

--3d15f75e39637138c31b5eb6b42e208a295fb1f9999d6996307de0cb3004
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Thu Nov 19, 2026 at 7:06 PM CET, Amir Goldstein wrote:
> On Sun, Nov 15, 2026 at 7:04=E2=80=AFPM koraynilay <koray.fra@gmail.com> =
wrote:
>>
>> Implement provenance time (ptime) in the NFS client, as introduced in a
>> previous commit ("vfs: add provenance time (ptime)").
>>
>> Support reading ptime via statx(2) and file_getattr(), returning the
>> cached creation time when the server advertises NFS_ATTR_FATTR_BTIME.
>>
>> Implement sending FATTR4_TIME_CREATE, asking the server to persist the
>> file creation time using ptime on the underlying filesystem.
>>
>> Also add .fileattr_set to struct nfs_rpc_ops and set it to
>> nfs4_fileattr_set() in nfs_v4_clientops. Provide a generic
>> nfs_fileattr_set() dispatcher so even symlinks can update ptime under
>> NFSv4 while cleanly returning -EOPNOTSUPP on NFSv2/v3.
>>
>> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
>> Signed-off-by: koraynilay <koray.fra@gmail.com>
>> ---
>>  fs/nfs/inode.c          | 27 ++++++++++++++++----
>>  fs/nfs/internal.h       |  2 ++
>>  fs/nfs/nfs4proc.c       | 56 ++++++++++++++++++++++++++++++++++++++---
>>  fs/nfs/nfs4xdr.c        | 19 +++++++++-----
>>  fs/nfs/symlink.c        |  1 +
>>  include/linux/nfs_xdr.h |  3 +++
>>  6 files changed, 93 insertions(+), 15 deletions(-)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index e0a2e92952af..2ddcfd872616 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -955,7 +955,7 @@ static u32 nfs_get_valid_attrmask(struct inode *inod=
e)
>>                 reply_mask |=3D STATX_BLOCKS;
>>         if (!(cache_validity & NFS_INO_INVALID_BTIME) &&
>>             (fattr_valid & NFS_ATTR_FATTR_BTIME))
>> -               reply_mask |=3D STATX_BTIME;
>> +               reply_mask |=3D STATX_BTIME | STATX_PTIME;
>>         if (!(cache_validity & NFS_INO_INVALID_CHANGE))
>>                 reply_mask |=3D STATX_CHANGE_COOKIE;
>>         return reply_mask;
>> @@ -978,10 +978,10 @@ int nfs_getattr(const struct mnt_idmap *idmap, con=
st struct path *path,
>>         request_mask &=3D STATX_TYPE | STATX_MODE | STATX_NLINK | STATX_=
UID |
>>                         STATX_GID | STATX_ATIME | STATX_MTIME | STATX_CT=
IME |
>>                         STATX_INO | STATX_SIZE | STATX_BLOCKS | STATX_BT=
IME |
>> -                       STATX_CHANGE_COOKIE;
>> +                       STATX_PTIME | STATX_CHANGE_COOKIE;
>>
>>         if (!(fattr_valid & NFS_ATTR_FATTR_BTIME))
>> -               request_mask &=3D ~STATX_BTIME;
>> +               request_mask &=3D ~(STATX_BTIME | STATX_PTIME);
>>
>>         if ((query_flags & AT_STATX_DONT_SYNC) && !force_sync) {
>>                 if (readdirplus_enabled)
>> @@ -1015,7 +1015,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, con=
st struct path *path,
>>         if (!(request_mask & (STATX_MODE|STATX_NLINK|STATX_ATIME|STATX_C=
TIME|
>>                                         STATX_MTIME|STATX_UID|STATX_GID|
>>                                         STATX_SIZE|STATX_BLOCKS|STATX_BT=
IME|
>> -                                       STATX_CHANGE_COOKIE)))
>> +                                       STATX_PTIME|STATX_CHANGE_COOKIE)=
))
>>                 goto out_no_revalidate;
>>
>>         /* Check whether the cached attributes are stale */
>> @@ -1038,7 +1038,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, con=
st struct path *path,
>>                 do_update |=3D cache_validity & NFS_INO_INVALID_OTHER;
>>         if (request_mask & STATX_BLOCKS)
>>                 do_update |=3D cache_validity & NFS_INO_INVALID_BLOCKS;
>> -       if (request_mask & STATX_BTIME)
>> +       if (request_mask & (STATX_BTIME | STATX_PTIME))
>>                 do_update |=3D cache_validity & NFS_INO_INVALID_BTIME;
>>
>>         if (do_update) {
>> @@ -1061,6 +1061,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, con=
st struct path *path,
>>         if (S_ISDIR(inode->i_mode))
>>                 stat->blksize =3D NFS_SERVER(inode)->dtsize;
>>         stat->btime =3D NFS_I(inode)->btime;
>> +       stat->ptime =3D NFS_I(inode)->btime;
>>
>
> As an example of what would be needed per the mutable btime proposal,
> adding stat->ptime and STATX_PTIME will not be needed...
>
>>         /* Special handling for STATX_DIOALIGN and STATX_DIO_READ_ALIGN
>>          * - NFS doesn't have DIO alignment constraints, avoid getting
>> @@ -1092,10 +1093,26 @@ int nfs_fileattr_get(struct dentry *dentry, stru=
ct file_kattr *fa)
>>         }
>>         if (nfs_server_capable(inode, NFS_CAP_CASE_NONPRESERVING))
>>                 fa->fsx_xflags |=3D FS_XFLAG_CASENONPRESERVING;
>
> This would need:
>                   fa->fsx_xflags |=3D FS_XFLAG_CASEFOLD;
> +                fa->fsx_xflags_mask |=3D FS_XFLAG_CASEFOLD;
> +                fa->fsx_xflags_ro_mask |=3D FS_XFLAG_CASEFOLD;
> +                /* unlink other fs FS_CASEFOLD_FL is read-only */
(oh, s/unlink/unlike/?)

>                   fa->flags |=3D FS_CASEFOLD_FL;
With the new API and vfs helpers, this would need to get removed, as vfs
would already handle this for legacy ioctls, correct?

>         }
>                    fa->fsx_xflags |=3D FS_XFLAG_CASENONPRESERVING;
> +                 fa->fsx_xflags_mask |=3D FS_XFLAG_CASENONPRESERVING;
> +                 fa->fsx_xflags_ro_mask |=3D FS_XFLAG_CASENONPRESERVING;
Uhm, why both in _mask and _ro_mask? If it's a RDONLY flag shouldn't
it *only* be in _ro_mask? (same for CASEFOLD)

>
>> +       if (NFS_SERVER(inode)->fattr_valid & NFS_ATTR_FATTR_BTIME) {
>> +               fa->fsx_xflags |=3D FS_XFLAG_PTIME;
>> +               fa->fsx_xflags_mask |=3D FS_XFLAG_PTIME;
>> +               fa->fsx_ptime =3D NFS_I(inode)->btime;
>> +       }
>
> +               fa->fsx_xflags |=3D FS_XFLAG_BTIME;
> +               fa->fsx_xflags_mask |=3D FS_XFLAG_BTIME;
> +               fa->fsx_btime =3D NFS_I(inode)->btime;
>
> Fs with immutable btime could either not advertise the BTIME flag
> in xflags/xflags_mask or advertise the flag also in xflags_ro_mask.

That makes sense.

>>         return 0;
>>  }
>>  EXPORT_SYMBOL_GPL(nfs_fileattr_get);
>>
>> +int nfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dent=
ry,
>> +                    struct file_kattr *fa)
>> +{
>> +       const struct nfs_rpc_ops *ops =3D NFS_PROTO(d_inode(dentry));
>> +
>> +       if (ops->fileattr_set)
>> +               return ops->fileattr_set(idmap, dentry, fa);
>> +       return -EOPNOTSUPP;
>> +}
>> +EXPORT_SYMBOL_GPL(nfs_fileattr_set);
>> +
>>  static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
>>  {
>>         refcount_set(&l_ctx->count, 1);
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index 5af6a032f145..0e47fad944de 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -458,6 +458,8 @@ extern int nfs_wait_bit_killable(struct wait_bit_key=
 *key, int mode);
>>
>>  struct file_kattr;
>>  int nfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa);
>> +int nfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dent=
ry,
>> +                    struct file_kattr *fa);
>>
>>  #if IS_ENABLED(CONFIG_NFS_LOCALIO)
>>  /* localio.c */
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index e1018b03c1cb..31d58ceb4dc0 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -55,6 +55,7 @@
>>  #include <linux/utsname.h>
>>  #include <linux/freezer.h>
>>  #include <linux/iversion.h>
>> +#include <linux/fileattr.h>
>>
>>  #include "nfs4_fs.h"
>>  #include "delegation.h"
>> @@ -98,7 +99,8 @@ static int _nfs4_proc_getattr(struct nfs_server *serve=
r, struct nfs_fh *fhandle,
>>                               struct nfs_fattr *fattr, struct inode *ino=
de);
>>  static int nfs4_do_setattr(struct inode *inode, const struct cred *cred=
,
>>                             struct nfs_fattr *fattr, struct iattr *sattr=
,
>> -                           struct nfs_open_context *ctx, struct nfs4_la=
bel *ilabel);
>> +                           struct nfs_open_context *ctx, struct nfs4_la=
bel *ilabel,
>> +                           const struct timespec64 *time_create);
>>  static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
>>                 const struct cred *cred,
>>                 struct nfs4_slot *slot,
>> @@ -3216,7 +3218,7 @@ static int _nfs4_do_open(struct inode *dir,
>>                         nfs_fattr_init(opendata->o_res.f_attr);
>>                         status =3D nfs4_do_setattr(state->inode, cred,
>>                                         opendata->o_res.f_attr, sattr,
>> -                                       ctx, label);
>> +                                       ctx, label, NULL);
>>                         if (status =3D=3D 0) {
>>                                 nfs_setattr_update_inode(state->inode, s=
attr,
>>                                                 opendata->o_res.f_attr);
>> @@ -3380,7 +3382,8 @@ static int _nfs4_do_setattr(struct inode *inode,
>>
>>  static int nfs4_do_setattr(struct inode *inode, const struct cred *cred=
,
>>                            struct nfs_fattr *fattr, struct iattr *sattr,
>> -                          struct nfs_open_context *ctx, struct nfs4_lab=
el *ilabel)
>> +                          struct nfs_open_context *ctx, struct nfs4_lab=
el *ilabel,
>> +                          const struct timespec64 *time_create)
>>  {
>>         struct nfs_server *server =3D NFS_SERVER(inode);
>>         __u32 bitmask[NFS4_BITMASK_SZ];
>> @@ -3391,6 +3394,7 @@ static int nfs4_do_setattr(struct inode *inode, co=
nst struct cred *cred,
>>                 .server         =3D server,
>>                 .bitmask =3D bitmask,
>>                 .label          =3D ilabel,
>> +               .time_create    =3D time_create,
>>         };
>>         struct nfs_setattrres  res =3D {
>>                 .fattr          =3D fattr,
>> @@ -3414,6 +3418,9 @@ static int nfs4_do_setattr(struct inode *inode, co=
nst struct cred *cred,
>>         if (sattr->ia_valid & ATTR_MTIME)
>>                 adjust_flags |=3D NFS_INO_INVALID_MTIME;
>>
>> +       if (time_create)
>> +               adjust_flags |=3D NFS_INO_INVALID_BTIME;
>> +
>>         do {
>>                 nfs4_bitmap_copy_adjust(bitmask, nfs4_bitmask(server, fa=
ttr->label),
>>                                         inode, adjust_flags);
>> @@ -4587,7 +4594,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nf=
s_fattr *fattr,
>>         if ((sattr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) !=3D 0)
>>                 nfs4_inode_make_writeable(inode);
>>
>> -       status =3D nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NULL)=
;
>> +       status =3D nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NULL,=
 NULL);
>>         if (status =3D=3D 0) {
>>                 nfs_setattr_update_inode(inode, sattr, fattr);
>>                 nfs_setsecurity(inode, fattr);
>> @@ -10845,6 +10852,44 @@ static void nfs4_disable_swap(struct inode *ino=
de)
>>         wake_up_var(&clp->cl_state);
>>  }
>>
>> +#define NFS4_SUPPORTED_XFLAGS  (FS_XFLAG_PTIME)
>> +static int nfs4_fileattr_set(const struct mnt_idmap *idmap, struct dent=
ry *dentry,
>> +                            struct file_kattr *fa)
>> +{
>> +       struct inode *inode =3D d_inode(dentry);
>> +       struct nfs_server *server =3D NFS_SERVER(inode);
>> +       struct nfs_fattr *fattr;
>> +       struct iattr sattr =3D { .ia_valid =3D 0 };
>> +       const struct timespec64 *time_create =3D NULL;
>> +       int error;
>> +
>> +       if (!(server->fattr_valid & NFS_ATTR_FATTR_BTIME))
>> +               return -EOPNOTSUPP;
>> +
>> +       if (fa->flags_valid)
>> +               return -EOPNOTSUPP;
>> +
>> +       if (fileattr_has_fsx_mask(fa, NFS4_SUPPORTED_XFLAGS))
>> +               return -EOPNOTSUPP;
>> +
>> +       if (fa->fsx_xflags_mask & ~NFS4_SUPPORTED_XFLAGS)
>> +               return -EOPNOTSUPP;
>> +
>
> These two checks look semantically identical.
> I am not sure yet what you intention was with the
> fileattr_has_fsx_mask() helper - I know you had reservations about it
> but at least in this code, it doesn't look like it is needed at all.

Eh, the name is not the best, but they aren't, _mask & check the _mask
field, has_fsx_mask checks the xflags field (which is why I added the
question of keeping its name as it is or changing it to
"fileattr_has_unsupported_fsx").
But I'm not even sure we still need this helper, so I may just drop it.

Thanks,
koraynilay

>> +       if (fa->fsx_xflags_mask & FS_XFLAG_PTIME)
>> +               time_create =3D &fa->fsx_ptime;
>
> This would be BTIME/btime but otherwise the same.
>
> Thanks,
> Amir.



--3d15f75e39637138c31b5eb6b42e208a295fb1f9999d6996307de0cb3004
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQSgVimKafU5DQMcjcDmj22qf5IGXAUCav9zvAAKCRDmj22qf5IG
XEu7AP0c9QT/KQu0eG63cpYzurcE7LoPHmzKV1r0ma0pNA660wEAz/ZrwIX/0f7l
NT9CD1fW2/fXVSRBSR06DNatdB/xhwc=
=Pvsm
-----END PGP SIGNATURE-----

--3d15f75e39637138c31b5eb6b42e208a295fb1f9999d6996307de0cb3004--
