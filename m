Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:34472 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755586Ab1KPKmU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Nov 2011 05:42:20 -0500
Received: from [192.168.6.99] (coptic.calvaedi.com [192.168.6.99])
	(authenticated (0 bits))
	by oceanic.CalvaEDI.COM (8.11.1-20030923/8.11.1/6.32) with ESMTP id pAGAgH424457
	(using TLSv1/SSLv3 with cipher RC4-MD5 (128 bits) verified NO)
	for <linux-nfs@vger.kernel.org>; Wed, 16 Nov 2011 11:42:18 +0100 (CET)
Message-ID: <4EC39389.9050603@Calva.COM>
Date: Wed, 16 Nov 2011 11:42:17 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: [BUG] nfs4 client loops printing "Error: state manager encountered
 RPCSEC_GSS session expired" if kerberos ticket expires
References: <4EBBF7AB.8030907@Calva.COM> <4EC126B0.204@Calva.COM>
In-Reply-To: <4EC126B0.204@Calva.COM>
Content-Type: multipart/mixed;
 boundary="------------090600030801010909050708"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090600030801010909050708
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 14/11/11 15:33, John Hughes wrote:
> Here is a ridiculously stupid patch that fixes the behaviour to be 
> closer to what I want.
>
> Now, if the krb5 ticket has expired processes get a EKEYEXPIRED error 
> and the kernel doesn't waste its time printing "ticket expired" errors.
A slight modification of the patch is needed to avoid scads of "state 
manager failed" errors, if we get EKEYEXPIRED in 
nfs4_recovery_handle_error we *should* return zero, but we don't want to 
call nfs4_warn_keyexpired (there is no reason to log this, it's not a 
kernel problem).

Here's a cleaner version of the patch.

Does anybody care about this?  Will anybody read this message?


--------------090600030801010909050708
Content-Type: text/x-patch;
 name="nfs4-ekeyexpired.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs4-ekeyexpired.patch"

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

--------------090600030801010909050708--
