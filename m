Received: from flow-a4-smtp.messagingengine.com (flow-a4-smtp.messagingengine.com [103.168.172.139])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 84A664B04B7;
	Tue, 11 Aug 2026 02:12:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.139
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786414324; cv=none; b=a4pYKy1AfpKunKdpvjGjwVR916i3FNWmwwFYvN0Y6GETWI2e94LTUq8yOIBK1PmTlEZqyCkPInpMGacCE83zGFlJqsHh6apdgqN0K5reawD5LVxhcJqFOkfh5W1GesRhKBiJq5xP2KtYNqHS6meXTyegAs7cWYv1FEqERIG1UMc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786414324; c=relaxed/simple;
	bh=KwaRZdlc7REB2zDbfklX0C4zMUsVEiT3D81VVqMcX+4=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=RAUp/Sk/E49YXXN81a9Lese58NqzXHmkXoLwmvTDxVbSw1y5Gjt3Cu9m4Z7H2i4zT0lwQCWarnMrvgS3EMeBtWzGUB19cJhBS8OgybdW0nFPIQ/XlVq5TwDCBKlC8dNsFamduMtkLff03nO1ASOT1OG6J8JDAA2HGxpQVY5N0cI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=ev/Z7da9; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=BeRe5VzN; arc=none smtp.client-ip=103.168.172.139
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="ev/Z7da9";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="BeRe5VzN"
Received: from phl-compute-11.internal (phl-compute-11.internal [10.202.2.51])
	by mailflow.phl.internal (Postfix) with ESMTP id 8B8DB13800E9;
	Mon, 10 Aug 2026 22:12:01 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-11.internal (MEProxy); Mon, 10 Aug 2026 22:12:01 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1786414321; x=1786421521; bh=z59H84mGp5chtaSVDA9MWaRAa7fU4ciWmVM
	LKTtAoYg=; b=ev/Z7da9p8cwQcaNeHVWhphBQkNLxbkRm7S0l36OJ+d8S+Q9qpb
	uvJOjgeeRpjUEJ7vH9Hzu1hp8K9wMiH4myBGCqCvLwUNr/+4HLkcSfYzDJfHM1Ba
	sVPa1Bp460YU8A6TEn9xJtSpeCr6hmLdZ6IF1TBbVB74B23WJWet3Trz/Wl3pj8E
	Me83adV8XvpvoMPF6JPHYLs9g74+D4cwXDv8ttU06KE5hvSCe5LMjFlMfo03r3nn
	hJ4qn3ILZgZXwdvYlXaQ/YaFPRkU6GhA76dnZYNL7R8yvSiZ3gb6jZcMCJ9muNB7
	CkwLzC0gHO5OY+b8adPpq+45ish4ZgqX69g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786414321; x=
	1786421521; bh=z59H84mGp5chtaSVDA9MWaRAa7fU4ciWmVMLKTtAoYg=; b=B
	eRe5VzNt+LlY+tHSbVayqPRJjuRndPXKsRDh2jvrEkojis7w41tucjBajRhLI/kA
	e94Rt+BmEIGyNanp0UHl5YWgSGA2kC11ZG7JpgpUkF0folXSIfRh/2oHT/lzZvCL
	RPs2J6nXbVqmYk7/T3awEz4F/N+J5rFU14GK7sknHOTI0fwcn6jjXGLzpIQlVlrX
	y52lb91ii9cvBG9AZ216p/gYo7VONmxgtcXLbQuKT4hfvrYdYpzFG1eNoTinMpsc
	sEp0QN511yAtN7bMDua8b59atPmGHL8awiKHWj1dp7kcPoVzM7fkFoknuvtYVuR7
	yhWITatRJj4Efjl6w9CUA==
X-ME-Sender: <xms:8IR6arCyA7tyPch4iET4Mq2YTh60wDVI7XdLMOFPY1yaD0e7c4fHJg>
    <xme:8IR6ajPQueAIyi5ky1_QHldQ7gIArqfmoPo0FfQ2rjti7jiigoXe9-1654kC3Ufuf
    L_mRprFvOSckEhXffPQzDanAuwJIJIIw-7iW4D74BScFxmqr9A>
X-ME-Received: <xmr:8IR6aqAoLsYqYihWGkohZ22EauJJQnelGTKqwIhODNaIhrzWrx7ICl2NXF9MswSpDboaKxgxViyXoo3oCnO8eLIgrXJKbwA>
X-ME-Proxy-Cause: dmFkZTGiFhqbMavz1GnHNgGnrM7aRU5foa/cHmUyoXxGd+EScvvMJzvJekNH/ltV7v2YtA
    KKbMVreFRkOyPn5sqVW2TgecBr3u2xPZOvs//haZKfCkUETFc9Dc+20w7B10YcIOqo4B3E
    TabCpIpl6/tH0XT0IGvOLprJTGWis8gKtNk1Rjm9VB88Tx3PzlLryvVLrq5lxuhVtQseO1
    1etPysa+a2nh8j/Ut8fnJ9KZdaeKaUwp61VZN57Xdd9LTnyPmhtnDkEuLIj5n3pyqWyG6x
    cZSa+pOJNSOie1q67PHP7DSVBVmOr1Pm3I4UkDSGGBMfN3tV9DodOiU8cpEWqDKzTuRcGz
    m6rPQvpdVdnLZODlanSGCKc6LKgwo2VUHapaar4Te0Y37NMl9dwAL4JfTjddJwQafGWl6H
    K0n0cgZrmq72mitnu6Z5gPbxIp6sNJXZvSVIgD8TVZkO/Tu9euem23e4SgO4b3BOT4Yo7L
    Q6CUJDi+O4BbUTVXw+dOPqEJCip/vPCwlW2GkmsViDuJnwRkkKVq2H3NSvmVQgHRteloxi
    WvTqS9HIEr+yVHLyrtHaEhwFcR1r7Zxz61HH3QO1RsmRtXfZQoqFnQzHrAnlZ5RduTyQaN
    NzNXd4Mswgswb4fo1mWdAIKNF3RdkBypQw8KE6kvXkHMEzF1cigCX6iUJd4w
X-ME-Proxy: <xmx:8IR6atkBFmfF5mlzsOM77rPYCO3p0-Y4ysejWCirCPvTVrTkTiR8Gg>
    <xmx:8IR6amocgJDydj6SrAkFnif_fEF5D5D2xwf8EcFtD-1B8bDhr74GdQ>
    <xmx:8IR6akjUrd7A9aBU37mBBRx5sulvzXqcBEHY9XR2gC7r4tMFmYYjdw>
    <xmx:8IR6aogZ9HXVMHvePRPh4E20z1v7OEizhENFM97ib_U6rbT-AWR8cQ>
    <xmx:8YR6an_MxMSzzg6Gcknh3_Ntgu1j2vBeMa0aMQyuwwdOJgwGNVTYpik6>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 10 Aug 2026 22:11:54 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Miklos Szeredi" <miklos@szeredi.hu>
Cc: "Ian Kent" <raven@themaw.net>, "Chuck Lever" <cel@kernel.org>,
 "Jake Edge" <jake@lwn.net>, "Ilya Dryomov" <idryomov@gmail.com>,
 "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, "Jan Harkes" <jaharkes@cs.cmu.edu>,
 coda@cs.cmu.edu, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jan Kara" <jack@suse.cz>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Amir Goldstein" <amir73il@gmail.com>,
 "Andrew Morton" <akpm@linux-foundation.org>,
 "Miklos Szeredi" <mszeredi@redhat.com>, autofs@vger.kernel.org,
 linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
 codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 01/12] VFS: don't count references through ->d_parent
In-reply-to:
 <CAJfpegt1wHngLs9uR943gT6zxV67D53k3n4GiFKowsAb3C6LJw@mail.gmail.com>
References: <20260803012648.2195405-1-neilb@ownmail.net>
  <20260803012648.2195405-2-neilb@ownmail.net>
  <CAJfpegt1wHngLs9uR943gT6zxV67D53k3n4GiFKowsAb3C6LJw@mail.gmail.com>
Date: Tue, 11 Aug 2026 12:11:50 +1000
Message-id: <178641431036.2852630.14175693646176331672@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 10 Aug 2026, Miklos Szeredi wrote:
> On Mon, 3 Aug 2026 at 03:37, NeilBrown <neilb@ownmail.net> wrote:
>=20
> > When a DCACHE_CURSOR dentry is added to d_children, it is only ever
> > added "before" or "behind" an existing child, so it will never be the
> > first and so never needs to adjust the refcount on the parent.  If it
> > remains on the list until dput() it could be the last child to be
> > removed, in which case normal handling applies in dentry_unlist() (where
> > it has been moved from dentry_kill().
>=20
> Not handling the parent refcount together with cursor removal can
> result in inconsistency, e.g:
>=20
>  - add cursor (seek between two positive dentries)
>  - remove all real children (parent refcount not touched, since cursor
> is still on d_children)
>  - remove cursor (seek to zero offset)
>  - close directory (dentry_unlist() will skip parent refcount update
> since dentry->d_sib is no longer linked)
>=20
> Repro attached, produces "BUG: Dentry ffff888107ef75d0{i=3D143e,n=3Ddir}
> still in use (1) [unm
> ount of hugetlbfs hugetlbfs]".
>=20
> Thanks,
> Milklos
>=20

Thanks for the review.  I realised that when I was doing patch 11 which
changes d_for_each_positive_child() to use a cursor, but I didn't think
the apply that understand back at this patch.

There is only on user of cursors so it can be easily fixed as follows.

Thanks,
NeilBrown

index 5a0d276379d1..91f535192ee2 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -169,6 +169,8 @@ loff_t dcache_dir_lseek(struct file *file, loff_t offset,=
 int whence)
 		hlist_del_init(&cursor->d_sib);
 		if (to)
 			hlist_add_behind(&cursor->d_sib, &to->d_sib);
+		else if (hlist_empty(&dentry->d_children)
+			dput_dlock(dentry);
 		spin_unlock(&dentry->d_lock);
 		dput(to);
=20
@@ -213,6 +215,8 @@ int dcache_readdir(struct file *file, struct dir_context =
*ctx)
 	hlist_del_init(&cursor->d_sib);
 	if (next)
 		hlist_add_before(&cursor->d_sib, &next->d_sib);
+	else if (hlist_empty(&dentry->d_children))
+		dput_dlock(dentry);
 	spin_unlock(&dentry->d_lock);
 	dput(next);
=20

