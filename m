From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch] flock/fcntl bug
Date: Wed, 15 Dec 2004 16:48:16 -0500
Message-ID: <1103147296.1236.7.camel@lade.trondhjem.org>
References: <OF05A12F51.B9794B13-ON88256F6B.0062DC68-88256F6B.0064504D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ceh1W-0004Qo-Gp
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 13:49:30 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ceh1V-0007F5-Ko
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 13:49:30 -0800
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF05A12F51.B9794B13-ON88256F6B.0062DC68-88256F6B.0064504D@us.ibm.com>
Sender: nfs-admin@lists.sourceforge.net
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

on den 15.12.2004 Klokka 10:15 (-0800) skreiv Marc Eshel:
> To fs/locks.c owner
> 
> There is a bug in the unlock of posix locks. If there is an flock held on a
> file that is being closed an unneeded call is made to the file system to do
> an fcntl unlock. In the case of NFS it will be a call to the NFS server
> which is expensive. This patch just checks that it is a posix lock before
> calling the file system.

Hmm... Not sure this is right.

What if the filesystem doesn't use inode->i_flock to bookkeep its locks?
It isn't obliged to do so now...

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
