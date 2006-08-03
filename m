From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 1/4] Add register_sysctl_table_path function
Date: Thu, 3 Aug 2006 13:05:37 +0200
Message-ID: <20060803110537.GA17163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8b1J-0007dg-7g
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 04:05:41 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8b1J-0001dU-3x
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 04:05:41 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 1F62C1FD0E
	for <nfs@lists.sourceforge.net>; Thu,  3 Aug 2006 13:05:38 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

From: Olaf Kirch <okir@suse.de>
Subject: Add register_sysctl_table_path function

  There are a number of modules that register a sysctl table
  somewhere deeply nested in the sysctl hierarchy, such as
  fs/nfs, fs/xfs, dev/cdrom, etc.

  They all specify several dummy ctl_tables for the path name.
  This patch implements register_sysctl_table_path that takes
  an additional path name, and makes up dummy sysctl nodes
  for each component.

Signed-off-by: Olaf Kirch <okir@suse.de>

 include/linux/sysctl.h |   10 ++++++
 kernel/sysctl.c        |   79 +++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 87 insertions(+), 2 deletions(-)

Index: linux-2.6.18/include/linux/sysctl.h
===================================================================
--- linux-2.6.18.orig/include/linux/sysctl.h
+++ linux-2.6.18/include/linux/sysctl.h
@@ -1006,8 +1006,18 @@ struct ctl_table_header
 	struct completion *unregistering;
 };
 
+/* struct ctl_path describes where in the hierarchy a table is added */
+struct ctl_path
+{
+	int ctl_name;
+	const char *procname;
+	mode_t mode;
+};
+
 struct ctl_table_header * register_sysctl_table(ctl_table * table, 
 						int insert_at_head);
+struct ctl_table_header * register_sysctl_table_path(ctl_table *table,
+						struct ctl_path *path);
 void unregister_sysctl_table(struct ctl_table_header * table);
 
 #else /* __KERNEL__ */
Index: linux-2.6.18/kernel/sysctl.c
===================================================================
--- linux-2.6.18.orig/kernel/sysctl.c
+++ linux-2.6.18/kernel/sysctl.c
@@ -135,6 +135,7 @@ static int parse_table(int __user *, int
 		       ctl_table *, void **);
 static int proc_doutsstring(ctl_table *table, int write, struct file *filp,
 		  void __user *buffer, size_t *lenp, loff_t *ppos);
+static void __insert_sysctl_table(struct ctl_table_header *, int);
 
 static ctl_table root_table[];
 static struct ctl_table_header root_table_header =
@@ -1353,6 +1354,74 @@ struct ctl_table_header *register_sysctl
 	if (!tmp)
 		return NULL;
 	tmp->ctl_table = table;
+	__insert_sysctl_table(tmp, insert_at_head);
+	return tmp;
+}
+
+/**
+ * register_sysctl_table_path - register a systl table below a given node
+ * @npath: The number of entries in the path array.
+ * @path: An array of ctl_path items. We assume that the procname strings
+ *        are valid for the lifetime of the registration.
+ * @table: the table structure to register
+ *
+ * This works like register_sysctl_table except that the table isn't
+ * registered at the sysctl root, but at the specified location in the
+ * sysctl hierarchy
+ */
+struct ctl_table_header *register_sysctl_table_path(ctl_table *table,
+				struct ctl_path *path)
+{
+	struct ctl_table_header *header;
+	struct ctl_table *new, **prevp;
+	unsigned int	n, npath;
+
+	/* Count the path components. If the path is empty,
+	 * fall back to the normal register_sysctl_table() */
+	for (npath = 0; path[npath].procname; ++npath)
+		;
+
+	if (npath == 0)
+		return register_sysctl_table(table, 0);
+
+	/* For each path component, allocate a 2-element ctl_table array.
+	 * The first array element will be filled with the sysctl entry
+	 * for this, the second will be the sentinel (ctl_name == 0).
+	 *
+	 * We allocate everything in one go so that we don't have to
+	 * worry about freeing additional memory in unregister_sysctl_table.
+	 */
+	header = kzalloc(sizeof(struct ctl_table_header)
+			+ 2 * npath * sizeof(struct ctl_table), GFP_KERNEL);
+	if (!header)
+		return NULL;
+	new = (struct ctl_table *) (header + 1);
+
+	/* Now connect the dots */
+	prevp = &header->ctl_table;
+	for (n = 0; n < npath; ++n, ++path) {
+		/* Copy the procname */
+		new->procname = path->procname;
+		new->ctl_name = path->ctl_name;
+		new->mode     = path->mode;
+
+		*prevp = new;
+		prevp = &new->child;
+
+		new += 2;
+	}
+
+	*prevp = table;
+	__insert_sysctl_table(header, 0);
+	return header;
+}
+
+/*
+ * Insert ctl_table_header into hierarchy
+ */
+void __insert_sysctl_table(struct ctl_table_header * tmp,
+			int insert_at_head)
+{
 	INIT_LIST_HEAD(&tmp->ctl_entry);
 	tmp->used = 0;
 	tmp->unregistering = NULL;
@@ -1363,9 +1432,8 @@ struct ctl_table_header *register_sysctl
 		list_add_tail(&tmp->ctl_entry, &root_table_header.ctl_entry);
 	spin_unlock(&sysctl_lock);
 #ifdef CONFIG_PROC_FS
-	register_proc_table(table, proc_sys_root, tmp);
+	register_proc_table(tmp->ctl_table, proc_sys_root, tmp);
 #endif
-	return tmp;
 }
 
 /**
@@ -2493,6 +2561,12 @@ struct ctl_table_header * register_sysct
 	return NULL;
 }
 
+struct ctl_table_header * register_sysctl_table_path(ctl_table * table,
+						struct ctl_path * path)
+{
+	return NULL;
+}
+
 void unregister_sysctl_table(struct ctl_table_header * table)
 {
 }
@@ -2512,6 +2586,7 @@ EXPORT_SYMBOL(proc_dostring);
 EXPORT_SYMBOL(proc_doulongvec_minmax);
 EXPORT_SYMBOL(proc_doulongvec_ms_jiffies_minmax);
 EXPORT_SYMBOL(register_sysctl_table);
+EXPORT_SYMBOL(register_sysctl_table_path);
 EXPORT_SYMBOL(sysctl_intvec);
 EXPORT_SYMBOL(sysctl_jiffies);
 EXPORT_SYMBOL(sysctl_ms_jiffies);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
