Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.46
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795107871;
	b=PDH8dSrvb7u8T8+yLovd2Pew4Eangew5QpZiDmte3yOQNsRp4jMkSJexr/3cqjIazA14
	 5qXItyZygvvTINlGJ/uRdTb5jf6T+nqYbx/hZUBqMKxv6qJltd4Mpx2sBermODeZFCOid
	 gUH6wjXrw5PZVUgIsvvPaDfBCDSZTRapkBRwq0jdJ16DlF5TCON4RjkjXW+bYFbbMU0go
	 AZdah/iEaeEsZ7Ad5LHAs1ce9xwT/mdZpZ709yPCXxqMpToFgDH0bU1GsvPrH/9D5Krzq
	 STLqSYZxA74Vd+h+iTQfFK1G6M0ZQlLtKdWgUkBtyyZTPHLrGRfTrfKKS0HZ6x2FdnQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795107871;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=2yLuK3u1QEHTUyBs9ayIe02GiJhaVWl6gJPjVQwJ7zg=;
	b=2vmSk1AQEHIFz35Lp820xFYO9zEGpTyyCS7AXMCw8R1CtYSYkg0Nyqe2vfIq/7pVgGt5
	 nyhNy8eKNimQHg/iUqv7KMyVhYotpt1nR8b5aAvRkqIJRwrbrnHD2WO73yCtTNbHHt/fy
	 dzn7xiuzpc5P+46VQYAc0FZBELjPGjwkInv7/gKMyHcJ6EvmINikT40UIfK1IqqBD58Tm
	 qmFWgUn1SvBLNH43yNsIB3yY3igwqcLk2evl8T4NcSnjV5O640RoHqhhkmGBYRZxtK5be
	 SUpNqsw/Zviwul6JVUVnMjikkbp2oVFjWG7i7BdkkWHIaaSXYCkdzohgjMT+5NSd1Hg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=s5zc6etq;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.46
Received: from mail-ed1-f46.google.com (mail-ed1-f46.google.com [209.85.208.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E5E7606A331
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:04:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4E5E7606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=s5zc6etq
Received: by mail-ed1-f46.google.com with SMTP id 4fb4d7f45d1cf-6b596afb4c5so2850194a12.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 09:04:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795107869; cv=none;
        d=google.com; s=arc-20260327;
        b=o8xr28YgeO2ONGpGLjJe3aZOFm6M8Kp8JCPZHhFYVR2K2mdOLut/AE25rD7Cy/0fsY
         Occa0KoHi6ORHdQVj2vFxocfnMjaIoS1x8UGguWNIF1OeY76us8AoF5mWak88eTrtK0M
         cT9OSrMns80J0x8wNYpEDyX3Q0a4w4lqiyQA8CZ+iUyZSg70aWbf71n9BDrBnX4N4qAA
         kbN7OHlIlkajBzJvFh8WNFC9jc5drnk3BzGGYhkc2G1GXw8eNm8yewAdZJVr2lbIE7PK
         IuR/z+Rq+VCW/cIkUz+wFqv/rMgrwbe6NTDN4br5DlQ3cJrqEMkhBB+2bfw3BX6AFEPM
         qRtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=2yLuK3u1QEHTUyBs9ayIe02GiJhaVWl6gJPjVQwJ7zg=;
        fh=DgihIzYp+FxZtdfCxFNpqXpYZmsOLFJhp03xfBl76FM=;
        b=s/S1GecCqulH0Ic/S6aBqOvR1NlkmJm+ATUuFXcXrsBmi+L45rxbACEwRCFiqMHQx1
         J0yI6IzSEuGEjr+eTT39sbRmxNY0hqFahJMB/5aFVk/Pgo1rUffCNcfoJu3I8bMM+hoc
         EYl4NY5GnjDIyJlFq00l+CfpKZZwCQa1CWtNeBwa0rAS4ayhcUBIzS399DrScEJqNHyU
         +Zi7yQQlRINq/Bf6H5tnkAJceOKHWSbCN37abTm3HsaLIiS90WU/OavX/dUhxcSUfj4+
         PeGRNaGufBfG5rQ8R5aYkToXZVX+dxTKFFqs7vUAQIAgSnp4Jl0ctY3QgPXidBPqchNg
         xM7Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795107869; x=1795712669; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=2yLuK3u1QEHTUyBs9ayIe02GiJhaVWl6gJPjVQwJ7zg=;
        b=s5zc6etqP3GKrfiHHgIM6qRwBj4GIrrYXAc6mNtEDxVzqmttJaHCzBqV1dtIN+vio3
         Bnt6ZD+22BFWnuCnU8EfLslCEzR54XnIaMRCfU4Wp6aReVvOjg7SSEeZ++TPablfbh0l
         nWScX+/5rkWM/Hp/yZ+hSStf6OX4OY+2MyRjQ6hvynNEq3yrt2g+oozsb2uIIRwN9Z0y
         kqeQwucwtBml5gJuvt9l9W1sgy2+Q505qHa2NQnc54/JOh7uClHStUwVlxpUu36xurI8
         7fgIaULXH+3INvDRKkck+rkIPO9DQA/oiLHBMSnEoMnziJpuqf6MgQUtU78WnH6opbGH
         aXRQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795107869; x=1795712669;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=2yLuK3u1QEHTUyBs9ayIe02GiJhaVWl6gJPjVQwJ7zg=;
        b=w8WDgaPfqEmpzum8A4igB3RFJ5cVPdTF6M0P8VxHbiJLj5IEkRy/t/si3If93qTbMc
         YnB9m7DvBRUTiKrzqq37j1fv7gBgucD4tjdQmWHwy3bUTahPk3xCsbw7Z9VZWCwxuEeP
         njS/kJKryea1JqvOabMHTe64luq+scvZ+ALRmxj+cy8fREJHdGuJh71+i09lGXcRDPLv
         Wz/59rCcp+XlAatyMwEV6DMGAqb/mUlFcEaXkMouJDFs7QNmyEaBGJWmoe4572RZcC2F
         rYYR+EXFyakW88V2AyLyeuSGs8cHiVROIKzLzl0t9mdw64r7mOOoyJaC38ay4nBcOcii
         1HXA==
X-Forwarded-Encrypted: i=1; AL+hErEZdJKuJzibVTXp/xrjf/8YTuVxtYe+vZoLtpn6HpEnhZeRQHC5ae+L60rwyoLxq7HIo4N0Gxqha0E=@vger.kernel.org
X-Gm-Message-State: APuU4Z95PV7zHtiudDOg0FB4vnLpIEgkptkRpZLvLJ4fJddGSRl4tH3j
	2LNLJtHpOo3pt4l9qUK8dPLof390oEm0HFNrefPp4GKcjAkBjRX+UzCAVZ1Nru7YXrEdFlQ82y7
	6MTTBbhPVcZoS5LecZKLD0WWbkK6v180=
X-Gm-Gg: AYBFou2ialhSTJs1FC/6BwbdQ1Fh9D8/65j4uQEgKkmcep+jJM++51ghC2i97CX+tnn
	MxZ7u4tElsAGqBu6ap0++O2jnIPRE9h0bUr88nV7qcOvXttdaoWRY3ovD98VebT6e8TCkqz3upp
	s527qJR00UibPE1LSJ9rAgvnvBMaWp2H3uvC3Q2ikMU36dVuXILm1QUmpbjZQZYpS0XAmvXh9Mo
	auglPJP7YXzEjmkUYNE/f65uFPwrjPFTvn+JN85iGFNO18W43QM1TiUx63FrH9RJb3oBj6c8v5S
	pi8XIJ3DUVnw0QikSPvsD++F2E6TPvnavWSdC2olrNFGYoHaXunGVk73aCpYV74n9OOOk1kuBD6
	MSHYhF/dp6ClsATWYEm3n+E1QrXaga5Jg5Gic2C3b/0wHlmcP9Jo9aefi0+JQCUFHQTiKUAg=
X-Received: by 2002:a05:6402:15cb:b0:6b7:b872:27a0 with SMTP id
 4fb4d7f45d1cf-6b887e9b3a2mr4758592a12.21.1795107868285; Thu, 19 Nov 2026
 09:04:28 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <av4Hn9u80fs8iHZ6@dread> <20261119095943.85048-1-lauri.gates@gmail.com>
 <DMZ4VQ7SZ07T.29WMPQ0BQZGSS@gmail.com>
In-Reply-To: <DMZ4VQ7SZ07T.29WMPQ0BQZGSS@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 19 Nov 2026 18:04:14 +0100
X-Gm-Features: AclHuK_v3fdGGegcviRdfo5LNeBocqyxiM32rnjQTLwAQD9spb3t-0FSAl1IioM
Message-ID: <CAOQ4uximow25oc=3XEN1ATgQvonQaTXtDPmQufxo75tJ=e355A@mail.gmail.com>
Subject: Re: Concurrent FIEMAP on reflinked files serialises on the AGF buffer lock
To: koraynilay <koray.fra@gmail.com>
Cc: Lauri Gates <lauri.gates@gmail.com>, Dave Chinner <dgc@kernel.org>, 
	Christian Brauner <brauner@kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, 
	Carlos Maiolino <cem@kernel.org>, Christian Brauner <christian@brauner.io>, 
	"Darrick J. Wong" <djwong@kernel.org>, linux-api@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	ocfs2-devel@lists.linux.dev, linux-nfs@vger.kernel.org, 
	linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 19, 2026 at 12:00=E2=80=AFPM koraynilay <koray.fra@gmail.com> w=
rote:
>
> On Thu Nov 19, 2026 at 10:59 AM CET, Lauri Gates wrote:
> > On Wed, Nov 18, 2026 at 10:16PM +0200, Dave Chinner wrote:
> >> I really don't care if it is exposed by statx or file_attr; checking
> >> the flag through either interface will be orders of magnitude faster
> >> than using FIEMAP to iterate extents on every file to find shared
> >> extents. My concern with statx is coherency - it runs completely
> >> unlocked and so can race with operations that add/remove the reflink
> >> flag...
> >
> > Thanks, Dave and Christian. Given Christian's preference and the
> > coherency point, I'll write the RFC against file_attr, once the
> > question at the end is settled. xfs_fileattr_get() already reads the
> > flags under XFS_ILOCK_SHARED, so the new flag gets that without extra
> > work. The answer can still go stale right after the call, as with any
> > stat result: a clone that lands after the read is missed, just as one
> > that lands after FIEMAP returns is missed today.
> >
> > As I suggested on the 6th, the flag would take the inverted meaning,
> > so that an unset flag stays the safe answer: say FS_XFLAG_NOSHARED
> > ("no extents shared with another file"), read-only, in
> > FS_XFLAG_RDONLY_MASK next to the case-folding flags.
>
> Hello, I don't have any say in the FIEMAP issue, but I wanted to let you
> know that, since also a mask was mentioned and your patch would be
> touching the fileattr API, there is work going[1] on for adding a
> fsx_xflags_mask that filesystem use[2][3] to advertise supported flags (o=
n
> get, like stx_attributes_mask) and users use to say what they want to
> change (on set).
> It doesn't seem like an FS_XFLAG_NOSHARED flag would touch this new
> change, but I thought it was worth pointing out, especially because this
> patch would also add FS_XFLAG_PROJID and a new FS_FILE_ATTR_XFLAGS_MASK
> to have a way to include both legacy and newly added xflags, so
> FS_XFLAG_NOSHARED would maybe also go there (correct me if I'm wrong).
>
> > Christian, one question on the shape within file_attr: would you take
> > the inverted flag, or would you rather keep a plain "may share" flag
> > and add a mask to struct file_attr that says which xflags the
> > filesystem reports?
>
> And if Christian chooses the mask approach, then my patch[4] becomes
> relevant.
> (in [4] I put the patch that will be sent in v5 of [1], since in [1]
> it's merged with the ptime change)
>
> (For Amir who I just CC'd, [5] is the main link for this thread)

Thanks for the CC and the link

>
> Thanks,
> koraynilay
>
> [1]: https://lore.kernel.org/all/20261115180343.576773-1-koray.fra@gmail.=
com/T/#u
> [2]: https://lore.kernel.org/all/CAOQ4uxj82K4z+2OiY5W1g7NyWAFOFjqqWnZSS3p=
rytW36j1LgA@mail.gmail.com/
> [3]: https://lore.kernel.org/all/CAOQ4uxiuJ=3DeZu28FZAUz3rpqPKqCimPxJucOn=
YYuBowvD09_Cw@mail.gmail.com/
> [5]: https://lore.kernel.org/linux-xfs/20261102193533.93690-1-lauri.gates=
@gmail.com/T/#u
>
> [4]:
> commit 0efe0de3b5cc2b767aa6e2bb9174eb05b0d818f1
> Author: koraynilay <koray.fra@gmail.com>
> Date:   Tue Nov 17 14:57:47 2026 +0100
>
>     vfs: add xflags mask to file_attr API
>
>     Add fa_xflags_mask to struct file_attr and equivalent fsx_xflags_mask
>     to struct file_kattr.
>
>     This lets filesystems advertise their support for specific xflags and
>     users specify only what they want to change, behaving like
>     statx.stx_attributes_mask:
>     - on GET (file_getattr): each filesystem fills the mask according to
>       its supported xflags, e.g. FS_XFLAG_COWEXTSIZE or FS_XFLAG_EXTSIZE,
>       and provides the values in the corresponding struct fields;
>     - on SET (file_setattr): userspace fills the mask according to which
>       xflags it wants to change, VFS validates this and preserves xflags
>       that were not specified in the mask;
>     - if xflags_mask =3D=3D 0, use legacy full-struct replacement to keep
>       compatibility with older programs.
>
>     Furthermore, add the missing FS_XFLAG_PROJID flag, to allow userspace=
 to
>     set the projid using file_[sg]etattr().

Correction. usersapce can already set projid using file_[sg]etattr().
With FS_XFLAG_PROJID in fsx_xflags_mask, chattr -p <projid>
could set the projid without having to read and set all the other xflags.

>
>     Finally, in order to prevent the legacy FS_IOC_FSSETXATTR from accept=
ing
>     FS_XFLAG_PROJID, add an FS_FILE_ATTR_XFLAGS_MASK to support new xflag=
s
>     and use it in fileattr_to_file_attr()/file_attr_to_fileattr() to
>     validate that the xflags passed in fa_xflags and fa_xflags_mask field=
s
>     are valid.
>
>     Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
>     Signed-off-by: koraynilay <koray.fra@gmail.com>
> ---
>  fs/file_attr.c           | 46 ++++++++++++++++++++++++++++++++++++++++++=
----
>  include/linux/fileattr.h |  5 +++++
>  include/uapi/linux/fs.h  |  3 +++
>  3 files changed, 50 insertions(+), 4 deletions(-)
>
> diff --git a/fs/file_attr.c b/fs/file_attr.c
> index 833e03810b24..56ea65f790f1 100644
> --- a/fs/file_attr.c
> +++ b/fs/file_attr.c
> @@ -102,10 +102,18 @@ EXPORT_SYMBOL(vfs_fileattr_get);
>  static void fileattr_to_file_attr(const struct file_kattr *fa,
>                                   struct file_attr *fattr)
>  {
> -       __u32 mask =3D FS_XFLAGS_MASK;
> +       /*
> +        * fsx_xflags_mask contains only flags added after the
> +        * file_[gs]etattr() API, so we need to tell userspace the filesy=
stem
> +        * actually supports all legacy (FS_XFLAGS_MASK and FS_XFLAG_PROJ=
ID,
> +        * which lacked its own bit) and new advertised flags.
> +        */
> +       __u32 mask =3D (FS_XFLAGS_MASK | FS_XFLAG_PROJID | fa->fsx_xflags=
_mask) &
> +                    FS_FILE_ATTR_XFLAGS_MASK;

This is not exactly how I envisioned exporting fa_xflags_mask.

fa_xflags_mask =3D=3D 0 means old kernel or unmodified fs.

For a new kernel with fs that supports flags other than
FS_XFLAGS_MASK it's the fs responsibility to advertise its supported
flags.

Something like:

     __u32 mask =3D (fa->fsx_xflags_mask ?: FS_XFLAGS_MASK) &
                              FS_FILE_ATTR_XFLAGS_MASK;

     memset(fattr, 0, sizeof(struct file_attr));
     fattr->fa_xflags =3D fa->fsx_xflags & mask;
     fattr->fa_xflags_mask =3D fa->fsx_xflags_mask ? mask : 0;

Then you can add filesystems that support get/set of new
attributes without support for legacy attributes.

And specific filesytems could opt-into the set of an individual
attribute like projid by advertising
fa->fsx_xflags_mask =3D FS_XFLAGS_MASK | FS_XFLAG_PROJID
or a subset thereof.

And I am still on the fence wrt should API also advertise the
fsx_xflags_ro_mask in addition to the supported mask.

The advantage being that it makes the interface symmetric.
User can alway setattr() with the buffer they got from getattr()
and instead of randomly ignoring flags in set, the fsx_ro_mask
along with fsx_mask defines the behavior exactly.

Thanks,
Amir.
