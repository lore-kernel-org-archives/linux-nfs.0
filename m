From: "Igor Rychkov" <rych@chem.scphys.kyoto-u.ac.jp>
Subject: re-exporting: exportfs gives Invalid argument
Date: Thu, 31 Oct 2002 20:17:11 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <ACEAKKINMBBEGMOOHHNAGEDPCGAA.rych@chem.scphys.kyoto-u.ac.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from radish.scphys.kyoto-u.ac.jp ([130.54.54.131])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187DEz-0008Vh-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 03:11:58 -0800
Received: from tarte (srv01.scphys.kyoto-u.ac.jp [130.54.55.203])
	by radish.scphys.kyoto-u.ac.jp (8.9.3/3.7Wpl2-00022500) with SMTP id UAA15828
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 20:02:56 +0900
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

Hi,
I have the following situation: "A" client of network "N" needs file =
access to the "C" server of network "M", and there's "B" with 2 network =
cards. The computers have RedHat 7.2 or 7.3 installed.

B mounts Cshare on /Bshare/Cshare

B's /etc/exports includes the following lines:

/Bshare              A(rw,async,no_subtree_check,no_root_squash)
/Bshare/Cshare       A(rw,nohide,async,no_subtree_check,no_root_squash)

then=20
B:# exportfs -ra
gives
A.N:/Bshare/Cshare: Invalid argument

Now I remember that one cannot "export a directory and an ancestor of =
that directory on the same filesystem to any one host". Yes, =
/Bshare/Cshare was created as a subdirectory, but wasn't it replaced =
when mounting? And isn't the manual requires extra lines in /etc/exports =
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
