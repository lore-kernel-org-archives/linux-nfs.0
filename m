Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:19903 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755996Ab1LNKpI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 05:45:08 -0500
Subject: [PATCH 01/11] SYSCTL: export root and set handling routines
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 14 Dec 2011 14:44:49 +0300
Message-ID: <20111214104449.3991.61989.stgit@localhost6.localdomain6>
In-Reply-To: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These routines are required for making SUNRPC sysctl's per network namespace
context.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sysctl.h |    1 +
 kernel/sysctl.c        |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 703cfa3..be586a9 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1084,6 +1084,7 @@ struct ctl_path {
 };
 
 void register_sysctl_root(struct ctl_table_root *root);
+void unregister_sysctl_root(struct ctl_table_root *root);
 struct ctl_table_header *__register_sysctl_paths(
 	struct ctl_table_root *root, struct nsproxy *namespaces,
 	const struct ctl_path *path, struct ctl_table *table);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ae27196..fb016a9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1700,6 +1700,15 @@ void register_sysctl_root(struct ctl_table_root *root)
 	list_add_tail(&root->root_list, &sysctl_table_root.root_list);
 	spin_unlock(&sysctl_lock);
 }
+EXPORT_SYMBOL_GPL(register_sysctl_root);
+
+void unregister_sysctl_root(struct ctl_table_root *root)
+{
+	spin_lock(&sysctl_lock);
+	list_del(&root->root_list);
+	spin_unlock(&sysctl_lock);
+}
+EXPORT_SYMBOL_GPL(unregister_sysctl_root);
 
 /*
  * sysctl_perm does NOT grant the superuser all rights automatically, because
@@ -1925,6 +1934,7 @@ struct ctl_table_header *__register_sysctl_paths(
 
 	return header;
 }
+EXPORT_SYMBOL_GPL(__register_sysctl_paths);
 
 /**
  * register_sysctl_table_path - register a sysctl table hierarchy
@@ -2007,6 +2017,7 @@ void setup_sysctl_set(struct ctl_table_set *p,
 	p->parent = parent ? parent : &sysctl_table_root.default_set;
 	p->is_seen = is_seen;
 }
+EXPORT_SYMBOL_GPL(setup_sysctl_set);
 
 #else /* !CONFIG_SYSCTL */
 struct ctl_table_header *register_sysctl_table(struct ctl_table * table)

