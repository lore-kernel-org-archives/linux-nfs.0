From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] First subset of nfs-utils IPv6 support
Date: Wed, 29 Oct 2008 13:22:07 -0400
Message-ID: <20081029172134.19663.13493.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:20248 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372AbYJ2RWZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Oct 2008 13:22:25 -0400
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m9THMM43009743
	for <linux-nfs@vger.kernel.org>; Wed, 29 Oct 2008 12:22:22 -0500
Received: from acsmt354.oracle.com (acsmt354.oracle.com [141.146.40.154])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9TA00Sn024258
	for <linux-nfs@vger.kernel.org>; Wed, 29 Oct 2008 11:22:21 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9THM7Ut019695
	for <linux-nfs@vger.kernel.org>; Wed, 29 Oct 2008 13:22:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

I sent these out yesterday, but I haven't seen them on the list or in
mail archives.  Ah.  It's because I didn't copy the list!  So, here
goes.

These two patches introduce a set of library functions that replace the
separate AF_INET-only implementations in each component of nfs-utils
(mount.nfs, showmount, sm-notify, etc) of GETPORT with a common shared
implementation that supports both PMAP_GETPORT and RPCB_GETADDR, and
both AF_INET and AF_INET6.  Subsequent patches will convert each
component to use these.

These should build and operate correctly on systems without any trace
of libtirpc libraries or headers.  On such systems, only PMAP_GETPORT
and AF_INET is supported.

I think these are ready to be included in nfs-utils, so let's start the
review process.

---

Chuck Lever (2):
      nfs-utils: Introduce rpcbind client utility functions
      nfs-utils: Add AF_INET6-capable API to acquire an RPC CLIENT *


 configure.ac             |    6 
 support/include/nfsrpc.h |  141 +++++++
 support/nfs/Makefile.am  |    2 
 support/nfs/getport.c    |  965 ++++++++++++++++++++++++++++++++++++++++++++++
 support/nfs/rpc_socket.c |  528 +++++++++++++++++++++++++
 5 files changed, 1641 insertions(+), 1 deletions(-)
 create mode 100644 support/include/nfsrpc.h
 create mode 100644 support/nfs/getport.c
 create mode 100644 support/nfs/rpc_socket.c

-- 
Chuck Lever
