Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 058E0C31D9B
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:04:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EDB2620717
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:04:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729029AbfDYOEc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 10:04:32 -0400
Received: from fieldses.org ([173.255.197.46]:50912 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727950AbfDYOEY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 10:04:24 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id EC8552012; Thu, 25 Apr 2019 10:04:22 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        jlayton@redhat.com, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/10] nfsd4: add file to display list of client's opens
Date:   Thu, 25 Apr 2019 10:04:18 -0400
Message-Id: <1556201060-7947-9-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1556201060-7947-1-git-send-email-bfields@redhat.com>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Add a nfsd/clients/#/opens file to list some information about all the
opens held by the given client.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 100 +++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 98 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 928705fc8ff5..829d1e5440d3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -684,7 +684,8 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&cl->cl_lock);
-	new_id = idr_alloc_cyclic(&cl->cl_stateids, stid, 0, 0, GFP_NOWAIT);
+	/* Reserving 0 for start of file in nfsdfs "opens" file: */
+	new_id = idr_alloc_cyclic(&cl->cl_stateids, stid, 1, 0, GFP_NOWAIT);
 	spin_unlock(&cl->cl_lock);
 	idr_preload_end();
 	if (new_id < 0)
@@ -2223,9 +2224,104 @@ static const struct file_operations client_info_fops = {
 	.release	= single_release,
 };
 
+static void *opens_start(struct seq_file *s, loff_t *pos)
+	__acquires(&clp->cl_lock)
+{
+	struct nfs4_client *clp = s->private;
+	unsigned long id = *pos;
+	void *ret;
+
+	spin_lock(&clp->cl_lock);
+	ret = idr_get_next_ul(&clp->cl_stateids, &id);
+	*pos = id;
+	return ret;
+}
+
+static void *opens_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	struct nfs4_client *clp = s->private;
+	unsigned long id = *pos;
+	void *ret;
+
+	id = *pos;
+	id++;
+	ret = idr_get_next_ul(&clp->cl_stateids, &id);
+	*pos = id;
+	return ret;
+}
+
+static void opens_stop(struct seq_file *s, void *v)
+	__releases(&clp->cl_lock)
+{
+	struct nfs4_client *clp = s->private;
+
+	spin_unlock(&clp->cl_lock);
+}
+
+static int opens_show(struct seq_file *s, void *v)
+{
+	struct nfs4_stid *st = v;
+	struct nfs4_ol_stateid *os;
+	u64 stateid;
+
+	if (st->sc_type != NFS4_OPEN_STID)
+		return 0; /* XXX: or SEQ_SKIP? */
+	os = openlockstateid(st);
+	/* XXX: get info about file, etc., here */
+
+	memcpy(&stateid, &st->sc_stateid, sizeof(stateid));
+	seq_printf(s, "stateid: %llx\n", stateid);
+	return 0;
+}
+
+static struct seq_operations opens_seq_ops = {
+	.start = opens_start,
+	.next = opens_next,
+	.stop = opens_stop,
+	.show = opens_show
+};
+
+static int client_opens_open(struct inode *inode, struct file *file)
+{
+	struct nfsdfs_client *nc;
+	struct seq_file *s;
+	struct nfs4_client *clp;
+	int ret;
+
+	nc = get_nfsdfs_client(inode);
+	if (!nc)
+		return -ENXIO;
+	clp = container_of(nc, struct nfs4_client, cl_nfsdfs);
+
+	ret = seq_open(file, &opens_seq_ops);
+	if (ret)
+		return ret;
+	s = file->private_data;
+	s->private = clp;
+	return 0;
+}
+
+static int client_opens_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *m = file->private_data;
+	struct nfs4_client *clp = m->private;
+
+	/* XXX: alternatively, we could get/drop in seq start/stop */
+	drop_client(clp);
+	return 0;
+}
+
+static const struct file_operations client_opens_fops = {
+	.open		= client_opens_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= client_opens_release,
+};
+
 static const struct tree_descr client_files[] = {
 	[0] = {"info", &client_info_fops, S_IRUSR},
-	[1] = {""},
+	[1] = {"open", &client_opens_fops, S_IRUSR},
+	[2] = {""},
 };
 
 static struct nfs4_client *create_client(struct xdr_netobj name,
-- 
2.20.1

