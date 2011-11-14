Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:47849 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786Ab1KNOdW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 09:33:22 -0500
Message-ID: <4EC126B0.204@Calva.COM>
Date: Mon, 14 Nov 2011 15:33:20 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: John Hughes <john@Calva.COM>
Subject: Re: [BUG] nfs4 client loops printing "Error: state manager encountered
 RPCSEC_GSS session expired" if kerberos ticket expires
References: <4EBBF7AB.8030907@Calva.COM>
In-Reply-To: <4EBBF7AB.8030907@Calva.COM>
Content-Type: multipart/mixed;
 boundary="------------010804070609020203080806"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010804070609020203080806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Here is a ridiculously stupid patch that fixes the behaviour to be 
closer to what I want.

Now, if the krb5 ticket has expired processes get a EKEYEXPIRED error 
and the kernel doesn't waste its time printing "ticket expired" errors.

 From the point of view of someone who has their home directory nfs 
mounted they go home after work, when they get back in the morning they 
give their password to the screensaver, pam_krb5 gets a new ticket and 
everything works.

(Without this hack the screensaver hangs before presenting the password 
prompt, presumably accessing something in the home directory).

Anyone care to comment?


--------------010804070609020203080806
Content-Type: text/x-patch;
 name="nfs4-hack.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs4-hack.patch"

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4700fae..3101f84 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -302,7 +302,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			}
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
+#if 0			/* JH hack - don't handle KRB5 ticket expiry */
 		case -EKEYEXPIRED:
+#endif
 			ret = nfs4_delay(server->client, &exception->timeout);
 			if (ret != 0)
 				break;
@@ -3732,7 +3734,9 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
+#if 0			/* JH hack - don't handle KRB5 ticket expiry */
 		case -EKEYEXPIRED:
+#endif
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
 			task->tk_status = 0;
 			return -EAGAIN;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 39914be..0137ec9 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1376,10 +1376,12 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
 			/* Zero session reset errors */
 			return 0;
+#if 0			/* JH hack: If there is nothing to do, do nothing */
 		case -EKEYEXPIRED:
 			/* Nothing we can do */
 			nfs4_warn_keyexpired(clp->cl_hostname);
 			return 0;
+#endif
 	}
 	return error;
 }

--------------010804070609020203080806--
