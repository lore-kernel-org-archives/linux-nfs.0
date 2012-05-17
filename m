Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57154 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754958Ab2EQMmc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 08:42:32 -0400
Date: Thu, 17 May 2012 22:42:16 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] osd_login: fix DESTDIR install
Message-ID: <20120517224216.421ad36d@notabene.brown>
In-Reply-To: <4FB4EEBF.3040005@RedHat.com>
References: <1337232243-18088-1-git-send-email-vapier@gentoo.org>
	<4FB4EEBF.3040005@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/DOdMDf4droo+tL/Q5oH7AxL"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/DOdMDf4droo+tL/Q5oH7AxL
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 17 May 2012 08:27:43 -0400 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 05/17/2012 01:24 AM, Mike Frysinger wrote:
> > If the destination dir doesn't exist, the current install fails:
> > make  install-data-hook
> > make[4]: Entering directory `/var/tmp/portage/net-fs/nfs-utils-1.2.6/wo=
rk/nfs-utils-1.2.6/utils/osd_login'
> > /usr/bin/install -c --mode 755 osd_login /var/tmp/portage/net-fs/nfs-ut=
ils-1.2.6/image//sbin/osd_login
> > /usr/bin/install: cannot create regular file =E2=80=98/var/tmp/portage/=
net-fs/nfs-utils-1.2.6/image//sbin/osd_login=E2=80=99: No such file or dire=
ctory
> > make[4]: *** [install-data-hook] Error 1
> >=20
> > Rewrite the code to use automake's existing script support rather
> > than trying to install the file by hand.
> >=20
> > Reported-by: Branko BAdrljica <brankob@avtomatika.com>
> > Signed-off-by: Mike Frysinger <vapier@gentoo.org>I
> I took Neil's patch... commit d4d3920 which basically does
> the same thing... (I believe)... =20

Yes, nearly identical - I was stunned. :-)

NeilBrown

--Sig_/DOdMDf4droo+tL/Q5oH7AxL
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT7TyKDnsnt1WYoG5AQLDcg//TwQ3TAemHfJQ55iZWLlFsdtMZw2jteMt
9We/SyfeSZ8Bb9rQr/U2tTldGe9mW2b0XhxX0Tgjc+qR4cXWlXXoETXqgZ+yTPFL
7AYNb/p4Q/ME4yCs5epU0W3TpQ9npKnPcrtyKb2y2XCNY1FlCf0032eBjLNVXOOj
Hx5m7HHzZgM6FXg+hjM9WyAtQtI+tx7S5PwFt/5oyVWEjy1uRJEb3FX+KsAWh0T/
pTDhpIP+kUoGYXTImj9SLo2xj143Dhp3NUlXBx8QWofQEi8HQpuHTnEjPzY6KQRn
5kjpmXmqQERVZG/IS0JsUEZqXKybt+JqZb4CWifdSAkmfufvaNCzEssZq1mCM9xM
vn0Hoo37vQ1C/M4w4ou0NYixrN7kCRMTLYRkoP//6iyutAi24gWrIS1jQROCrG1q
pEPT+cGt0oogoJwJ0AgFilSsACH2e8Ubim6jlA4vqAvDUUCQDqDDiYRdPm8958TR
rrreMGtjZIuxgHi60xw2fiieSLXlWixZqgXUZmafZ0FR8QqTYJ/9q8e3mugbEjnn
XHVjk6bQSjA8WUv89zXLKBxdyoigycX7PHPbzBdZzvhb/iCmEmqdSUEQYccUiWrk
yYj+rSq3XjbOrD7uYE/wWm2wxSs8/WgtnsTYABkc3poCU8r1saCm9X9pmZ9Fk9tl
lqHjRZskyEk=
=pjLK
-----END PGP SIGNATURE-----

--Sig_/DOdMDf4droo+tL/Q5oH7AxL--
