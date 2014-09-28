Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44440 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753653AbaI1X2u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Sep 2014 19:28:50 -0400
Date: Mon, 29 Sep 2014 09:28:36 +1000
From: NeilBrown <neilb@suse.de>
To: Benjamin ESTRABAUD <be@mpstor.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS auto-reconnect tuning.
Message-ID: <20140929092836.6de0fd92@notabene.brown>
In-Reply-To: <5423E461.8020108@mpstor.com>
References: <5422E5CB.6000402@mpstor.com>
	<20140925114452.121776c0@notabene.brown>
	<5423E461.8020108@mpstor.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/b.J4DyqDF203HgGC5Jv=dJ4"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/b.J4DyqDF203HgGC5Jv=dJ4
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 25 Sep 2014 10:46:09 +0100 Benjamin ESTRABAUD <be@mpstor.com> wrote:

> On 25/09/14 02:44, NeilBrown wrote:
> > On Wed, 24 Sep 2014 16:39:55 +0100 Benjamin ESTRABAUD <be@mpstor.com> w=
rote:
> >
> >> Hi!
> >>
> >> I've got a scenario where I'm connected to a NFS share on a client, ha=
ve
> >> a file descriptor open as read only (could also be write) on a file fr=
om
> >> that share, and I'm suddenly changing the IP address of that client.
> >>
> >> Obviously, the NFS share will hang, so if I now try to read the file
> >> descriptor I've got open (here in Python), the "read" call will also h=
ang.
> >>
> >> However, the driver seems to attempt to do something (maybe
> >> save/determine whether the existing connection can be saved) and then,
> >> after about 20 minutes the driver transparently reconnects to the NFS
> >> share (which is what I wanted anyways) and the "read" call instantiated
> >> earlier simply finishes (I don't even have to re-open the file again or
> >> even call "read" again).
> >>
> >> The dmesg prints I get are as follow:
> >>
> >> [ 4424.500380] nfs: server 10.0.2.17 not responding, still trying <--
> >> changed IP address and started reading the file.
> >> [ 4451.560467] nfs: server 10.0.2.17 OK <--- The NFS share was
> >> reconnected, the "read" call completes successfully.
> >
> > The difference between these timestamps is 27 seconds, which is a lot l=
ess
> > than the "20 minutes" that you quote.  That seems odd.
> >
> Hi Neil,
>=20
> My bad, I had made several attempts and must have copied the wrong dmesg=
=20
> trace. The above happened when I manually reverted the IP config back to=
=20
> its original address (when doing so the driver reconnects immediately).
>=20
> Here is what had happened:
>=20
> [ 1663.940406] nfs: server 10.0.2.17 not responding, still trying
> [ 2712.480325] nfs: server 10.0.2.17 OK
>=20
> > If you adjust
> >     /proc/sys/net/ipv4/tcp_retries2
> >
> > you can reduce the current timeout.
> > See Documentation/networking/ip-sysctl.txt for details on the setting.
> >
> > https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt
> >
> > It claims the default gives an effective timeout of 924 seconds or abou=
t 15
> > minutes.
> >
> > I just tried and the timeout was 1047 seconds. This is probably the next
> > retry after 924 seconds.
> >
> > If I reduce tcp_retries2 to '3' (well below the recommended minimum) I =
get
> > a timeout of 5 seconds.
> > You can possibly find a suitable number that isn't too small...
> >
> That's very interesting! Thank you very much! However, I'm a bit worried=
=20
> when changing the whole TCP stack settings, NFS is only one small chunk=20
> of a much bigger network storage box, so if there are alternative it'll=20
> probably be better. Also I would need a very very small timeout, in the=20
> order of 10-20 secs *max* so that would probably cause other issues=20
> elsewhere, but this is very interesting indeed.
>=20
> > Alternately you could use NFSv4.  It will close the connection on a tim=
eout.
> > In the default config I measure a 78 second timeout, which is probably =
more
> > acceptable.  This number would respond to the timeo mount option.
> > If I set that to 100, I get a 28 second timeout.
> >
> This is great! I had no idea, I will definitely roll NFSv4 and try that.=
=20
> Thanks again for your help!

Actually ... it turns out that NFSv4 shouldn't close the connection early
like that.  It happens due to a bug which is now being fixed :-)

Probably the real problem is that the TCP KEEPALIVE feature isn't working
properly.  NFS configures it so that keep-alives are sent at the 'timeout'
time and the connection should close if a reply is not seen fairly soon.

However TCP does not send keepalives when the are packets in the queue
waiting to go out (which is appropriate) and also doesn't check for timeouts
problem when the queue is full.

I'll post to net-dev asking if I've understood this correctly and will take
the liberty of cc:ing you.

NeilBrown



--Sig_/b.J4DyqDF203HgGC5Jv=dJ4
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCiZpDnsnt1WYoG5AQI0uA//UnE/uVHJfZl+gtt2M3lg8iZPObr0jLMS
4Wn/PrUQEl3dcHc//OA14le1DdYRA+gwHbk62ZFhRGfbqnG6xcZf6TMo/nDEDCLC
jrxTdl/6s8b4mduflap5DjrxuETXQ+9b3xymTfkplWbQN/IgJmp4JWmDiIbUhZam
p/xSJ5LV0aiErnUEACnk7VdxEWrxQS4KhR1EcL4MOOvR+jOuz4f3buviPqCnnMWQ
kiYPVZTX0wGA8MFrME08YcV9UVxQprPvsZnwErEfa7rGgHOkDYIWzUnL8vh4HrUA
ban09qrEXyMz49bMvHr4o5mNJkBrcrc7hsXCry9n4gm4w5ZlOUnA01rd0KAN45A+
geat1g5p7jUi9v1zAX+jk4W/dXWWIWxZrp+upaK+krMORsHSewO/G1F7Pqpd8w2F
zmyy1ZKEN2k4R/RjZ2JxMDWagnTIjlTmClx2w44Pj8FE1CBXfgSozpsd42rmBp5K
y25HRo5Jig1RjM5QZDVG3LrdZun7W/Jkc+0OD3PQW3F/d+Xog8vnFB0AlsUpCHjG
XAemJXkiTp8SHaGOOoKYMnKZgi1tNsyHkzO464rUE7WhYqG9N0U5ywMFahlqXkx/
SrVQyPKOky72e9FTSPMHL04XemmsVw8Y2A/9p4p3W+S/bT7ZLxMS/FSFYpYvDtU1
BOC+m+p59sE=
=RmCT
-----END PGP SIGNATURE-----

--Sig_/b.J4DyqDF203HgGC5Jv=dJ4--
