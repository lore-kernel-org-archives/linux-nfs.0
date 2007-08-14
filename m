From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Tue, 14 Aug 2007 09:58:41 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708140923370.3964@maggie.lkpg.cendio.se>
References: <46B37CDE.1070904@redhat.com>
	<Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
	<46C05C40.30707@redhat.com>
	<Pine.LNX.4.64.0708131555330.15782@maggie.lkpg.cendio.se>
	<1187021560.6628.7.camel@heimdal.trondhjem.org>
	<1187022103.6628.12.camel@heimdal.trondhjem.org>
	<Pine.LNX.4.64.0708131838580.19529@maggie.lkpg.cendio.se>
	<1187024268.6628.33.camel@heimdal.trondhjem.org>
	<Pine.LNX.4.64.0708131939160.20652@maggie.lkpg.cendio.se>
	<1187033724.6628.82.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-547090719-1187077236=:3964"
Cc: Peter Staubach <staubach@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>, drepper@redhat.com
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKrIf-00025b-0U
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 00:58:49 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKrIf-0000di-BW
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 00:58:52 -0700
In-Reply-To: <1187033724.6628.82.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-547090719-1187077236=:3964
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0708140949351.3964@maggie.lkpg.cendio.se>

On Mon, 13 Aug 2007, Trond Myklebust wrote:

> > > If it isn't capable of dealing with the possibility of EOVERFLOW, the=
n
> > > it is violating the Single Unix Spec.
> >=20
> > What can an app do, besides displaying a good error message? There's no=
=20
> > way to "deal" with EOVERFLOW that makes the user happy.=20
>=20
> So you are saying it should never have been defined in the first place?

No, it might be useful from time to time, on some systems.=20

For example, the previous situation was that you got EOVERFLOW on 64 bit=20
kernels but truncated inode numbers on 32 bit kernels. I think this was a=
=20
fairly good compromise - customers had a choice. Typically, you select a=20
32 bit kernel not because your hardware cannot do 64 bits, but because you=
=20
want maximum compatibility with old apps. So the approach with keep=20
truncating on 32 bit kernels made sense.=20

Again, if would be even better if the behaviour could be selected runtime=
=20
or boot-time. A patch which simply changes this unconditionally is a=20
regression, IMHO.


> > I can't see how a lack of LFS (of a binary) is a violation of SUS or=20
> > POSIX. Linux Standard Base requires that a platform provides LFS suppor=
t,=20
> > but it doesn't deprecate or forbid the non-LFS API functions.
>=20
> If you are using the correct types, then recompiling with
> -D_FILE_OFFSET_BITS=3D64 should be sufficient to enable LFS-compliant
> behaviour. Portability was the reason for defining those types in the
> first place.

You shouldn't be required to recompile.=20


> > Recompiling is almost never trivial. OpenOffice.org is just one example=
 of=20
> > this. KDE is another. And sometimes the source is not available.=20
>=20
> Recompiling packages like OpenOffice.org is the bread-and-butter
> business of Linux distributors.

Still, OO is not recompiled in RHEL5.=20

In my opinion, it's also wrong to assume that all software running on a=20
certain system is compiled by the distribution maker. This is somewhat of=
=20
a Debian approach: all software should be included in the distribution, or=
=20
may otherwise fail. Wrong, IMHO.=20


> > I still haven't understood what kind of functionality you are "sick and=
=20
> > tired of having to constantly postpone", that requires EOVERFLOW in 32 =
bit=20
> > non-LFS land.=20
>=20
> The ability to supply the full 64-bit inode numbers to actual LFS
> compliant applications.
> LFS-aware backup apps, for instance, still cannot trust the inode number
> to tell them whether or not two directory entries are actually hard
> links to the same file. That would be pretty much the entire reason for
> wanting to look at the st_ino variable in the first place.

LFS-aware applications running on 32 bit platforms needs to understand=20
that the world is not yet perfect. Even if 2.6.24 would stop truncating,=20
there are hundreds of earlier kernel versions in use, which will probably=
=20
still be in use for several more years from now.=20

The backup application can take some extra care, for example, by verifying=
=20
st_size, st_mtime and perhaps a few bytes of the file as well. Not rocket=
=20
science. Probably done anyway, to detect if the file has been changed=20
during backup.=20

Still, I'm not opposing to enable full 64 bit inode numbers for LFS apps,=
=20
as long as non-LFS apps can still run. I'm no glibc expert, but as I=20
understand it, it *should* be possible to fix this in glibc. Have you=20
tried talking to the glibc developers about this?=20

Another idea is a runtime kernel configuration option, say either booting=
=20
with a command line option. This solution could be useful even if future=20
glibc versions solves this issue, to work around the problem on systems=20
with old/current versions of glibc. What do you think of this?


Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-547090719-1187077236=:3964
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--789237761-547090719-1187077236=:3964
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-547090719-1187077236=:3964--
