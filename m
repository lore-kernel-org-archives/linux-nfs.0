From: Bernd Schubert <bernd-schubert@web.de>
Subject: nfsd-fh: found a name that I didn't expect:
Date: Fri, 14 Mar 2003 18:02:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200303141802.24284.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18tsZq-0002uj-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Mar 2003 09:02:38 -0800
Received: from euklid.pci.uni-heidelberg.de (mail@euklid.pci.uni-heidelberg.de [129.206.21.104])
	by relay.uni-heidelberg.de (8.12.8/8.12.8) with ESMTP id h2EH2PvW003785
	for <nfs@lists.sourceforge.net>; Fri, 14 Mar 2003 18:02:25 +0100 (MET)
Received: from bernd by euklid.pci.uni-heidelberg.de with local (Exim 3.36 #1 (Debian))
	id 18tsZc-0005yR-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Mar 2003 18:02:24 +0100
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

Hi,

on our fileserver we sometimes get a message like this:

coulomb kernel: nfsd-fh: found a name that I didn't expect:=20
servicetypes/kdeveloplanguagesupport.desktop

What does this mean?

System is a linux-2.4.19 patched with all the patches that went into 2.4.20=
=20
except the tcp ones (I know we should probably update, but we never reboote=
d=20
ever since).

Thanks in advance,=09
	Bernd

=2D-=20
Bernd Schubert
Physikalisch Chemisches Institut
Abt. Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
