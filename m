From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: [patch] provide non-standard getgrouplist() in
 libnfsidmap when need be
Date: Mon, 26 Mar 2007 16:32:37 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0703261624130.12321@maggie.lkpg.cendio.se>
References: <200703250329.03353.vapier@gentoo.org>
	<1174915365.6838.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-492803860-1174919054=:12321"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVqFZ-0003XO-Ie
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 07:32:45 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HVqFa-000843-EI
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 07:32:47 -0700
In-Reply-To: <1174915365.6838.6.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-492803860-1174919054=:12321
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0703261624411.12321@maggie.lkpg.cendio.se>

On Mon, 26 Mar 2007, Trond Myklebust wrote:

> On Sun, 2007-03-25 at 03:29 -0400, Mike Frysinger wrote:
> > libnfsidmap uses the non-standard function getgrouplist() ... the attac=
hed=20
> > patch takes code from FreeBSD to implement the function based on POSIX=
=20
> > functions when the system libc is not sufficient
> > -mike
>=20
> Why not just modify libnfsidmap to directly use the posix functions?

The traditional way of fetching the list of user groups is to enumerate=20
the entire group database, and then add the groups that the user is a=20
member of. This is *very* slow on systems with a large number of users and=
=20
groups. Many NSS backends, such as nss_ldap, provides a faster API, which=
=20
uses smart LDAP queries instead. initgroups() uses this, and perhaps also
getgroups(). (If not, it needs a fix.)

(As a side note, there's a lot of software out there which enumerates=20
groups the slow way. This includes the OpenSSH server, so if you activate=
=20
the AllowGroups configuration directive, SSH logins takes forever on=20
large systems.)

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-492803860-1174919054=:12321
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-492803860-1174919054=:12321
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-492803860-1174919054=:12321--
