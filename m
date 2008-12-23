Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752188AbYLWXXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:39 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNaFT006177
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:38 -0800 (PST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/69] NFS client patches queued for the 2.6.29 merge window
To: linux-nfs@vger.kernel.org
Date: Tue, 23 Dec 2008 18:02:04 -0500
Message-ID: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here is the full set of patches that I'm planning on queueing for
2.6.29. Please note in particular the fairly extensive changes to the
NFSv4 state recovery code, which was mainly motivated by the desire to
get rid of the global nfs_client->cl_sem lock. In the end, it helped add
support for a couple of new features, including the ability to recover
state on individual files rather than doing so for the entire server.
This latter feature is necessary in order to close a couple of races
when returning delegations, as well as when recovering state after
network partitions have invalidated our lease.

Also note the a number of changes to the delegation code, mainly in
order to make the locking more robust. There is now also code in there
to ensure that we return delegations that haven't been used in a while.
This will help reduce the amount of unnecessary state that servers will
need to track, as well as reducing the number of sources of conflict
with other NFS clients.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
