From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: re-exporting: exportfs gives Invalid argument
Date: Thu, 31 Oct 2002 13:06:33 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C775E@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <rych@chem.scphys.kyoto-u.ac.jp>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187KeU-00021F-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 11:06:46 -0800
To: <nfs@lists.sourceforge.net>
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


Re-exporting is not allowed/supported on the kernel nfsd in
linux.    Most other versions on Unix also don't support this=20
sort of thing.

                               Roger


From: "Igor Rychkov" <rych@chem.scphys.kyoto-u.ac.jp>
To: <nfs@lists.sourceforge.net>
Date: Thu, 31 Oct 2002 20:17:11 +0900
Subject: [NFS] re-exporting: exportfs gives Invalid argument

Hi,
I have the following situation: "A" client of network "N" needs file =3D
access to the "C" server of network "M", and there's "B" with 2 network =
=3D
cards. The computers have RedHat 7.2 or 7.3 installed.

B mounts Cshare on /Bshare/Cshare

B's /etc/exports includes the following lines:

/Bshare              A(rw,async,no_subtree_check,no_root_squash)
/Bshare/Cshare       A(rw,nohide,async,no_subtree_check,no_root_squash)

then=3D20
B:# exportfs -ra
gives
A.N:/Bshare/Cshare: Invalid argument

Now I remember that one cannot "export a directory and an ancestor of =
=3D
that directory on the same filesystem to any one host". Yes, =3D
/Bshare/Cshare was created as a subdirectory, but wasn't it replaced =3D
when mounting? And isn't the manual requires extra lines in /etc/exports =
=3D
to "nohide" such mounts?

Any hint, please.
Igor




-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
