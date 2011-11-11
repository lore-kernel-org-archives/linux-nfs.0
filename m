Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e33.co.us.ibm.com ([32.97.110.151]:46379 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664Ab1KKXGC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 18:06:02 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 16:06:02 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pABN5pmk230064
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 16:05:53 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pABN5oMP008879
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 16:05:51 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC 7/7] Added error handling for NFS4ERR_FHEXPIRED
Date: Fri, 11 Nov 2011 18:04:32 -0500
Message-Id: <1321052673-22171-8-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added checks in the nfs4_handle_exception for FHEXPIRED.
If FHEXPIRED is received from the server and the appropriate
attributes are enabled then the client calls
nfs4_fhexpired_recovery() to perform the lookup operation to
try and recovery the expired vfh.

If the mount option is not enabled or the server FH_EXPIRE_TYPE
doesn't have VOLATILE_ANY then client will convert the
FHEXPIRED error into ESTALE since recovery isn't possible.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/nfs4proc.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ebc5ee9..8ae5c49 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -277,6 +277,16 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case -NFS4ERR_STALE_CLIENTID:
 			nfs4_schedule_lease_recovery(clp);
 			goto wait_on_recovery;
+		case -NFS4ERR_FHEXPIRED:
+			if (server->flags & NFS_MOUNT_VFHRETRY)
+				if (server->fhexpiretype & NFS4_FH_VOLATILE_ANY) {
+					ret = nfs4_fhexpired_recovery(server, exception);
+					if (!ret)
+						ret = -EAGAIN;
+					break;
+				}
+			ret = -ESTALE;
+			break;
 #if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
-- 
1.7.4.4

