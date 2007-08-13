From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Mon, 13 Aug 2007 19:54:27 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708131939160.20652@maggie.lkpg.cendio.se>
References: <46B37CDE.1070904@redhat.com>
	<Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
	<46C05C40.30707@redhat.com>
	<Pine.LNX.4.64.0708131555330.15782@maggie.lkpg.cendio.se>
	<1187021560.6628.7.camel@heimdal.trondhjem.org>
	<1187022103.6628.12.camel@heimdal.trondhjem.org>
	<Pine.LNX.4.64.0708131838580.19529@maggie.lkpg.cendio.se>
	<1187024268.6628.33.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="789237761-1894071575-1187026978=:20652"
Cc: Peter Staubach <staubach@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKe7f-0001QR-P6
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 10:54:35 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKe7g-0007bN-Go
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 10:54:40 -0700
In-Reply-To: <1187024268.6628.33.camel@heimdal.trondhjem.org>
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

--789237761-1894071575-1187026978=:20652
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0708131943011.20652@maggie.lkpg.cendio.se>

On Mon, 13 Aug 2007, Trond Myklebust wrote:

> > >functionality just because application writers aren't capable of codin=
g=20
> > >up standards compliant programs.
> >=20
> > I don't understand this logic. What kind of standard is a 32 bit non-LF=
S=20
> > app breaking?
>=20
> If it isn't capable of dealing with the possibility of EOVERFLOW, then
> it is violating the Single Unix Spec.

What can an app do, besides displaying a good error message? There's no=20
way to "deal" with EOVERFLOW that makes the user happy.=20


> If it is making assumptions about the size of st_ino, then it is
> violating not only SUS, but also POSIX, which does now mandate the use
> of the specific types:
>=20
>   http://www.opengroup.org/onlinepubs/009695399/toc.htm

Even if the application is using specific types and takes care not to make=
=20
assumptions about sizes, EOVERFLOW can occur. It can happen either because=
=20
it's not built with LFS on platforms where LFS is not default (right?), or=
=20
because it was built on another system, perhaps lacking LFS entirely.=20

I can't see how a lack of LFS (of a binary) is a violation of SUS or=20
POSIX. Linux Standard Base requires that a platform provides LFS support,=
=20
but it doesn't deprecate or forbid the non-LFS API functions.


> > What kind of functionality are you thinking of? 100% guaranteed unique=
=20
> > inode numbers, assuming that all fileids are unique? You already have t=
hat=20
> > on 64 bit systems, and as far as I understand, it should be possible to=
=20
> > get this for LFS-aware 32 bit apps as well.=20
> >=20
> > Or are you referring to 100% guaranteed unique inode numbers for 32 bit=
=20
> > apps, LFS aware or not? Why is this important?
> >=20
> > Or are you thinking of some other functionality?
>=20
> If the program is written in a manner that is POSIX compliant (i.e. uses
> the correct types) then recompiling for a 64-bit LFS environment is
> trivial.

Recompiling is almost never trivial. OpenOffice.org is just one example of=
=20
this. KDE is another. And sometimes the source is not available.=20

I still haven't understood what kind of functionality you are "sick and=20
tired of having to constantly postpone", that requires EOVERFLOW in 32 bit=
=20
non-LFS land.=20

Rgds,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-1894071575-1187026978=:20652
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--789237761-1894071575-1187026978=:20652
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-1894071575-1187026978=:20652--
