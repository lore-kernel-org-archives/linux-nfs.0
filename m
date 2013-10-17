Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45410 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762262Ab3JQSOA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:14:00 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HIDxvc006321
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:14:00 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HIDxJT008180
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:59 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 19/21] NFS: Handle SEQ4_STATUS_LEASE_MOVED
Date: Thu, 17 Oct 2013 14:13:58 -0400
Message-Id: <20131017181358.1073.89113.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With the advent of NFSv4 sessions in NFSv4.1 and following, a "lease
moved" condition is reported differently than it is in NFSv4.0.

NFSv4 minor version 0 servers return an error status code,
NFS4ERR_LEASE_MOVED, to signal that a lease has moved.  This error
causes the whole compound operation to fail.  Normal compounds
against this server continue to fail until the client performs
migration recovery on the migrated share.

Minor version 1 and later servers assert a bit flag in the reply to
a compound's SEQUENCE operation to signal LEASE_MOVED.  This is not
a fatal condition: operations against this server continue normally.
The server asserts this flag until the client performs migration
recovery on the migrated share.

Note that servers MUST NOT return NFS4ERR_LEASE_MOVED to NFSv4
clients not using NFSv4.0.

After the server asserts any of the sr_status_flags in the SEQUENCE
operation in a typical compound, our client initiates standard lease
recovery.  For NFSv4.1+, a stand-alone SEQUENCE operation is
performed to discover what recovery is needed.

If SEQ4_STATUS_LEASE_MOVED is asserted in this stand-alone SEQUENCE
operation, our client attempts to discover which FSIDs have been
migrated, and then performs migration recovery on each.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4state.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 3fbce1f..6daa064 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2230,9 +2230,10 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 		nfs41_handle_server_reboot(clp);
 	if (flags & (SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED |
 			    SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED |
-			    SEQ4_STATUS_ADMIN_STATE_REVOKED |
-			    SEQ4_STATUS_LEASE_MOVED))
+			    SEQ4_STATUS_ADMIN_STATE_REVOKED))
 		nfs41_handle_state_revoked(clp);
+	if (flags & SEQ4_STATUS_LEASE_MOVED)
+		nfs4_schedule_lease_moved_recovery(clp);
 	if (flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
 		nfs41_handle_recallable_state_revoked(clp);
 	if (flags & SEQ4_STATUS_BACKCHANNEL_FAULT)

