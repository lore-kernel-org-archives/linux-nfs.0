Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46346 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752692AbaCFEiF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2014 23:38:05 -0500
Date: Thu, 6 Mar 2014 15:37:57 +1100
From: NeilBrown <neilb@suse.de>
To: Jim Rees <rees@umich.edu>
Cc: Andrew Martin <amartin@xes-inc.com>, linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
Message-ID: <20140306153757.5ab046e0@notabene.brown>
In-Reply-To: <20140306034727.GA18942@umich.edu>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
	<260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
	<20140305201149.GA16212@umich.edu>
	<1106484945.149062.1394052088011.JavaMail.zimbra@xes-inc.com>
	<20140305211124.GA16979@umich.edu>
	<20140306143454.75eb2726@notabene.brown>
	<20140306034727.GA18942@umich.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Vq+82X_c2AIGfa+zkMbloiQ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Vq+82X_c2AIGfa+zkMbloiQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Mar 2014 22:47:27 -0500 Jim Rees <rees@umich.edu> wrote:

> NeilBrown wrote:
>=20
>   On Wed, 5 Mar 2014 16:11:24 -0500 Jim Rees <rees@umich.edu> wrote:
>  =20
>   > Andrew Martin wrote:
>   >=20
>   >   Isn't intr/nointr deprecated (since kernel 2.6.25)?
>   >=20
>   > It isn't so much that it's deprecated as that it's now the default (e=
xcept
>   > that only SIGKILL will work).
>  =20
>   Not quite correct.  Any signal will work providing its behaviour is to =
kill
>   the process.  So SIGKILL will always work, and SIGTERM SIGINT SIGQUIT e=
tc
>   will work providing that aren't caught or ignored by the process.
>=20
> If that's true, then the man page is wrong and someone should fix it. I'll
> work up a patch if someone can confirm the behavior.

I just mounted a filesystem, turned off my network connection, ran "ls -l" =
and
then tried to kill the "ls"....
To my surprise, only SIGKILL worked.
I looked more closely and discovered that "ls" catches SIGHUP SIGINT SIGQUIT
SIGTERM, so those signals won't kill it....

So I tried to "cat" a file on the NFS filesystem.  'cat' doesn't catch any
signals.  SIGHUP SIGTERM SIGINT all worked on 'cat'.
'df' also responds to 'SIGINT'.

It would be nice if 'ls' only caught signals while printing (so it can
restore the default colour) and didn't during 'stat' and 'readdir'.  But
maybe no-one cares enough.

So the man page is not quite accurate.

NeilBrown

--Sig_/Vq+82X_c2AIGfa+zkMbloiQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxf7pTnsnt1WYoG5AQLzJg//fQNRdIFjBmtHleS+OwUpgLvRt23+vohT
KnAdwHYWIN4w21wggAGX1kaTL4WXNcrEgcpWeCAsUUBQhVgHPP7lgJxA4EySzaBq
kO7FHCBnLOX9IsWF5Fs8ARh/4rsRHwS3lAxgMdWd/NPbFIi7WfrcDNXPcIuPTxgk
85avui0Y7z3f+LQyvUjx3lFQbL3+A8nnlOYmT3lISTnKx3ewhkAAOUZfrNAITbOw
Te6Zdm0g0Zo85vOf2C1IbLTwukiPAPmEeRsmZtAUm01myLqt+ZSFX/1+ywNdR6UB
YiPQv8jME9eJOz1lr4oH1tusR416Omoroi1P7Z6Wd2jVIRoI6jtBijrXyfYtFbKj
Z+RKomwJIiV4I/J6QEexB8mRi0JIPRk48i+dczoV7hblb2pG4Lu4A8uD1nROSQ7U
pV4sUuG03Kf7LHXibJsd7htg2dTpFLGOgAup2wPwvT5hTlzDZ7PhYPzCECwfPojt
HRDup4oGG4+hmr3Dj7iJhVfmuS2mCDKwSwrh08v7jajtoc5P5GkaU45uMusi05ba
wOlgruBfYtNS9IDlZiavhCKwdvtjYacgZJwKuiGz47/X6imO26qyldVCWA5VerZ9
DsucUAUNTTYmhc1uocPvvmvwhuvQ/2Ej4PiwoPmbRkMswBLIu9Iuo/XUCKLc7zjo
HCWcWjl261k=
=697j
-----END PGP SIGNATURE-----

--Sig_/Vq+82X_c2AIGfa+zkMbloiQ--
