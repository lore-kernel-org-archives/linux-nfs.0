Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:38149 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250Ab1KPSNv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Nov 2011 13:13:51 -0500
Message-ID: <4EC3FD8B.6000705@calvaedi.com>
Date: Wed, 16 Nov 2011 19:14:35 +0100
From: John Hughes <john@calvaedi.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] Don't hang user processes if Kerberos ticket for nfs4 mount
 expires
Content-Type: multipart/mixed;
 boundary="------------080701090702090605060104"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080701090702090605060104
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

With recent kernels if the Kerberos ticket for a nfs4 mount expires any 
user process trying to access the mount hangs until a new ticket is 
obtained.  Simultaneously a (luckily rate-limited, but still seemingly 
endless) stream of "Error: state manager encountered RPCSEC_GSS session 
expired against NFSv4 server" messages is written to the kernel log.

In a common setup with user home directories nfs4 mounted on 
workstations one of the processes that is likely to hang is the 
screen-unlock function which would normally (via pam_krb5 or similar) 
get the new ticket.

In older kernels the EKEYEXPIRED error would be passed to userland, 
which would usualy just give up.

This patch restores the old behavior, which makes nfs4 mounted home 
directories usable for me.




--------------080701090702090605060104
Content-Type: text/x-patch;
 name="nfs4-ekeyexpired.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs4-ekeyexpired.patch"

Signed-off-by: John Hughes <john@calva.com>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4700fae..dc28a78 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -302,7 +302,6 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			}
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
-		case -EKEYEXPIRED:
 			ret = nfs4_delay(server->client, &exception->timeout);
 			if (ret != 0)
 				break;
@@ -3732,7 +3731,6 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
-		case -EKEYEXPIRED:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
 			task->tk_status = 0;
 			return -EAGAIN;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 39914be..2bee41e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1377,8 +1377,9 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 			/* Zero session reset errors */
 			return 0;
 		case -EKEYEXPIRED:
-			/* Nothing we can do */
-			nfs4_warn_keyexpired(clp->cl_hostname);
+			/* Nothing we can do, so do nothing.  Don't even
+			   print a warning message, this is not a kernel
+			   problem */
 			return 0;
 	}
 	return error;

--------------080701090702090605060104--
