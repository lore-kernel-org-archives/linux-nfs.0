Received: from flow-a1-smtp.messagingengine.com (flow-a1-smtp.messagingengine.com [103.168.172.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3D583644C6;
	Tue, 11 Aug 2026 23:32:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.136
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786491137; cv=none; b=b8myu5RL/UuXROA8IupPfaPK4hCsxS4ESZApkCRBrz3xk6p6/CMJbkObbMRpC/F9MX7lvRifR1nci2X118JBLSrS8xlcKBEIEicwP8im9EN/e6x+qBJB0EFnE8ZIV1jKr63LrjOY4VJKFVSO9FDGLPFHzOz+MSd+Q1ZwcHr6W2I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786491137; c=relaxed/simple;
	bh=NPltb/iH6YaFOwMdz80B1aN3i+mkHaznIeYdcYKZB18=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=AH+CXm8TZ3VDkyefJVp1Y0Pc3/+d8mhCuL/aYFU2gza/jf2Burb3HOOizTHlQczc/nWyx6s9jXo9eNHQrKU+EVhYOOWRSWCcg/fRaKHoyd+EQSGALQJA2RGAOwtEbxQXfTFzQFtZmWs1C/kmP0FVuzaEmX/8QzwZm6gmOqeAQ/U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=jfjS1G3v; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=V15yaMSq; arc=none smtp.client-ip=103.168.172.136
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="jfjS1G3v";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="V15yaMSq"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailflow.phl.internal (Postfix) with ESMTP id C4C70138012C;
	Tue, 11 Aug 2026 19:32:14 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Tue, 11 Aug 2026 19:32:14 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1786491134; x=1786498334; bh=m+9TijTFiG6m0kBcX5J+XksT6BIsUJV1L+8
	4jH9kz90=; b=jfjS1G3vOiqAZtj7+0A2dtsHRG8NVB+FSXtUmMqz4fN47I2NoIX
	AtSEbXrlVvzVLFPWd5xhnf525fZ4vKXhWy6hHmKpxW7ZGZHqkrZlQkO6yjLWXkxX
	1iwL6PJbOzRuaAE8zJpjaouD2sMIc2a9v5YcCRY72bHEhLjHLYOEo8WpOxmQGfaq
	YzUdN+pi024fQkIkC+jttAIIbmzWMmAwiyfb2zp1Bfsit5SS405sIwe6FbG/3bGb
	xMx02JTMlk9duUBYjwcUAzfVplm+ZR43wwmRurif4cUHXjGaghCg0+ay6FLEAoVA
	piYuy0yJcrzoyEYfSFd133gJ9i09foKI/Cw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786491134; x=
	1786498334; bh=m+9TijTFiG6m0kBcX5J+XksT6BIsUJV1L+84jH9kz90=; b=V
	15yaMSq87rR4NMbajuJB4LCb+UnevHguYc/rIsfKkxJ5TylDFVP8/9gZFcOcoPRW
	TwdR60BFpTHVaOfTTFkQG58+N+0ueGRmaCcGhLUf2tEj6wgUbBmCpg1SEEhjZO1M
	PKilNggR8iITkQ5HGSNupdjfxcnCFfA3gPprq+WP8NEPeu52LwR+iXjwpsc+hQPc
	CCFOUyDREbbI3EshlgzaZd4UP106VUdmvL1ZU/itKBfeeV8Owm46LZaxbWXxZxKS
	HT014B4PCquz4LIc6zUEHNtUVZQCnDngimKsWigrct0HZk3y/IWBnUilEfnTtFGT
	yrKrwXv9OChJC8PJ8sNcw==
X-ME-Sender: <xms:_rB7agp5z42pFVxlN1UMgmK8Hu8fTXUgFS9RQlz9dQhUalVU4d634g>
    <xme:_rB7aoUgqpzrvl1OtSgXyZ_5hlP8qqVtVzYMhCkPZZrKxe95ZLlpxJlaYh1Zg1CXO
    qBzuZA-xYShtmJxGcB8oAe7dTugn7l1Mkg23Bc-q3PIqBmdGg>
X-ME-Received: <xmr:_rB7aooHQtv-9syUiAX04iK3uvHsAAVy5suoEntjt0kGQFiAlMtv0QapxNtC_QiRaVY32zkDg_Fhx9bHrf6d6nMgNnkN7OY>
X-ME-Proxy-Cause: dmFkZTErY4FQz6/WYoq7hv0YrOl7Fe0YELDGXvpyyrJiO1tFEgXhrzwno+69YLuTINmewd
    HiJD7LvGBjGHO2b7hGE/6HA2kqbtljmDKXaAuS5ZJy+CbTHuiFQg2BWwJR7hUatbGfiS8f
    lAa/uoOWToWTBiVQOdIJeOh81px0t7aLQTgi1AAqa1Yck10DHOjV9UZwkNtdmY9JuI78kr
    OcasPIuiBYBtj+NCjoO0C2LVK575qn4ztKjQxLVuVqccEc02qW3wuyRCDnBlKZvrdPZHbq
    soEbJmb/jG+SnrVwrabfAGI1qwwv4oz01UW7bQA48ZsVpdfi+az9CgQpT6LpNJqZnKtkWu
    pfCEW5TQOTZTqAeam1DmAlpBDaElwyvHrul8MQe9jyPn0+gHbj9UbQ/x60iq2gKxUu9F44
    6arXnBu3BLa9qpN79MVcJtv3WdH4MhbxXfVGLutHfTJX9+54aN9M/BGElnEVl4bwOIQAhT
    SAxewuQ8hk/9VvEs5jedV6hT6zM1vJPI+vVnoENp6KOd+pRWmqfGlKQ+/tOkm0UC/deIKQ
    a50SZsQXwD8H1gP8/heo0NksXm9bSC/jMmA25P38xjsy29Z5BYZroHLLFrAsyj/0epLoPF
    qn9p+Hy0kCReSAWyIh9HYzHZSKbIalynQROkFBTnv0KAEjYJlZLS/F7dEkXw
X-ME-Proxy: <xmx:_rB7ansniqZoRb7IGPKX_68X5niPZhlscDFzHJvzPgHXyt0fwaxBLQ>
    <xmx:_rB7amSuGxwh4o63h0fV6JFBDltth_nl9zfCVvNcb8eGHjutcA6_kw>
    <xmx:_rB7arqXiXNsXZD8VM0o-JeAJayAStBDFzDUPnApJs5leYJwiU-F7A>
    <xmx:_rB7ahK9NlJsj3MKkI6BjxKrK92M7_WrHgcyNcrc1TNjSXEgvL2Zog>
    <xmx:_rB7ammTfM0iPhzrkfIFqhbJwPja5UiP4js9_3FUnHOW1aAUESK5W4WU>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 19:32:07 -0400 (EDT)
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
 <CAJfpeguZh6Bo7hxVW5f-OvKJ3UazJTn26Wkba8+rXY-LC-QNWA@mail.gmail.com>
References: <20260803012648.2195405-1-neilb@ownmail.net>
  <20260803012648.2195405-2-neilb@ownmail.net>
  <CAJfpegt1wHngLs9uR943gT6zxV67D53k3n4GiFKowsAb3C6LJw@mail.gmail.com>
  <178641431036.2852630.14175693646176331672@noble.neil.brown.name>
  <CAJfpeguZh6Bo7hxVW5f-OvKJ3UazJTn26Wkba8+rXY-LC-QNWA@mail.gmail.com>
Date: Wed, 12 Aug 2026 09:32:04 +1000
Message-id: <178649112433.2852630.18233880228109399337@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 11 Aug 2026, Miklos Szeredi wrote:
> On Tue, 11 Aug 2026 at 04:12, NeilBrown <neilb@ownmail.net> wrote:
>=20
> > --- a/fs/libfs.c
> > +++ b/fs/libfs.c
> > @@ -169,6 +169,8 @@ loff_t dcache_dir_lseek(struct file *file, loff_t off=
set, int whence)
> >                 hlist_del_init(&cursor->d_sib);
> >                 if (to)
> >                         hlist_add_behind(&cursor->d_sib, &to->d_sib);
> > +               else if (hlist_empty(&dentry->d_children)
> > +                       dput_dlock(dentry);
>=20
> you mean dput_dlock(cursor)?

No, I really do mean dput_dlock(dentry).  dentry->d_children has just
transitioned from non-empty to empty, so we need to decrement the
refcount.  Though maybe cursor wasn't actually on the d_children list.
hlist_del_init() checks if it is on the list before removing it, so we
lose that info.

I've been wondering if some helpers would make this clearer.

static inline void hlist_move_behind(struct hlist_node *n,
                                     struct hlist_node *prev)
{
        hlist_del_init(n);
        hlist_add_behind(n, prev);
}

static inline void d_detach_cursor(struct dentry *cursor)
{
	if (hlist_unhashed(&cursor->d_sib))
                return;
        hlist_del_init(&cursor->d_sib);
        if (hlist_empty(&cursor->d_parent->d_children))
                 /* ->d_children has just become empty, so drop the implied r=
eference */
                dput_dlock(cursor->d_parent);
}

Then the above snippet would be

    if (to)
        hlist_move_behind(&cursor->d_sib, &to->d_sib);
    else
        d_detach_cursor(cursor);


Thanks,
NeilBrown


>=20
> But that's no good, since the directory could be repopulated and the
> cursor needed again.
>=20
> Thanks,
> Miklos
>=20

