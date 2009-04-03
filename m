From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 08/35] nfsd41: xdr infrastructure
Date: Fri,  3 Apr 2009 08:27:55 +0300
Message-ID: <1238736475-17326-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:20650 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754592AbZDCF2A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:00 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Define nfsd41_dec_ops vector and add it to nfsd4_minorversion for
minorversion 1.

Note: nfsd4_enc_ops vector is shared for v4.0 and v4.1
since we don't need to filter out obsolete ops as this is
done in the decoding phase.

exchange_id, create_session, destroy_session, and sequence ops are
implemented as stubs returning nfserr_opnotsupp at this stage.

[was nfsd41: xdr stubs]
[get rid of CONFIG_NFSD_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c         |  148 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/xdr4.h |   22 +++++++
 2 files changed, 170 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 76a0b2a..6973d61 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -997,6 +997,34 @@ nfsd4_decode_release_lockowner(struct nfsd4_compoundargs *argp, struct nfsd4_rel
 }
 
 static __be32
+nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
+			 struct nfsd4_exchange_id *clid)
+{
+	return nfserr_opnotsupp;	/* stub */
+}
+
+static __be32
+nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
+			    struct nfsd4_create_session *sess)
+{
+	return nfserr_opnotsupp;	/* stub */
+}
+
+static __be32
+nfsd4_decode_destroy_session(struct nfsd4_compoundargs *argp,
+			     struct nfsd4_destroy_session *destroy_session)
+{
+	return nfserr_opnotsupp;	/* stub */
+}
+
+static __be32
+nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
+		      struct nfsd4_sequence *seq)
+{
+	return nfserr_opnotsupp;	/* stub */
+}
+
+static __be32
 nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
 {
 	return nfs_ok;
@@ -1050,6 +1078,67 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_RELEASE_LOCKOWNER]	= (nfsd4_dec)nfsd4_decode_release_lockowner,
 };
 
+static nfsd4_dec nfsd41_dec_ops[] = {
+	[OP_ACCESS]		(nfsd4_dec)nfsd4_decode_access,
+	[OP_CLOSE]		(nfsd4_dec)nfsd4_decode_close,
+	[OP_COMMIT]		(nfsd4_dec)nfsd4_decode_commit,
+	[OP_CREATE]		(nfsd4_dec)nfsd4_decode_create,
+	[OP_DELEGPURGE]		(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_DELEGRETURN]	(nfsd4_dec)nfsd4_decode_delegreturn,
+	[OP_GETATTR]		(nfsd4_dec)nfsd4_decode_getattr,
+	[OP_GETFH]		(nfsd4_dec)nfsd4_decode_noop,
+	[OP_LINK]		(nfsd4_dec)nfsd4_decode_link,
+	[OP_LOCK]		(nfsd4_dec)nfsd4_decode_lock,
+	[OP_LOCKT]		(nfsd4_dec)nfsd4_decode_lockt,
+	[OP_LOCKU]		(nfsd4_dec)nfsd4_decode_locku,
+	[OP_LOOKUP]		(nfsd4_dec)nfsd4_decode_lookup,
+	[OP_LOOKUPP]		(nfsd4_dec)nfsd4_decode_noop,
+	[OP_NVERIFY]		(nfsd4_dec)nfsd4_decode_verify,
+	[OP_OPEN]		(nfsd4_dec)nfsd4_decode_open,
+	[OP_OPENATTR]		(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_OPEN_CONFIRM]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_OPEN_DOWNGRADE]	(nfsd4_dec)nfsd4_decode_open_downgrade,
+	[OP_PUTFH]		(nfsd4_dec)nfsd4_decode_putfh,
+	[OP_PUTPUBFH]		(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_PUTROOTFH]		(nfsd4_dec)nfsd4_decode_noop,
+	[OP_READ]		(nfsd4_dec)nfsd4_decode_read,
+	[OP_READDIR]		(nfsd4_dec)nfsd4_decode_readdir,
+	[OP_READLINK]		(nfsd4_dec)nfsd4_decode_noop,
+	[OP_REMOVE]		(nfsd4_dec)nfsd4_decode_remove,
+	[OP_RENAME]		(nfsd4_dec)nfsd4_decode_rename,
+	[OP_RENEW]		(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_RESTOREFH]		(nfsd4_dec)nfsd4_decode_noop,
+	[OP_SAVEFH]		(nfsd4_dec)nfsd4_decode_noop,
+	[OP_SECINFO]		(nfsd4_dec)nfsd4_decode_secinfo,
+	[OP_SETATTR]		(nfsd4_dec)nfsd4_decode_setattr,
+	[OP_SETCLIENTID]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_SETCLIENTID_CONFIRM](nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_VERIFY]		(nfsd4_dec)nfsd4_decode_verify,
+	[OP_WRITE]		(nfsd4_dec)nfsd4_decode_write,
+	[OP_RELEASE_LOCKOWNER]	(nfsd4_dec)nfsd4_decode_notsupp,
+
+	/* new operations for NFSv4.1 */
+	[OP_BACKCHANNEL_CTL]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_BIND_CONN_TO_SESSION](nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_EXCHANGE_ID]	(nfsd4_dec)nfsd4_decode_exchange_id,
+	[OP_CREATE_SESSION]	(nfsd4_dec)nfsd4_decode_create_session,
+	[OP_DESTROY_SESSION]	(nfsd4_dec)nfsd4_decode_destroy_session,
+	[OP_FREE_STATEID]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_GET_DIR_DELEGATION]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_GETDEVICEINFO]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_GETDEVICELIST]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTCOMMIT]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTGET]		(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTRETURN]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_SECINFO_NO_NAME]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_SEQUENCE]		(nfsd4_dec)nfsd4_decode_sequence,
+	[OP_SET_SSV]		(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_TEST_STATEID]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_WANT_DELEGATION]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_DESTROY_CLIENTID]	(nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_RECLAIM_COMPLETE]	(nfsd4_dec)nfsd4_decode_notsupp,
+};
+
 struct nfsd4_minorversion_ops {
 	nfsd4_dec *decoders;
 	int nops;
@@ -1057,6 +1146,7 @@ struct nfsd4_minorversion_ops {
 
 static struct nfsd4_minorversion_ops nfsd4_minorversion[] = {
 	[0] = { nfsd4_dec_ops, ARRAY_SIZE(nfsd4_dec_ops) },
+	[1] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
 };
 
 static __be32
@@ -2572,6 +2662,38 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 }
 
 static __be32
+nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, int nfserr,
+			 struct nfsd4_exchange_id *exid)
+{
+	/* stub */
+	return nfserr;
+}
+
+static __be32
+nfsd4_encode_create_session(struct nfsd4_compoundres *resp, int nfserr,
+			    struct nfsd4_create_session *sess)
+{
+	/* stub */
+	return nfserr;
+}
+
+static __be32
+nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
+			     struct nfsd4_destroy_session *destroy_session)
+{
+	/* stub */
+	return nfserr;
+}
+
+static __be32
+nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
+		      struct nfsd4_sequence *seq)
+{
+	/* stub */
+	return nfserr;
+}
+
+static __be32
 nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
 {
 	return nfserr;
@@ -2579,6 +2701,11 @@ nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
 
 typedef __be32(* nfsd4_enc)(struct nfsd4_compoundres *, __be32, void *);
 
+/*
+ * Note: nfsd4_enc_ops vector is shared for v4.0 and v4.1
+ * since we don't need to filter out obsolete ops as this is
+ * done in the decoding phase.
+ */
 static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_ACCESS]		= (nfsd4_enc)nfsd4_encode_access,
 	[OP_CLOSE]		= (nfsd4_enc)nfsd4_encode_close,
@@ -2617,6 +2744,27 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_VERIFY]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_WRITE]		= (nfsd4_enc)nfsd4_encode_write,
 	[OP_RELEASE_LOCKOWNER]	= (nfsd4_enc)nfsd4_encode_noop,
+
+	/* NFSv4.1 operations */
+	[OP_BACKCHANNEL_CTL]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_BIND_CONN_TO_SESSION] = (nfsd4_enc)nfsd4_encode_noop,
+	[OP_EXCHANGE_ID]	= (nfsd4_enc)nfsd4_encode_exchange_id,
+	[OP_CREATE_SESSION]	= (nfsd4_enc)nfsd4_encode_create_session,
+	[OP_DESTROY_SESSION]	= (nfsd4_enc)nfsd4_encode_destroy_session,
+	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_GET_DIR_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_SECINFO_NO_NAME]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_SEQUENCE]		= (nfsd4_enc)nfsd4_encode_sequence,
+	[OP_SET_SSV]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_TEST_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_WANT_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_DESTROY_CLIENTID]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
 };
 
 void
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index fd15ddc..28af925 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -344,6 +344,22 @@ struct nfsd4_write {
 	nfs4_verifier	wr_verifier;        /* response */
 };
 
+struct nfsd4_exchange_id {
+	int	foo;	/* stub */
+};
+
+struct nfsd4_create_session {
+	int	foo;	/* stub */
+};
+
+struct nfsd4_sequence {
+	int	foo;	/* stub */
+};
+
+struct nfsd4_destroy_session {
+	int	foo;	/* stub */
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -378,6 +394,12 @@ struct nfsd4_op {
 		struct nfsd4_verify		verify;
 		struct nfsd4_write		write;
 		struct nfsd4_release_lockowner	release_lockowner;
+
+		/* NFSv4.1 */
+		struct nfsd4_exchange_id	exchange_id;
+		struct nfsd4_create_session	create_session;
+		struct nfsd4_destroy_session	destroy_session;
+		struct nfsd4_sequence		sequence;
 	} u;
 	struct nfs4_replay *			replay;
 };
-- 
1.6.2.1

