Received: from flow-a6-smtp.messagingengine.com (flow-a6-smtp.messagingengine.com [103.168.172.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA4582D7DEF;
	Tue, 11 Aug 2026 02:37:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786415833; cv=none; b=PRFWiPM7YSPwIQCJaKyYwP8Ahmo2HEWJpE2XWClMz7feiZNMz8jq85oYSraZuSPNgpauhfhzWccUmSQIZ5nkZD7zUZzHwipUxrh7+O83BL6ukJoOxFHkTBOZcgty+OloKFEmlCFdXb3/3sa5GIRVryjrb5DkktcrxyM9CZXR9vQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786415833; c=relaxed/simple;
	bh=PvCRmW0I4sXX2lyRuNN2lenlarZnGysEI/lJoAxPaT0=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=ujdjJSJN4W5Z1IwnnA+RCk8QVklsMdVRtprMg8QRnee+HhuFrcynVhgrO5Z8W0kTh5P/pwAx+9LYW32chncqshoy0/CwTS0JKtiPfnBdVLGMs4Xt6u7KA+T8uIUP1gvKp7hOUOr6Nn6KWFaBWnCSKJxksoX7ptxBqVBdxtYUj40=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=IQe3frLR; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=XIzRUhVE; arc=none smtp.client-ip=103.168.172.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="IQe3frLR";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="XIzRUhVE"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.phl.internal (Postfix) with ESMTP id C96FE13801A0;
	Mon, 10 Aug 2026 22:37:09 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Mon, 10 Aug 2026 22:37:09 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1786415829; x=1786423029; bh=AJICugo9YIPu7sFPHM1uhNH1CDar73i69gO
	Kv84ZcT0=; b=IQe3frLR+OFW6aeW5snfIqcarSr0vpzZcHeEfIxj+cDaNbCiN5d
	IqBd4A8nAoSMGjZnQl8jnF/YLhuf1EKRdA7oVnwfLESGjyH7Lkx0gkR9Mxt+1/+U
	iMd5JkLZ+iz5e0MLG9XTmWCtUqBO1MjKvChBBgV7b6uaP1VxkSAVD6FxhDz3mXWD
	u6NZh8AzSWTydLjbPk410CethSvHQDko7KhZw0BX05kKoaoB7KZgT9asppdLfa+E
	1Z1daowGvvGxBORBxw0DR4SMbFwnSxfWYAJvTuinxl07UHpDfyKTtdzGAQBSQcMJ
	1QHOrrBG/NiqsEAnlgKr2HJ/D5venAz6EQg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786415829; x=
	1786423029; bh=AJICugo9YIPu7sFPHM1uhNH1CDar73i69gOKv84ZcT0=; b=X
	IzRUhVESAisoJ33Eqm5Dky/NiP6clzQDtaZVYZRcCwUWJ2PMKmCcjkkPVPwXobr+
	6H1HPSj9LDNe7vXk40QVQWNAqw77KGToRTKK5s4Ab0eRaLae2HNo7G7l2AOOPXIl
	BdY1qqwHyPj8vvolTwVTNSgl8+s/cLUDsgRzo4azWjdGr6Nkewpb8OLtO8msEwkC
	h1H6up0iaiyKVbK/+IofmqsdVz8zvhELnjAbiLDQb2mnokgRp/CZ8+3HJ7IEOyEG
	tGXW/3q706Cpw/AWuVkPvAR0bcePXHAFeCHew7C+HstbhjqWzFJJfKcSFotIA1iM
	M1B/QSEqcntSj/I1imARw==
X-ME-Sender: <xms:1Yp6ahNcDTN_vXWtCRg7ODrnjiJ0QjaryoRDkioUhYA6wT5q76P2yw>
    <xme:1Yp6alrhSaw2vMk_-1aHovyjV0MpRljcQ52TtpVVOr4HkaIflnDglLTKaEGcCQr02
    X9NwrxafkRImwaYFnoFnb5824QqaYafNNvrnPh0O3vG9232JQ>
X-ME-Received: <xmr:1Yp6ajuA4oP974sBmvBaj2OPDKIJrrUxP23CWaMN_qmthtg-VeZWlRifNC_CWwZa6u9xZoigI1IZ3n3Lc2TS68VU3dyBMDE>
X-ME-Proxy-Cause: dmFkZTEfdCq7QEw5hqn94XqsJYuYH99flEPEwzpisxCC2chNvHbKOmyQik/TvWypJ5/kSz
    4CIHkScVg5wKpqxeLZqMA5bXEftQ3sS5T5cIGlWJgWN4ev0CXL33J/xhTvQW/zQRe3F9JQ
    VUFodRL8942ok8P5dlE33d19tI+Zl3EjonXOkMhmSWVBdjK7gVoIONNU3TPVijDg9nGlNq
    82rOmRr1XtLtnUjXin0GwsoadGX53JduN9iupI2ePKet+b39Lc+eQO/SCewFRLcL6ZHkQd
    7qiky1Mh7/uOPB/pUQX1t0PyPfIkXmVdAmBwupHTNVRGmA0UOjSFqdjZuYzNM21KAYVUdM
    /8T3JiOmuWZt7TFqwsSOv2I6DKyQ5RQSj0KOz/+1O6ZJglfow7yA1R/ydRvxlnzgUnwkvY
    s7siHWebYsStDCK04wBA0bs/6050T/ucxEHE8qyjxqAY13zV9KjqlqXtJa86MhxiccRosY
    O8n7lwatpHIysg0nTIUgQoC1tyjoTyHDNNQ9v3Zck5N+wu/zHrCVUpPOyX6WPEG0YDldBs
    xIwUxO3G6g/Ts7u9tx1hw2pm77l0K8tAHr/4s1OgcCxpUFdRjoq8cRY6O3diG34JZimzPQ
    4BW+qFqEXEW9FB45wLHUrBTcZqFBfKMldpaUyQhobF8S9RRtsh2iJ/I/JjWw
X-ME-Proxy: <xmx:1Yp6atiQeGBSs0MF7bb0_6WtwEv2o4zV389YfX1g6OkbGhy1aBHuzQ>
    <xmx:1Yp6av0YBEEfuRXhPhukSLdz-hsAP07xNiy_tkPpm5WSPuoW0QXMBA>
    <xmx:1Yp6at9wUO2Nncc51EleUl2irlH4yQtK35cvisjETEC4mKyoM0wIgw>
    <xmx:1Yp6atNvFBc2JkJ9l3JCkIF7wjo8XV2wTBWvT6FZrnIQQtU19nFVAQ>
    <xmx:1Yp6ahpwHU1J8PNWo1NzFHgJAwUDvkL0C5DVaxtTeFmF3xDQPGeb94MZ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 10 Aug 2026 22:37:03 -0400 (EDT)
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
Subject: Re: [PATCH v1 02/12] Add and use d_for_each_positive_child family of
 iterators
In-reply-to:
 <CAJfpegvTXG_kJHyFB115zdQvbyvDNtfqA_Mv9UKiEf9BE5qXwQ@mail.gmail.com>
References: <20260803012648.2195405-1-neilb@ownmail.net>
  <20260803012648.2195405-3-neilb@ownmail.net>
  <CAJfpegvTXG_kJHyFB115zdQvbyvDNtfqA_Mv9UKiEf9BE5qXwQ@mail.gmail.com>
Date: Tue, 11 Aug 2026 12:36:59 +1000
Message-id: <178641581980.2852630.8389705136744176114@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 11 Aug 2026, Miklos Szeredi wrote:
> On Mon, 3 Aug 2026 at 03:38, NeilBrown <neilb@ownmail.net> wrote:
>=20
> > coda_flag_children() doesn't need rcu_read_lock() as holding any
> > spinlock prevents an RCU critical section from finishing.
>=20
> I think prep changes should go in separate patches.
>=20
> The conversion should be an equivalent transformation.

Ok, that's reasonable.

>=20
> > nfs_clear_verifier_directory() is changed slightly so the parent lock is
> > dropped and retaken between clearing the verifier on the parent and on
> > all the children.  I think this is safe.
>=20
> This can also be a prep patch.
>=20
> > get_next_postive_dentry() in autofs now holds the parent lock a bit
> > less.  The only non-trivial code that is no locked any more is
> >    parent =3D p->d_parent
> > This cannot need the lock as autofs doesn't support rename and
> > a ref is held on a descendent of parent, so ->d_parent cannot
> > change.  And if it could, the lock wouldn't help.
>=20
> And this too.
>=20
> > diff --git a/fs/autofs/expire.c b/fs/autofs/expire.c
> > index 5c2d459e1e48..7b0a22629415 100644
> > --- a/fs/autofs/expire.c
> > +++ b/fs/autofs/expire.c
> > @@ -70,12 +70,9 @@ static int autofs_mount_busy(struct vfsmount *mnt,
> >         return status;
> >  }
> >
> > -/* p->d_lock held */
> >  static struct dentry *positive_after(struct dentry *p, struct dentry *ch=
ild)
>=20
> Move this primitive to libfs.c?

By the end of the series it is nearly identical to scan_positives().
So maybe I could add a patch which exports that and uses it instead
of positive_after().

>=20
> > --- a/fs/ceph/mds_client.c
> > +++ b/fs/ceph/mds_client.c
> > @@ -2182,14 +2182,10 @@ static bool drop_negative_children(struct dentry =
*dentry)
> >         if (!d_is_dir(dentry))
> >                 goto out;
> >
> > -       spin_lock(&dentry->d_lock);
> > -       hlist_for_each_entry(child, &dentry->d_children, d_sib) {
> > -               if (d_really_is_positive(child)) {
> > -                       all_negative =3D false;
> > -                       break;
> > -               }
> > +       d_for_each_positive_child(child, dentry) {
> > +               all_negative =3D false;
> > +               break;
> >         }
> > -       spin_unlock(&dentry->d_lock);
>=20
> simple_empty()?

Maybe...
They aren't quite the same in that simple_empty() locks the found
positive dentry and checks again.  drop_negative_children() doesn't pay
the cost of that spin lock.
Does that matter?  Is the spinlock needed?  Should I remove it from
simple_empty()?

Also they are called in different circumstances.

simple_empty() is used for an in-dcache filesystem.  It is called with
the directory locked (i_rwsem) so nothing can be added/removed and it
gives an answer about the directory (and so shouldn't need the spinlock
as it has the i_rwsem).

drop_negative_children() is called on a caching filesystem so it is
reporting on the cache, not on the directory.  Also i_rwsem isn't held
(so maybe it does need the spinlock???)

I wonder if ceph really wants a version of shrink_dcache_parent() which
only drops negative children.....  looking at the history is probably
doesn't and probably isn't bothered by TOCTOU races between checking for
positives, and calling shrink_dcache_parent().

I think I would rather keep the to separate.

Thanks again,
NeilBrown


>=20
> Thanks,
> Miklos
>=20

