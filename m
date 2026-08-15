Received: from flow-a3-smtp.messagingengine.com (flow-a3-smtp.messagingengine.com [103.168.172.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15F6319DF55;
	Sat, 15 Aug 2026 00:28:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.138
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786753736; cv=none; b=nvPhZnMqx39oJnvzi4VmWgSKtb1c1fq9m/4Otr9bsZlcVg2dRxav44kkwbPeIyaaqz8JP4DGRLDLGYvubs5koIZMelYIqWhsth3BvvfqFWU5d8qSTOWt8OfzF+kvbt4y8pkpyflFrrr82NOWEDQlWR6RxcWE3oKSc+xaWXHfkk4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786753736; c=relaxed/simple;
	bh=g7nh7dsEZ1pjHvCiqIb3hdYLn0K81/1DIip0VhIf2gw=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=ZvmCJqVuOJeCeF/vZA4Bc5baXati+F6HVDoNn6CcHt2CTEIgRNnnWMJ8PWq/VqG9/1LEjRrEe4rFLnk7SDU/06GTExSdHuKLO294PNI9gHUtbMuSPVjjWdwYGMdYNyR6R/x5h7DiF4j6DK2o7YwGxopSnnuleaHKtRjkoKdqNc4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=nSdn1EKL; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=HGIMHqle; arc=none smtp.client-ip=103.168.172.138
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="nSdn1EKL";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="HGIMHqle"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailflow.phl.internal (Postfix) with ESMTP id 082A613802D3;
	Fri, 14 Aug 2026 20:28:53 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Fri, 14 Aug 2026 20:28:53 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1786753733; x=1786760933; bh=o1aQLt2LpUGrKjGYOvTLlFvcRJJ/81F/gPY
	p8FQi+3k=; b=nSdn1EKLriHb/2RhjTK0cVnbZ8IPk5rQcDeD8azatLHjlfr69xT
	sT8lcvsByuamdXOvg2BGtbXVhXrMuRFNtBIwWVgmd4cfVoTd4zirM1bs7F30ZXio
	AxRLJK5tMfRWgtUCkIyfUaPv9Twnq25W5/PK5v2TY5GdxZsdETK937XWlSrREFSz
	ZkDwXiTfVfX2Klwo8+xTOcGYNCtNGm9n6maaFnqa7qMngoEaoSlXWflFFKCSoBe5
	Eqp6WLfQzODbkolKOCA/9kcztSbIqwbb9yndmvOYTFjC7eyCfUEvUDrAobeT0YUv
	rp0LRtFbgAqZobYbt2kiWyvrRrGNh5QGauQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786753733; x=
	1786760933; bh=o1aQLt2LpUGrKjGYOvTLlFvcRJJ/81F/gPYp8FQi+3k=; b=H
	GIMHqleYRAtYTzuNLHIW0VOhVR6exRSL7nZ5T5Dsz0cz6aOpHWsGICyl+pE3NR82
	mco5ZnChpP8n+3LJf6/qgsplhBlic6kUvy/Zaj+ez0SDX4A0iIkOypwW+VgHGYvm
	18iEVvspYmiC+YipF5gfBW+oaYwJ7HG3IiSJ/PfjfnckWpn+fEORTE0lIcTEv4Qs
	3bdFzfAS4Hf0cvclf+FNTKMbnlgSYP7FkQjn5O/kSpM7CgrAQnUm2cyE5Rg09uyu
	mjXGMd0kmzYCkJdl48Y0I5n1gkySyOAdSVII+Qq5qOD/dLgS4tSbRkkamGTSUfCO
	vxOilKqKj0KjdiHcl7gDw==
X-ME-Sender: <xms:w7J_ajsw_D4dIBSOuzcQo2vIV-l0PSNzPLLcLTsvnO-jNoJLh7hRHw>
    <xme:w7J_amImdpjuHUPBRSOu2I3DiZ6OniA38JL7-r01735HNYLbk1iNdq7miXpg3pc1d
    389oLC4p6psQQP09vx7NgqVCvWsvJxcpE3dX-zyICYTLDBQ>
X-ME-Received: <xmr:w7J_aqMUIWzv8WujNwOgoY2jXshZ3oO24yqckHdHXdgTekXMRHGTPMIUPa3lB9oJdZelDVj9Mf4z-AnfxcZDP70iamDB0kE>
X-ME-Proxy-Cause: dmFkZTGhRd+yp9NPun85awSEtfR1b0DaxVZ8t32qHaq72VOb+fKnQFTMpUjPKMl4oJ2dKy
    gOjLZhbW40/d4Ulw989zBT19O3J56mT9sS5rxsWCiVTu8vRmTtWa2gwOxUu1coWL+kTsR7
    zmF2Zwe8MZREiTR8u9Z6GHWp4ZVFB3oCWHEJwmE4AiUxVslFtexvzkQPYTNMBTOvixMRl7
    ue9FrMhh+etRV4Q7GPmTxD6DxMmiIx05X6A8pvkrhWhpC72ojp0oZFmvkiTJo0YxlCrro+
    pBmQzdu/NZkZsXqD0LSR3ezEgtdjawbAV6VACqf0UJlWIwTN1pZCdMHFEk1Ba5Wr/xoil5
    m1ar3vXpRZiJADwZajrw72r3Yi5ZCzTqB7k41pfnjSsbzNYpwCgjpXbOdd4WWwcCTT6o8W
    ckRtMXwxQkh/MABiNiJsZX0sPw+VI+Gu5u5eK3SgsQruwdV4O76AH74wjb5LS4M0UbB7uz
    Yz/qOr55Gs9lBDTSyzfNPrw8WtWbkSaU7GkBesK5cMj+Ann5hn3m+a865CJHQ3aShv+zVQ
    SoCyPbBmuJ5qcdP9a8T9exmbFYSAIkrrt//AWzz5nGeAOJoXNXZGoUHuUlGKOAGKHb+D8L
    yvQ+67sZMYi+TmzVSaRGL4XEmltVRmq8SV3JJlLzwwfH65tiHhbT6fN/dtCg
X-ME-Proxy: <xmx:w7J_aiAxU3yZcbvrk8wJkNME9XsrJoCBIhIovLvZmpIBD5p2p1V0mQ>
    <xmx:w7J_aqUHe7vV58t_zchUPDraJXzCnvao8pQ0b5pYZcZc5fwOCtPvIg>
    <xmx:w7J_amf-Pp8IZHxZhr00evSaKWknmXyDWl812zsr2QSqrXFQHkLSLA>
    <xmx:w7J_arviLpY4ox76MBoGRvR8A0KiaJEUV6R6080rf-p8mlgAQldpwQ>
    <xmx:xbJ_aoKkBl9MZquIyCaQj_jCvcp2KbVnRX6HidmH9i4ZggtUaLYvnJ_J>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 14 Aug 2026 20:28:45 -0400 (EDT)
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
Subject: Re: [PATCH v1 03/12] fsnotify: don't hold a spin_lock across
 fsnotify_recalc_mask() calls.
In-reply-to: <178642552869.2852630.11443303758249822243@noble.neil.brown.name>
References: <20260803012648.2195405-1-neilb@ownmail.net>
  <20260803012648.2195405-4-neilb@ownmail.net>
  <CAJfpegs-k3skRGiwZvQLzD7OrAK4KL8zwmpmJKyjRHSQ-rqX+Q@mail.gmail.com>
  <178642552869.2852630.11443303758249822243@noble.neil.brown.name>
Date: Sat, 15 Aug 2026 10:28:41 +1000
Message-id: <178675372176.2852630.1305553887009521382@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 11 Aug 2026, NeilBrown wrote:
> On Tue, 11 Aug 2026, Miklos Szeredi wrote:
> > On Mon, 3 Aug 2026 at 03:39, NeilBrown <neilb@ownmail.net> wrote:
> >=20
> > > @@ -116,11 +117,15 @@ static int dnotify_handle_event(struct fsnotify_m=
ark *inode_mark, u32 mask,
> > >                 else {
> > >                         *prev =3D dn->dn_next;
> > >                         kmem_cache_free(dnotify_struct_cache, dn);
> > > -                       dnotify_recalc_inode_mask(inode_mark);
> > > +                       need_recalc =3D true;
> > >                 }
> > >         }
> > >
> > > +       if (need_recalc)
> > > +               need_recalc =3D dnotify_recalc_inode_mask(inode_mark);
> > >         spin_unlock(&inode_mark->lock);
> > > +       if (need_recalc)
> > > +               fsnotify_recalc_mask(inode_mark->connector);
> >=20
> > Is the fsnotify_group_lock() held in this case?   I don't see it.
>=20
> It isn't held.  Doesn't it need to be...
> It seems to protect marks, so maybe it does.
>=20
> srcu seems to be used to protect this section, so maybe we can rely on
> that.

I dug into this some more, and we do rely on srcu, but don't need the
extra code below.
inode_mark->lock doesn't protect inode_mark->connector, so moving the
dereference out of the lock has no effect.
srcu_read_lock is taken before we get the ref to the mark, so the mark
and the connector cannot disappear underneath us.
A race could result in inode_mark->connector reading as NULL, but
fsnotify_recalc_mask() checks for NULL, so there is no risk for harm.

Thanks for encouraging me to dig into this.

NeilBrown

> Maybe:
>=20
> diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
> index 7553fe0d7850..ba746284bded 100644
> --- a/fs/notify/dnotify/dnotify.c
> +++ b/fs/notify/dnotify/dnotify.c
> @@ -17,6 +17,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/slab.h>
>  #include <linux/fsnotify_backend.h>
> +#include "../fsnotify.h"
> =20
>  static int dir_notify_enable __read_mostly =3D 1;
>  #ifdef CONFIG_SYSCTL
> @@ -94,6 +95,7 @@ static int dnotify_handle_event(struct fsnotify_mark *ino=
de_mark, u32 mask,
>  	struct dnotify_struct *dn;
>  	struct dnotify_struct **prev;
>  	struct fown_struct *fown;
> +	struct fsnotify_mark_connector *conn;
>  	bool need_recalc =3D false;
>  	__u32 test_mask =3D mask & ~FS_EVENT_ON_CHILD;
> =20
> @@ -123,9 +125,10 @@ static int dnotify_handle_event(struct fsnotify_mark *=
inode_mark, u32 mask,
> =20
>  	if (need_recalc)
>  		need_recalc =3D dnotify_recalc_inode_mask(inode_mark);
> +	conn =3D srcu_dereference(inode_mark->connector, &fsnotify_mark_srcu);
>  	spin_unlock(&inode_mark->lock);
>  	if (need_recalc)
> -		fsnotify_recalc_mask(inode_mark->connector);
> +		fsnotify_recalc_mask(conn);
> =20
>  	return 0;
>  }
>=20
> Does that make sense?
>=20
> Thanks,
> NeilBrown
>=20
>=20

