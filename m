From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [PATCH] rpcbind: Change prognum, versnum, minvers, and maxvers in
	progping to rpcprog_t and rpcvers_t from u_long
Date: Wed, 22 Apr 2009 15:36:40 -0700
Message-ID: <1240439800.2246.24.camel@dyn9047022153>
References: <1240436748.2246.9.camel@dyn9047022153>
	 <5FEB87E5-10FA-4586-9E0B-A07139D85A35@oracle.com>
	 <D9F240D4-2B18-4A32-8B86-926727368F13@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS List <linux-nfs@vger.kernel.org>,
	Steve Dickson <SteveD@redhat.com>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:33379 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392AbZDVWbA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Apr 2009 18:31:00 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3MMLo7w014401
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 18:21:50 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3MMUxru198492
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 18:30:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3MMTC4P008574
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 18:29:12 -0400
In-Reply-To: <D9F240D4-2B18-4A32-8B86-926727368F13@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-04-22 at 18:08 -0400, Chuck Lever wrote:
> I take that back.  Replacing u_long with rpcvers_t will work in both  
> cases.  glibc's CLNT_CONTROL expects a u_long here, but TI-RPC expects  
> an u_int32_t.  These match the typedef for rpcvers_t for each of these.
> 
> So, you have to make sure you are building with the headers that go  
> with your RPC library.  The headers in /usr/include/rpc go with glibc,  
> and the headers in /usr/include/tirpc/rpc go with libtirpc.

Ok, here's a patch that implements it that way. It works fine on PPC64.

This fixes a problem where "rpcinfo -T transport host prognum" fails on a PPC64
because CLNT_CONTROL expects the version number to be a 32 bit quantity. u_long
probably works fine on little endian machines, but won't work on big endian
machines.

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
---
 src/rpcinfo.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/src/rpcinfo.c b/src/rpcinfo.c
index 0170f65..c9f51cf 100644
--- a/src/rpcinfo.c
+++ b/src/rpcinfo.c
@@ -1591,7 +1591,8 @@ progping (netid, argc, argv)
   CLIENT *client;
   struct timeval to;
   enum clnt_stat rpc_stat;
-  u_long prognum, versnum, minvers, maxvers;
+  rpcprog_t prognum;
+  rpcvers_t versnum, minvers, maxvers;
   struct rpc_err rpcerr;
   int failure = 0;
   struct netconfig *nconf;
-- 
1.5.2.2



