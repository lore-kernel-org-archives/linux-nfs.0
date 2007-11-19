From: "Steven Wilton" <steven.wilton@team.eftel.com.au>
Subject: [NFS] NFS4 locking behaviour
Date: Mon, 19 Nov 2007 16:07:43 +0900
Message-ID: <A9A789A67725D94F88AD7C3CB2AA61020F235C@exch-perth.corporate.eftel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <nfs@lists.sourceforge.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iu0jW-00085N-UD
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 23:07:51 -0800
Received: from staff-gw.eftel.com.au ([203.16.9.138]
	helo=exch-perth.corporate.eftel.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iu0ja-0000Eo-GJ
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 23:07:56 -0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi all,

We've just changed some of our servers over to NFSv4, and we have
noticed that if a program on a NFS client opens a file read-only and
then tries to obtain an exclusive lock on that file, the server logs the
following to the kernel log:

NFSD: preprocess_seqid_op: bad seqid (expected 4, got 5)


And the NFS client logs this corresponding entry to its logs:

NFS: v4 server 10.16.101.2  returned a bad sequence-id error!


Is this the desired behaviour?  Or should the NFS server allow the
exclusive lock to be acquired by a process that has opened a file
read-only?  (or has this been fixed in a newer release of the nfs server
code?)  The NFS server is using the standard Debian kernel for Etch
(2.6.18-5-amd64).

The NFS clients are running a variety of kernels as follows:
2.6.22-2-amd64 (from www.backports.org)
2.6.23-1-amd64 (from
http://kernel-archive.buildserver.net/debian-kernel/pool/main/l/linux-2.
6/)
2.6.18-5-686   (current kernel from Etch)




Steven

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

