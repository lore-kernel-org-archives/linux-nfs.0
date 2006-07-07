From: NeilBrown <neilb@suse.de>
Subject: [PATCH] knfsd: nfsd4: add per-operation server stats
Date: Fri, 7 Jul 2006 17:47:28 +1000
Message-ID: <1060707074728.20633@suse.de>
References: <20060707174156.20585.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Shankar Anand <shanand@novell.com>,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fyl3s-0001bB-JS
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 00:47:40 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fyl3r-0004Nc-CK
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 00:47:41 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Andrew,
 I know the merge window is officially closed, but I wonder if this could
slip in? It adds per-operation(*) statistics for NFSv4.  It didn't
make it for the previous batch as we needed to clarify some issues with
the appearance of the data in /proc.

(*) For those not in "the know", while NFSv2 and NFSv3 have a number
of difference proceedures (READ, WRITE, UNLINK, etc). NFSv4 a single(+)
procedure "COMPOUND" and can contain a list of operations like READ,
WRITE, UNLINK etc so there can be multiple operations per RPC.
Because of this, slight different statistics gathering are needed.

(+) Actually, NFSv4 has two proceedures: COMPOUND and NULL...

Thanks,
NeilBrown

### Comments for Changeset

From: "Shankar Anand" <shanand@novell.com>

This patch adds a nfs4 operations count array to nfsd_stats structure.
The count is  incremented in nfsd4_proc_compound() where all the operations
are handled by the nfsv4 server. This count of individual nfsv4 operations
is also entered into /proc filesystem. 

Signed-off-by: Shankar Anand<shanand@novell.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c         |    8 ++++++++
 ./fs/nfsd/stats.c            |   10 ++++++++++
 ./include/linux/nfs4.h       |    6 ++++++
 ./include/linux/nfsd/stats.h |    6 ++++++
 4 files changed, 30 insertions(+)

diff .prev/fs/nfsd/nfs4proc.c ./fs/nfsd/nfs4proc.c
--- .prev/fs/nfsd/nfs4proc.c	2006-07-07 17:29:24.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2006-07-07 17:31:15.000000000 +1000
@@ -721,6 +721,12 @@ nfsd4_proc_null(struct svc_rqst *rqstp, 
 	return nfs_ok;
 }
 
+static inline void nfsd4_increment_op_stats(u32 opnum)
+{
+	if (opnum >= FIRST_NFS4_OP && opnum <= LAST_NFS4_OP)
+		nfsdstats.nfs4_opcount[opnum]++;
+}
+
 
 /*
  * COMPOUND call.
@@ -930,6 +936,8 @@ encode_op:
 		/* XXX Ugh, we need to get rid of this kind of special case: */
 		if (op->opnum == OP_READ && op->u.read.rd_filp)
 			fput(op->u.read.rd_filp);
+
+		nfsd4_increment_op_stats(op->opnum);
 	}
 
 out:

diff .prev/fs/nfsd/stats.c ./fs/nfsd/stats.c
--- .prev/fs/nfsd/stats.c	2006-07-07 17:29:24.000000000 +1000
+++ ./fs/nfsd/stats.c	2006-07-07 17:36:45.000000000 +1000
@@ -72,6 +72,16 @@ static int nfsd_proc_show(struct seq_fil
 	/* show my rpc info */
 	svc_seq_show(seq, &nfsd_svcstats);
 
+#ifdef CONFIG_NFSD_V4
+	/* Show count for individual nfsv4 operations */
+	/* Writing operation numbers 0 1 2 also for maintaining uniformity */
+	seq_printf(seq,"proc4ops %u", LAST_NFS4_OP + 1);
+	for (i = 0; i <= LAST_NFS4_OP; i++)
+		seq_printf(seq, " %u", nfsdstats.nfs4_opcount[i]);
+
+	seq_putc(seq, '\n');
+#endif
+
 	return 0;
 }
 

diff .prev/include/linux/nfs4.h ./include/linux/nfs4.h
--- .prev/include/linux/nfs4.h	2006-07-07 17:29:24.000000000 +1000
+++ ./include/linux/nfs4.h	2006-07-07 17:29:24.000000000 +1000
@@ -157,6 +157,12 @@ enum nfs_opnum4 {
 	OP_ILLEGAL = 10044,
 };
 
+/*Defining first and last NFS4 operations implemented.
+Needs to be updated if more operations are defined in future.*/
+
+#define FIRST_NFS4_OP	OP_ACCESS
+#define LAST_NFS4_OP 	OP_RELEASE_LOCKOWNER
+
 enum nfsstat4 {
 	NFS4_OK = 0,
 	NFS4ERR_PERM = 1,

diff .prev/include/linux/nfsd/stats.h ./include/linux/nfsd/stats.h
--- .prev/include/linux/nfsd/stats.h	2006-07-07 17:29:24.000000000 +1000
+++ ./include/linux/nfsd/stats.h	2006-07-07 17:34:51.000000000 +1000
@@ -9,6 +9,8 @@
 #ifndef LINUX_NFSD_STATS_H
 #define LINUX_NFSD_STATS_H
 
+#include <linux/nfs4.h>
+
 struct nfsd_stats {
 	unsigned int	rchits;		/* repcache hits */
 	unsigned int	rcmisses;	/* repcache hits */
@@ -27,6 +29,10 @@ struct nfsd_stats {
 	unsigned int	ra_size;	/* size of ra cache */
 	unsigned int	ra_depth[11];	/* number of times ra entry was found that deep
 					 * in the cache (10percentiles). [10] = not found */
+#ifdef CONFIG_NFSD_V4
+	unsigned int	nfs4_opcount[LAST_NFS4_OP + 1];	/* count of individual nfsv4 operations */
+#endif
+
 };
 
 /* thread usage wraps very million seconds (approx one fortnight) */

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
