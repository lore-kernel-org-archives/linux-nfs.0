From: Fabrizio Nesti <nesti@medialab.sissa.it>
Subject: 2.4.20 TCP server + solaris client performance
Date: Mon, 17 Feb 2003 18:36:26 +0100 (MET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.40.0302171823390.26640-100000@bodoni>
Reply-To: Fabrizio Nesti <nesti@medialab.sissa.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from didot.sissa.it ([147.122.2.50])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18kpES-0002f4-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 09:39:08 -0800
Received: from bodoni.sissa.it (bodoni [147.122.2.45])
	by didot.sissa.it (8.9.3+Sun/8.9.3) with ESMTP id SAA16884
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 18:38:38 +0100 (MET)
Received: from localhost (nesti@localhost)
	by bodoni.sissa.it (8.9.3+Sun/8.9.3) with ESMTP id SAA26784
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 18:36:26 +0100 (MET)
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

Hello to everybody.
we are reporting a very low performance for nfs access from Solaris clients
to the linux nfs server on RH8.0. We thought it was udp and upgraded to
kernel 2.4.20.

Now the performance is still low, compared to a solaris server:
	# time gtar xf /var/tmp/cvs-1.11.5.tar
	Writing on Linux_2.4.20> real    0m22.132s
	Writing on Solaris_8>    real    0m7.174s

Both filesystems are mounted with proto=tcp,rsize=32768,wsize=32768.
Snooping the traffic however, it appears that the linux server is not
serving with size=32768, but with a maximum size of 8192.

- Is there a reson for this?
- May this be the reason for the poor performance above?

Thanks in advance,
Fabrizio Nesti


PS: Some snoop traffic:
...
  solaris -> linux  NFS C CREATE3 FH=884D (EXCLUSIVE) check_cvs.in
linux -> solaris    NFS R CREATE3 OK FH=174A
 solaris -> linux   NFS C SETATTR3 FH=174A
linux -> solaris    NFS R SETATTR3 OK
  solaris -> linux  NFS C WRITE3 FH=174A at 0 for 8192 (ASYNC)
  solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849797604 Len=1460
  solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849799064 Len=1460
  solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849800524 Len=1460
  solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849801984 Len=1460
  solaris -> linux  TCP D=2049 S=793 Ack=633960980 Seq=849803444 Len=1056
linux -> solaris    TCP D=793 S=2049 Ack=849804500 Seq=633960980 Len=0
...



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
