From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: Multiple heterogeneous NFS servers on one machine
Date: Mon, 29 May 2006 20:50:14 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0605292046470.13557@maggie.lkpg.cendio.se>
References: <20060529182400.GQ13353@chiark.greenend.org.uk>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1424731465-1148928614=:13557"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fkmop-0006SH-KL
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 11:50:23 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fkmop-0004rB-Hn
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 11:50:23 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fkmoo-0001to-9s
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 11:50:23 -0700
To: Theo Markettos <nfs@markettos.org.uk>
In-Reply-To: <20060529182400.GQ13353@chiark.greenend.org.uk>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1424731465-1148928614=:13557
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable


> I need to run two different NFS servers on the same 2.6 Linux machine. =
 This
> is because I need the --re-export option from Debian's 'nfs-user-server=
'
> package, and I also need an NFS 3 server, for which I'm using Linux's k=
ernel
> mode server.  I've been trying to work out a way of doing this.

> Is it possible to run NFS without portmap?

Sure. With unfs3, just use the "-p" option. You can use the same or=20
different ports for the NFS and MOUNT service. Typically, I run unfs3=20
with:

unfsd -n 4711 -m 4711 -p

When mounting you need to use the port=3D and mountport=3D options.

Kind regards,
--=20
Peter =C5strand		ThinLinc Chief Developer
Cendio			http://www.cendio.se
Teknikringen 3
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-1424731465-1148928614=:13557--


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
