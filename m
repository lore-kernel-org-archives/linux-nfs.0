From: Norbert Preining <preining@logic.at>
Subject: Sharing /var/spool/mail, locking, which versions are safe?
Date: Mon, 1 Jul 2002 18:09:08 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020701160908.GC27263@alpha.logic.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from alpha.logic.tuwien.ac.at ([128.130.175.20])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17P3jp-0003Fg-00
	for <nfs@lists.sourceforge.net>; Mon, 01 Jul 2002 09:09:17 -0700
Received: (from preining@localhost)
	by alpha.logic.tuwien.ac.at (8.11.6/8.11.6) id g61G98c15340
	for nfs@lists.sourceforge.net; Mon, 1 Jul 2002 18:09:08 +0200
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi all!

For the zoo of diskless clients (and brainless users ;-) i want to
share /var/spool/mail via nfs. We had problems with locking on=20
older kernel version (2.2.16) and corrupted mboxes (sendmail and
mua).=20

Which version of linux kernel (and of nfs) are safe for this purpose?

At them moment we are updating the server to a debian woody with=20
2.2.20 (and up to 2.4.X), clients are the same. Is this a possible
combination, what else has to be taken into account?

Thanks a lot for any suggestions and PLEASE send me a Cc since I am
not subscribed to the list. Thanks a lot.

Best wishes

Norbert

-------------------------------------------------------------------------=
------
Norbert Preining <preining AT logic DOT at>         Technische Universit=E4=
t Wien
gpg DSA: 0x09C5B094      fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 09C=
5 B094
-------------------------------------------------------------------------=
------
WIVENHOE (n.)

The cry of alacrity with which a sprightly eighty-year-old breaks the
ice on the lake when going for a swim on Christmas Eve.

			--- Douglas Adams, The Meaning of Liff=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
