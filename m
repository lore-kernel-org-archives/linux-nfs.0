From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC]: ESTALE is not a permanent error
Date: Thu, 23 Sep 2004 01:06:57 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095926816.6871.37.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435E85A@lavender-fe.eng.netapp.com>
	 <1095924422.6871.9.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAOdU-0005A7-D0
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 01:07:28 -0700
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CAOdS-0004Q6-S2
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 01:07:28 -0700
To: "Lever, Charles" <cel@netapp.com>
In-Reply-To: <1095924422.6871.9.camel@lade.trondhjem.org>
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

P=E5 to , 23/09/2004 klokka 00:27, skreiv Trond Myklebust:

> Honestly, if the server returns ESTALE, then we do *NOT TRUST* that the
> inode resulting from the "temporary" situation is the same as the inode
> that existed before.

To clarify (once again!) what I mean here:

 If the client receives an ESTALE error, then it will drop all pending
reads/writes like a stone, so it is not as if this is an error that the
kernel can recover from automatically. Better that the customer be told
right up front that something stupid has happened on the server, and it
is up to them to fix the problem manually.

Trond



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
