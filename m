Return-Path: linux-nfs-owner@vger.kernel.org
Received: from numidia.opendz.org ([98.142.220.152]:56777 "EHLO
	numidia.opendz.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933173Ab3FRRHs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jun 2013 13:07:48 -0400
From: Djalal Harouni <tixxdz@opendz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Djalal Harouni <tixxdz@opendz.org>
Subject: [PATCH] NFSv4: SETCLIENTID add the format string for the NETID
Date: Tue, 18 Jun 2013 17:58:12 +0100
Message-Id: <1371574692-10257-1-git-send-email-tixxdz@opendz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure that NFSv4 SETCLIENTID does not parse the NETID as a
format string.

Signed-off-by: Djalal Harouni <tixxdz@opendz.org>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2122881..822e767 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4714,7 +4714,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	/* cb_client4 */
 	rcu_read_lock();
 	setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
-				sizeof(setclientid.sc_netid),
+				sizeof(setclientid.sc_netid), "%s",
 				rpc_peeraddr2str(clp->cl_rpcclient,
 							RPC_DISPLAY_NETID));
 	rcu_read_unlock();
-- 
1.7.11.7

