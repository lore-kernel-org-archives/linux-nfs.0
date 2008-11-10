From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 51/51] nfsd41: print DRC statistics
Date: Mon, 10 Nov 2008 22:58:14 +0200
Message-ID: <1226350694-12043-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:44382 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbYKJU60 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:58:26 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Add page-use counters to the cache entry. Add a proc file to trigger printing
the session, slot, and DRC statistics for a client ipv4 address.

To print the DRC stats for an IP address:
  echo "192.168.1.106" > /proc/fs/nfsd/nfsv41_DRC_printstats

To reset all slot counters on all clients:
  echo "0.0.0.0" > /proc/fs/nfsd/nfsv41_DRC_printstats

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |   95 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsctl.c           |   52 ++++++++++++++++++++++++
 include/linux/nfsd/nfsd.h  |    8 ++++
 include/linux/nfsd/state.h |    4 ++
 4 files changed, 159 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0d8fde7..3a8d5c7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1018,6 +1018,100 @@ nfsd41_set_statp(struct svc_rqst *rqstp, __be32 *statp)
 	resp->statp = statp;
 }
 
+static void
+nfsd4_print_slotstats(struct nfs41_slot *slot)
+{
+	struct nfs41_cache_entry *e = &slot->sl_cache_entry;
+
+	printk(KERN_INFO " sequence number               %d\n", slot->sl_seqid);
+	printk(KERN_INFO " pages cached                  %d\n", e->ce_resused);
+	printk(KERN_INFO " total pages cached            %lu\n",
+		e->ce_total_pages);
+	printk(KERN_INFO " lowest # pages per request    %lu\n",
+		e->ce_lowest_pages);
+	printk(KERN_INFO " higest # pages per request    %lu\n",
+		e->ce_highest_pages);
+}
+
+static void
+nfsd4_reset_slotstats(struct nfs41_slot *slot)
+{
+	struct nfs41_cache_entry *e = &slot->sl_cache_entry;
+
+	e->ce_total_pages = e->ce_lowest_pages = e->ce_highest_pages = 0;
+}
+
+static void
+nfsd4_drc_printstats(struct nfs4_client *clp, int reset)
+{
+	struct nfs41_session *ses;
+	struct nfsd_sessionid *id;
+	int i;
+
+	printk(KERN_INFO "\n----- DRC Stats for %u.%u.%u.%u -----\n",
+		NIPQUAD(clp->cl_addr));
+	if (reset)
+		printk(KERN_INFO "         ------ RESET ------\n");
+	list_for_each_entry(ses, &clp->cl_sessions, se_perclnt) {
+		id = (struct nfsd_sessionid *)ses;
+		printk(KERN_INFO " -- Sessionid:[clientid] %x%x [boot]"
+			"%x [seq] %x -- \n",
+			id->clientid.cl_boot, id->clientid.cl_id,
+			id->boot_time, id->sequence);
+		printk(KERN_INFO "   Forward Channel\n\n");
+		printk(KERN_INFO "     headerpad          %d\n",
+			ses->se_fheaderpad_sz);
+		printk(KERN_INFO "     maxreq size        %d\n",
+			ses->se_fmaxreq_sz);
+		printk(KERN_INFO "     maxresp size       %d\n",
+			ses->se_fmaxresp_sz);
+		printk(KERN_INFO "     maxresp (numslots) %d\n",
+			ses->se_fmaxresp_cached);
+		printk(KERN_INFO "     maxops             %d\n",
+			ses->se_fmaxops);
+		for (i = 0; i < ses->se_forward.ch_maxreqs; i++) {
+			printk(KERN_INFO "\n----- Slot # %d -------\n", i);
+			if (reset)
+				nfsd4_reset_slotstats(&ses->se_slots[i]);
+			else
+				nfsd4_print_slotstats(&ses->se_slots[i]);
+		}
+	}
+	printk(KERN_INFO "\n\n   Create Session Slot\n\n");
+	nfsd4_print_slotstats(&clp->cl_slot);
+	printk(KERN_INFO "\n--------- DRC Slot Stats End ---------\n\n");
+}
+
+void
+nfsd4_do_drcstats(__be32 ip4addr)
+{
+	struct nfs4_client *clp = NULL;
+	int i;
+
+	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
+		list_for_each_entry(clp, &conf_id_hashtbl[i], cl_idhash) {
+			if (ip4addr == 0)
+				nfsd4_drc_printstats(clp, 1);
+			else if (!memcmp(&clp->cl_addr, &ip4addr,
+							sizeof(__be32))) {
+				nfsd4_drc_printstats(clp, 0);
+				break;
+			}
+		}
+	}
+}
+
+static void
+nfs4_set_drc_stats(struct svc_rqst *rqstp, struct nfs41_cache_entry *entry)
+{
+	if (entry->ce_lowest_pages == 0 ||
+	    rqstp->rq_resused < entry->ce_lowest_pages)
+		entry->ce_lowest_pages = rqstp->rq_resused;
+	if (rqstp->rq_resused > entry->ce_highest_pages)
+		entry->ce_highest_pages = rqstp->rq_resused;
+	entry->ce_total_pages += rqstp->rq_resused;
+}
+
 /*
  * Cache the reply pages, clearing the previous pages.
  * Store the base and length of the rq_req.head[0] page
@@ -1038,6 +1132,7 @@ nfsd41_set_cache_entry(struct nfsd4_compoundres *resp)
 	if (resp->opcnt == 1 && resp->status && slot->sl_session)
 		return;
 	spin_lock(&entry->ce_lock);
+	nfs4_set_drc_stats(rqstp, entry);
 	nfsd4_clear_respages(entry->ce_respages, entry->ce_resused);
 	nfsd4_cache_rqst_pages(rqstp, entry->ce_respages, &entry->ce_resused);
 	entry->ce_status = resp->status;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e3f9783..e7f850a 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -71,6 +71,9 @@ enum {
 	NFSD_Leasetime,
 	NFSD_RecoveryDir,
 #endif
+#ifdef CONFIG_NFSD_V4_1
+	NFSD_DRC_print_stats,
+#endif /* CONFIG_NFSD_V4_1 */
 };
 
 /*
@@ -93,6 +96,9 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size);
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
+#ifdef CONFIG_NFSD_V4_1
+static ssize_t write_drcstats(struct file *file, char *buf, size_t size);
+#endif /* CONFIG_NFSD_V4_1 */
 
 static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size);
 static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size);
@@ -117,6 +123,9 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Leasetime] = write_leasetime,
 	[NFSD_RecoveryDir] = write_recoverydir,
 #endif
+#ifdef CONFIG_NFSD_V4_1
+	[NFSD_DRC_print_stats] = write_drcstats,
+#endif /* CONFIG_NFSD_V4_1 */
 };
 
 static ssize_t nfsctl_transaction_write(struct file *file, const char __user *buf, size_t size, loff_t *pos)
@@ -727,6 +736,45 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 	return sprintf(buf, "%d\n", nfsd_max_blksize);
 }
 
+#ifdef CONFIG_NFSD_V4_1
+static ssize_t __write_drcstats(struct file *file, char *buf, size_t size)
+{
+	char *mesg = buf;
+	char *ip4addr = NULL;
+	int len;
+	__be32 cl_addr = 0;
+	u8 *addr = (u8 *)&cl_addr;
+
+	if (size > 0) {
+		if (size > PATH_MAX || buf[size-1] != '\n')
+			return -EINVAL;
+		buf[size-1] = 0;
+
+		ip4addr = mesg;
+		len = qword_get(&mesg, ip4addr, size);
+		if (len <= 0)
+			return -EINVAL;
+		if (!(in4_pton(ip4addr, len, addr, '\0', NULL)))
+			return -EINVAL;
+		nfsd4_do_drcstats(cl_addr);
+	}
+	if (!ip4addr)
+		return 0;
+	sprintf(buf, "%s\n", ip4addr);
+	return strlen(buf);
+}
+
+static ssize_t write_drcstats(struct file *file, char *buf, size_t size)
+{
+	ssize_t rv;
+
+	mutex_lock(&nfsd_mutex);
+	rv = __write_drcstats(file, buf, size);
+	mutex_unlock(&nfsd_mutex);
+	return rv;
+}
+
+#endif /* CONFIG_NFSD_V4_1 */
 #ifdef CONFIG_NFSD_V4
 extern time_t nfs4_leasetime(void);
 
@@ -830,6 +878,10 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
 #endif
+#ifdef CONFIG_NFSD_V4_1
+		[NFSD_DRC_print_stats] =
+		   {"nfsv41_DRC_printstats", &transaction_ops, S_IWUSR|S_IRUSR},
+#endif /* CONFIG_NFSD_V4_1 */
 		/* last one */ {""}
 	};
 	return simple_fill_super(sb, 0x6e667364, nfsd_files);
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index c8bbe94..e31a4f6 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -181,6 +181,14 @@ static inline void nfs4_reset_lease(time_t leasetime) { }
 static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
 #endif
 
+#ifdef CONFIG_NFSD_V4_1
+void nfsd4_do_drcstats(__be32 ip4addr);
+#else
+static inline void nfsd4_do_drcstats(__be32 client_ip4addr) {}
+#endif /* CONFIG_NFSD_V4_1 */
+
+
+
 /*
  * lockd binding
  */
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index a336687..03aaba4 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -131,6 +131,10 @@ struct nfs41_cache_entry {
 	struct kvec	ce_datav; /* encoded NFSv4.1 data in rq_res.head[0] */
 	struct page	*ce_respages[RPCSVC_MAXPAGES];
 	short		ce_resused;
+	/* slot page stats */
+	unsigned long	ce_total_pages;
+	unsigned long	ce_lowest_pages;
+	unsigned long	ce_highest_pages;
 };
 
 /*
-- 
1.6.0.2

