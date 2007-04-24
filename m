From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Tue, 24 Apr 2007 21:09:21 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0704242053510.32688@maggie.lkpg.cendio.se>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240908.39672.olaf.kirch@oracle.com>
	<20070424161027.GA30213@infradead.org> <462E38B9.5020808@RedHat.com>
	<20070424171708.GA7936@infradead.org> <462E43CC.6040806@RedHat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="789237761-2147413521-1177440872=:32688"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgQOI-0008SC-Qg
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 12:09:31 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgQOJ-0004fS-Sz
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 12:09:33 -0700
In-Reply-To: <462E43CC.6040806@RedHat.com>
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

--789237761-2147413521-1177440872=:32688
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0704242057501.32688@maggie.lkpg.cendio.se>

On Tue, 24 Apr 2007, Steve Dickson wrote:

> > Well, even with a separate library it's probably better to
> > start out with the glibc code to bug to bug compatible.
> In theory yes...  but unfortunately Transport Independent
> RPC code is much different than the RPC we have in glibc.
> The TI-RPC code deals with things like CLTS and COTS and
> has configuration file that defines how theses CLITS/COTS
> are handled... notions that are completely foreign to
> the current RPC code...
>=20
> Again, I realize this code is very raw, but the only way
> to bring it up to speed (something I really thing we want
> to do) is using it and making it available to the community.

One thing that bothers me is that the current libtirpc[*] is different=20
from other TI-RPC versions. The current version (as far as I understand)=20
is based on a snapshot from FreeBSD, which is turn is based on Suns TIRPC=
=20
2.3. This code is *not* up to date with TI-RPC 2.9 (aka tirpcsrc_99) and=20
certainly not with the latest OpenSolaris version.

Another problem with TI-RPC is that a Windows port seems to be hard.=20
That's one reason why I'm not porting unfs3 to TI-RPC.=20

Getting Linux distributions to ship (the same) version of TI-RPC is a=20
worthwhile goal, but ideally, we should have an upstream project that=20
covers not only Linux, but also, *BSD, OpenSolaris etc. I know it's not=20
going to be easy, but I think it's worth a try.=20

[*]: http://sourceforge.net/projects/libtirpc

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-2147413521-1177440872=:32688
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--789237761-2147413521-1177440872=:32688
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-2147413521-1177440872=:32688--
