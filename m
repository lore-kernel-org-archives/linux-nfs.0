From: Juergen Sauer <juergen.sauer@automatix.de>
Subject: Re: Journaling FileSystems w/ NFS
Date: Fri, 20 Sep 2002 19:17:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200209201917.38085.juergen.sauer@automatix.de>
References: <Pine.LNX.4.33.0209201145290.16674-100000@node1.nacs.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from www.automatix.de ([212.4.161.35] helo=mail.automatix.de)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sRRw-0008EH-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 10:20:16 -0700
Received: from uucp by mail.automatix.de with local-bsmtp (Exim 3.36 #1)
	id 17sRT7-0003gQ-00
	for nfs@lists.sourceforge.net; Fri, 20 Sep 2002 19:21:29 +0200
To: Greg Boehnlein <damin@nacs.net>,
 <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.33.0209201145290.16674-100000@node1.nacs.net>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Am Freitag, 20. September 2002 17:48 schrieb Greg Boehnlein:
> Hello,
> 	Can someone point me to a FAQ on which is the best solution for
> running a Journalized Filesystem with NFS support under Linux? We've
> tried deploying JFS with RedHat 7.3 and NFS and have run into problems.
> From my investigation, it appears that XFS is our best option for
> running NFS with +2gig file size support.

Full Ack. We are runneing here somwhat >6 TB NFS Servers  with XFS.
(Applications: NFS, Samba, SapDB) XFS ist nearly unbraekable.

The worst problem we had was with the bleeding edge Kernel 2.4.19 
from the CVS sources in a test box, where a log-replay-race coused a 
singular kernal crash. After rebooting/reseting this box, all was fine.

The log-replay-race condition isr IMHO solved.

mfG
	Jojo

- -- 
Jürgen Sauer - AutomatiX GmbH, +49-4209-4699, jojo@automatix.de **
** Das Linux Systemhaus - Service - Support - Server - Lösungen **
http://www.automatix.de to Mail me: remove: -not-for-spawm-     **
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iEYEARECAAYFAj2LWDIACgkQW7UKI9EqarGGgACgsZnc4Se43Z92MKvW7s6fL2FS
zhMAoJ1coSMiZFmfzLwhOPGPgqgWr8lQ
=8Zgy
-----END PGP SIGNATURE-----



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
