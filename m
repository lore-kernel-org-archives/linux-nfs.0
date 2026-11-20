Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.52
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795186534;
	b=qvCH5bUIlc/4O3ygH9y34qRFkOP/Qxs3ddhvxhtZ7hSPcrPCJMklUvOWdzBZsUVBqDtl
	 q4ahi8pjLrHBlk4p9K+n2EDxxiG+J16AXVLd9sgXui0yVotyCjFUnl4yOrbdMx6n8Qdh+
	 dNuBlaGxURpd/ooYBMWXEG3jtxKNMdEhZkWm09mhHYAOY8aXZh+VaZOzfq4Ec04OI+hJR
	 i92zxQq6eTrgQQ1WeBgn6Le79vjchqR9rVSBWP+k7TAs1E6v0C0vLAnrmj3/gkCa9gnnK
	 AgONEsHG7VeMX9K2b2tyuzpumwfPHcJ8T0ivdXhLzLqjfIUziZ/6lhAJf39UuW10jmw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795186534;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=zpoWzG1+g8sYeNmdw7RPLfc/0HSn9Ajkmbs7oAG/5Qs=;
	b=ZT9x9zZOB21RenAxRqkvz3d7wkuZAxYKlNXCjHYI6biY4WokFar8S90NMyVufud1oAxy
	 PS0uV0K5S0yIaQGEdZuUS2T14fZN3Rc2QiegFPaJPbPqYOasMpk6n7ArExKsbO6VGCukV
	 3Lk/KE5v5r1H8JgzXsLaoIY2uiDlaDj3sistDloOygQxMTcDt+aUa7HW0Cg2a0kbr7mHz
	 Enrpl0LsgGD9UxpBQDBN5+/pY5R91kCEHugjI+8NwgcVXTclpRFa7712QMfu9o8U6TaFF
	 iHvM/Oo0w7Ipbiw2sRp1u9uotE+qmsbr4PoFFAhZC3YTWk5XJkOdjJHyRO5n9Crwhtw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=0liT1xoc;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.52
Received: from mail-ed1-f52.google.com (mail-ed1-f52.google.com [209.85.208.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E94A606A33D
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 14:55:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9E94A606A33D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=0liT1xoc
Received: by mail-ed1-f52.google.com with SMTP id 4fb4d7f45d1cf-6b4bd3d98bfso1174481a12.1
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 06:55:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795186532; cv=none;
        d=google.com; s=arc-20260327;
        b=fPjyW97H9GWb978d+aIgQN+AA9pLTn5uyZAUZJdyBQtD5Yt0BB7Z7cpGcACaExO0G3
         LkaKBe4nI/RUBqWRcwst7RiKmiIrut1/b+c9qFzcBleadNXDG0rzsGDjKm/mz/WQYomE
         iErW/IenlTAjo10YbW3vpTX8+tCprDUR1cfUiW0Q7fcxr3SBWbzzT8Krb9UCAkQaJ1oM
         LSM8H4kLLw9zjUHBGYPcRK8sQBgxa5prR1pUCZgF7ggfAk0dbp+HsdXCLN12o0MDIGs1
         EYTrVwoDPS1bCwBfKa8/UnajA1iZHvWbOrJnQ9ETw46FavX5sAwF+X3p5RoXj7cv2mc2
         Y+HQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=zpoWzG1+g8sYeNmdw7RPLfc/0HSn9Ajkmbs7oAG/5Qs=;
        fh=ChDfIafkGDYKTgJiEu6Ni1OZXnBgHAc8aflYA+ReMOU=;
        b=U1YKjrgMqYQKXxTaGqfv1fewHfSzji43Zx29D2YMbVKpqprgmq7+dMkYAgEX7eGIRX
         OtOd07HoIyOE6hLxO6FxwPqP/nTmyw3Y2OsSCgz/Q/TsCZFUku42VwMuw0fmlYRcOePh
         Ma38tQVYaQSZtgq0o6NdRSxfv+E2TJ6CfuUvnERsIXTCyYhP7ZiYDH8wqaEgmRbdXuei
         sifOElJeYdNLUWe8mcpDHIwPHebsjhTK3LGMbly+pccltWEyqs+U+HNKz6TYIqi5PQ8s
         gcdyLBEXHb4SIaFOUV5Qh9FQkxiDEJj7Zx2kQAXD3aumYb8oyqiVSVMgMdtb7TljnNRu
         Csnw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795186531; x=1795791331; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=zpoWzG1+g8sYeNmdw7RPLfc/0HSn9Ajkmbs7oAG/5Qs=;
        b=0liT1xocYY04eRAxMyqyT2RQyS2Apuso3FTjJTR5lpw4eouwRyxilXw/O5YJII3zt+
         VD0II0g/cMhmGgQLJuyvPgrS+v/q+lSTIiREXmKBDWHZWddNmP1BCwbpdAECCnL8uK2P
         w/XN7av4Bx94DaTolcfmIv8HDVX8wb/UFewp75CZTmAWMBZCqohdq8p8gWmtYn9G223f
         l3U2uQtULEusH/eC2yIzvuS/6itcAYgwJMB4B4wfo+0nhA/r5V+5q8dl6kGd+z9/xf3a
         3u8dy7zO+Sbsd6MHTa1mBCMZn/a/G396WDTvvP1tMl4KFrrXzIQCVlcVB223r4i9EW1V
         oEmA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795186531; x=1795791331;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=zpoWzG1+g8sYeNmdw7RPLfc/0HSn9Ajkmbs7oAG/5Qs=;
        b=r3w8+RHAExSUhcp/qHIaMDigkhCtJ/qQDrHK4LUh3pIM583aFw4Fhw+/W7u+TjLyWA
         fgbnAXKRPoJkYPoS+AXLfT78piAADDSv0ywelQnUouKHfoO9n8KUl72jDhmxnZH36i+n
         5H9PHAHy5prB+6TLOhgMuWiPve6xPmXqGS5TbHBSuY1pKlL1yd31VEJ0l+N8v5Ne85KV
         B/b/Y4QHj64I8cp4idbZ7Z7ZWwq4L2ScIKS4I1c5do5py2BUOzRqVmHm5AXR9fsze4Dc
         zqnwWIDDwtg8QHGyayacbx3+s8n5NWWq4qCTTCKHlB4rJkWUnfI0BUTTQfSSlqOiZ0YW
         0jvg==
X-Forwarded-Encrypted: i=1; AL+hErHKKxAR1V3tX3lPs7XZOLepULhNijZLD2crTiap5itYSzxhV/nDoPOBX4v6DrpaPvxM42sY3XUj5KM=@vger.kernel.org
X-Gm-Message-State: APuU4Z8srfSiUHxE5CGy0IBRUmizSd4ctDm+O/jjM/Y8v805QU16mf0i
	HezuzGjGEpwbnL2eRQgD1saVM5nglGF624+XndxQ7qW1MmaSm/qSEE7PeQVDHqKWEP8nlSBeStO
	HMGk/5VqWOU9aM3q1UUvJ7qFjRB/yz0Q=
X-Gm-Gg: AZFdTZcCbzAWvR8+wxzYu58Qgx9Hj7QT9D27tcwu1hRbokFbOsmhkA3b6vCx4/Kjolx
	qrdQH9nt6wqTk95bh0dm+sxQeLaVahCiYT7b534t+RYLIJ1/ucqM9BAQlzHTGR7ggPSoiGV4siN
	SZJHC567rka3PIVrNg4fSlLvhHwzaP5T6OJp6ovB0xJ/cu4dZh9IX6QoAHAZIj4Uc9YhLK6UKA1
	uwgekFojuN4CTKFpgF70Fcgm5D/xSYDTUE90Ui2kWvoINLVsgVOm6lqMb3EVTVBu0z4e9gWrLqo
	3Sk3zGfWwvMUoLljBNk6tdIIWCMSrix7+Q4KUAWHAK5c2RPckGpjf3KegHCc9L5eKroAdt/LdhF
	tI1oNRu4DktKbkemKUOvGFAZtb8ypnmG2lBo24svuj1A09OVEuMfR/CyY5cNQQLi2OSvhLQ==
X-Received: by 2002:a05:6402:3223:b0:6b8:5f08:931b with SMTP id
 4fb4d7f45d1cf-6ba37ea44b2mr2503989a12.26.1795186531571; Fri, 20 Nov 2026
 06:55:31 -0800 (PST)
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
 <CAOQ4uxgoNsOH82FyrCxc+qSoid_CFmbmpL0qgWFw-e8E689fFA@mail.gmail.com>
 <DMZJ4PL1JVA4.2YEB7EPYJR5Q7@gmail.com> <CAOQ4uxi6h9BBP7pf4sR+gc2+4XtkEgbxXZha45iZzdB_wGFVgQ@mail.gmail.com>
 <DN02S2XNGRZD.1KNOZJ0GGDJNG@gmail.com>
In-Reply-To: <DN02S2XNGRZD.1KNOZJ0GGDJNG@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 20 Nov 2026 15:55:19 +0100
X-Gm-Features: Aa3M54om4CtJTUNd2Te8u7pI-ZPclkwXdtuzgdSJLpiBpdV9ZiFnAJvfZll4Px8
Message-ID: <CAOQ4uxh+d-wNC0aWLEexPFz7zj=TZjLyu61kaEmwBx9_hKn2gg@mail.gmail.com>
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

On Fri, Nov 20, 2026 at 2:34=E2=80=AFPM koraynilay <koray.fra@gmail.com> wr=
ote:
>
> On Fri Nov 20, 2026 at 7:45 AM CET, Amir Goldstein wrote:
> > On Thu, Nov 19, 2026 at 11:10=E2=80=AFPM koraynilay <koray.fra@gmail.co=
m> wrote:

> >> >                    fa->fsx_xflags |=3D FS_XFLAG_CASENONPRESERVING;
> >> > +                 fa->fsx_xflags_mask |=3D FS_XFLAG_CASENONPRESERVIN=
G;
> >> > +                 fa->fsx_xflags_ro_mask |=3D FS_XFLAG_CASENONPRESER=
VING;
> >> Uhm, why both in _mask and _ro_mask? If it's a RDONLY flag shouldn't
> >> it *only* be in _ro_mask? (same for CASEFOLD)
> >>
> >
> > Good question. Maybe
> > I guess if you want to follow some percent
> > FS_FL_USER_MODIFIABLE is a subset of FS_FL_USER_VISIBLE
> > but I think that exporting ro_mask and _mask is going to be easier and
> > cleaner than rw_mask but not sure.
>
> Hmm I asked that also because you said in the xfs shared extent thread:
>
> > The advantage being that it makes the interface symmetric.
> > User can alway setattr() with the buffer they got from getattr()
> > and instead of randomly ignoring flags in set, the fsx_ro_mask
> > along with fsx_mask defines the behavior exactly.
>
> But by putting the ro flags in _mask too, a user would have to clean
> them out or vfs will reject the call with -EINVAL/something else, since
> in that case the vfs would see the user say "I want to change this [ro]
> flag".
>

That's just a matter of interpretation.

You could say that if flag FS_XFLAG_CASENONPRESERVING
is in ro_mask then its value may not be modified and fs needs to
fail the set if the user given value is not a match to the current
kernel's value.

Could be used for an "atomic flag set" operation, but I think
this is taking this too far.

I am fine with xflags_ro_mask and xflags_rw_mask I guess this
is the less ambiguous option.

Thanks,
Amir.
