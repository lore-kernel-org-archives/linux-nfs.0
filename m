Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58310 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756486Ab0BKUl0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 15:41:26 -0500
From: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: trond@netapp.com, Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 0/5] nfs: fix umount - renewd race
Date: Fri,  5 Feb 2010 03:32:29 -0800
Message-Id: <1265369554-2105-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This set contains the first 5 patches from my previous attempt (with an updated changelog).
The RPC patches will follow in a seperate patchset, as we need to further evaluate the proposed
timeout changes.

root (5):
  nfs: kill renewd before clearing client minor version
  nfs: prevent backlogging of renewd requests
  nfs41: renewd sequence operations should take/put client reference
  nfs4: renewd renew operations should take/put a client reference
  nfs4: adjust rpc timeout for nfs_client->rpcclient based on the
    lease_time

 fs/nfs/client.c     |   45 ++++++++++++++++++++++-----------------------
 fs/nfs/nfs4proc.c   |   50 ++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4renewd.c |   24 +++++++-----------------
 3 files changed, 77 insertions(+), 42 deletions(-)

