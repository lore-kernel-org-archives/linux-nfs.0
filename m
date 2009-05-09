From: =?iso-8859-1?Q?Andr=E9?= Berger <andre.berger-S0/GAf8tV78@public.gmane.org>
Subject: Re: NFS issues with recent kernels [long]
Date: Sat, 9 May 2009 20:57:36 +0200
Message-ID: <20090509185736.GF3801@fuchs>
References: <20090417102659.GC55096@fuchs> <B05C16C7-53B5-4E26-8239-956C600CF452@oracle.com> <20090420091454.GB614@fuchs> <F1250240-F050-47B7-9569-54941AAAD572@oracle.com> <20090421043642.GA52257@fuchs> <20090508193813.GC3801@fuchs> <8D7394C9-0142-4635-88E5-139F4F5F39F6@oracle.com> <20090508203751.GD3801@fuchs> <1241815735.7291.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:42325 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbZEIS5g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 May 2009 14:57:36 -0400
In-Reply-To: <1241815735.7291.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Trond Myklebust (2009-05-08):
> On Fri, 2009-05-08 at 22:37 +0200, Andr=C3=A9 Berger wrote:
> > * Chuck Lever (2009-05-08):
> > > On May 8, 2009, at 3:38 PM, Andr=C3=A9 Berger wrote:
> > >> * Andr=C3=A9 Berger (2009-04-21):
> > >>> * Chuck Lever (2009-04-20):
> > >>>> On Apr 20, 2009, at 5:14 AM, Andr=C3=A9 Berger wrote:
> > >>>>> * Chuck Lever (2009-04-17):
> > [...]
> > > Assuming 192.168.1.8 is your server, frame 79 and 622 report FSIN=
=46O =20
> > > results:
> > >
> > > Network File System, FSINFO Reply
> > >     [Program Version: 3]
> > >     [V3 Procedure: FSINFO (19)]
> > >     Status: NFS3_OK (0)
> > >     obj_attributes
> > >         attributes_follow: no value (0)
> > >     rtmax: 16384
> > >     rtpref: 16384
> > >     rtmult: 4096
> > >     wtmax: 16384
> > >     wtpref: 16384
> > >     wtmult: 4096
> > >     dtpref: 4096
> > >     maxfilesize: 2194719883264
> > >     time delta: 1.000000000 seconds
> > >         seconds: 1
> > >         nano seconds: 0
> > >     Properties: 0x0000001b
> > >         1... . =3D SETATTR can set time on server
> > >         .1.. . =3D PATHCONF is valid for all files
> > >         ...1 . =3D File System supports symbolic links
> > >         .... 1 =3D File System supports hard links
> > >
> > > says your server operating system supports NFS rsize and wsize ma=
xima of=20
> > > 16384 bytes.
> > >
> > > RFC 1813:
> > >> rtmax
> > >> The maximum size in bytes of a READ request supported by the ser=
ver. =20
> > >> Any READ with a number greater than rtmax will result in a short=
 read of=20
> > >> rtmax bytes or less.
> >=20
> > My OS is 2.6.29.2, Debian etch, on a PPC system. I swear I got 32K
> > [rw]size with kernels < 2.6.19, at least "mount" reported them as
> > such. With recent kernels, "mount" and your analysis agree on just
> > 16K. So, what can I do?
>=20
> There is nothing the client can do as long as the server says it won'=
t
> accept NFS requests with read or write sizes > 16k. You therefore nee=
d
> to fix the server.

So what can I do to fix this? I've upgraded to nfs-utils-1.1.4 in the
meantime, 1.1.5 and both 1.1.6 give me=20

  make[2]: Entering directory `/tmp/nfs-utils-1.1.5/support/misc'
  gcc -DHAVE_CONFIG_H -I. -I../../support/include   -I/usr/include  -D_=
GNU_SOURCE -Wall -Wstrict-prototypes  -pipe -g -O2 -MT tcpwrapper.o -MD=
 -MP -MF .deps/tcpwrapper.Tpo -c -o tcpwrapper.o tcpwrapper.c
  tcpwrapper.c: In function =E2=80=98haccess_add=E2=80=99:
  tcpwrapper.c:117: warning: implicit declaration of function =E2=80=98=
TAILQ_EMPTY=E2=80=99
  tcpwrapper.c:119: error: expected expression before =E2=80=98else=E2=80=
=99
  tcpwrapper.c: In function =E2=80=98haccess_lookup=E2=80=99:
  tcpwrapper.c:131: warning: implicit declaration of function =E2=80=98=
TAILQ_FOREACH=E2=80=99
  tcpwrapper.c:131: error: =E2=80=98list=E2=80=99 undeclared (first use=
 in this function)
  tcpwrapper.c:131: error: (Each undeclared identifier is reported only=
 once
  tcpwrapper.c:131: error: for each function it appears in.)
  tcpwrapper.c:131: error: expected =E2=80=98;=E2=80=99 before =E2=80=98=
{=E2=80=99 token
  make[2]: *** [tcpwrapper.o] Error 1
  make[2]: Leaving directory `/tmp/nfs-utils-1.1.5/support/misc'
  make[1]: *** [all-recursive] Error 1
  make[1]: Leaving directory `/tmp/nfs-utils-1.1.5/support'
  make: *** [all-recursive] Error 1

with=20

  ./configure --prefix=3D/usr/local --sysconfdir=3D/etc --with-tcp-wrap=
pers=3D/usr/include --with-statedir=3D/var/lib/nfs

I've already upgraded tcpd to the Lenny version 7.6.q-16 (from
source), but that didn't help.=20

With 1.1.4, I still get 16384 [rw]size while 32768 were requested.=20

-Andr=C3=A9

--=20
May as well be hung for a sheep as a lamb!
Linkstation/KuroBox/HG/HS/Tera Kernel 2.6/PPC from <http://hvkls.dyndns=
=2Eorg>
iPhone <http://hvkls.dyndns.org/downloads/documentation/README-iphone.h=
tml>
