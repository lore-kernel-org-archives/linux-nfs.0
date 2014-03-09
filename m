Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51199 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606AbaCIXnf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Mar 2014 19:43:35 -0400
Date: Mon, 10 Mar 2014 10:43:27 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount.nfs: background mount now do directly into
 background
Message-ID: <20140310104327.212f72ce@notabene.brown>
In-Reply-To: <20140310101816.17e7d98a@notabene.brown>
References: <1394284964-12997-1-git-send-email-steved@redhat.com>
	<20140310101816.17e7d98a@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/2I_AaMUke5zrzljTSIrTQDH"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/2I_AaMUke5zrzljTSIrTQDH
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 10 Mar 2014 10:18:16 +1100 NeilBrown <neilb@suse.de> wrote:

> On Sat,  8 Mar 2014 08:22:44 -0500 Steve Dickson <steved@redhat.com> wrot=
e:
>=20
> > Modern day kernel will no longer return all timeout
> > errors instead the process spins endlessly in the kernel.
> > This behavior will cause the foreground mount to hang, never
> > allowing the mount to go into background.
> >=20
> > So this patch eliminates the foreground mount cause
> > background mounts to go directly into background
> >=20
> > Signed-off-by: Steve Dickson <steved@redhat.com>
>=20
> Did NFS mounts *ever* time out (when 'soft' isn't given)?
>=20
> If so, there is probably a regression which maybe should be fixed.
>=20
> If not, then this has always been a bug since sting-options were introduc=
ed
> and the kernel started doing the mountd filehandle lookup...
>=20
> So I'm probably OK with the patch but I wonder if there is more of a story
> behind this that we should be sure we understand...
>=20
> Thanks,
> NeilBrown

Sorry, I really should read email in chronological order, shouldn't I :-)

The foregoing discussion seemed to focus on NFSv4.  Does NFSv3 behave the
same way?  A quick test suggests that it doesn't. =20
   mount -o bg,vers=3D3 server:/path /mnt
backgrounds as it should after a few seconds.

So I suspect this patch should be version dependent?

However falling-back from v4 (which we leave entirely to the kernel) to v3
could be a bit awkward.

I think that an NFSv4 mount really does need to timeout - whether that
happens in the kernel or through the use of "alarm()" doesn't really bother
me.  But if it doesn't timeout, then it is violating the documentation and
ignoring the retry=3D setting.

NeilBrown



--Sig_/2I_AaMUke5zrzljTSIrTQDH
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxz8nznsnt1WYoG5AQIrvg/7BFa3s7z0dOgtZS/myPT9kY4Imkb9sZJ4
NJpcidVhjXkSU3PcQNxIQmY+mvYKt9KnXwJpb10hz2ecK7XjW87gm8SVr5frvGsk
DbG0aGZa/3YCWJpxrzErRz1C72aFSHlSXD9G3z94tJ0HTJ8zojZVItfra/UFg4al
FaUJHob8VKmCatBN38eLDBkYA43oDc5npVr16tHjP+1Jg0MQ6YAJ0lTJa1+WfAXH
h2Z5dSYFj4BsJrx/FE5rugFXHtEBT4Vxu6JJeFg6DY70rd1tT/6gmvQKQXv1x2ae
gPOwiXzNQnuCC6q1DwzvNJt7sPtxYeg7tWSkKET09nJ5LQQ3DTNHlHT6VlU7NdGw
Rq/EnZVMMmaM09iZY4Bu78gPXBta77EJCqSX8OD2WsTevqHK7CiakgGSwXpqooKN
p5my2UQoTo7DQazqb6+yXgjjmQ/Mx430OSKFj37lFpDfLTD+ABUxowNKOlFcmeRO
DpIG2dN+72eux5z0K2nOTi4coV+JX602X28o/qs8I1/PApuW2wuyI63zQVnwmgTg
7UucPGYx1mwNRX+fnohc510Y4wZdOPH0Uof1pHC7g9KZNhZyxUOurvabJ2BNRsSP
HCBoJ7WRneXqEaj/xJ+q2fIKFfP8wGI+52sZvMduBFsfmd14hsSw9WNo2JYB8Uxo
ae0mMKGrGCA=
=n1eq
-----END PGP SIGNATURE-----

--Sig_/2I_AaMUke5zrzljTSIrTQDH--
