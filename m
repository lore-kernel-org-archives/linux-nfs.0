From: Marc Eshel <eshel@almaden.ibm.com>
Subject: lockd problem
Date: Fri, 5 May 2006 22:01:44 -0700
Message-ID: <OFE9A5A9E8.C1D26EA2-ON88257166.00166EDC-88257166.001B37A9@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FcEq2-0003yu-Fh
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 21:56:18 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FcEq2-0003Gd-IG
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 21:56:18 -0700
Received: from e3.ny.us.ibm.com ([32.97.182.143])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FcEq2-0001kN-7z
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 21:56:18 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k464uBwQ004483
	for <nfs@lists.sourceforge.net>; Sat, 6 May 2006 00:56:11 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k464u7P0250980
	for <nfs@lists.sourceforge.net>; Sat, 6 May 2006 00:56:11 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k464u6tG014474
	for <nfs@lists.sourceforge.net>; Sat, 6 May 2006 00:56:06 -0400
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

Hi Trond,
I see a problem testing lockd with 2.6.16-CITI_NFS4_ALL-2,  I see that you 
made few changes in lockd, so let me describe it and see if can recall any 
changes that might cause the following problem.

I think that the source of the problem is that 2 clients from 2 different 
machine end up with the same fl_pid on the lockd server.

What I see is that client 1 gets a lock, client 2 request the same lock 
and is blocked, client 1 unlock but in the process of unlocking it finds 
the block queued for client 2 and deletes it, by the time 
nlmsvc_notify_blocked() is called the block is gone so there is no grant 
call to the client. Client 2 will retry after 30 seconds and get it if it 
is still free.

May  5 21:01:55 fin20 kernel: lockd: UNLOCK        called
May  5 21:01:55 fin20 kernel: lockd: nlm_lookup_host(090148e3, p=6, v=4)
May  5 21:01:55 fin20 kernel: lockd: get host 9.1.72.227
May  5 21:01:55 fin20 kernel: lockd: nlm_file_lookup (02010001 00000000 
00013eec 15b2e9e4 00013eea 68b34ef5 00000000 00000000)
May  5 21:01:55 fin20 kernel: lockd: found file f58ea880 (count 1)
May  5 21:01:55 fin20 kernel: lockd: nlmsvc_unlock(sda2/81644, pi=6, 
10-29)
May  5 21:01:55 fin20 kernel: lockd: nlmsvc_cancel(sda2/81644, pi=6, 
10-29)
May  5 21:01:55 fin20 kernel: lockd: nlmsvc_lookup_block f=f58ea880 pd=6 
10-29 ty=2
May  5 21:01:55 fin20 kernel: lockd: check f=f58ea880 pd=6 10-29 ty=1 
cookie=97120000
May  5 21:01:55 fin20 kernel: lockd: unlinking block f4d6ca00...
May  5 21:01:55 fin20 kernel: lockd: freeing block f4d6ca00...
May  5 21:01:56 fin20 kernel: lockd: release host 9.1.72.239
May  5 21:01:56 fin20 kernel: lockd: nlm_release_file(f58ea880, ct = 2)
May  5 21:01:56 fin20 kernel: lockd: UNLOCK        status 0

Marc.


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
