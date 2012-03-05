Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e3.ny.us.ibm.com ([32.97.182.143]:35449 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932332Ab2CEU2J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 15:28:09 -0500
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 15:28:08 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id D62F838C806A
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 15:26:59 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25KQwVE2785366
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:26:59 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25KQvfb010551
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:26:58 -0500
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v3 08/10] Added error handling for NFS4ERR_FHEXPIRED
Date: Mon,  5 Mar 2012 15:26:49 -0500
Message-Id: <1330979211-894-9-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
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
index a593eef..78ed5c5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -283,6 +283,16 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
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

