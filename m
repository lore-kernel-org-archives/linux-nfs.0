From: Steve Dickson <SteveD@redhat.com>
Subject: Re: lockd recovery not working on RH with 2.6 kernel
Date: Fri, 19 Nov 2004 15:38:05 -0500
Message-ID: <419E59AD.9070302@RedHat.com>
References: <OF573E8465.7E3D5CC0-ON88256F49.0064BB5C-88256F49.00698B56@us.ibm.com>	 <419CD343.4000600@RedHat.com> <1100882099.11209.8.camel@lade.trondhjem.org> <419E3252.3040602@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010902070700060407060601"
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <419E3252.3040602@RedHat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------010902070700060407060601
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hey Neil,

Steve Dickson wrote:

> Unfortunately the NLM protocol does not support a EAGAIN notion and 
> the way
> the NLM rpc routines are setup, is does not seem possible to simply 
> svc_drop
> NLM messages....

Well... it turns out make the nlm rpc routines drop messages  was not 
that difficult.
Fairly straightforward actually....  basically copying working code in 
to other places
and  making things work just like the kNFSd does...

So that attached patch does the following:
1) Adds an internal nlm_lck_dropit error code.
2) Adds a  nlmsvc_dispatch() function that will drop message when the NLM
    procedure function returns nlm_lck_dropit.
3) Changes nlm_fopen() and nlm_lookup_file() to handle the nlm_lck_dropit
    error code.

Finally, I left in some of the truly helpful debugging statements. The 
ones that
were key in helping me figure out what was going on... Now I'm not one 
to force my
debugging style on anybody, but... having fh_verify() and exp_find_key() 
tell
us why they are failing is a good thing... imho...

Comments?

SteveD.

--------------010902070700060407060601
Content-Type: text/plain;
 name="linux-2.6.9-lockd-svc-reclaims.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.9-lockd-svc-reclaims.patch"

--- linux-2.6.9/include/linux/lockd/xdr.h.orig	2004-11-18 15:06:39.000000000 -0500
+++ linux-2.6.9/include/linux/lockd/xdr.h	2004-11-19 14:32:31.880197648 -0500
@@ -21,6 +21,11 @@
 #define	nlm_lck_denied_nolocks	__constant_htonl(NLM_LCK_DENIED_NOLOCKS)
 #define	nlm_lck_blocked		__constant_htonl(NLM_LCK_BLOCKED)
 #define	nlm_lck_denied_grace_period	__constant_htonl(NLM_LCK_DENIED_GRACE_PERIOD)
+/* error codes for internal use */
+/* if a request fails due to kmalloc failure, it gets dropped.
+ *  Client should resend eventually
+ */
+#define	nlm_lck_dropit		__constant_htonl(30000)
 
 /* Lock info passed via NLM */
 struct nlm_lock {
--- linux-2.6.9/fs/nfsd/nfsfh.c.orig	2004-11-18 15:06:39.000000000 -0500
+++ linux-2.6.9/fs/nfsd/nfsfh.c	2004-11-19 14:51:20.079685256 -0500
@@ -142,13 +142,15 @@ fh_verify(struct svc_rqst *rqstp, struct
 		}
 
 		error = nfserr_dropit;
-		if (IS_ERR(exp) && PTR_ERR(exp) == -EAGAIN)
+		if (IS_ERR(exp) && PTR_ERR(exp) == -EAGAIN) {
+			dprintk("nfsd: fh_verify failed: nfserr_dropit\n");
 			goto out;
-
+		}
 		error = nfserr_stale; 
-		if (!exp || IS_ERR(exp))
+		if (!exp || IS_ERR(exp)) {
+			dprintk("nfsd: fh_verify failed: nfserr_stale\n");
 			goto out;
-
+		}
 		/* Check if the request originated from a secure port. */
 		error = nfserr_perm;
 		if (!rqstp->rq_secure && EX_SECURE(exp)) {
@@ -162,6 +164,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 		/* Set user creds for this exportpoint */
 		error = nfsd_setuser(rqstp, exp);
 		if (error) {
+			dprintk("nfsd: nfsd_setuser failed: %d\n", error);
 			error = nfserrno(error);
 			goto out;
 		}
@@ -198,6 +201,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 		if (dentry == NULL)
 			goto out;
 		if (IS_ERR(dentry)) {
+			dprintk("nfsd: CALL(nop,decode_fh) failed: %ld\n", PTR_ERR(dentry));
 			if (PTR_ERR(dentry) != -EINVAL)
 				error = nfserrno(PTR_ERR(dentry));
 			goto out;
@@ -243,6 +247,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 			error = nfserr_isdir;
 		else
 			error = nfserr_inval;
+		dprintk("nfsd: bad type: %d\n", ntohl(error));
 		goto out;
 	}
 	if (type < 0 && (inode->i_mode & S_IFMT) == -type) {
@@ -252,6 +257,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 			error = nfserr_isdir;
 		else
 			error = nfserr_notdir;
+		dprintk("nfsd: bad type2: %d\n", ntohl(error));
 		goto out;
 	}
 
--- linux-2.6.9/fs/nfsd/lockd.c.orig	2004-10-18 17:54:55.000000000 -0400
+++ linux-2.6.9/fs/nfsd/lockd.c	2004-11-19 10:10:10.239244488 -0500
@@ -42,15 +42,18 @@ nlm_fopen(struct svc_rqst *rqstp, struct
  	/* nlm and nfsd don't share error codes.
 	 * we invent: 0 = no error
 	 *            1 = stale file handle
-	 *	      2 = other error
+	 *            2 = nfserr_dropit (or -EAGAIN)
+	 *	          3 = other error
 	 */
 	switch (nfserr) {
 	case nfs_ok:
 		return 0;
 	case nfserr_stale:
 		return 1;
-	default:
+	case nfserr_dropit:
 		return 2;
+	default:
+		return 3;
 	}
 }
 
--- linux-2.6.9/fs/nfsd/export.c.orig	2004-10-18 17:54:32.000000000 -0400
+++ linux-2.6.9/fs/nfsd/export.c	2004-11-19 14:54:37.145726664 -0500
@@ -509,9 +509,12 @@ exp_find_key(svc_client *clp, int fsid_t
 	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
 
 	ek = svc_expkey_lookup(&key, 0);
-	if (ek != NULL)
-		if ((err = cache_check(&svc_expkey_cache, &ek->h, reqp)))
+	if (ek != NULL) {
+		if ((err = cache_check(&svc_expkey_cache, &ek->h, reqp))) {
+			dprintk("exp_find_key: cache_check failed: %d\n", err);
 			ek = ERR_PTR(err);
+		}
+	}
 	return ek;
 }
 
--- linux-2.6.9/fs/lockd/svcsubs.c.orig	2004-10-18 17:54:37.000000000 -0400
+++ linux-2.6.9/fs/lockd/svcsubs.c	2004-11-19 14:32:57.842250816 -0500
@@ -90,7 +90,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
 	 * the file.
 	 */
 	if ((nfserr = nlmsvc_ops->fopen(rqstp, f, &file->f_file)) != 0) {
-		dprintk("lockd: open failed (nfserr %d)\n", ntohl(nfserr));
+		dprintk("lockd: open failed (nfserr %d)\n", nfserr);
 		goto out_free;
 	}
 
@@ -114,7 +114,10 @@ out_free:
 		nfserr = nlm4_stale_fh;
 	else
 #endif
-	nfserr = nlm_lck_denied;
+	if (nfserr == 2)
+		nfserr = nlm_lck_dropit;
+	else
+		nfserr = nlm_lck_denied;
 	goto out_unlock;
 }
 
--- linux-2.6.9/fs/lockd/svc4proc.c.orig	2004-11-18 15:06:39.000000000 -0500
+++ linux-2.6.9/fs/lockd/svc4proc.c	2004-11-19 14:56:36.204626960 -0500
@@ -128,9 +128,12 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file))) {
+		dprintk("lockd: LOCK(args)    status %d\n", ntohl(resp->status));
+		if (resp->status == nlm_lck_dropit)
+			return nlm_lck_dropit;
 		return rpc_success;
-
+	}
 #if 0
 	/* If supplied state doesn't match current state, we assume it's
 	 * an old request that time-warped somehow. Any error return would
--- linux-2.6.9/fs/lockd/svc.c.orig	2004-11-18 15:06:39.000000000 -0500
+++ linux-2.6.9/fs/lockd/svc.c	2004-11-19 14:39:07.076118736 -0500
@@ -86,6 +86,46 @@ static inline void clear_grace_period(vo
 {
 	nlmsvc_grace_period = 0;
 }
+int
+nlmsvc_dispatch(struct svc_rqst *rqstp, u32 *statp)
+{
+	struct svc_procedure	*procp;
+	kxdrproc_t		xdr;
+	struct kvec *argv;
+	struct kvec *resv;
+
+	dprintk("nlmsvc_dispatch: vers %d proc %d\n",
+				rqstp->rq_vers, rqstp->rq_proc);
+
+	procp = rqstp->rq_procinfo;
+	argv = &rqstp->rq_arg.head[0];
+	resv = &rqstp->rq_res.head[0];
+
+	/* Decode arguments */
+	xdr = procp->pc_decode;
+	if (xdr && !xdr(rqstp, argv->iov_base, rqstp->rq_argp)) {
+		dprintk("nlmsvc_dispatch: failed to decode arguments!\n");
+		*statp = rpc_garbage_args;
+		return 1;
+	}
+	*statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
+	if (*statp == nlm_lck_dropit) {
+		dprintk("nlmsvc_dispatch: dropping request\n");
+		return 0;
+	}
+
+	/* Encode reply */
+	if (*statp == rpc_success && (xdr = procp->pc_encode)
+	 && !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
+		dprintk("nlmsvc_dispatch: failed to encode reply\n");
+		*statp = rpc_system_err;
+		return 1;
+	}
+
+	dprintk("nlmsvc_dispatch: statp %d\n", ntohl(*statp));
+
+	return 1;
+}
 
 /*
  * This is the lockd kernel thread
@@ -459,12 +499,14 @@ static struct svc_version	nlmsvc_version
 		.vs_vers	= 1,
 		.vs_nproc	= 17,
 		.vs_proc	= nlmsvc_procedures,
+		.vs_dispatch = nlmsvc_dispatch,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 static struct svc_version	nlmsvc_version3 = {
 		.vs_vers	= 3,
 		.vs_nproc	= 24,
 		.vs_proc	= nlmsvc_procedures,
+		.vs_dispatch = nlmsvc_dispatch,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #ifdef CONFIG_LOCKD_V4
@@ -472,6 +514,7 @@ static struct svc_version	nlmsvc_version
 		.vs_vers	= 4,
 		.vs_nproc	= 24,
 		.vs_proc	= nlmsvc_procedures4,
+		.vs_dispatch = nlmsvc_dispatch,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #endif

--------------010902070700060407060601--


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
