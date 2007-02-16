From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: WebNFS support
Date: Fri, 16 Feb 2007 15:49:50 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0702161539470.2004@maggie.lkpg.cendio.se>
References: <45D5FC14.8E99.00F4.0@novell.com>
	<Pine.LNX.4.64.0702161427080.32604@maggie.lkpg.cendio.se>
	<200702161514.50493.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-250869244-1171637390=:2004"
Cc: nfs@lists.sourceforge.net
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HI4PT-00062W-Ok
	for nfs@lists.sourceforge.net; Fri, 16 Feb 2007 06:50:03 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HI4PT-0006qh-9y
	for nfs@lists.sourceforge.net; Fri, 16 Feb 2007 06:50:05 -0800
In-Reply-To: <200702161514.50493.olaf.kirch@oracle.com>
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

--789237761-250869244-1171637390=:2004
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 16 Feb 2007, Olaf Kirch wrote:

> On Friday 16 February 2007 14:31, Peter =C3=85strand wrote:
> > I have some plans to implement WebNFS support in userspace server unfs3=
,
> > though. Since it can already run the NFS and MOUNT protocol on the same
> > TCP port, I haven't considered WebNFS support critical.
>=20
> At some point in the very distant past I added WebNFS support to
> unfsd. There was zero interest in it. I think webnfs was an Internet
> bubble idea, ie very trendy but devoid of any technical use.
> May it rest in peace.

I'm not sure I agree. Although you *can* use plain NFSv3 in a way that's=20
pretty close to WebNFS (just one TCP port, no portmapper etc), the WebNFS=
=20
spec actually specifies & standardizes how this should be done. The NFS=20
URL is also nice.=20

I think it's somewhat sad that WebNFS (or WebNFS-like NFSv3 setups)=20
didn't become more successful. Instead, folks are using protocols like=20
FTP, SFTP, SCP, WebDav, CIFS etc in contexts where NFSv3 could do the job=
=20
equally well or even better.=20

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-250869244-1171637390=:2004
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-250869244-1171637390=:2004
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-250869244-1171637390=:2004--
