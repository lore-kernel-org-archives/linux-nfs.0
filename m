From: "Steve M. Robbins" <steven.robbins@videotron.ca>
Subject: how experimental is the seekdir patch
Date: Mon, 28 Apr 2003 15:27:51 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030428192751.GA19752@nyongwa.montreal.qc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relais.videotron.ca ([24.201.245.36] helo=VL-MS-MR001.sc1.videotron.ca)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AEJ0-0003hx-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Apr 2003 12:28:50 -0700
Received: from riemann.nyongwa.montreal.qc.ca ([24.202.211.97])
 by VL-MS-MR001.sc1.videotron.ca
 (iPlanet Messaging Server 5.2 HotFix 1.10 (built Jan 23 2003))
 with ESMTP id <0HE200IQVJEYQG@VL-MS-MR001.sc1.videotron.ca> for
 nfs@lists.sourceforge.net; Mon, 28 Apr 2003 15:28:10 -0400 (EDT)
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

Hello,

I was having problems with mounting a filesystem exported by an IRIX
server that appear to be fixed by the "seekdir.dif" patch located at

    http://www.fys.uio.no/~trondmy/src/2.4.21-pre6/

According to the NFS FAQ, this problem has been known since 2.4.17.
Yet the patch does not appear in the 2.4.21-rc1 kernel.  Why not?

FWIW, my servers use the "32bitclients" export option.  But, contrary
to the patch notes, I see the problem using NFS version 2.

-S


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
