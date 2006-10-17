From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [patch 0/4] correct kernel locking for RPC rpc_release
	callbacks
Date: Tue, 17 Oct 2006 10:24:30 -0700
Message-ID: <1161105870.3315.20.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZsgz-0001GR-3a
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 10:25:29 -0700
Received: from e34.co.us.ibm.com ([32.97.110.152])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZsgw-0000I4-Ry
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 10:25:30 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com
	[9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9HHOP0K030986
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 13:24:25 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k9HHOPeg362760
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:25 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k9HHOPgQ015471
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:25 -0600
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9HHOO6g015436
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:25 -0600
To: NFS List <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The following set of patches corrects use of the big kernel lock in
protecting RPC calls and associated call backs.

A problem was noted where nfs_async_unlink_release() was called without
the BKL being held as expected. Chuck Lever and Trond Myklebust noted
that the rpc_release() callback is a recent addition and other callbacks
might also expect the BKL to be held.

With the addition of lock_kernel()/unlock_kernel() around all calls to
the rpc_release() callbacks, there is no need for NFS code to hold the
BKL when making calls to rpc_execute(), rpc_call_sync(), and
rpc_call_async().

Frank Filz



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
