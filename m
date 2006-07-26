From: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
Subject: (no subject)
Date: Wed, 26 Jul 2006 12:47:35 +0200
Message-ID: <200607261247.35653.bernd.schubert@pci.uni-heidelberg.de>
Reply-To: bernd-schubert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5gvf-0005Bh-KC
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 03:47:55 -0700
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5gve-0007H6-9c
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 03:47:51 -0700
To: nfs@lists.sourceforge.net
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

Hi,

I'm just looking into a nfs i/o error problem. The server for /etc is unfs3 =

and the client is 2.6.16. I need some help regarding the nfs protocol.

Probably after updating mozilla /etc/mozilla/mozillarc was rewritten, I als=
o =

guess the inode was recycled.

A 'ls /etc/mozilla/mozillarc' worked fine and showed the correct results.
A 'cat /etc/mozilla/mozillarc' gave i/o errors.

Ethereal shows that the getattr gives the correct results, but the read cal=
l =

gives an NFS3ERR_STALE. =

Should the client in this case drop its filehandle cache and entirely =

re-request the file from the server, or is the given i/o error ok?

>From the point of the server, I guess, it already should return the =

NFS3ERR_STALE for the getattr call, shouldn't it? I will look into the =

sources to see why it didn't. (unfs3 was compiled with inode generation =

number support).

After an 'echo 3 > /proc/sys/vm/drop_caches' the problem was solved for now=
, =

of course.


Thanks in advance,
	Bernd



-- =

Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
