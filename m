Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2835540DB5E
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 05:54:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790142891; cv=none; b=EJ1GaNBw1sLCMm3WyovQ0peU+lmDCeM9vAv0RPSBzUq0xYq4GNFYKIxMlQdJD3MvzskNft0iw1tcYbHmXuPblXqFw6o216hMjfX/pVjzPVqYxihHHegAOptEcZf0tiiXyniroYEGhUfX5QeI4pcVKBPtEwlOF4y3PpFU7JGqOPs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790142891; c=relaxed/simple;
	bh=LgWVLK6gvdnHJpUDwHlN4pWuYgqNDy3TE0yb4Pj2fOs=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=Ik5UUVYQULXVtA5mVlc94RGcxrwHwMnGVHViUAdXKkfmvxq92ZrUV+gjpKbQOISZa5tzKzjETTrbX7yv1OM9phSuzGkYx+sVQnBUNyMTL2Mq7kKDAob1fhGd86KPJXJGYxucxYkowU0Mbr6AQLPDaxsogvTtR4ymgz9yrxCnzvo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DSoIibtM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DSoIibtM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E4DCB1F0089F
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 05:54:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790142889;
	bh=5PfmXhl6pDJmGcZOb1arBTuyqaLDSoD3cVhEOoKPAdQ=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc;
	b=DSoIibtMXWwq7/HHqHROJh+DvTrgAhbDo+4G7g13PRQ0A/+/87G9oViX1MsZSUv0n
	 Ipo1Fq+Sha/PccULMVkaVUaZ7XHl0uGysjEw2o8Xbr87plIMA54q+ZCElqYluSLWHs
	 ljGpP8HV/CXtlSPLWRUMlr4FS7MBt4vtjKlnn/nkmSTrkJ/E5nNvUU+auhjYhJC4OD
	 8KddNDN4XmWTXEK7Pi485sT7YZVx6lh3j0jNHvZsgUiqotLZv2GF41PDodeOaqE1P2
	 zG4FcMGJDllnHmNbDtvSjxvvMOF+NAHSGguBDbiwO1QP3BnIexop4X1smJT1d4hbmN
	 EKBECAMeWzaCQ==
Received: by mail-ej2-f36.google.com with SMTP id a640c23a62f3a-c254f9f0b1eso77155366b.1
        for <linux-nfs@vger.kernel.org>; Tue, 22 Sep 2026 22:54:49 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AKwUvBxRMv7oqFGngyefpgve9xq8tXufVY0UE1Q7+J3JIBdajxsfsNYPpVSw5Un//mdxbmL7Eg24UkvH8Ys=@vger.kernel.org
X-Gm-Message-State: AFuF++mqh7uVEaXUbjYCOTZ4pgchRElMryP1oqdHAihUTNO+xMz0ofWq
	/AoOE2TnGNVWZyymOQEtrQ0SCqcUcdWyDhXcotJTJc2nELAJpsklJDt+Zmo6iTBWvieu3ASefSi
	ncTMvQfGldSBQZrtpnJGZ1W3sFSVqxK4=
X-Received: by 2002:a17:907:ea93:b0:c29:4490:50c8 with SMTP id
 a640c23a62f3a-c2aada6a9c9mr122986066b.8.1790142888439; Tue, 22 Sep 2026
 22:54:48 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260919022441.3305170-1-neilb@ownmail.net> <20260919022441.3305170-6-neilb@ownmail.net>
In-Reply-To: <20260919022441.3305170-6-neilb@ownmail.net>
From: Namjae Jeon <linkinjeon@kernel.org>
Date: Wed, 23 Sep 2026 14:54:36 +0900
X-Gmail-Original-Message-ID: <CAKYAXd9W3O=Dsavu4=XUp+3SyFWOL3Bs7fbzg0YBFpwk4-TCAA@mail.gmail.com>
X-Gm-Features: AclHuK8GYgU6BX6NCq2-6QNZx7GNKhZ3196sjTH0JZehxyF3dSZODayjCY9JTRw
Message-ID: <CAKYAXd9W3O=Dsavu4=XUp+3SyFWOL3Bs7fbzg0YBFpwk4-TCAA@mail.gmail.com>
Subject: Re: [PATCH v2 05/14] cifs: allow -EISDIR precedence over -EFTYPE in __cifs_do_create()
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Jori Koolstra <jkoolstra@xs4all.nl>, 
	Mateusz Guzik <mjguzik@gmail.com>, Dorjoy Chowdhury <dorjoychy111@gmail.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Andreas Gruenbacher <agruenba@redhat.com>, gfs2@lists.linux.dev, 
	Ilya Dryomov <idryomov@gmail.com>, Alex Markuze <amarkuze@redhat.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org, 
	Paulo Alcantara <pc@manguebit.org>, linux-cifs@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 19, 2026 at 11:25=E2=80=AFAM NeilBrown <neilb@ownmail.net> wrot=
e:
>
> From: NeilBrown <neil@brown.name>
>
> If atomic_open is given __O_REGULAR, we now would prefer -EISDIR
> if a directory was found.  So move the S_ISDIR() tests earlier.
>
> Also don't return -EFTYPE for S_ISLNK() - that should get -ELOOP and only
> if O_NOFOLLOW.
Simply exempting symlinks from the __O_REGULAR check in cifs is not
sufficient. Once this check allows the symlink through,
cifs_atomic_open() still calls finish_open() on it, setting
FMODE_OPENED. open_last_lookups() then skips symlink traversal, so
do_open() returns -EFTYPE before may_open() can return -ELOOP. This
path also reaches cifs_new_fileinfo(), which pins the symlink dentry
with dget(). The symlink's file operations do not provide CIFS's
.release handler, so the failed open does not call cifs_close() to
release that reference.
