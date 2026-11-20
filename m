Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.43
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795157157;
	b=uUY3aEm9vrN6SpiRXtKfr4qUZ06pcE+nMzVE7GdDkVPrfbliaP4OMF6Ko2obx74Cihzl
	 NTMa+444QMu46iWz+GQwXRj04kdD2LZLYefe850QXgPM1kS7vM/QT9BbVYqw/OaqENrS/
	 nPt8H5kEm/RnggN5NiCz+G65TPD9rVRDsN2qH2loLv+37iQ36X9+DcX7hyjgp4W0IR3cC
	 Eleo2qjw1e9sjxzlbofiex9qbNp3aRKjf6TNwl7RI5TpYe+dnN0zl4PLsI/qHGcd4FldC
	 VUu3tKY6+tC61ggHhpHkBdvuivxMoGGZXx/Jcmkm9MBRykqmWTl5MJFWnqugILYxdYw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795157157;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=PhesRb2fJL2sv3VQKNbTEK9VdI6Zm/OpjPUoDzeKyOI=;
	b=g6vPSaXAjosKEN8PGxg1tkWgHsVtQLspmGcyc/ToZ4PnqO71pO+9bLlz3ATJTExHIjKs
	 9ydMM1zTgiLXfhPnE2+VOC9e3ExP9iuainPZhbLFSp3C6+RVSguyRVGTVKTIwUrTG+R33
	 vR0jQ37xpAI2y74T48uhp99KAzqOBWVpQSe8t0TlNu/0C+L3tAqD1waj45yn3BN8/6Rm/
	 hyIbV9CO8L9QL49TNkMp/USydiVvwSer9JBvSpPEi2Yqw8JsldIYdKRG73xJJKfpPJllt
	 Nn2PRqmsTXhY/UwygOEatkh91Hfw3HNHZE09XBFJUIOJQQW4HQbTDpqPptRW26ABwtw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=QnXYqMQr;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.43
Received: from mail-ed1-f43.google.com (mail-ed1-f43.google.com [209.85.208.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1145606A320
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 06:45:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D1145606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=QnXYqMQr
Received: by mail-ed1-f43.google.com with SMTP id 4fb4d7f45d1cf-6b894d9a075so603132a12.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 22:45:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795157155; cv=none;
        d=google.com; s=arc-20260327;
        b=IC+EbQpaqlrC95mKjw8j3eeJfTEQ6NcfoDR4x+K4Tu9L0BKK7qAahc8LmGAqYtZmBR
         OykgIxarYLhgOEu0tz0uLmG/dgBpI5xsjVhDVcRUh1N16lfGoiazuHake962i2Bz/IoP
         9oSIVbI5Hq8DmT9qSTWB0rD/NNrIVxINDfW9809si/bdFYeYhoMRJgX11zU419z+JVJ6
         6sGgP5PsU1KJ/ANzAyw3xMFV86AED4+6M2Bz2YH77fxnTD2PQugTRojR1WVSqIFkublF
         eghomoT2yCOzLvq9LyWUC2DBpbbl6/QR+PQC/yHqoAXUfzI3oJrLGlxwKwoNF/nWywRO
         wTsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=PhesRb2fJL2sv3VQKNbTEK9VdI6Zm/OpjPUoDzeKyOI=;
        fh=M0i8bTGGCBZUz9nbZkwoQaNIuBDOpX4A2470sDcuZyA=;
        b=rZMEZ4ooOWpxUnEDjYsBKT0pH7k/o/9qNYXGJmZ6k/xQqn1PDzaiLTCFix1D/3cvUR
         ZLmnuzRUg+oFPZAZ8I0fU/43TnGtAharwYJh9KrDB3xUvhzypXrwbnBOJxCsioldtcat
         FI9yogp5D/aVzA6KxRCHBhOk0oAvAA0OFRjhXhF8iYvlov2BS/9XCfoRdrxVwlOOIWW8
         FImXOhfIvHgcksPCNcxCC+Am1FROR8pVID937IEsdsgGaqwEOpy9JMkuhMqQc4Lgrwim
         gLq8HCCvT3y5JWf8KW81uh0KwqmCQMRmmEjpvVuA68SVfKwVENUPPp875uQ/+xwYmFqO
         WVtw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795157155; x=1795761955; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=PhesRb2fJL2sv3VQKNbTEK9VdI6Zm/OpjPUoDzeKyOI=;
        b=QnXYqMQr5z0NMr6hBuiBJQpdXHRabmycCVdbr+hnA8j8kwrJNNnGAKynnSO7Gvqhdg
         SwN+TixLmyMkD2wVDOCWnA8nu71rr8HfNDI/8h1i0q3ZT3nHsiux1iOQIvRU3UqAvxe7
         0MdSAviV1wPO0L/ENM1FwkfPoM3/P0JztGsiSczg4oihtTmhpVJGQfM5KbiZen3X7PMR
         yDaLS+S4QeMiQcP7CYLX/0Kpv96D6vKQ9XcRDplT0I6yi1wMdl6hYQxAIJKH44RRlD9j
         MIp6JtUsObTVf/yv4MhCOYPaS8/PEu+bzH2udGN6HONxsB9gjHCHNbYy/iW0vTdeUfzD
         3DBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795157155; x=1795761955;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=PhesRb2fJL2sv3VQKNbTEK9VdI6Zm/OpjPUoDzeKyOI=;
        b=AgilLpTKeXYBqi1OK10lwBynij9zEQmDQuXG6Pj1TXsUPOSpBXViAeuBpDamZGO4Yu
         6K0u/9GWZpOLO49+o3IQc4mGuugUSDcNMF2te3NHR0Us0fn4bJRRl/YoQmNckbhNL1dR
         SdwNmeIVp2zSt9I65iioZjWma/UohUTaPJoTUixyX2kFSyWNUeZ7crSUtY+9Yuu13OaJ
         pKDNByJIvH7ymZch5z1Uu5/sDwPnNXsYzwvu9z/QnkvZ30/luZDmPtp++onvY/qiShNw
         OphX0HBVJRSz4fw436banUk1LdTqdB8gUz5VVksHalRGJdHC9q9ZoUSQ/HH79gjLE6px
         lMjQ==
X-Forwarded-Encrypted: i=1; AL+hErE0u51aFlyoLMYgOLqnh0vF00R+VTnhciehR68AAvZQ9kRTBZpZTq4IYC/8YBApxxy6TuqhT/79LkY=@vger.kernel.org
X-Gm-Message-State: APuU4Z+t6MbMX+WqD2GEMJE6JDzg1doHHsRvNjAOmYX8cBfm0cYMCUmr
	XvlkSKtmZ2E+Uo9GeMtFmVJnG+F1605lgaoVhG5yhr8IrisIgHj4WJckZEhw0qNJuXXfeUI5ngW
	BHFoDUSaoY3ADjHJc1PbCPaJyveHnnDs=
X-Gm-Gg: AZFdTZeGwnFo+VNgxSiw7MbPYYUiREVOJkgqUd4flhdSorZjApbHiZXlZIljaLky6z5
	BXPuHgpfHnE3jooGMapQlDIFY3Xxfh5hhLM72+E90DnFzP0r7miqNbZxQ1FYuZNED7rtd4jF8po
	f1Hffidjj+QwT8sJG4pzdyfwL3/hN79E37IWABO8QDM3cZpAP/KvvAcNV4GeAd+RO+z7M8JvyEF
	lTSSfKS/KbvIBrBBjPFZi/tFXxn93+PvX/tazbfcvGgukb6bNr5f6S2SUzd4ddE9zB8Fq/JMWBW
	aUqbXOTjF5f3zd02MO6BNqAJXZq72dSHr2KobIQnDhh/gHYv9x0xSzzzp3ljWS/ly5aWItT+8sD
	F6La4s/rFkhdpmBAOJgefR1hWtvmzVOV3Wxs83zVUffiu3dakvlxs4FuJ5c2uf5VYbvnGqA==
X-Received: by 2002:a05:6402:a592:10b0:6b8:8706:8e91 with SMTP id
 4fb4d7f45d1cf-6ba37d6526dmr960183a12.12.1795157154882; Thu, 19 Nov 2026
 22:45:54 -0800 (PST)
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
 <CAOQ4uxgoNsOH82FyrCxc+qSoid_CFmbmpL0qgWFw-e8E689fFA@mail.gmail.com> <DMZJ4PL1JVA4.2YEB7EPYJR5Q7@gmail.com>
In-Reply-To: <DMZJ4PL1JVA4.2YEB7EPYJR5Q7@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 20 Nov 2026 07:45:43 +0100
X-Gm-Features: AclHuK_wtO-xn2FdXS4_uzyRTAs2S8_YFxhSnFKIVmGgyyWPtzVK3ZO9hbfvgbU
Message-ID: <CAOQ4uxi6h9BBP7pf4sR+gc2+4XtkEgbxXZha45iZzdB_wGFVgQ@mail.gmail.com>
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
	linux-api@vger.kernel.org, Theodore Tso <tytso@mit.edu>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 19, 2026 at 11:10=E2=80=AFPM koraynilay <koray.fra@gmail.com> w=
rote:
>
> On Thu Nov 19, 2026 at 7:06 PM CET, Amir Goldstein wrote:
> > On Sun, Nov 15, 2026 at 7:04=E2=80=AFPM koraynilay <koray.fra@gmail.com=
> wrote:
> >>
> >> Implement provenance time (ptime) in the NFS client, as introduced in =
a
> >> previous commit ("vfs: add provenance time (ptime)").
> >>
> >> Support reading ptime via statx(2) and file_getattr(), returning the
> >> cached creation time when the server advertises NFS_ATTR_FATTR_BTIME.
> >>
> >> Implement sending FATTR4_TIME_CREATE, asking the server to persist the
> >> file creation time using ptime on the underlying filesystem.
> >>
> >> Also add .fileattr_set to struct nfs_rpc_ops and set it to
> >> nfs4_fileattr_set() in nfs_v4_clientops. Provide a generic
> >> nfs_fileattr_set() dispatcher so even symlinks can update ptime under
> >> NFSv4 while cleanly returning -EOPNOTSUPP on NFSv2/v3.
> >>
> >> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
> >> Signed-off-by: koraynilay <koray.fra@gmail.com>
> >> ---
> >>  fs/nfs/inode.c          | 27 ++++++++++++++++----
> >>  fs/nfs/internal.h       |  2 ++
> >>  fs/nfs/nfs4proc.c       | 56 ++++++++++++++++++++++++++++++++++++++--=
-
> >>  fs/nfs/nfs4xdr.c        | 19 +++++++++-----
> >>  fs/nfs/symlink.c        |  1 +
> >>  include/linux/nfs_xdr.h |  3 +++
> >>  6 files changed, 93 insertions(+), 15 deletions(-)
> >>
> >> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> >> index e0a2e92952af..2ddcfd872616 100644
> >> --- a/fs/nfs/inode.c
> >> +++ b/fs/nfs/inode.c
> >> @@ -955,7 +955,7 @@ static u32 nfs_get_valid_attrmask(struct inode *in=
ode)
> >>                 reply_mask |=3D STATX_BLOCKS;
> >>         if (!(cache_validity & NFS_INO_INVALID_BTIME) &&
> >>             (fattr_valid & NFS_ATTR_FATTR_BTIME))
> >> -               reply_mask |=3D STATX_BTIME;
> >> +               reply_mask |=3D STATX_BTIME | STATX_PTIME;
> >>         if (!(cache_validity & NFS_INO_INVALID_CHANGE))
> >>                 reply_mask |=3D STATX_CHANGE_COOKIE;
> >>         return reply_mask;
> >> @@ -978,10 +978,10 @@ int nfs_getattr(const struct mnt_idmap *idmap, c=
onst struct path *path,
> >>         request_mask &=3D STATX_TYPE | STATX_MODE | STATX_NLINK | STAT=
X_UID |
> >>                         STATX_GID | STATX_ATIME | STATX_MTIME | STATX_=
CTIME |
> >>                         STATX_INO | STATX_SIZE | STATX_BLOCKS | STATX_=
BTIME |
> >> -                       STATX_CHANGE_COOKIE;
> >> +                       STATX_PTIME | STATX_CHANGE_COOKIE;
> >>
> >>         if (!(fattr_valid & NFS_ATTR_FATTR_BTIME))
> >> -               request_mask &=3D ~STATX_BTIME;
> >> +               request_mask &=3D ~(STATX_BTIME | STATX_PTIME);
> >>
> >>         if ((query_flags & AT_STATX_DONT_SYNC) && !force_sync) {
> >>                 if (readdirplus_enabled)
> >> @@ -1015,7 +1015,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, c=
onst struct path *path,
> >>         if (!(request_mask & (STATX_MODE|STATX_NLINK|STATX_ATIME|STATX=
_CTIME|
> >>                                         STATX_MTIME|STATX_UID|STATX_GI=
D|
> >>                                         STATX_SIZE|STATX_BLOCKS|STATX_=
BTIME|
> >> -                                       STATX_CHANGE_COOKIE)))
> >> +                                       STATX_PTIME|STATX_CHANGE_COOKI=
E)))
> >>                 goto out_no_revalidate;
> >>
> >>         /* Check whether the cached attributes are stale */
> >> @@ -1038,7 +1038,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, c=
onst struct path *path,
> >>                 do_update |=3D cache_validity & NFS_INO_INVALID_OTHER;
> >>         if (request_mask & STATX_BLOCKS)
> >>                 do_update |=3D cache_validity & NFS_INO_INVALID_BLOCKS=
;
> >> -       if (request_mask & STATX_BTIME)
> >> +       if (request_mask & (STATX_BTIME | STATX_PTIME))
> >>                 do_update |=3D cache_validity & NFS_INO_INVALID_BTIME;
> >>
> >>         if (do_update) {
> >> @@ -1061,6 +1061,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, c=
onst struct path *path,
> >>         if (S_ISDIR(inode->i_mode))
> >>                 stat->blksize =3D NFS_SERVER(inode)->dtsize;
> >>         stat->btime =3D NFS_I(inode)->btime;
> >> +       stat->ptime =3D NFS_I(inode)->btime;
> >>
> >
> > As an example of what would be needed per the mutable btime proposal,
> > adding stat->ptime and STATX_PTIME will not be needed...
> >
> >>         /* Special handling for STATX_DIOALIGN and STATX_DIO_READ_ALIG=
N
> >>          * - NFS doesn't have DIO alignment constraints, avoid getting
> >> @@ -1092,10 +1093,26 @@ int nfs_fileattr_get(struct dentry *dentry, st=
ruct file_kattr *fa)
> >>         }
> >>         if (nfs_server_capable(inode, NFS_CAP_CASE_NONPRESERVING))
> >>                 fa->fsx_xflags |=3D FS_XFLAG_CASENONPRESERVING;
> >
> > This would need:
> >                   fa->fsx_xflags |=3D FS_XFLAG_CASEFOLD;
> > +                fa->fsx_xflags_mask |=3D FS_XFLAG_CASEFOLD;
> > +                fa->fsx_xflags_ro_mask |=3D FS_XFLAG_CASEFOLD;
> > +                /* unlink other fs FS_CASEFOLD_FL is read-only */
> (oh, s/unlink/unlike/?)

Yeh :)
It's a comment for you not for the code

>
> >                   fa->flags |=3D FS_CASEFOLD_FL;
> With the new API and vfs helpers, this would need to get removed, as vfs
> would already handle this for legacy ioctls, correct?
>
> >         }
> >                    fa->fsx_xflags |=3D FS_XFLAG_CASENONPRESERVING;
> > +                 fa->fsx_xflags_mask |=3D FS_XFLAG_CASENONPRESERVING;
> > +                 fa->fsx_xflags_ro_mask |=3D FS_XFLAG_CASENONPRESERVIN=
G;
> Uhm, why both in _mask and _ro_mask? If it's a RDONLY flag shouldn't
> it *only* be in _ro_mask? (same for CASEFOLD)
>

Good question. Maybe
I guess if you want to follow some percent
FS_FL_USER_MODIFIABLE is a subset of FS_FL_USER_VISIBLE
but I think that exporting ro_mask and _mask is going to be easier and
cleaner than rw_mask but not sure.

> >
> >> +       if (NFS_SERVER(inode)->fattr_valid & NFS_ATTR_FATTR_BTIME) {
> >> +               fa->fsx_xflags |=3D FS_XFLAG_PTIME;
> >> +               fa->fsx_xflags_mask |=3D FS_XFLAG_PTIME;
> >> +               fa->fsx_ptime =3D NFS_I(inode)->btime;
> >> +       }
> >
> > +               fa->fsx_xflags |=3D FS_XFLAG_BTIME;
> > +               fa->fsx_xflags_mask |=3D FS_XFLAG_BTIME;
> > +               fa->fsx_btime =3D NFS_I(inode)->btime;
> >
> > Fs with immutable btime could either not advertise the BTIME flag
> > in xflags/xflags_mask or advertise the flag also in xflags_ro_mask.
>
> That makes sense.
>
> >>         return 0;
> >>  }
> >>  EXPORT_SYMBOL_GPL(nfs_fileattr_get);
> >>
> >> +int nfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *de=
ntry,
> >> +                    struct file_kattr *fa)
> >> +{
> >> +       const struct nfs_rpc_ops *ops =3D NFS_PROTO(d_inode(dentry));
> >> +
> >> +       if (ops->fileattr_set)
> >> +               return ops->fileattr_set(idmap, dentry, fa);
> >> +       return -EOPNOTSUPP;
> >> +}
> >> +EXPORT_SYMBOL_GPL(nfs_fileattr_set);
> >> +
> >>  static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
> >>  {
> >>         refcount_set(&l_ctx->count, 1);
> >> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> >> index 5af6a032f145..0e47fad944de 100644
> >> --- a/fs/nfs/internal.h
> >> +++ b/fs/nfs/internal.h
> >> @@ -458,6 +458,8 @@ extern int nfs_wait_bit_killable(struct wait_bit_k=
ey *key, int mode);
> >>
> >>  struct file_kattr;
> >>  int nfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa);
> >> +int nfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *de=
ntry,
> >> +                    struct file_kattr *fa);
> >>
> >>  #if IS_ENABLED(CONFIG_NFS_LOCALIO)
> >>  /* localio.c */
> >> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> >> index e1018b03c1cb..31d58ceb4dc0 100644
> >> --- a/fs/nfs/nfs4proc.c
> >> +++ b/fs/nfs/nfs4proc.c
> >> @@ -55,6 +55,7 @@
> >>  #include <linux/utsname.h>
> >>  #include <linux/freezer.h>
> >>  #include <linux/iversion.h>
> >> +#include <linux/fileattr.h>
> >>
> >>  #include "nfs4_fs.h"
> >>  #include "delegation.h"
> >> @@ -98,7 +99,8 @@ static int _nfs4_proc_getattr(struct nfs_server *ser=
ver, struct nfs_fh *fhandle,
> >>                               struct nfs_fattr *fattr, struct inode *i=
node);
> >>  static int nfs4_do_setattr(struct inode *inode, const struct cred *cr=
ed,
> >>                             struct nfs_fattr *fattr, struct iattr *sat=
tr,
> >> -                           struct nfs_open_context *ctx, struct nfs4_=
label *ilabel);
> >> +                           struct nfs_open_context *ctx, struct nfs4_=
label *ilabel,
> >> +                           const struct timespec64 *time_create);
> >>  static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
> >>                 const struct cred *cred,
> >>                 struct nfs4_slot *slot,
> >> @@ -3216,7 +3218,7 @@ static int _nfs4_do_open(struct inode *dir,
> >>                         nfs_fattr_init(opendata->o_res.f_attr);
> >>                         status =3D nfs4_do_setattr(state->inode, cred,
> >>                                         opendata->o_res.f_attr, sattr,
> >> -                                       ctx, label);
> >> +                                       ctx, label, NULL);
> >>                         if (status =3D=3D 0) {
> >>                                 nfs_setattr_update_inode(state->inode,=
 sattr,
> >>                                                 opendata->o_res.f_attr=
);
> >> @@ -3380,7 +3382,8 @@ static int _nfs4_do_setattr(struct inode *inode,
> >>
> >>  static int nfs4_do_setattr(struct inode *inode, const struct cred *cr=
ed,
> >>                            struct nfs_fattr *fattr, struct iattr *satt=
r,
> >> -                          struct nfs_open_context *ctx, struct nfs4_l=
abel *ilabel)
> >> +                          struct nfs_open_context *ctx, struct nfs4_l=
abel *ilabel,
> >> +                          const struct timespec64 *time_create)
> >>  {
> >>         struct nfs_server *server =3D NFS_SERVER(inode);
> >>         __u32 bitmask[NFS4_BITMASK_SZ];
> >> @@ -3391,6 +3394,7 @@ static int nfs4_do_setattr(struct inode *inode, =
const struct cred *cred,
> >>                 .server         =3D server,
> >>                 .bitmask =3D bitmask,
> >>                 .label          =3D ilabel,
> >> +               .time_create    =3D time_create,
> >>         };
> >>         struct nfs_setattrres  res =3D {
> >>                 .fattr          =3D fattr,
> >> @@ -3414,6 +3418,9 @@ static int nfs4_do_setattr(struct inode *inode, =
const struct cred *cred,
> >>         if (sattr->ia_valid & ATTR_MTIME)
> >>                 adjust_flags |=3D NFS_INO_INVALID_MTIME;
> >>
> >> +       if (time_create)
> >> +               adjust_flags |=3D NFS_INO_INVALID_BTIME;
> >> +
> >>         do {
> >>                 nfs4_bitmap_copy_adjust(bitmask, nfs4_bitmask(server, =
fattr->label),
> >>                                         inode, adjust_flags);
> >> @@ -4587,7 +4594,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct =
nfs_fattr *fattr,
> >>         if ((sattr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) !=3D 0)
> >>                 nfs4_inode_make_writeable(inode);
> >>
> >> -       status =3D nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NUL=
L);
> >> +       status =3D nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NUL=
L, NULL);
> >>         if (status =3D=3D 0) {
> >>                 nfs_setattr_update_inode(inode, sattr, fattr);
> >>                 nfs_setsecurity(inode, fattr);
> >> @@ -10845,6 +10852,44 @@ static void nfs4_disable_swap(struct inode *i=
node)
> >>         wake_up_var(&clp->cl_state);
> >>  }
> >>
> >> +#define NFS4_SUPPORTED_XFLAGS  (FS_XFLAG_PTIME)
> >> +static int nfs4_fileattr_set(const struct mnt_idmap *idmap, struct de=
ntry *dentry,
> >> +                            struct file_kattr *fa)
> >> +{
> >> +       struct inode *inode =3D d_inode(dentry);
> >> +       struct nfs_server *server =3D NFS_SERVER(inode);
> >> +       struct nfs_fattr *fattr;
> >> +       struct iattr sattr =3D { .ia_valid =3D 0 };
> >> +       const struct timespec64 *time_create =3D NULL;
> >> +       int error;
> >> +
> >> +       if (!(server->fattr_valid & NFS_ATTR_FATTR_BTIME))
> >> +               return -EOPNOTSUPP;
> >> +
> >> +       if (fa->flags_valid)
> >> +               return -EOPNOTSUPP;
> >> +
> >> +       if (fileattr_has_fsx_mask(fa, NFS4_SUPPORTED_XFLAGS))
> >> +               return -EOPNOTSUPP;
> >> +
> >> +       if (fa->fsx_xflags_mask & ~NFS4_SUPPORTED_XFLAGS)
> >> +               return -EOPNOTSUPP;
> >> +
> >
> > These two checks look semantically identical.
> > I am not sure yet what you intention was with the
> > fileattr_has_fsx_mask() helper - I know you had reservations about it
> > but at least in this code, it doesn't look like it is needed at all.
>
> Eh, the name is not the best, but they aren't, _mask & check the _mask
> field, has_fsx_mask checks the xflags field (which is why I added the
> question of keeping its name as it is or changing it to
> "fileattr_has_unsupported_fsx").
> But I'm not even sure we still need this helper, so I may just drop it.
>

I don't care either way as long as the code reads fine.

Thanks,
Amir.
