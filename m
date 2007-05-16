From: Baurzhan Ismagulov <ibr@radix50.net>
Subject: flock LOCK_EX hangs
Date: Wed, 16 May 2007 15:12:53 +0200
Message-ID: <20070516131253.GC19167@radix50.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoJJW-0008SI-Uu
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 06:13:10 -0700
Received: from kz-easy.com ([85.214.25.173] helo=almaty.kz-easy.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HoJJW-0007uT-J5
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 06:13:13 -0700
Received: from alatau.radix50.net (dslb-088-064-026-025.pools.arcor-ip.net
	[88.64.26.25]) (authenticated bits=0)
	by almaty.kz-easy.com (8.13.8/8.13.8/Debian-3) with ESMTP id
	l4GDCxZ2006532
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Wed, 16 May 2007 15:13:00 +0200
Received: from alatau.radix50.net (localhost [127.0.0.1])
	by alatau.radix50.net (8.13.8/8.13.8/Debian-3) with ESMTP id
	l4GDCr8c024558
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Wed, 16 May 2007 15:12:53 +0200
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello all,

I'm experiencing problems with the kernel NFS server. The client hangs
on the flock call. This is Debian etch, Linux 2.6.16-1-686-smp, the
server and the client is the same machine. The directory is exported
with rw, no mount options. The lockd kernel thread is present, rpcinfo
-p reports nlockmgr registered, the firewall passes all the traffic
through.

I've googled and searched the list archive, the postings are usually
quite old (only two were from 2006 and referred to Linux 2.6), and I
couldn't see how I could further analyze the problem. I've also tried
mounting with nolock, but this apparently makes flock / fcntl to fail,
since the tools I use (automake and debootstrap, although I checked this
only with the latter) exited with an error code, and I rely upon it.

How can I fix the problem?

Thanks in advance,
-- 
Baurzhan Ismagulov
http://www.kz-easy.com/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
