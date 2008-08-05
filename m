From: Chuck Lever <chuck.lever@oracle.com>
Subject: [RFC] [PATCH 0/8] nfs-utils rpcbind v3/v4 and IPv6 support sampler
Date: Tue, 05 Aug 2008 14:12:25 -0400
Message-ID: <20080805180004.23104.29661.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:13234 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756137AbYHESNd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Aug 2008 14:13:33 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m75IDUaF032610
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 13:13:31 -0500
Received: from acsmt353.oracle.com (acsmt353.oracle.com [141.146.40.153])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m755lOFC030925
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:30 -0600
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.2/8.14.2) with ESMTP id m75ICPHo023160
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 14:12:25 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Request For Comments/Review

As a taste of what is to come in nfs-utils, and to garner comments on the
work to date, here is a set of eight patches that implement efficent
support for rpcbind v2, v3, and v4 over AF_INET and AF_INET6, and then
make use of this new implementation to update the showmount command to
support IPv6 and use the new rpcbind versions.

The plan is to use this implementation in the [u]mount.nfs[4] commands
as well.

To try it out, you can apply these patches to the latest nfs-utils.  If
you want IPv6 support for the showmount command, in addition to the new
rpcbind versions, configure nfs-utils with "--enable-ipv6".

If you are time-limited, please have a look at just the first two patches.
These introduce the new getport() implementation.

For the curious, a full set of client-side nfs-utils patches (minus IPv6
support in rpc.statd) is available in the usual place:

  http://git.linux-nfs.org/?p=cel/nfs-utils.git;a=summary

---

Chuck Lever (8):
      showmount: support querying IPv6 servers
      showmount command: move logic to acquire RPC client handle out of main()
      showmount: Remove unused local getport() implementation
      showmount command: call nfs_getport instead of local getport
      showmount command: clean up error returns from connect_nb()
      showmount: destroy RPC client when finished
      nfs-utils: Create rpcbind client utility functions
      nfs-utils: Add AF_INET6-capable API to acquire an RPC CLIENT *


 support/include/nfsrpc.h    |  119 ++++++
 support/nfs/Makefile.am     |    2 
 support/nfs/getport.c       |  871 +++++++++++++++++++++++++++++++++++++++++++
 support/nfs/rpc_socket.c    |  467 +++++++++++++++++++++++
 utils/showmount/showmount.c |  260 +++++--------
 5 files changed, 1563 insertions(+), 156 deletions(-)
 create mode 100644 support/include/nfsrpc.h
 create mode 100644 support/nfs/getport.c
 create mode 100644 support/nfs/rpc_socket.c

-- 
Chuck Lever
