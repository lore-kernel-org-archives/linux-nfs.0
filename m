From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [patch] flock/fcntl bug
Date: Wed, 15 Dec 2004 18:16:42 -0800
Message-ID: <OFDB90A431.EDCAD4C3-ON88256F6C.000B5989-88256F6C.000C8438@us.ibm.com>
References: <1103157295.1236.70.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CelIk-0001AS-8R
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 18:23:34 -0800
Received: from e3.ny.us.ibm.com ([32.97.182.143])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CelIj-0002CY-Ik
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 18:23:34 -0800
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBG2NRV8029093
	for <nfs@lists.sourceforge.net>; Wed, 15 Dec 2004 21:23:27 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBG2NRft283580
	for <nfs@lists.sourceforge.net>; Wed, 15 Dec 2004 21:23:27 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBG2NQiZ025694
	for <nfs@lists.sourceforge.net>; Wed, 15 Dec 2004 21:23:26 -0500
In-Reply-To: <1103157295.1236.70.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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



Trond Myklebust <trond.myklebust@fys.uio.no> wrote on 12/15/2004 04:34:55
PM:

> > It would be nice if it didn't have to care but the fact is that right
now
> > there is dependency on the lock state to be in the VFS too for correct
> > operation.

> Then fix the VFS to do the right thing. Move the decision about whether
> or not to do an RPC call or whatever into the filesystem where it
> belongs.

I will be glad to. Please add my patch 'locking for cluster filesystem' so
other users can experiment with their favorite file system and give some
feed back. My patch is getting too big and it is a pain to retrofit it to
constantly changing code. It will than be easier to build small patches for
the specific problem that will arise.

Thanks, Marc.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
