From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/15] NFSD: Convert printk's to dprintk's in NFSD's
	nfs4xdr
Date: Tue, 11 Sep 2007 18:01:20 -0400
Message-ID: <20070911220120.26136.8914.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDo3-00073M-OI
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:02:03 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDo8-0005jG-8z
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:02:08 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Due to recent edict to remove or replace printk's that can flood the system
log.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfs4xdr.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 8ef0964..62e6464 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -102,7 +102,8 @@ check_filename(char *str, int len, __be32 err)
 out:						\
 	return status;				\
 xdr_error:					\
-	printk(KERN_NOTICE "xdr error! (%s:%d)\n", __FILE__, __LINE__);	\
+	dprintk("NFSD: xdr error (%s:%d)\n",	\
+			__FILE__, __LINE__);	\
 	status = nfserr_bad_xdr;		\
 	goto out
 
@@ -124,7 +125,8 @@ xdr_error:					\
 	if (!(x = (p==argp->tmp || p == argp->tmpp) ? \
  		savemem(argp, p, nbytes) :	\
  		(char *)p)) {			\
-		printk(KERN_NOTICE "xdr error! (%s:%d)\n", __FILE__, __LINE__); \
+		dprintk("NFSD: xdr error (%s:%d)\n", \
+				__FILE__, __LINE__); \
 		goto xdr_error;			\
 		}				\
 	p += XDR_QUADLEN(nbytes);		\
@@ -140,7 +142,8 @@ xdr_error:					\
 		p = argp->p;			\
 		argp->p += XDR_QUADLEN(nbytes);	\
 	} else if (!(p = read_buf(argp, nbytes))) { \
-		printk(KERN_NOTICE "xdr error! (%s:%d)\n", __FILE__, __LINE__); \
+		dprintk("NFSD: xdr error (%s:%d)\n", \
+				__FILE__, __LINE__); \
 		goto xdr_error;			\
 	}					\
 } while (0)
@@ -948,7 +951,8 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 	 */
 	avail = (char*)argp->end - (char*)argp->p;
 	if (avail + argp->pagelen < write->wr_buflen) {
-		printk(KERN_NOTICE "xdr error! (%s:%d)\n", __FILE__, __LINE__); 
+		dprintk("NFSD: xdr error (%s:%d)\n",
+				__FILE__, __LINE__); 
 		goto xdr_error;
 	}
 	argp->rqstp->rq_vec[0].iov_base = p;
@@ -1019,7 +1023,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		argp->ops = kmalloc(argp->opcnt * sizeof(*argp->ops), GFP_KERNEL);
 		if (!argp->ops) {
 			argp->ops = argp->iops;
-			printk(KERN_INFO "nfsd: couldn't allocate room for COMPOUND\n");
+			dprintk("nfsd: couldn't allocate room for COMPOUND\n");
 			goto xdr_error;
 		}
 	}
@@ -1326,7 +1330,7 @@ static char *nfsd4_path(struct svc_rqst *rqstp, struct svc_export *exp, __be32 *
 	path = exp->ex_path;
 
 	if (strncmp(path, rootpath, strlen(rootpath))) {
-		printk("nfsd: fs_locations failed;"
+		dprintk("nfsd: fs_locations failed;"
 			"%s is not contained in %s\n", path, rootpath);
 		*stat = nfserr_notsupp;
 		return NULL;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
