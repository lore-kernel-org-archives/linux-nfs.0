Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795183561;
	b=wY+xGc1y9uzvi5KyGRBXFCvikCFviaBDabwHb+55v5O99B6BA0WhoN19m5UeS4+eJivZ
	 qQ/oHbRQ360/Fj0b7pvHRVM9qkbsjM8dApxSIpRtqhhqmIOo6wiM2QgLIWXjRxplwEH+u
	 JneLe+7P+YNb/rIj0f6ZNpkiabvC5AI9obZYbf4x0uAIa5CUjM5TW2CUb65HqP04dv1rk
	 Ggx5NG4Ks3QBxG8f3iIt3XhvNf3B8dd8M3vCZEDnTl+S6xnykKq3xxWJxaCYOfaH1nwoX
	 v77TrEtQCOGS5qOR0WcZJV028SmupmKYSYSfogr3D2WBZ0YZRiOlGtRh6h6NCOgRrtA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795183561;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:To:Cc:Subject:From:X-Mailer:
	 References:In-Reply-To;
	bh=lQXWhNQQlhPXEIIcGVoxJddlPdJJNSTkNAUDZ7QCuXs=;
	b=QLtL/v2l7+ESiXdDnota3t0XSePCjSVgmape1LPsxHJ3b0XH2WRJigSRo1UIZ11JYH4J
	 cnQBvvQBuIPwXt3AfHO3IFubeFAPqNlGLC3/7qiwwnoJ/dvsSgKQyQAS7of8RAuDAtbzU
	 Ot2/KZGN19fttoQI7FzmgS0fg9csszXB4NzqwTf+Tw2EeNGDZPeo9Jq7lKQidILUO99Qi
	 aT5OIjZY7bHEZLyuueASSKKKybpIBf84Qno0Lgpl+zgEmhZ7LPnFbnMVGVerwZw0t+Yyy
	 2BHTStvRrj2LhtKixUHhi7hXdYRBiSMvC1S2u2Pj8Jlwocs3817DgUDf/cHr2KfQl+w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="gpLZb0Z/";
	arc=none smtp.remote-ip=209.85.221.47
Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F4E3606A333
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 14:06:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9F4E3606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=gpLZb0Z/
Received: by mail-wr1-f47.google.com with SMTP id ffacd0b85a97d-498f5fa4f70so744220f8f.0
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 06:06:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795183559; x=1795788359; darn=vger.kernel.org;
        h=in-reply-to:references:from:subject:cc:to:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=lQXWhNQQlhPXEIIcGVoxJddlPdJJNSTkNAUDZ7QCuXs=;
        b=gpLZb0Z/dRVHbMoXZrh+kzP5ioym8u6jETVmOgUHiTsO0gHBZvjaY1u8xn9vZYPjI3
         HlADiDIbW85273oCtZNkS/gSMZj7KDnEn2FCDAQplgZJNRBrG8J9zrvGJt5nkEQ6W9mF
         fyOtpp1IFic0Xu2tcDpKrH6QzUNu+5abygtChqmqZyNkLbL0LOGVwoaOpODRNVGjAFvj
         k86yIOI2k6HAthLvLU42zksjw+fJO5ba8Jqt7Q7/f94IEHSHQAXazZxeQGEOHaejOQg0
         KlroNHqPtg8w0ywi+z661oXiBCqpbpJqy0269kS0oz/lBVQ4wbPIsmv7FRbzRIsX7nVg
         1l4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795183559; x=1795788359;
        h=in-reply-to:references:from:subject:cc:to:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=lQXWhNQQlhPXEIIcGVoxJddlPdJJNSTkNAUDZ7QCuXs=;
        b=X2qISAHm9CMoWvMbI0oNqF7vp8ZAhReUwicBtUvFuEFZQZo/netw9zVqkZAul7WLI2
         0LnCDfHYf/aEOBOWET2VH60eB6I4axS+EFWJYuGdHQ9U4XjqBzTfdMbU+ecBmLFrZ+oM
         F6BUPYyBy63JHrS2aqUCHtxXNTbiq2InFCMekwbBl70/whtbTNOLhn4Qg9Igi0YYrj/A
         51tmOSEuxuTm0hkZi0pDXiGd5GAnvDu0qlHpoE3V7H1hww15Iu59H8URrm9pyUTy03DR
         PiC80YlPEJEHD3USWwnyyYDJCuYcnvawS7R4NMNJ3rPVXcpsxNvrs1Oj47DUFXah2/3N
         tMsw==
X-Forwarded-Encrypted: i=1; AL+hErGH5nU12VpOuhXDE6hQ0TeObdh9Mt5zhyYaefz3FDSvcCgOq0ggx8gPz/34YuS3NedhI/UUbYXsLbs=@vger.kernel.org
X-Gm-Message-State: APuU4Z+R/8N4YUvVdLa2jbwo5o0D/fIHscT5bzYxkaJy71zZO0X9WOYM
	EijC4r1a/YTG2e/ZsM0zK1zkvJ4DTOPapHime0vui+qKvOAHDi3LBrRY
X-Gm-Gg: AZFdTZf3+X0PPQlN+Kpd57tVllkKwVPZgWvM2dDG/UhStTIHmwq+XaMgY6NSvrUF3Et
	FLDFXaDrQAB6fObabnnHzh8qL6vPkx93wWIr4dz257b4qSn0MqO9nlObCo8XoKuWGuOezeS1nVF
	h9K7EkKR50u+eSt1b2kPp/X21P/L+EFaiXRjRoYWkYUrYorv2OANrO8VuACrJgASkfKoIe+DyZ6
	SkGu1tNGI6DPAvHV+pk636Mw3KxGV+PRyPBWDs4ahr7Fo0yyXvnBhMa+javH5WyS46JeXpTCPyt
	o+LE+YQ/aZaQxF44LbmCe/RDKAVihPIXygddcLKOsd3hmn26wXsf+jVXrYe8s3C0JSepHr2AfBR
	6Ao08+MW2hJEgqhApoDFGZ7dPmDK6a4ltNSysPP0Acaz6ev3xaauNJoTxj1fRqxZ/iHLblCePlF
	WzV3f7a3AQrP6MDHEsxYGwdFhb80YNJL9lXrQDxbQfDoiFy2RXwGOM4T231MhBOiOv1JdO5mo1U
	KDsMtRQ1U+2DxkUhNJ7X5I0IC8BHkCJL18IMkXEYcX3a/8b8DAXuByYukJlNJt66WJNI4RApgdn
	hXeQN/ozzb+V0i8qidYs7AJ+My+TwL2Dd+8Iz8GqXgsUdRzp2Dj/sAKTHxaw+j7YbnRAcw==
X-Received: by 2002:a05:6000:24c3:b0:4a4:368:409d with SMTP id ffacd0b85a97d-4abaa9769d3mr7118563f8f.3.1795183558599;
        Fri, 20 Nov 2026 06:05:58 -0800 (PST)
Received: from localhost ([130.192.98.149])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab658e2d1bsm6110394f8f.8.2026.11.20.06.05.56
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 20 Nov 2026 06:05:57 -0800 (PST)
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
 boundary=9e5986ede954feecad11ad001d02150c5a356196d013aeccc838f4a9c70a;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Fri, 20 Nov 2026 15:05:53 +0100
Message-Id: <DN03GJ80ZWNZ.9GM35HM4T48N@gmail.com>
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
 <linux-api@vger.kernel.org>, "Miklos Szeredi" <miklos@szeredi.hu>
Subject: Re: [RFC PATCH v4 10/10] cifs: add provenance time (ptime) and map
 it to SMB's CreationTime
From: "koraynilay" <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261115180343.576773-11-koray.fra@gmail.com>
 <CAOQ4uxg2gpC99ohuvKm-SgPzuffJy1fSvXorbuBnYZ=OFSxT3w@mail.gmail.com>
 <DMZIZ05H7MMB.1WYNR4X44BPGR@gmail.com>
 <CAOQ4uxg8aVcWyNiFDk8djdn-M3xJcu_7-kRxVq9jjFsbcGp1ew@mail.gmail.com>
In-Reply-To: <CAOQ4uxg8aVcWyNiFDk8djdn-M3xJcu_7-kRxVq9jjFsbcGp1ew@mail.gmail.com>

--9e5986ede954feecad11ad001d02150c5a356196d013aeccc838f4a9c70a
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Fri Nov 20, 2026 at 7:34 AM CET, Amir Goldstein wrote:
> On Thu, Nov 19, 2026 at 11:02=E2=80=AFPM koraynilay <koray.fra@gmail.com>=
 wrote:
>>
>> On Thu Nov 19, 2026 at 7:32 PM CET, Amir Goldstein wrote:
>> > On Sun, Nov 15, 2026 at 7:04=E2=80=AFPM koraynilay <koray.fra@gmail.co=
m> wrote:
>> >>
>> >> Implement provenance time (ptime) in cifs, as introduced in a
>> >> previous commit ("vfs: add provenance time (ptime)").
>> >>
>> >> Map it to SMB's CreationTime, making it settable from userspace and
>> >> propagating it to the SMB server via FILE_BASIC_INFO.
>> >>
>> >> Support reading ptime via statx(2) and fileattr_get() from the cached
>> >> CreationTime.
>> >>
>> >> Update cifs_fileattr_set() to check xflags instead of only legacy fla=
gs
>> >> and add the cifs_set_file_crtime() helper to wrap the RPC call to the
>> >> SMB server.
>> >>
>> >> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
>> >> Signed-off-by: koraynilay <koray.fra@gmail.com>
>> >> ---
>> >>  fs/smb/client/cifsfs.c |   8 +++
>> >>  fs/smb/client/inode.c  |   7 ++-
>> >>  fs/smb/client/ioctl.c  | 109 ++++++++++++++++++++++++++++++---------=
--
>> >>  3 files changed, 94 insertions(+), 30 deletions(-)
>> >>
>> >> diff --git a/fs/smb/client/cifsfs.c b/fs/smb/client/cifsfs.c
>> >> index 8cff7857b450..c2f557e406d3 100644
>> >> --- a/fs/smb/client/cifsfs.c
>> >> +++ b/fs/smb/client/cifsfs.c
>> >> @@ -1307,6 +1307,14 @@ int cifs_fileattr_get(struct dentry *dentry, s=
truct file_kattr *fa)
>> >>         if (READ_ONCE(CIFS_I(inode)->cifsAttrs) & ATTR_COMPRESSED)
>> >>                 fa->flags |=3D FS_COMPR_FL;
>> >>
>> >> +       /* Report provenance time (ptime) to userspace */
>> >> +       if (CIFS_I(inode)->createtime) {
>> >> +               fa->fsx_xflags |=3D FS_XFLAG_PTIME;
>> >> +               fa->fsx_xflags_mask |=3D FS_XFLAG_PTIME;
>> >> +               fa->fsx_ptime =3D
>> >> +                     cifs_NTtimeToUnix(cpu_to_le64(CIFS_I(inode)->cr=
eatetime));
>> >> +       }
>> >> +
>> >>         /*
>> >>          * FS_CASEFOLD_FL is defined by UAPI as a folder attribute,
>> >>          * and userspace tools (e.g., lsattr) display it only on
>> >> diff --git a/fs/smb/client/inode.c b/fs/smb/client/inode.c
>> >> index 2647785ec1e4..f0b20a72b9c2 100644
>> >> --- a/fs/smb/client/inode.c
>> >> +++ b/fs/smb/client/inode.c
>> >> @@ -222,6 +222,7 @@ cifs_fattr_to_inode(struct inode *inode, struct c=
ifs_fattr *fattr,
>> >>
>> >>         cifs_i->cifsAttrs =3D fattr->cf_cifsattrs;
>> >>         cifs_i->reparse_tag =3D fattr->cf_cifstag;
>> >> +       cifs_i->createtime =3D fattr->cf_createtime;
>> >>
>> >>         if (fattr->cf_flags & CIFS_FATTR_NEED_REVAL)
>> >>                 cifs_i->time =3D 0;
>> >> @@ -2958,7 +2959,8 @@ int cifs_getattr(const struct mnt_idmap *idmap,=
 const struct path *path,
>> >>          * We need to be sure that all dirty pages are written and th=
e server
>> >>          * has actual ctime, mtime and file length.
>> >>          */
>> >> -       if ((request_mask & (STATX_CTIME | STATX_MTIME | STATX_SIZE |=
 STATX_BLOCKS)) &&
>> >> +       if ((request_mask & (STATX_CTIME | STATX_MTIME | STATX_PTIME
>> >> +                            | STATX_SIZE | STATX_BLOCKS)) &&
>> >>             !CIFS_CACHE_READ(CIFS_I(inode)) &&
>> >>             inode->i_mapping && inode->i_mapping->nrpages !=3D 0) {
>> >>                 rc =3D filemap_fdatawait(inode->i_mapping);
>> >> @@ -2992,6 +2994,9 @@ int cifs_getattr(const struct mnt_idmap *idmap,=
 const struct path *path,
>> >>                 stat->result_mask |=3D STATX_BTIME;
>> >>                 stat->btime =3D
>> >>                       cifs_NTtimeToUnix(cpu_to_le64(CIFS_I(inode)->cr=
eatetime));
>> >> +               stat->result_mask |=3D STATX_PTIME;
>> >> +               stat->ptime =3D
>> >> +                     cifs_NTtimeToUnix(cpu_to_le64(CIFS_I(inode)->cr=
eatetime));
>> >>         }
>> >>
>> >>         stat->attributes_mask |=3D (STATX_ATTR_COMPRESSED | STATX_ATT=
R_ENCRYPTED);
>> >> diff --git a/fs/smb/client/ioctl.c b/fs/smb/client/ioctl.c
>> >> index bb8808289a46..19a9556d39b4 100644
>> >> --- a/fs/smb/client/ioctl.c
>> >> +++ b/fs/smb/client/ioctl.c
>> >> @@ -181,6 +181,41 @@ static int cifs_set_compression(unsigned int xid=
, struct dentry *dentry,
>> >>                                             compression_state);
>> >>  }
>> >>
>> >> +static int cifs_set_file_crtime(unsigned int xid, struct dentry *den=
try,
>> >> +                               struct cifs_tcon *tcon, u64 crtime)
>> >> +{
>> >> +       struct inode *inode =3D d_inode(dentry);
>> >> +       struct TCP_Server_Info *server =3D tcon->ses->server;
>> >> +       FILE_BASIC_INFO info_buf =3D {};
>> >> +       const char *full_path;
>> >> +       void *page;
>> >> +       int rc;
>> >> +
>> >> +       if (!server->ops->set_file_info)
>> >> +               return -EOPNOTSUPP;
>> >> +
>> >> +       info_buf.CreationTime =3D cpu_to_le64(crtime);
>> >> +
>> >> +       page =3D alloc_dentry_path();
>> >> +       full_path =3D build_path_from_dentry(dentry, page);
>> >> +       if (IS_ERR(full_path)) {
>> >> +               rc =3D PTR_ERR(full_path);
>> >> +               goto out;
>> >> +       }
>> >> +
>> >> +       rc =3D server->ops->set_file_info(inode, full_path, &info_buf=
, xid);
>> >> +       if (rc =3D=3D 0) {
>> >> +               CIFS_I(inode)->createtime =3D crtime;
>> >> +               CIFS_I(inode)->time =3D 0;
>> >> +               inode_set_ctime_current(inode);
>> >> +       }
>> >> +
>> >> +out:
>> >> +       free_dentry_path(page);
>> >> +       return rc;
>> >> +}
>> >> +
>> >> +#define CIFS_SUPPORTED_XFLAGS (FS_XFLAG_PTIME)
>> >>  int cifs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *=
dentry,
>> >>                       struct file_kattr *fa)
>> >>  {
>> >> @@ -193,49 +228,65 @@ int cifs_fileattr_set(const struct mnt_idmap *i=
dmap, struct dentry *dentry,
>> >>         bool enable_compression;
>> >>         struct cifs_tcon *tcon;
>> >>         unsigned int xid;
>> >> -       int rc;
>> >> +       int rc =3D 0;
>> >>
>> >> -       if (!fa->flags_valid)
>> >> +       if (fileattr_has_fsx_mask(fa, CIFS_SUPPORTED_XFLAGS))
>> >>                 return -EOPNOTSUPP;
>> >
>> > What is this supposed to check that is not already checked
>> > explicitly with fsx_xflags_mask below?
>>
>> It should work for FS_IOC_FSSETXATTR, where mask is 0... but it's also
>> there because when I started writing the various filesystems code I
>> hadn't added _mask yet, so I'll need to take a little step back and
>> revisit.
>>
>
> Yes, I see.
> I think the helper may still have value for fs that still parse the
> two types of flags.

Yeah maybe, I'll see after I the first vfs-only patch I think.

> To reduce the scope of your patch set this may be better.
>
>> >>
>> >> -       /*
>> >> -        * chattr writes back all flags returned by fileattr_get(). A=
ccept
>> >> -        * FS_CASEFOLD_FL only when it reflects the share's casefold =
state.
>> >> -        */
>> >> -       if (fa->flags & FS_CASEFOLD_FL) {
>> >> -               rc =3D cifs_fileattr_get(dentry, &current_fa);
>> >> -               if (rc)
>> >> -                       return rc;
>> >> -               if (current_fa.flags & FS_CASEFOLD_FL)
>> >> -                       allowed |=3D FS_CASEFOLD_FL;
>> >> -       }
>> >> -       if (fa->flags & ~allowed)
>> >> +       if (fa->fsx_xflags_mask & ~CIFS_SUPPORTED_XFLAGS)
>> >>                 return -EOPNOTSUPP;
>> >>
>> >> -       enable_compression =3D fa->flags & FS_COMPR_FL;
>> >> -       compression_state =3D enable_compression ? COMPRESSION_FORMAT=
_DEFAULT :
>> >> -                                                COMPRESSION_FORMAT_N=
ONE;
>> >> +       if (fa->flags_valid) {
>> >> +               /*
>> >> +                * chattr writes back all flags returned by fileattr_=
get(). Accept
>> >> +                * FS_CASEFOLD_FL only when it reflects the share's c=
asefold state.
>> >> +                */
>> >> +               if (fa->flags & FS_CASEFOLD_FL) {
>> >> +                       rc =3D cifs_fileattr_get(dentry, &current_fa)=
;
>> >> +                       if (rc)
>> >> +                               return rc;
>> >> +                       if (current_fa.flags & FS_CASEFOLD_FL)
>> >> +                               allowed |=3D FS_CASEFOLD_FL;
>> >> +               }
>> >> +               if (fa->flags & ~allowed)
>> >> +                       return -EOPNOTSUPP;
>> >
>> > This whole mess could be sorted out by switching the cifs
>> > implementation to the new API
>>
>> ("new API" you mean _mask right?)
>>
>
> Yes and ro_mask, but it probably also means converting all the
> read-only CASEFOLD fs to new api, so that FS_XFLAG_CASEFOLD
> could be taken out of FS_XFLAG_RDONLY_MASK

Can all flags currently in FS_XFLAG_RDONLY_MASK be rw for some
filesystems or only some?
Should they all be removed from FS_XFLAG_RDONLY_MASK and left to each
filesystem to define them as ro (to put in _ro_mask)?

>> > and implementing a generic vfs
>> > helper which does something like the above code to handle the
>> > old ioctls.
>> > FS_XFLAG_CASEFOLD would then be removed from
>> > FS_XFLAG_RDONLY_MASK and set explicitly in xflags_ro_mask
>> > by fs which don't allow to set if (e.g. nfs) and added to
>> > FS_COMMON_FL/FS_XFLAG_COMMON
>> >
>> > cifs would advertise FS_XFLAG_CASEFOLD in its ro_mask
>> > and then the generic helper would mask it and the new syscall
>> > will not allow it.
>> >
>> >> +       }
>> >> [...]
>> >> +               cifs_dbg(FYI, "set compress flag rc %d\n", rc);
>> >
>> > I think that the roadmap should be to slowly define all the old FS_*_F=
L
>> > flags as FS_XFLAGS_* and let the generic helpers deal with the convers=
ion.
>>
>> > But it is not so hard to convert one filesystem at a time in a way tha=
t
>> > fa->fsx_valid will have to be true, because, for example, here
>> > all the relevant flags would be supported by the new xflags API.
>>
>> So, something like what fileattr_fill_{x,}flags() do now, but for
>> file_attr_to_fileattr()?
>>
>
> Yes, something like this (maybe)
>
>  void fileattr_fill_flags(struct file_kattr *fa, u32 flags)
>  {
>         fa->flags_valid =3D true;
> +       fa->fsx_valid =3D !(flags & ~FS_COMMON_FL);
> +       fa->fsx_xflags_mask =3D FS_XFLAG_COMMON;
>         fa->flags =3D flags;

So, for the filesystems that switch to the new API, these new/changed
helpers should handle giving userspace the legacy FS_*_FL flags (if
userspace uses FS_IOC_GETFLAGS) by converting them from the FS_XFLAG_*
reported by the filesystem?

But did you write this
> +       fa->fsx_valid =3D !(flags & ~FS_COMMON_FL);
> +       fa->fsx_xflags_mask =3D FS_XFLAG_COMMON;
while thinking about FS_IOC_SETFLAGS, so from userspace to filesystem,
and this would be needed because that filesystem wouldn't know what
FS_*_FL are, so it will use the _mask and the converted xflags?

But why the opposite of (flags & ~FS_COMMON_FL) as fsx_valid?

Why fsx_valid =3D 0 if the passed flags also contain non-FS_COMMON_FL
flags and fsx_valid =3D 1 if the passed flags contain only FS_COMMON_FL
flags?
(if I understood correctly)

> But in this model FS_XFLAG_COMMON are only the ones that
> are mutable from the old ioctl.
>
> We would need to define FS_READONLY_FL to deal with the
> group of read-only legacy flags, if some fs needs them and wants
> to use the new API.

So the those filesystems can put it in _ro_mask on GET you mean?

>> > No need to do that now, as part of this patch set which is complicated
>> > enough, just need to see the road ahead of us that we have a way
>> > forward out of this messy flags_valid/fsx_valid inside filesystem
>> > implementations.
>>
>> I think it's probably better to clean up the API now, before introducing
>> new flags (like FS_XFLAG_BTIME/PTIME or the shared extent one in the
>> other thread) and as I'll say in that reply (I'll write it in a bit) I
>> think it's even better to first split the _mask changes into their own
>> RFC PATCH series, then have a separate one for ptime/btime.
>>
>
> Agree.
>
> It's even two different changes -
> The vfs internal _mask change and the UAPI _mask change.
> chattr -p implementation with new API would be the perfect
> champion to drive this UAPI change IMO.

Ah, right, they could even be made in 2 separate patches but it's
probably better to keep both in only one, since otherwise there would
need to be temporary vfs functions to convert xflags to xflags_mask and
back.

>> > My understanding is that Miklos introduced those hints to reduce the
>> > work needed per filesystem for the initial implementation of the
>> > vfs methods.
>>
>> Ah yeah that would make sense.
>>
>
> BTW the trigger for the vfs interface was ovl_copy_fileattr()
> so this is a user of the new vfs _mask API that we need to
> pay attention to.

Ah ok, I'll look into that too then.

> Thanks,
> Amir.



--9e5986ede954feecad11ad001d02150c5a356196d013aeccc838f4a9c70a
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQRJ2XvJtXGwULYEerQ0bnTtJTDoOAUCawBTwQAKCRA0bnTtJTDo
OAhLAQD6MiOLbbybL5wy9alM14eREvB1XFf4dJYhOSWBa9LYCQD+OXKSMpjBKzE6
Qide56j5p8y/OESAy2MNJBjIhpYtBQU=
=hD6S
-----END PGP SIGNATURE-----

--9e5986ede954feecad11ad001d02150c5a356196d013aeccc838f4a9c70a--
