From: "Shankar Anand" <shanand@novell.com>
Subject: Re: PATCH [1/2] Capture nfsv4 server operations statistics
Date: Fri, 19 May 2006 09:23:20 -0600
Message-ID: <446E3040.AD69.00CC.0@novell.com>
References: <4469C82B.AD69.00CC.0@novell.com>
	<20060517213638.GE11237@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=__Part5B7E7FF8.1__="
Return-path: <nfsv4-bounces@linux-nfs.org>
To: "J. Fields" <bfields@fieldses.org>,<nfsv4@linux-nfs.org>,
	<nfs@lists.sourceforge.net>
In-Reply-To: <20060517213638.GE11237@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

This is a MIME message. If you are reading this text, you may want to 
consider changing to a mail reader or gateway that understands how to 
properly handle MIME multipart messages.

--=__Part5B7E7FF8.1__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

Attaching the new patch with changes according to Bruce's comments.

> On 5/18/2006 at 3:06:38 am "J. Bruce Fields" <bfields@fieldses.org>
wrote:
> On Tue, May 16, 2006 at 01:10:10AM -0600, Shankar Anand wrote:
>> This patch adds a nfs4 operations count array to nfsd_stats
structure.
>> The count is  incremented in nfsd4_proc_compound() where all the
>> operations are handled by the nfsv4 server. This count of
individual
>> nfsv4 operations is also entered into /proc filesystem. 
>> 
>> Submitted by: Shankar Anand <shanand@novell.com>
> 
> Note that should be "Signed-off-by:"; see the "Developer's
Certificate
> of Origin" in Documentation/SubmittingPatches.

Changed.
 
>> @@ -91,7 +97,12 @@ static const struct file_operations nfsd
>>  void
>>  nfsd_stat_init(void)
>>  {
>> +	int i;
>>  	svc_proc_register(&nfsd_svcstats, &nfsd_proc_fops);
>> +
>> +	/* Initialising nfsv4 operations counters */
>> +	for (i=0; i<NFS4_NUMOPS; i++)
>> +		nfsdstats.nfs4_opcount[i] = 0;
>>  }
> 
> Hm.  Have you checked whether this compiles when NFSv4 is 
> configured out?

Verified compilation when nfsv4 is configured out. And also 
made changes so that the nfsv4 operation statistics are captured
only when nfsv4 is configured.


--=__Part5B7E7FF8.1__=
Content-Type: text/plain; name="linux-2.6.17-rc2-add-nfs4-server-stats.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-2.6.17-rc2-add-nfs4-server-stats.diff"

This patch adds a nfs4 operations count array to nfsd_stats structure.
The count is  incremented in nfsd4_proc_compound() where all the operations
are handled by the nfsv4 server. This count of individual nfsv4 operations
is also entered into /proc filesystem. 

Signed-off-by: Shankar Anand<shanand@novell.com> 

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
+++ linux-2.6.17-rc2/fs/nfsd/stats.c	2006-05-20 01:51:27.000000000 +0530
@@ -72,6 +72,14 @@ static int nfsd_proc_show(struct seq_fil
 	/* show my rpc info */
 	svc_seq_show(seq, &nfsd_svcstats);
 
+#ifdef	CONFIG_NFS_V4
+	/* show count for individual nfsv4 operations */
+	seq_printf(seq,"proc4ops %u", NFS4_NUMOPS);
+	for (i=0; i<NFS4_NUMOPS; i++)
+		seq_printf(seq, " %u", nfsdstats.nfs4_opcount[i]);
+
+	seq_putc(seq, '\n');
+#endif
 	return 0;
 }
 
@@ -91,6 +99,12 @@ static const struct file_operations nfsd
 void
 nfsd_stat_init(void)
 {
+#ifdef	CONFIG_NFS_V4
+	int i;
+	/* Initialising nfsv4 operations counters */
+	for (i=0; i<NFS4_NUMOPS; i++)
+		nfsdstats.nfs4_opcount[i] = 0;
+#endif
 	svc_proc_register(&nfsd_svcstats, &nfsd_proc_fops);
 }
 
diff -aurp linux-2.6.17-rc2.old/include/linux/nfsd/stats.h linux-2.6.17-rc2/include/linux/nfsd/stats.h
--- linux-2.6.17-rc2.old/include/linux/nfsd/stats.h	2006-04-19 08:30:49.000000000 +0530
+++ linux-2.6.17-rc2/include/linux/nfsd/stats.h	2006-05-20 01:47:42.000000000 +0530
@@ -9,6 +9,10 @@
 #ifndef LINUX_NFSD_STATS_H
 #define LINUX_NFSD_STATS_H
 
+#ifdef	CONFIG_NFSD_V4
+#define NFS4_NUMOPS	37
+#endif
+
 struct nfsd_stats {
 	unsigned int	rchits;		/* repcache hits */
 	unsigned int	rcmisses;	/* repcache hits */
@@ -27,6 +31,9 @@ struct nfsd_stats {
 	unsigned int	ra_size;	/* size of ra cache */
 	unsigned int	ra_depth[11];	/* number of times ra entry was found that deep
 					 * in the cache (10percentiles). [10] = not found */
+#ifdef  CONFIG_NFSD_V4
+	unsigned int	nfs4_opcount[NFS4_NUMOPS];	/* count of individual nfsv4 operations */
+#endif
 };
 
 /* thread usage wraps very million seconds (approx one fortnight) */

--=__Part5B7E7FF8.1__=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--=__Part5B7E7FF8.1__=--
