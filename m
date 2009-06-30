Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:21456
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752670AbZF3RDb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Jun 2009 13:03:31 -0400
Message-ID: <4A4A4564.3000708@panasas.com>
Date: Tue, 30 Jun 2009 20:03:32 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>,
        pNFS Mailing List <pnfs@linux-nfs.org>
Subject: [PATCH 0/3] nfs41 fixes for 2.6.31
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond,

please consider the following patches for 2.6.31-rc

[PATCH 1/3] nfs41: sunrpc: #include <linux/net.h> from sunrpc.h
	fixes compiler warning

[PATCH 2/3] nfs4: record nfs4_reclaim_lease error in cl_cons_state
[PATCH 3/3] nfs41: pass state recovery error back to caller
	These 2 patches deal with lease recovery error handling.
	This is most visible at mount time when, e.g. when the server exports entry
	exported a non-existing path, mounting over nfs4.0 got into a loop
	broken only with ^C and mounting with minorversion=1 always returned
	the wrong error (-EPROTONOSUPPORT)

 fs/nfs/client.c     |   10 +++-------
 fs/nfs/nfs4proc.c   |   16 ++++++++++++----
 fs/nfs/nfs4state.c  |    2 ++
 net/sunrpc/sunrpc.h |    2 ++
 4 files changed, 19 insertions(+), 11 deletions(-)

Benny
