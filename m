Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:56291 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758050Ab1KRQUi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 11:20:38 -0500
Message-ID: <4EC685D1.2000900@Calva.COM>
Date: Fri, 18 Nov 2011 17:20:33 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] Don't spam kernel log with EKEYEXPIRED and EACCESS errors
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't write anything to the log if a user Kerberos ticket expires or is missing,
these are not kernel problems.

Signed-off-by: John Hughes<john@calva.com>

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 39914be..18897cb 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1339,14 +1339,6 @@ static void nfs4_state_start_reclaim_nograce(struct nfs_client *clp)
  	nfs4_state_mark_reclaim_helper(clp, nfs4_state_mark_reclaim_nograce);
  }

-static void nfs4_warn_keyexpired(const char *s)
-{
-	printk_ratelimited(KERN_WARNING "Error: state manager"
-			" encountered RPCSEC_GSS session"
-			" expired against NFSv4 server %s.\n",
-			s);
-}
-
  static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
  {
  	switch (error) {
@@ -1378,7 +1370,6 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
  			return 0;
  		case -EKEYEXPIRED:
  			/* Nothing we can do */
-			nfs4_warn_keyexpired(clp->cl_hostname);
  			return 0;
  	}
  	return error;
@@ -1620,7 +1611,6 @@ static void nfs4_set_lease_expired(struct nfs_client *clp, int status)
  		break;

  	case -EKEYEXPIRED:
-		nfs4_warn_keyexpired(clp->cl_hostname);
  	case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
  				 * in nfs4_exchange_id */
  	default:
@@ -1728,8 +1718,9 @@ static void nfs4_state_manager(struct nfs_client *clp)
  	} while (atomic_read(&clp->cl_count)>  1);
  	return;
  out_error:
-	printk(KERN_WARNING "Error: state manager failed on NFSv4 server %s"
-			" with error %d\n", clp->cl_hostname, -status);
+	if (status != -EACCESS)
+		printk(KERN_WARNING "Error: state manager failed on NFSv4 server %s"
+				" with error %d\n", clp->cl_hostname, -status);
  	nfs4_end_drain_session(clp);
  	nfs4_clear_state_manager_bit(clp);
  }


