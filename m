Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:60466 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750990Ab1FCOd1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jun 2011 10:33:27 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1QSV63-0005K7-JG
	for linux-nfs@vger.kernel.org; Fri, 03 Jun 2011 10:11:31 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs4: v4 mounts should not need rpcbind running
Date: Fri,  3 Jun 2011 10:11:30 -0400
Message-Id: <1307110290-30672-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When RPC services are created with svc_create() an
svc_unregister() is done to remove any stale registrations.

This unregister is not needed with the v4 callback
service and will cause the mount to hang if rpcbind
is not running.

This patch makes the nfs4 callback service a hide service
by setting the vs_hidden flag in the nfs4_callback_version4
structure

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/callback_xdr.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index c6c86a7..7c8b800 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -996,4 +996,5 @@ struct svc_version nfs4_callback_version4 = {
 	.vs_proc = nfs4_callback_procedures1,
 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
 	.vs_dispatch = NULL,
+	.vs_hidden = 1,
 };
-- 
1.7.4.4

