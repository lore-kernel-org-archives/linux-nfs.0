From: "Shankar Anand" <shanand@novell.com>
Subject: PATCH [1/2] Capture nfsv4 server operations statistics
Date: Tue, 16 May 2006 01:11:18 -0600
Message-ID: <4469C86F.AD69.00CC.0@novell.com>
References: <4469C82B.AD69.00CC.0@novell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=__Part381D1806.0__="
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fftgo-0003QR-Sa
	for nfs@lists.sourceforge.net; Tue, 16 May 2006 00:09:54 -0700
Received: from lucius.provo.novell.com ([137.65.81.172])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fftgo-00084p-EL
	for nfs@lists.sourceforge.net; Tue, 16 May 2006 00:09:54 -0700
To: <nfs@lists.sourceforge.net>
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

This is a MIME message. If you are reading this text, you may want to 
consider changing to a mail reader or gateway that understands how to 
properly handle MIME multipart messages.

--=__Part381D1806.0__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch adds a nfs4 operations count array to nfsd_stats structure.
The count is  incremented in nfsd4_proc_compound() where all the
operations
are handled by the nfsv4 server. This count of individual nfsv4
operations
is also entered into /proc filesystem. 

Submitted by: Shankar Anand <shanand@novell.com>

diff -aurp linux-2.6.17-rc2.old/fs/nfsd/nfs4proc.c
linux-2.6.17-rc2/fs/nfsd/nfs4proc.c
--- linux-2.6.17-rc2.old/fs/nfsd/nfs4proc.c	2006-04-19
08:30:49.000000000 +0530
+++ linux-2.6.17-rc2/fs/nfsd/nfs4proc.c	2006-05-15
21:05:00.000000000 +0530
@@ -54,6 +54,7 @@
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
 #include <linux/nfs4_acl.h>
+#include <linux/nfsd/stats.h>
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
@@ -930,6 +931,10 @@ encode_op:
 		/* XXX Ugh, we need to get rid of this kind of special
case: */
 		if (op->opnum == OP_READ && op->u.read.rd_filp)
 			fput(op->u.read.rd_filp);
+		
+		/* Maintaining count for each nfsv4 operation */
+		if ( (op->opnum >= OP_ACCESS) && ( (op->opnum -
OP_ACCESS) < NFS4_NUMOPS) )
+			nfsdstats.nfs4_opcount[op->opnum -
OP_ACCESS]++;
 	}
 
 out:
diff -aurp linux-2.6.17-rc2.old/fs/nfsd/stats.c
linux-2.6.17-rc2/fs/nfsd/stats.c
--- linux-2.6.17-rc2.old/fs/nfsd/stats.c	2006-04-19
08:30:49.000000000 +0530
+++ linux-2.6.17-rc2/fs/nfsd/stats.c	2006-05-15 21:13:31.000000000
+0530
@@ -72,6 +72,12 @@ static int nfsd_proc_show(struct seq_fil
 	/* show my rpc info */
 	svc_seq_show(seq, &nfsd_svcstats);
 
+	/* show count for individual nfsv4 operations */
+	seq_printf(seq,"proc4ops %u", NFS4_NUMOPS);
+	for (i=0; i<NFS4_NUMOPS; i++)
+		seq_printf(seq, " %u", nfsdstats.nfs4_opcount[i]);
+
+	seq_putc(seq, '\n');
 	return 0;
 }
 
@@ -91,7 +97,12 @@ static const struct file_operations nfsd
 void
 nfsd_stat_init(void)
 {
+	int i;
 	svc_proc_register(&nfsd_svcstats, &nfsd_proc_fops);
+
+	/* Initialising nfsv4 operations counters */
+	for (i=0; i<NFS4_NUMOPS; i++)
+		nfsdstats.nfs4_opcount[i] = 0;
 }
 
 void
diff -aurp linux-2.6.17-rc2.old/include/linux/nfsd/stats.h
linux-2.6.17-rc2/include/linux/nfsd/stats.h
--- linux-2.6.17-rc2.old/include/linux/nfsd/stats.h	2006-04-19
08:30:49.000000000 +0530
+++ linux-2.6.17-rc2/include/linux/nfsd/stats.h	2006-05-15
18:12:30.000000000 +0530
@@ -9,6 +9,8 @@
 #ifndef LINUX_NFSD_STATS_H
 #define LINUX_NFSD_STATS_H
 
+#define NFS4_NUMOPS	37	 
+
 struct nfsd_stats {
 	unsigned int	rchits;		/* repcache hits */
 	unsigned int	rcmisses;	/* repcache hits */
@@ -27,6 +29,7 @@ struct nfsd_stats {
 	unsigned int	ra_size;	/* size of ra cache */
 	unsigned int	ra_depth[11];	/* number of times ra entry was
found that deep
 					 * in the cache (10percentiles).
[10] = not found */
+	unsigned int	nfs4_opcount[NFS4_NUMOPS];	/* count of
individual nfsv4 operations */
 };
 
 /* thread usage wraps very million seconds (approx one fortnight) */


--=__Part381D1806.0__=
Content-Type: text/plain; name="linux-2.6.17-rc2-add-nfs4-server-stats.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="linux-2.6.17-rc2-add-nfs4-server-stats.diff"

This patch adds a nfs4 operations count array to nfsd_stats structure.
The count is  incremented in nfsd4_proc_compound() where all the operations
are handled by the nfsv4 server. This count of individual nfsv4 operations
is also entered into /proc filesystem. 

Submitted by: Shankar Anand <shanand@novell.com>

diff -aurp linux-2.6.17-rc2.old/fs/nfsd/nfs4proc.c linux-2.6.17-rc2/fs/nfsd/nfs4proc.c
--- linux-2.6.17-rc2.old/fs/nfsd/nfs4proc.c	2006-04-19 08:30:49.000000000 +0530
+++ linux-2.6.17-rc2/fs/nfsd/nfs4proc.c	2006-05-15 21:05:00.000000000 +0530
@@ -54,6 +54,7 @@
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
 #include <linux/nfs4_acl.h>
+#include <linux/nfsd/stats.h>
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
@@ -930,6 +931,10 @@ encode_op:
 		/* XXX Ugh, we need to get rid of this kind of special case: */
 		if (op->opnum == OP_READ && op->u.read.rd_filp)
 			fput(op->u.read.rd_filp);
+		
+		/* Maintaining count for each nfsv4 operation */
+		if ( (op->opnum >= OP_ACCESS) && ( (op->opnum - OP_ACCESS) < NFS4_NUMOPS) )
+			nfsdstats.nfs4_opcount[op->opnum - OP_ACCESS]++;
 	}
 
 out:
diff -aurp linux-2.6.17-rc2.old/fs/nfsd/stats.c linux-2.6.17-rc2/fs/nfsd/stats.c
--- linux-2.6.17-rc2.old/fs/nfsd/stats.c	2006-04-19 08:30:49.000000000 +0530
+++ linux-2.6.17-rc2/fs/nfsd/stats.c	2006-05-15 21:13:31.000000000 +0530
@@ -72,6 +72,12 @@ static int nfsd_proc_show(struct seq_fil
 	/* show my rpc info */
 	svc_seq_show(seq, &nfsd_svcstats);
 
+	/* show count for individual nfsv4 operations */
+	seq_printf(seq,"proc4ops %u", NFS4_NUMOPS);
+	for (i=0; i<NFS4_NUMOPS; i++)
+		seq_printf(seq, " %u", nfsdstats.nfs4_opcount[i]);
+
+	seq_putc(seq, '\n');
 	return 0;
 }
 
@@ -91,7 +97,12 @@ static const struct file_operations nfsd
 void
 nfsd_stat_init(void)
 {
+	int i;
 	svc_proc_register(&nfsd_svcstats, &nfsd_proc_fops);
+
+	/* Initialising nfsv4 operations counters */
+	for (i=0; i<NFS4_NUMOPS; i++)
+		nfsdstats.nfs4_opcount[i] = 0;
 }
 
 void
diff -aurp linux-2.6.17-rc2.old/include/linux/nfsd/stats.h linux-2.6.17-rc2/include/linux/nfsd/stats.h
--- linux-2.6.17-rc2.old/include/linux/nfsd/stats.h	2006-04-19 08:30:49.000000000 +0530
+++ linux-2.6.17-rc2/include/linux/nfsd/stats.h	2006-05-15 18:12:30.000000000 +0530
@@ -9,6 +9,8 @@
 #ifndef LINUX_NFSD_STATS_H
 #define LINUX_NFSD_STATS_H
 
+#define NFS4_NUMOPS	37	 
+
 struct nfsd_stats {
 	unsigned int	rchits;		/* repcache hits */
 	unsigned int	rcmisses;	/* repcache hits */
@@ -27,6 +29,7 @@ struct nfsd_stats {
 	unsigned int	ra_size;	/* size of ra cache */
 	unsigned int	ra_depth[11];	/* number of times ra entry was found that deep
 					 * in the cache (10percentiles). [10] = not found */
+	unsigned int	nfs4_opcount[NFS4_NUMOPS];	/* count of individual nfsv4 operations */
 };
 
 /* thread usage wraps very million seconds (approx one fortnight) */

--=__Part381D1806.0__=--


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
