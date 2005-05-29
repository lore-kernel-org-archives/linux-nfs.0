From: Leonid Podolny <leonid99@mail.ru>
Subject: Problems with kNFSd 2.6.5
Date: Sun, 29 May 2005 12:18:05 +0300
Message-ID: <429988CD.3040608@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DcJv1-00039N-FH
	for nfs@lists.sourceforge.net; Sun, 29 May 2005 02:17:15 -0700
Received: from mtaout4.barak.net.il ([212.150.49.174])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DcJuy-0005IW-Cf
	for nfs@lists.sourceforge.net; Sun, 29 May 2005 02:17:14 -0700
Received: from [192.168.1.135] ([62.90.35.123])
 by mtaout4.barak.net.il (Sun Java System Messaging Server 6.1 HotFix 0.02
 (built Aug 25 2004)) with ESMTPA id <0IH800IWEVBAY7M0@mtaout4.barak.net.il> for
 nfs@lists.sourceforge.net; Sun, 29 May 2005 12:21:11 +0300 (IDT)
To: nfs@lists.sourceforge.net
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

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,
I'm not sure that this one is a correct list to report such a bug. I
experience a weird issue and I'm not sure whether it's a bug or a
feature. :)
I'm connecting a fedora core 3 (i.e. 2.6.9) client to a sles9 (i.e.
2.6.5) server. Once I perform the following (completely legal) steps,
I'm unable to unmount the disk that was once exported.

1) at the server: mount /dev/sdag1 /tmp/export
2) at the server: exportfs "*:/tmp/export"  -o "rw" #note that this
export is not at the /etc/exports
3) at the client: mount server:/tmp/export /tmp/mountpoint
4) at the client: ls /tmp/mountpoint         #or some other usage
5) at the client: unexport /tmp/mountpoint
6) at the server: exportfs -r			# removes the export, as it is not in
the /etc/exports
7) at the server: umount /dev/sdag1		#fails, though noone uses it.
It looks like that the exportfs -r somehow fails to decrement the usage
count on the block device.


As a totally separate issue, I fail to figure out a conditions, when a
client sends a READDIR instead of a READDIR+. I've found in the sources,
that it happens once a directory size is bigger than 8 pages, but I
tried to gradually remove files to the directory at the server and
failed to return from READDIR to READDIR+.
- --




- ------------------------------------------------------------------------
 Leonid Podolny       |   /"\
                      |   \ /     ASCII Ribbon Campaign
 leonidp(at)gmail.com |    x      Against HTML Mail
 +972-54-5696948      |   / \
- ------------------------------------------------------------------------
PGP fingerprint:      51B2 F1DB 485E 2C48 2E17  94D1 7EC4 E524 B156 B9F0
PGP key:    http://pgp.mit.edu:11371/pks/lookup?op=get&search=0xB156B9F0
- ------------------------------------------------------------------------
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFCmYjNfsTlJLFWufARAtdxAJ4zJcYKltNs9kOetnXk0OZysp7QpACghbZI
lFMELBYrRgLbTPQTmdM5Dmo=
=qzvN
-----END PGP SIGNATURE-----


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
