Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54527 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672Ab3GIDXG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jul 2013 23:23:06 -0400
Date: Tue, 9 Jul 2013 13:22:53 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - RFC]  new "nosharetransport" option for NFS mounts.
Message-ID: <20130709132253.3dd4f90a@notabene.brown>
In-Reply-To: <1373309499.2231.46.camel@leira.trondhjem.org>
References: <20130708095812.355d7cfc@notabene.brown>
	<1373309499.2231.46.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Ju2+KmI9WxrIVjB9fnqbGWk"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Ju2+KmI9WxrIVjB9fnqbGWk
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 8 Jul 2013 18:51:40 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Mon, 2013-07-08 at 09:58 +1000, NeilBrown wrote:
> >=20
> > This patch adds a "nosharetransport" option to allow two different
> > mounts from the same server to use different transports.
> > If the mounts use NFSv4, or are of the same filesystem, then
> > "nosharecache" must be used as well.
>=20
> Won't this interfere with the recently added NFSv4 trunking detection?

Will it?  I googled around a bit but couldn't find anything that tells me
what trunking really was in this context.  Then I found commit 05f4c350ee02=
=20
which makes it quite clear (thanks Chuck!).

Probably the code I wrote could interfere.

>=20
> Also, how will it work with NFSv4.1 sessions? The server will usually
> require a BIND_CONN_TO_SESSION when new TCP connections attempt to
> attach to an existing session.

Why would it attempt to attach to an existing session?  I would hope there
the two different mounts with separate TCP connections would look completely
separate - different transport, different cache, different session.
??

>=20
> > There are at least two circumstances where it might be desirable
> > to use separate transports:
> >=20
> > 1/ If the NFS server can get into a state where it will ignore
> >   requests for one filesystem while servicing request for another,
> >   then using separate connections for the separate filesystems can
> >   stop problems with one affecting access to the other.
> >=20
> >   This is particularly relevant for NetApp filers where one filesystem
> >   has been "suspended".  Requests to that filesystem will be dropped
> >   (rather than the more correct NFS3ERR_JUKEBOX).  This currently
> >   interferes with other filesystems.
>=20
> This is a known issue that really needs to be fixed on the server, not
> on the client. As far as I know, work is already underway to fix this.

I wasn't aware of this, nor were our support people.  I've passed it on so
maybe they can bug Netapp....

>=20
> > 2/ If a very fast network is used with a many-processor client, a
> >   single TCP connection can present a bottle neck which reduces total
> >   throughput.  Using multiple TCP connections (one per mount) removes
> >   the bottleneck.
> >   An alternate workaround is to configure multiple virtual IP
> >   addresses on the server and mount each filesystem from a different
> >   IP.  This is effective (throughput goes up) but an unnecessary
> >   administrative burden.
>=20
> As I understand it, using multiple simultaneous TCP connections between
> the same endpoints also adds a risk that the congestion windows will
> interfere. Do you have numbers to back up the claim of a performance
> improvement?

A customer upgraded from SLES10 (2.6.16 based) to SLES11 (3.0 based) and saw
a slowdown on some large DB jobs of between 1.5 and 2 times (i.e. total time
150% to 200% of what is was before).
After some analysis they created multiple virtual IPs on the server and
mounted the several filesystem each from different IPs and got the
performance back (they see this as a work-around rather than a genuine
solution).
Numbers are like "500MB/s on a single connection, 850MB/sec peaking to
1000MB/sec on multiple connections".

If I can get something more concrete I'll let you know.

As this worked well in 2.6.16 (which doesn't try to share connections) this
is seen as a regression.

On links that are easy to saturate, congestion windows are important and
having a single connection is probably a good idea - so the current default
is certainly correct.
On a 10G ethernet or infiniband connection (where the issue has been
measured) congestion just doesn't seem to be an issue.

Thanks,
NeilBrown


--Sig_/Ju2+KmI9WxrIVjB9fnqbGWk
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUduCDTnsnt1WYoG5AQLZHA//X2FstciOm4aYpc3ossKH1AeSkU2uOsdZ
RKTC3X59Go36EGHsDdaY7o7ufg5p22NWPvWBQaUEm+thDbWidrSGACDDF7jW6knV
f2W9fch8E8KB3q2i6XO/5go+fyrQ/C/l0TzdK7Vs/yjAcmbzqhn3vJCPaKK5J0Jp
qjI/2/qxNsUKHKpHeqa3XPTNka0js7ggvmUUUSDn2GStSWu8ps8x5lHfjtH38opW
dyfQ63oBI/syfJGFG5lLRhmwiukPsAtWwLdcivCK6b8OQ7zk/rVf4XtoIF9/ChHK
R9iivO/9uml31vGM3mZKKlB9GkIkkNPtXVnW4/o4PGTiJO77NouuQc6h2/6Jsoe0
kejobwtBJSLUbO06sbBismliWx1cphtJC+M0BA0VL8FbdqNvud6NhWIbZsFSzxDT
JpeLHQudBiRRR2jPJjv0ZL8SKDeYDKQ5fIzP9KY0Og/fXtPpnmkWBEDMVf9CGUmx
RAXkgXmTdqUoLnzI3NTMMorpfHAILLn8AEXUBOuwuoCNyQlUdDugpXgW/WwlP+Cj
25BMaB7Vmb1AcgDXDjON7IXVk/zhKWRIz1I0ELthrDhbD7Unj2FGoUYOTJKnI4OH
bNQ0VHDjB7Af+3B1VISQVOApCZvCqsfc0jrGetcy1sK5RsC5qvSv94CxXSVwTWme
ItA9HdAzha8=
=7v6S
-----END PGP SIGNATURE-----

--Sig_/Ju2+KmI9WxrIVjB9fnqbGWk--
