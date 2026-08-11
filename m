Received: from flow-a2-smtp.messagingengine.com (flow-a2-smtp.messagingengine.com [103.168.172.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A7D72E06D2;
	Tue, 11 Aug 2026 05:18:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.137
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786425544; cv=none; b=WBoxALPOiGvR5lma6yhtTA+SzL2GbDa/pVwmK4OSZFXDspKOUxMKX4MZtdBf+XQ1rTurUbKAttOljQEhI+KJYwTfyNP5fkv6qK7wri6O0pPyZAE1HVe4vMAeVyEF5hkCOjKy+etWkDP7W0mwaReUC35uC+Sv0GV4rL37cB+3tJY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786425544; c=relaxed/simple;
	bh=qV3QUciC5jpkDDS6x7iOwPa1PgpN4Lu9TJCjFpiEWgA=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=MiA3gC3OKGJmSOkXrWxPC5sZLYVlRvFTKUJJNkPrBqgT2johsmY0vHzSRxBZOCoGu6wh4Xzzw5AgX9m/BLCdh1j0wkP0n32y6UZE3kxiru1eTZfHFUVoGZmBPyRE/N+f9J96prBRFj0XhuzUH/Ftx42n5P5HftnqJfZCqtHNVj0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=F8iWoKdA; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=PknB7V/w; arc=none smtp.client-ip=103.168.172.137
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="F8iWoKdA";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="PknB7V/w"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailflow.phl.internal (Postfix) with ESMTP id 023C5138014C;
	Tue, 11 Aug 2026 01:18:57 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Tue, 11 Aug 2026 01:18:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1786425537; x=1786432737; bh=yIPzOZPj6bFZVGzFQgSwtywJ8VHP6g1rxC/
	O4hZ/kD0=; b=F8iWoKdAN0epDjXqUe9BJXmkXzGADQHZ4W9nsxIb1xhJxJDI22k
	5b+j48rlryp7mMtRcxj/Vv6uxPAWeASqUU6IkZIBxTuvmwVHb9iV04qYH1KPIxpM
	AdtF4hXlf24M27foBj1YPxJtByHHwRQ2SamGnEd2AZ8hEvwmf6JFwkXAwihGxD6U
	TsxsJQXHEmfqRpr1Z+wK7KNGOqsk16QD/Nu2lS9gsx4dCvfG8rsX19pFkaYcTdfU
	E0Cb7sqDO8fJ5YYXQ6gwUrPBYUOCRX8LyzLve8XF0CeDSb8fykX2+XUdTZIxDQJY
	T7eVYnviQWDfpmKe8nLkNfqG0XXyHYTcJRQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786425537; x=
	1786432737; bh=yIPzOZPj6bFZVGzFQgSwtywJ8VHP6g1rxC/O4hZ/kD0=; b=P
	knB7V/wEftW1n6i2bh61vuqN5hAJ98R0xajmWMa/1nodebn4UQM0EcwG5jiZLoBZ
	Nw4sIq0N8vjBP8iprvw1l6IBF7Y7vnALKj29pklj5bO6ALvjMIsmQZnuO3K09SC5
	gRy5vNhpahD5PM+wUmPeYEV2yEiuoA/eyQ6PNuGx0+Ac2Lbz9mKk0rjwwN4z2/SS
	PJbhZhgbOU6n46UnVsCCAzYIXze3ldlgYNIUhSgeNWggUHzPpo9sxJG2v/hJnYp9
	JXvZU28JP74qM2+aGJjxb5d517TZ9VQYBFo0NOZWjiOtqssTsN0HCytFJusNx498
	EI0Ce27C67sAVzRud7MOg==
X-ME-Sender: <xms:wLB6ah4Gj1xwB3_Ij1DqwAU7bIB-wVRIhu7BnWDbM2s7rZXxHkhYNg>
    <xme:wLB6agkqaSPwwhZn8cYaSG9yBuW50Vug80q7g766wmoSnYWUrc6ugjODG7zpBubzi
    aTvyuWFHoUeEn7qhvE_amVQvrFOj3ZC0MkpbX1ZTMUacFew>
X-ME-Received: <xmr:wLB6ar6s1Roo1v3Nymb-zjpil1WfYAdiu5Df2DUQRQpdRgwRZN3JKyY7Id2aIi3-TzMZaE4VbmUvi-TSB9GdlDiw899bOBg>
X-ME-Proxy-Cause: dmFkZTFCiCyrumSR7jngdWcHxN7jbp3z+mT9Bg09XSTh4ZlvO7zoSvAlSPKhh5se8+5XVR
    7B+WVTfTNr9ys98GsP47siw0jcBUAN/azkEOzKloAbavC4TLXPa0GPqTKO8/sl5lAcYMvq
    7hZQD+IPf18+NRSWbpR23WiHzwL8rSK4WIX11LL83p78t1ponL8YeO2TmITu6cn+nCVctM
    hjr8QnUgyRO04Ccf2ttn6cLUKx0nWQkkUIf8JQI0bt9gIi+s1UE6tnqgrhFVFwtim0oaF4
    C422WgHhab/FIE6dB2/+1Cn6e/KdkL6z4y85QMKu2JR2hF4IPMN1GRNl6no826C0twLmn+
    WhTXMBOUJWKCwaJP7d0XGmzZwR10F2tqqCbzlf0ITEAm7zPXJX6Zp/TaKYm++qv8afXAeO
    pUrfsqLbG4l+uvbe/+oXBPmU/qtlpPrx953h6pmjAOO1wukt0B+Z7lWT2nL++iwyd9ds42
    ky+TYilQcLSFURkiRhMeK6fn3tv0spRZpnXqsvyfnWjqmihxpetCULdxWKVxVIicaBLaeO
    CMF0oDL3SMgTL0QZUIcDuBMFeBZjOo06jD3dGNrHdl0hxmzry0x41xGXmRxKU0M52V+1Sk
    zcFtoaBoEpIRoVxJgeuLaqTK7Jw6KcKq43AJKg5Z/q4BCFsTFX3ECJD6sntg
X-ME-Proxy: <xmx:wLB6ap82xMJv3vcQxGYSXQmIdqh7wmdn9s-sTOK71WJuS53VkNLzAw>
    <xmx:wLB6arh4nnc1CykmMstrRzhfJhA7BUIlaxEUV6-b7mjCDvr26minUA>
    <xmx:wLB6an41cUm659Auy2pDO5cChEmh3fYLhS0xJBSFbVccCL2xrwq95g>
    <xmx:wLB6aoYBQ-Z29sxa1zw5Ke61RJoxA1FU5Eqvg8uMfYGncwsA5K0VAg>
    <xmx:wbB6aqn4wIxc6jAWyewEj5XZ5oABGdrZARbVg-JbcjXLYlT5lvb1Hi9a>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 01:18:50 -0400 (EDT)
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
In-reply-to:
 <CAJfpegs-k3skRGiwZvQLzD7OrAK4KL8zwmpmJKyjRHSQ-rqX+Q@mail.gmail.com>
References: <20260803012648.2195405-1-neilb@ownmail.net>
  <20260803012648.2195405-4-neilb@ownmail.net>
  <CAJfpegs-k3skRGiwZvQLzD7OrAK4KL8zwmpmJKyjRHSQ-rqX+Q@mail.gmail.com>
Date: Tue, 11 Aug 2026 15:18:48 +1000
Message-id: <178642552869.2852630.11443303758249822243@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 11 Aug 2026, Miklos Szeredi wrote:
> On Mon, 3 Aug 2026 at 03:39, NeilBrown <neilb@ownmail.net> wrote:
>=20
> > @@ -116,11 +117,15 @@ static int dnotify_handle_event(struct fsnotify_mar=
k *inode_mark, u32 mask,
> >                 else {
> >                         *prev =3D dn->dn_next;
> >                         kmem_cache_free(dnotify_struct_cache, dn);
> > -                       dnotify_recalc_inode_mask(inode_mark);
> > +                       need_recalc =3D true;
> >                 }
> >         }
> >
> > +       if (need_recalc)
> > +               need_recalc =3D dnotify_recalc_inode_mask(inode_mark);
> >         spin_unlock(&inode_mark->lock);
> > +       if (need_recalc)
> > +               fsnotify_recalc_mask(inode_mark->connector);
>=20
> Is the fsnotify_group_lock() held in this case?   I don't see it.

It isn't held.  Doesn't it need to be...
It seems to protect marks, so maybe it does.

srcu seems to be used to protect this section, so maybe we can rely on
that.
Maybe:

diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
index 7553fe0d7850..ba746284bded 100644
--- a/fs/notify/dnotify/dnotify.c
+++ b/fs/notify/dnotify/dnotify.c
@@ -17,6 +17,7 @@
 #include <linux/spinlock.h>
 #include <linux/slab.h>
 #include <linux/fsnotify_backend.h>
+#include "../fsnotify.h"
=20
 static int dir_notify_enable __read_mostly =3D 1;
 #ifdef CONFIG_SYSCTL
@@ -94,6 +95,7 @@ static int dnotify_handle_event(struct fsnotify_mark *inode=
_mark, u32 mask,
 	struct dnotify_struct *dn;
 	struct dnotify_struct **prev;
 	struct fown_struct *fown;
+	struct fsnotify_mark_connector *conn;
 	bool need_recalc =3D false;
 	__u32 test_mask =3D mask & ~FS_EVENT_ON_CHILD;
=20
@@ -123,9 +125,10 @@ static int dnotify_handle_event(struct fsnotify_mark *in=
ode_mark, u32 mask,
=20
 	if (need_recalc)
 		need_recalc =3D dnotify_recalc_inode_mask(inode_mark);
+	conn =3D srcu_dereference(inode_mark->connector, &fsnotify_mark_srcu);
 	spin_unlock(&inode_mark->lock);
 	if (need_recalc)
-		fsnotify_recalc_mask(inode_mark->connector);
+		fsnotify_recalc_mask(conn);
=20
 	return 0;
 }

Does that make sense?

Thanks,
NeilBrown
