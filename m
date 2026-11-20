Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795183979;
	b=j2OKFvLRjAyFqQhaKN/1QBg9bJhzJb7rbnAdSsb4yGADON23bTDHTCwinfb9zOwQuPvW
	 8spp/zCtkd0TnRclIRjHBFP1MxajAosL0jjtN9d7r1kiytC0EGdJEHXu0uWWqaa/sBOkN
	 rKieDTpAgjQCNRazDlX8Xj+J/mrYhCHVp3NYqSh6oM1eD7BB/g05Y29X/l1JO2spS7NwT
	 282C33m3VZ1aPqKAAj9fMRuUVOVxb9ww3dCM4WnDxR72RFQtVFxAnTQrMzY+kpZ7ogVFA
	 QtbcPWS1EdQRIsXUAo+16G+luPtEag6ZkuJzScbelk8cpvxr968MoWeR4FJo+wZI8ww==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795183979;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=ob1FlA4nHTyzVacAeo+PvFthXWjQDamhK5368LJKCsA=;
	b=stPNqXo4FoABk0ydrAWGTlelY04XmYa4d+BNmWgRvjnohqWKbddfh/Vrm+HVzTxOyCmo
	 yoP3sjn3GVdRIHSea6tFYQpaTwvlYpQv5Pk68tVYBYwlH6kalRTO2nXwa+poahI53awGA
	 odBsUKG9pQ09s6AuIczcR9dDaDgZtFaNIfJcQ8eTFYF8fdot/LIjmS68ii4HrGvCWRhe1
	 83op/Mki35DYDFVU5FT54z66RjrEAEiAK4blqKOsozIoC7rm5KhXBQ+jIUs8IKy8FGRkQ
	 VwSfo0n5NqPbUdrxe94HdYu8EkYOzXpT3rTnd3KIz/gzktJ4ktKrIzbTVwhq9d4xJBg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=rbdeZn9I;
	arc=none smtp.remote-ip=209.85.128.53
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 46DD6606A334
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 14:12:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 46DD6606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=rbdeZn9I
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-4bb64ef5a14so9879815e9.1
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 06:12:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795183978; x=1795788778; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=ob1FlA4nHTyzVacAeo+PvFthXWjQDamhK5368LJKCsA=;
        b=rbdeZn9ILcLAYFNo6TnnJ/A/KWVu0+5+Msk52h1KKBNcteqyesyrPXI/akOkn7Y5nZ
         IJyrZg0HBWpxlikd55uohYATUxLodDwD7+b0Es+Sv1nPKJ9z0TnzqWj2CjA739oyp/6S
         YFXswRBrBr/Roowpp01nTbbkrenfbJmQnMPa7Wvw4iNxateK7/eiauenrJfEXM37DDZh
         JQQGJufT9v88mGvYant1EA3p1ELjXQH8dS6GrkmHhnTOb/00rX33bFSULeUgKsQShHVD
         y459Q8ZJz1MEcjiZvRKUq6FM655W5Trml3NMjWgRKIK/DU3HXLHP9kP7MoIvCkq7hyDx
         oZfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795183978; x=1795788778;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=ob1FlA4nHTyzVacAeo+PvFthXWjQDamhK5368LJKCsA=;
        b=mGoxqdohHu+9GK9uHIT/30HeFskHqTpZa+FGo5Cfq2o80I/e9nw7ZPTf8vvS1y7BQY
         smwQJAPepKC25xiqcZ0puHgA4EbcUSwevXSzi6Pu5+q2PqmVfxx7/BGQXjNTeSWzAaUP
         JPJ+Qgjv49uGYEerjMYNvadSupvRphUHFj0CEOfruGURp+pUKDTfrB3IMUfFYrB4YMgb
         7Be0HRZV0hOmh1XKPEznHYZbO6xgfTA58VfuzTWThIkflXgHl3cuhWo5mOiQ0bZ/B1Km
         DTwn+P6rkqZ7UcdICVnypq//CWOEY3k4XjjGP/zZqwmmlxbu+sR3q6SpDhL4yC1IapHs
         ziTQ==
X-Forwarded-Encrypted: i=1; AL+hErG8CdOd+Rkwb2z7jWluqw8x/oeiqbNvpJqZL8lzLZg4G+Li7ijgfz7frXHmcoHutI0pdvXB5u9Yqtk=@vger.kernel.org
X-Gm-Message-State: APuU4Z+pini+A2tG84nUyN75RIOgYiiFmZr9oAXY9Wja0NE6QO+4zLMO
	pTS4KOZtxplA4mt+Ytsm3X6x+Z94/HDqBYmgPKND4OpdklDiNSVfWddj
X-Gm-Gg: AYBFou36Shq9R1DzEjZ3qqJzNaA+bLhbDBx8jrz/j9OdbjyOdbIAQ5Mfec0p9fBKC+z
	ds0Hfsr3iYSetsV/XPP7zEOnXCjZ/q4ICXjMDbKVrQDZ/AudDr5CzA0nuvGAS0qF/G/11Y8Xeqi
	OVeRX2nENVNe3yunGzKpDpUIPAIIvZT0iNafjp9Bw002UJHSaJTBtt9Q8Eq2MSYkz5QexjoLnCo
	aDtVzWGxnRb0tUjgWnGRYtJsLLe6kTEvedoMvI7vtq1IjEcwxkOKxZwfUSWKHBRWFNEbGLCqMWb
	EKsXnmZorNfuVPVLzY1FTJ69mwqgnIEWMKrFKt8cWm5vxgPHjRK1mCojZoj3htlTvxI3lPKwKJF
	VDiG7tzB/svrHwtWPZJZGU2ZsA1DpXioAGk8tWPEQOax6HcZs1jKQO2edby1KjrYZol+weC5DbN
	ygd5FhNzEwkXC2QFkuCzRnuij8VjWtQ3YeI8fI6CaNWTGRucqWs/qCPs8gLAY3jHVaSDERgzHZy
	H8bRtkncYoN+qbW3oVUGuuZL3yt+LszKHgqU1tpH7bsZ7T0jDC2F2hsfU91bYb7zd8LRAGgXDuE
	dRU93pmvN4T7bU6EENzmsmsDPGHOWOlHW1F4ryTQWX4CoS/a
X-Received: by 2002:a05:600c:3d05:b0:4b8:d17e:da27 with SMTP id 5b1f17b1804b1-4bb88930872mr78210085e9.27.1795183977527;
        Fri, 20 Nov 2026 06:12:57 -0800 (PST)
Received: from localhost ([130.192.98.149])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb8538b09bsm189744955e9.4.2026.11.20.06.12.54
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 20 Nov 2026 06:12:55 -0800 (PST)
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
 boundary=1c0f90a8e81abc35d40b9da9afa2a275d20c96cec9fed1a0bbc0e0120237;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Fri, 20 Nov 2026 15:12:54 +0100
Message-Id: <DN03LWNSDYP5.11FTQ5KCWU2X7@gmail.com>
Cc: "Lauri Gates" <lauri.gates@gmail.com>, "Dave Chinner" <dgc@kernel.org>,
 "Christian Brauner" <brauner@kernel.org>, "Christoph Hellwig"
 <hch@infradead.org>, <linux-xfs@vger.kernel.org>, "Carlos Maiolino"
 <cem@kernel.org>, "Christian Brauner" <christian@brauner.io>, "Darrick J.
 Wong" <djwong@kernel.org>, <linux-api@vger.kernel.org>,
 <linux-fsdevel@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
 <ocfs2-devel@lists.linux.dev>, <linux-nfs@vger.kernel.org>,
 <linux-cifs@vger.kernel.org>, "Theodore Tso" <tytso@mit.edu>
Subject: Re: Concurrent FIEMAP on reflinked files serialises on the AGF
 buffer lock
From: "koraynilay" <koray.fra@gmail.com>
To: "Amir Goldstein" <amir73il@gmail.com>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <av4Hn9u80fs8iHZ6@dread>
 <20261119095943.85048-1-lauri.gates@gmail.com>
 <DMZ4VQ7SZ07T.29WMPQ0BQZGSS@gmail.com>
 <CAOQ4uximow25oc=3XEN1ATgQvonQaTXtDPmQufxo75tJ=e355A@mail.gmail.com>
 <DMZJDGMJ1RVF.32ES391JKNFGP@gmail.com>
 <CAOQ4uxjVQ9cjV=_jBjQtNg9zCuWUEJT9KNYMKV+1jwBkHen5OA@mail.gmail.com>
In-Reply-To: <CAOQ4uxjVQ9cjV=_jBjQtNg9zCuWUEJT9KNYMKV+1jwBkHen5OA@mail.gmail.com>

--1c0f90a8e81abc35d40b9da9afa2a275d20c96cec9fed1a0bbc0e0120237
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Fri Nov 20, 2026 at 6:52 AM CET, Amir Goldstein wrote:
> On Thu, Nov 19, 2026 at 11:21=E2=80=AFPM koraynilay <koray.fra@gmail.com>=
 wrote:
>>
>> On Thu Nov 19, 2026 at 6:04 PM CET, Amir Goldstein wrote:
>> > On Thu, Nov 19, 2026 at 12:00=E2=80=AFPM koraynilay <koray.fra@gmail.c=
om> wrote:
>> >>
>> >> On Thu Nov 19, 2026 at 10:59 AM CET, Lauri Gates wrote:
>> >> > On Wed, Nov 18, 2026 at 10:16PM +0200, Dave Chinner wrote:
>> >> >> I really don't care if it is exposed by statx or file_attr; checki=
ng
>> >> >> the flag through either interface will be orders of magnitude fast=
er
>> >> >> than using FIEMAP to iterate extents on every file to find shared
>> >> >> extents. My concern with statx is coherency - it runs completely
>> >> >> unlocked and so can race with operations that add/remove the refli=
nk
>> >> >> flag...
>> >> >
>> >> > Thanks, Dave and Christian. Given Christian's preference and the
>> >> > coherency point, I'll write the RFC against file_attr, once the
>> >> > question at the end is settled. xfs_fileattr_get() already reads th=
e
>> >> > flags under XFS_ILOCK_SHARED, so the new flag gets that without ext=
ra
>> >> > work. The answer can still go stale right after the call, as with a=
ny
>> >> > stat result: a clone that lands after the read is missed, just as o=
ne
>> >> > that lands after FIEMAP returns is missed today.
>> >> >
>> >> > As I suggested on the 6th, the flag would take the inverted meaning=
,
>> >> > so that an unset flag stays the safe answer: say FS_XFLAG_NOSHARED
>> >> > ("no extents shared with another file"), read-only, in
>> >> > FS_XFLAG_RDONLY_MASK next to the case-folding flags.
>> >>
>> >> Hello, I don't have any say in the FIEMAP issue, but I wanted to let =
you
>> >> know that, since also a mask was mentioned and your patch would be
>> >> touching the fileattr API, there is work going[1] on for adding a
>> >> fsx_xflags_mask that filesystem use[2][3] to advertise supported flag=
s (on
>> >> get, like stx_attributes_mask) and users use to say what they want to
>> >> change (on set).
>> >> It doesn't seem like an FS_XFLAG_NOSHARED flag would touch this new
>> >> change, but I thought it was worth pointing out, especially because t=
his
>> >> patch would also add FS_XFLAG_PROJID and a new FS_FILE_ATTR_XFLAGS_MA=
SK
>> >> to have a way to include both legacy and newly added xflags, so
>> >> FS_XFLAG_NOSHARED would maybe also go there (correct me if I'm wrong)=
.
>> >>
>> >> > Christian, one question on the shape within file_attr: would you ta=
ke
>> >> > the inverted flag, or would you rather keep a plain "may share" fla=
g
>> >> > and add a mask to struct file_attr that says which xflags the
>> >> > filesystem reports?
>> >>
>> >> And if Christian chooses the mask approach, then my patch[4] becomes
>> >> relevant.
>> >> (in [4] I put the patch that will be sent in v5 of [1], since in [1]
>> >> it's merged with the ptime change)
>> >>
>> >> (For Amir who I just CC'd, [5] is the main link for this thread)
>> >
>> > Thanks for the CC and the link
>> >
>> >>
>> >> Thanks,
>> >> koraynilay
>> >>
>> >> [1]: https://lore.kernel.org/all/20261115180343.576773-1-koray.fra@gm=
ail.com/T/#u
>> >> [2]: https://lore.kernel.org/all/CAOQ4uxj82K4z+2OiY5W1g7NyWAFOFjqqWnZ=
SS3prytW36j1LgA@mail.gmail.com/
>> >> [3]: https://lore.kernel.org/all/CAOQ4uxiuJ=3DeZu28FZAUz3rpqPKqCimPxJ=
ucOnYYuBowvD09_Cw@mail.gmail.com/
>> >> [5]: https://lore.kernel.org/linux-xfs/20261102193533.93690-1-lauri.g=
ates@gmail.com/T/#u
>> >>
>> >> [4]:
>> >> commit 0efe0de3b5cc2b767aa6e2bb9174eb05b0d818f1
>> >> Author: koraynilay <koray.fra@gmail.com>
>> >> Date:   Tue Nov 17 14:57:47 2026 +0100
>> >>
>> >>     vfs: add xflags mask to file_attr API
>> >>
>> >>     Add fa_xflags_mask to struct file_attr and equivalent fsx_xflags_=
mask
>> >>     to struct file_kattr.
>> >>
>> >>     This lets filesystems advertise their support for specific xflags=
 and
>> >>     users specify only what they want to change, behaving like
>> >>     statx.stx_attributes_mask:
>> >>     - on GET (file_getattr): each filesystem fills the mask according=
 to
>> >>       its supported xflags, e.g. FS_XFLAG_COWEXTSIZE or FS_XFLAG_EXTS=
IZE,
>> >>       and provides the values in the corresponding struct fields;
>> >>     - on SET (file_setattr): userspace fills the mask according to wh=
ich
>> >>       xflags it wants to change, VFS validates this and preserves xfl=
ags
>> >>       that were not specified in the mask;
>> >>     - if xflags_mask =3D=3D 0, use legacy full-struct replacement to =
keep
>> >>       compatibility with older programs.
>> >>
>> >>     Furthermore, add the missing FS_XFLAG_PROJID flag, to allow users=
pace to
>> >>     set the projid using file_[sg]etattr().
>> >
>> > Correction. usersapce can already set projid using file_[sg]etattr().
>> > With FS_XFLAG_PROJID in fsx_xflags_mask, chattr -p <projid>
>> > could set the projid without having to read and set all the other xfla=
gs.
>>
>> Oh right, thanks, I'll fix it.
>>
>> >>
>> >>     Finally, in order to prevent the legacy FS_IOC_FSSETXATTR from ac=
cepting
>> >>     FS_XFLAG_PROJID, add an FS_FILE_ATTR_XFLAGS_MASK to support new x=
flags
>> >>     and use it in fileattr_to_file_attr()/file_attr_to_fileattr() to
>> >>     validate that the xflags passed in fa_xflags and fa_xflags_mask f=
ields
>> >>     are valid.
>> >>
>> >>     Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
>> >>     Signed-off-by: koraynilay <koray.fra@gmail.com>
>> >> ---
>> >>  fs/file_attr.c           | 46 ++++++++++++++++++++++++++++++++++++++=
++++----
>> >>  include/linux/fileattr.h |  5 +++++
>> >>  include/uapi/linux/fs.h  |  3 +++
>> >>  3 files changed, 50 insertions(+), 4 deletions(-)
>> >>
>> >> diff --git a/fs/file_attr.c b/fs/file_attr.c
>> >> index 833e03810b24..56ea65f790f1 100644
>> >> --- a/fs/file_attr.c
>> >> +++ b/fs/file_attr.c
>> >> @@ -102,10 +102,18 @@ EXPORT_SYMBOL(vfs_fileattr_get);
>> >>  static void fileattr_to_file_attr(const struct file_kattr *fa,
>> >>                                   struct file_attr *fattr)
>> >>  {
>> >> -       __u32 mask =3D FS_XFLAGS_MASK;
>> >> +       /*
>> >> +        * fsx_xflags_mask contains only flags added after the
>> >> +        * file_[gs]etattr() API, so we need to tell userspace the fi=
lesystem
>> >> +        * actually supports all legacy (FS_XFLAGS_MASK and FS_XFLAG_=
PROJID,
>> >> +        * which lacked its own bit) and new advertised flags.
>> >> +        */
>> >> +       __u32 mask =3D (FS_XFLAGS_MASK | FS_XFLAG_PROJID | fa->fsx_xf=
lags_mask) &
>> >> +                    FS_FILE_ATTR_XFLAGS_MASK;
>> >
>> > This is not exactly how I envisioned exporting fa_xflags_mask.
>>
>> This is exactly why I CC'd you :D
>>
>> > fa_xflags_mask =3D=3D 0 means old kernel or unmodified fs.
>> >
>> > For a new kernel with fs that supports flags other than
>> > FS_XFLAGS_MASK it's the fs responsibility to advertise its supported
>> > flags.
>> >
>> > Something like:
>> >
>> >      __u32 mask =3D (fa->fsx_xflags_mask ?: FS_XFLAGS_MASK) &
>> >                               FS_FILE_ATTR_XFLAGS_MASK;
>> >
>> >      memset(fattr, 0, sizeof(struct file_attr));
>> (I'm sorry, but why memset if we assign the fields right after?)
>> >      fattr->fa_xflags =3D fa->fsx_xflags & mask;
>> >      fattr->fa_xflags_mask =3D fa->fsx_xflags_mask ? mask : 0;
>> >
>> > Then you can add filesystems that support get/set of new
>> > attributes without support for legacy attributes.
>> >
>> > And specific filesytems could opt-into the set of an individual
>> > attribute like projid by advertising
>> > fa->fsx_xflags_mask =3D FS_XFLAGS_MASK | FS_XFLAG_PROJID
>> > or a subset thereof.
>>
>> I agree, this is definitely better.
>>
>> > And I am still on the fence wrt should API also advertise the
>> > fsx_xflags_ro_mask in addition to the supported mask.
>> >
>> > The advantage being that it makes the interface symmetric.
>> > User can alway setattr() with the buffer they got from getattr()
>> > and instead of randomly ignoring flags in set, the fsx_ro_mask
>> > along with fsx_mask defines the behavior exactly.
>>
>> Hmm, so ro_mask would be ignored by vfs on set so users don't have to
>> manually remove the read only flags, correct?
>>
>
> Correct.

Ok.

> With non-zero xflags_mask, internal contact masks
> can be used for -EINVAL not for silent ignoring.

What do you mean by "internal contact masks"?

>> Also I think I'll try writing some basic userspace programs that use
>> this API and see how I'd expect it to be.
>>
>
> Don't write programs please contribute to chattr (e2fsprogs) and
> xfs_io (xfsprogs). The latter already support the new syscalls, the
> former not yet.

Oh no, I didn't mean full fledged programs, just simple struct ->
syscall like the set_ptime[1] I've been using for testing.

>>
>> Anyway, I think it would be better to split the _mask change into its
>> own separate patch series, so it can more easily be used by this shared
>> extent patch and it's easier to reason about the API when it's
>> disconnected from the ptime/btime change.
>
> Agree.

Nice.

Thanks,
koraynilay

> Thanks,
> Amir.

[1]:

#include "include/uapi/linux/fs.h"

int main(int argc, char *argv[]) {
	char *path =3D argv[1];
	long long sec =3D atoll(argv[2]);
	long long nsec =3D atoll(argv[3]);
	struct file_attr fa =3D {
		.fa_xflags =3D FS_XFLAG_PTIME,
		.fa_xflags_mask =3D FS_XFLAG_PTIME,
		.fa_ptime_sec =3D sec,
		.fa_ptime_nsec =3D nsec,
	};

	return syscall(__NR_file_setattr, AT_FDCWD, path, &fa, sizeof(fa), AT_SYML=
INK_NOFOLLOW);
}

--1c0f90a8e81abc35d40b9da9afa2a275d20c96cec9fed1a0bbc0e0120237
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQRJ2XvJtXGwULYEerQ0bnTtJTDoOAUCawBVZgAKCRA0bnTtJTDo
OMQNAP9TcBGO7jcWF1/PpewpEzZJSL/5N2sNKL8LH7OSI8wxDwD8Cp4yvccYDNFU
CFFrvp1gJzGGHbalK20JCnIW5/YPGQ0=
=XOHR
-----END PGP SIGNATURE-----

--1c0f90a8e81abc35d40b9da9afa2a275d20c96cec9fed1a0bbc0e0120237--
