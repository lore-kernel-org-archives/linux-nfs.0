From: =?iso-8859-1?Q?Peter_=C5strand?= <peter@cendio.se>
Subject: broken umount -f
Date: Fri, 27 Dec 2002 17:44:06 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0212271736030.4143-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.cendio.se ([193.12.253.66])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Rxap-0006in-00
	for <nfs@lists.sourceforge.net>; Fri, 27 Dec 2002 08:44:15 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (8.11.6/8.11.6) with ESMTP id gBRGi7F04764
	for <nfs@lists.sourceforge.net>; Fri, 27 Dec 2002 17:44:07 +0100
Received: from localhost (localhost [127.0.0.1])
	by maggie.lkpg.cendio.se (Postfix) with ESMTP id E1A16177BA3
	for <nfs@lists.sourceforge.net>; Fri, 27 Dec 2002 17:44:06 +0100 (CET)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


For as long as I remember, umount -f has been broken. I got a reminder of
this fact today when we took an older NFS server out of use. I had to
reboot almost all machines that had mounts from this server. Not nice.=20

Anyone knows why -f does not work? When I try, I get:

# umount -f /import/applix
Cannot MOUNTPROG RPC: RPC: Port mapper failure - RPC: Unable to receive
umount2: Device or resource busy
umount: /import/applix: device is busy

lsof and fuser hangs, as do "df" and "du". Really frustrating. It's not=20
even possible to cleanly reboot the system, since RedHats shutdown script=
s=20
wants to unmount NFS fs's.=20

I'm not exactly sure I understand what -f is supposed to do. Is it correc=
t
that it is supposed to unmount without contacting the NFS server? I assum=
e
that I still have to make sure no processes are using the FS? Would it be
possible to add a "-9" flag (or something like that) that kills off all
processes that uses the NFS fs automatically?

(I'm using all kinds of RedHat Linux versions, from 5.0 up to 7.3. From=20
what I can tell, this problems exists in all versions.)

--=20
Peter =C5strand                Telephone: +46-13-21 46 00
Cendio Systems               E-mail: peter@cendio.se
Teknikringen 3
583 30 Link=F6ping




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
