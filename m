From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: nfs over ssh : invalid protocol
Date: Mon, 8 Jan 2007 22:25:53 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0701082221500.16141@maggie.lkpg.cendio.se>
References: <36900.193.178.136.53.1168256160.squirrel@altern.org>
	<f992145d0701080534r3b979de3yea805c59509ad672@mail.gmail.com>
	<60484.193.178.136.53.1168269481.squirrel@altern.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="789237761-1914871903-1168291553=:16141"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H420Q-0000bv-It
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 13:26:10 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H420N-0004cO-VH
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 13:26:09 -0800
To: oudoubah@altern.org
In-Reply-To: <60484.193.178.136.53.1168269481.squirrel@altern.org>
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

--789237761-1914871903-1168291553=:16141
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 8 Jan 2007, oudoubah@altern.org wrote:

> >> ssh -f -L38000:10.0.0.1:2049 -L38001:10.0.0.1:32767 -l save 10.0.0.1
> >> sleep 60
> >> mount -t nfs -o
> >> tcp,sync,rsize=3D8192,wsize=3D8192,soft,timeo=3D60,port=3D38000,mountp=
ort=3D38001
> >> localhost:/images /tmp/save.11601
> >> mount to NFS server 'localhost' failed: possible invalid protocol.
>=20
> On the nfs server :
> #cat /etc/sysconfig/nfs
> STATD_PORT=3D32765
> STATD_OUTGOING_PORT=3D32766
> MOUNTD_PORT=3D32767
> LOCKD_TCPPORT=3D32768
> RQUOTAD_PORT=3D32769

Is it really possible to use statd/lockd over SSH? Otherwise, I would try=
=20
mounting with "nolock".=20

If that fails, a Wireshark trace should give you a hint. Another hint is=20
that some versions of Fedora and RHEL have a broken mount command (unless=
=20
the updates are installed), see=20
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D140016.

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-1914871903-1168291553=:16141
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-1914871903-1168291553=:16141
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-1914871903-1168291553=:16141--
