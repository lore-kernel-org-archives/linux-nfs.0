From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: 2.4.19 NFSALL performance oddity
Date: Tue, 8 Oct 2002 00:20:55 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15778.2247.997239.729461@charged.uio.no>
References: <5CA6F03EF05E0046AC5594562398B91653BCAE@poexmb3.conoco.net>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ygFL-0005lI-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Oct 2002 15:21:03 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B91653BCAE@poexmb3.conoco.net>
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


FYI: I updated 2.4.19-NFS_ALL on Saturday with a couple of
bugfixes. Among them was one which fixes a queueing bottleneck when a
timeout+resend occurs.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
