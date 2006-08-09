From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 00/25] RPC client transport switch, continued...
Date: Wed, 09 Aug 2006 10:47:16 -0400
Message-ID: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApXg-0008To-8F
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:00:20 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApXg-0001GB-1E
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:00:20 -0700
To: trond.myklebust@fys.uio.no
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

I'd like these 25 patches to be considered for inclusion in 2.6.19.

1.  A patch that increases the minimum allowed port number to avoid a port
    used by some IPMI implementations.

2.  A set of patches that provides a clean API for supporting per-transport 
    RPC bind implementations.  It also improves scalability by replacing the
    single portmapper spinlock with a per-transport bit lock.

3.  A set of patches that replaces the two-call API for instantiating an RPC
    transport with a single-call API that allows for remote addresses of
    arbitrary size.

4.  A set of patches that modifies the NFS client's symlink creation logic
    to use the page cache.  This is the only NFS operation that makes use of
    large RPC buffers; using the page cache instead means it can use small
    RPC buffers now.

Trond, these are patches you reviewed two weeks ago, with some modifications
we've discussed, and one or two minor additions.  Over the past months these
have been tested, in various forms, in many different environments.

Any other comments or review are welcome.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
