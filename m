From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 000/112] What's in the NFS queue for linux-2.6.25
Date: Fri, 25 Jan 2008 11:59:13 -0500
Message-ID: <1201280354.24283.70.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10534 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753533AbYAYQ7Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:16 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxFcG019787
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:15 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series contains all the patches that are currently queued
up for inclusion in 2.6.25.

Main changes include

      * Cleanup of the SUNRPC client call API. Extend rpc_run_task() so
        that it can act as the universal point of entry for all RPC
        calls. Unexport rpc_execute() and assorted other low-level
        interfaces.
      * Fix the remaining 'mount' issues: mainly to do with allowing
        people to select tcp both and udp mounts to the same server,
        setting per-mountpoint timeo/retrans etc...
      * More IPv6 cleanups from Chuck. NFSv4 support for IPv6 should now
        almost be complete (IPv6 callback support is still not ready).
      * Assorted bugfixes, including SteveD's fix for the
        sillyrename/umount race.

Cheers
  Trond
