From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] nfsd: use C99 struct initializers
Date: Tue, 28 Apr 2009 16:48:25 -0700
Message-ID: <49F795C9.6040909@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756951AbZD1XsX@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Eliminate 56 sparse warnings like this one:

fs/nfsd/nfs4xdr.c:1331:15: warning: obsolete array initializer, use C99 syntax

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
---
 fs/nfsd/nfs4xdr.c |  112 +++++++++++++++++++++++++++---------------------------
 1 file changed, 56 insertions(+), 56 deletions(-)

--- linux-2.6.30-rc3-git4.orig/fs/nfsd/nfs4xdr.c
+++ linux-2.6.30-rc3-git4/fs/nfsd/nfs4xdr.c
@@ -1328,64 +1328,64 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 };
 
 static nfsd4_dec nfsd41_dec_ops[] = {
-	[OP_ACCESS]		(nfsd4_dec)nfsd4_decode_access,
-	[OP_CLOSE]		(nfsd4_dec)nfsd4_decode_close,
-	[OP_COMMIT]		(nfsd4_dec)nfsd4_decode_commit,
-	[OP_CREATE]		(nfsd4_dec)nfsd4_decode_create,
-	[OP_DELEGPURGE]		(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_DELEGRETURN]	(nfsd4_dec)nfsd4_decode_delegreturn,
-	[OP_GETATTR]		(nfsd4_dec)nfsd4_decode_getattr,
-	[OP_GETFH]		(nfsd4_dec)nfsd4_decode_noop,
-	[OP_LINK]		(nfsd4_dec)nfsd4_decode_link,
-	[OP_LOCK]		(nfsd4_dec)nfsd4_decode_lock,
-	[OP_LOCKT]		(nfsd4_dec)nfsd4_decode_lockt,
-	[OP_LOCKU]		(nfsd4_dec)nfsd4_decode_locku,
-	[OP_LOOKUP]		(nfsd4_dec)nfsd4_decode_lookup,
-	[OP_LOOKUPP]		(nfsd4_dec)nfsd4_decode_noop,
-	[OP_NVERIFY]		(nfsd4_dec)nfsd4_decode_verify,
-	[OP_OPEN]		(nfsd4_dec)nfsd4_decode_open,
-	[OP_OPENATTR]		(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_OPEN_CONFIRM]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_OPEN_DOWNGRADE]	(nfsd4_dec)nfsd4_decode_open_downgrade,
-	[OP_PUTFH]		(nfsd4_dec)nfsd4_decode_putfh,
-	[OP_PUTPUBFH]		(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_PUTROOTFH]		(nfsd4_dec)nfsd4_decode_noop,
-	[OP_READ]		(nfsd4_dec)nfsd4_decode_read,
-	[OP_READDIR]		(nfsd4_dec)nfsd4_decode_readdir,
-	[OP_READLINK]		(nfsd4_dec)nfsd4_decode_noop,
-	[OP_REMOVE]		(nfsd4_dec)nfsd4_decode_remove,
-	[OP_RENAME]		(nfsd4_dec)nfsd4_decode_rename,
-	[OP_RENEW]		(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_RESTOREFH]		(nfsd4_dec)nfsd4_decode_noop,
-	[OP_SAVEFH]		(nfsd4_dec)nfsd4_decode_noop,
-	[OP_SECINFO]		(nfsd4_dec)nfsd4_decode_secinfo,
-	[OP_SETATTR]		(nfsd4_dec)nfsd4_decode_setattr,
-	[OP_SETCLIENTID]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_SETCLIENTID_CONFIRM](nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_VERIFY]		(nfsd4_dec)nfsd4_decode_verify,
-	[OP_WRITE]		(nfsd4_dec)nfsd4_decode_write,
-	[OP_RELEASE_LOCKOWNER]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_ACCESS]		= (nfsd4_dec)nfsd4_decode_access,
+	[OP_CLOSE]		= (nfsd4_dec)nfsd4_decode_close,
+	[OP_COMMIT]		= (nfsd4_dec)nfsd4_decode_commit,
+	[OP_CREATE]		= (nfsd4_dec)nfsd4_decode_create,
+	[OP_DELEGPURGE]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_DELEGRETURN]	= (nfsd4_dec)nfsd4_decode_delegreturn,
+	[OP_GETATTR]		= (nfsd4_dec)nfsd4_decode_getattr,
+	[OP_GETFH]		= (nfsd4_dec)nfsd4_decode_noop,
+	[OP_LINK]		= (nfsd4_dec)nfsd4_decode_link,
+	[OP_LOCK]		= (nfsd4_dec)nfsd4_decode_lock,
+	[OP_LOCKT]		= (nfsd4_dec)nfsd4_decode_lockt,
+	[OP_LOCKU]		= (nfsd4_dec)nfsd4_decode_locku,
+	[OP_LOOKUP]		= (nfsd4_dec)nfsd4_decode_lookup,
+	[OP_LOOKUPP]		= (nfsd4_dec)nfsd4_decode_noop,
+	[OP_NVERIFY]		= (nfsd4_dec)nfsd4_decode_verify,
+	[OP_OPEN]		= (nfsd4_dec)nfsd4_decode_open,
+	[OP_OPENATTR]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_OPEN_CONFIRM]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_OPEN_DOWNGRADE]	= (nfsd4_dec)nfsd4_decode_open_downgrade,
+	[OP_PUTFH]		= (nfsd4_dec)nfsd4_decode_putfh,
+	[OP_PUTPUBFH]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_PUTROOTFH]		= (nfsd4_dec)nfsd4_decode_noop,
+	[OP_READ]		= (nfsd4_dec)nfsd4_decode_read,
+	[OP_READDIR]		= (nfsd4_dec)nfsd4_decode_readdir,
+	[OP_READLINK]		= (nfsd4_dec)nfsd4_decode_noop,
+	[OP_REMOVE]		= (nfsd4_dec)nfsd4_decode_remove,
+	[OP_RENAME]		= (nfsd4_dec)nfsd4_decode_rename,
+	[OP_RENEW]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_RESTOREFH]		= (nfsd4_dec)nfsd4_decode_noop,
+	[OP_SAVEFH]		= (nfsd4_dec)nfsd4_decode_noop,
+	[OP_SECINFO]		= (nfsd4_dec)nfsd4_decode_secinfo,
+	[OP_SETATTR]		= (nfsd4_dec)nfsd4_decode_setattr,
+	[OP_SETCLIENTID]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_SETCLIENTID_CONFIRM]= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_VERIFY]		= (nfsd4_dec)nfsd4_decode_verify,
+	[OP_WRITE]		= (nfsd4_dec)nfsd4_decode_write,
+	[OP_RELEASE_LOCKOWNER]	= (nfsd4_dec)nfsd4_decode_notsupp,
 
 	/* new operations for NFSv4.1 */
-	[OP_BACKCHANNEL_CTL]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_BIND_CONN_TO_SESSION](nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_EXCHANGE_ID]	(nfsd4_dec)nfsd4_decode_exchange_id,
-	[OP_CREATE_SESSION]	(nfsd4_dec)nfsd4_decode_create_session,
-	[OP_DESTROY_SESSION]	(nfsd4_dec)nfsd4_decode_destroy_session,
-	[OP_FREE_STATEID]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_GET_DIR_DELEGATION]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_GETDEVICEINFO]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_GETDEVICELIST]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_LAYOUTCOMMIT]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_LAYOUTGET]		(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_LAYOUTRETURN]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_SECINFO_NO_NAME]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_SEQUENCE]		(nfsd4_dec)nfsd4_decode_sequence,
-	[OP_SET_SSV]		(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_TEST_STATEID]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_WANT_DELEGATION]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_DESTROY_CLIENTID]	(nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_RECLAIM_COMPLETE]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_BACKCHANNEL_CTL]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_BIND_CONN_TO_SESSION]= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_EXCHANGE_ID]	= (nfsd4_dec)nfsd4_decode_exchange_id,
+	[OP_CREATE_SESSION]	= (nfsd4_dec)nfsd4_decode_create_session,
+	[OP_DESTROY_SESSION]	= (nfsd4_dec)nfsd4_decode_destroy_session,
+	[OP_FREE_STATEID]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_GET_DIR_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_SECINFO_NO_NAME]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_SEQUENCE]		= (nfsd4_dec)nfsd4_decode_sequence,
+	[OP_SET_SSV]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_TEST_STATEID]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_WANT_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_notsupp,
 };
 
 struct nfsd4_minorversion_ops {
