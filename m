From: "Jeremy Kusnetz" <JKusnetz@nrtc.org>
Subject: RE: Chrooted BIND broke on NFS server between kernel 2.4.21 and 2.4.22
Date: Fri, 12 Dec 2003 16:55:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F7F4B5EA9EBD414D8A0091E80389450569D3CE@exchange.nrtc.coop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUvGW-0003Tl-Jr
	for nfs@lists.sourceforge.net; Fri, 12 Dec 2003 13:56:04 -0800
Received: from outmail.nrtc.org ([204.145.144.17] helo=exchange.nrtc.coop)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AUvGV-0003Vy-JV
	for nfs@lists.sourceforge.net; Fri, 12 Dec 2003 13:56:03 -0800
To: "Jeremy Kusnetz" <JKusnetz@nrtc.org>,
	<nfs@lists.sourceforge.net>
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

> So there must have been some change between 2.4.21 and 2.4.22=20
> that broke this functionality.  Any ideas?

I've done some more digging, apparently things broke with 2.4.22-pre1

In the kernel changelogs, the only NFS changes I see for pre1 are:

Neil Brown <neilb@cse.unsw.edu.au>:
  o Handle concurrent failure of two drives in raid5
  o Fix bug in /proc/mdstat
  o Fix the check for execute permissions of parent directories in NFSd
  o kNFSd: SVC sockets don't disable Nagle
  o kNFSd: TCP nfsd connection hangs when partial record header is =
received
  o kNFSd: Make sure an early close on a nfs/tcp connection is handled =
properly


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
