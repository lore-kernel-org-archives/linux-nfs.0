From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: Linux NFS client against Auspex server crashes
Date: Tue, 21 Jan 2003 09:54:12 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C780A@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18b0jE-0001XC-00
	for <nfs@lists.sourceforge.net>; Tue, 21 Jan 2003 07:54:20 -0800
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

	Guys,

	I have a group I work with that is using Linux 2.4.19,=20
	NFSALL (Oct-Nov timeframe), they are reporting that their machines
	lock up (process space quits responding) on multiple machines running
	almost identical jobs (with almost identical start times) at the about =
same=20
	time.  They are running against a Auspex server of some sort.

	I am having them run similar tests against a raidzone nfs server and
	seeing if that also crashes.

	What kernel/nfs should we try to duplicate this one? =20
	2.4.21pre3+NFSALL?     And I will see if I can get a trace of
	exactly what is happening just before the crash.

					Roger


-------------------------------------------------------
This SF.net email is sponsored by: Scholarships for Techies!
Can't afford IT training? All 2003 ictp students receive scholarships.
Get hands-on training in Microsoft, Cisco, Sun, Linux/UNIX, and more.
www.ictp.com/training/sourceforge.asp
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
