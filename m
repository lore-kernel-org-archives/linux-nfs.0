From: =?iso-8859-15?Q?Ga=EBl?= Roualland <gael.roualland@oleane.net>
Subject: Re: 2.6.0 -- nfs client runs 15x faster if client app runs as
 root.
Date: Thu, 08 Jan 2004 15:15:43 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FFD660F.1333683F@oleane.net>
References: <34280.141.211.133.197.1073512478.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: ewhiting@amis.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Aeax6-0008Cm-V4
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 06:16:00 -0800
Received: from hal.oleane.net ([62.161.136.5])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Aeax6-0000oF-Bx
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 06:16:00 -0800
To: trond.myklebust@fys.uio.no
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

trond.myklebust@fys.uio.no a =E9crit :
>=20
> > My 2.6.0 nfs clients to a netapps 940 NFS server run very differently
> depending
> > on who the user is. Both tcp and udp mounts seem to show the same beh=
avior.
> > This is very apparent when doing the bonnie putc() tests.
> > nfsstat and tcpdump show a lot of extra setattr calls when running as=
 a
> normal
> > user. I assume this is the reason for the slowdown. Is there a fix? O=
r
> is this the
> > way it is supposed to be?
>=20
> Huh?
> I'm certainly not seeing one setattr call per write on my 2.6 clients. =
Is
> this stock
> 2.6.0 or is it patched? Does 2.6.1-rc2 change anything?

Has the file exec permission set ?
If yes this would look like an earlier problem that seems to still occur
on 2.6.0.
See http://marc.theaimsgroup.com/?l=3Dlinux-nfs&m=3D106966481311224 and
http://marc.theaimsgroup.com/?l=3Dlinux-nfs&m=3D106981736010493.

Ga=EBl.

--=20
Ga=EBl Roualland -+- gael.roualland@oleane.net


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
