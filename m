Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f194.google.com ([209.85.166.194]:34964 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729439AbeJAVUb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:31 -0400
Received: by mail-it1-f194.google.com with SMTP id p64-v6so4680427itp.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:22 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/15] SUNRPC: Add lockless lookup of the server's auth domain
Date: Mon,  1 Oct 2018 10:41:44 -0400
Message-Id: <20181001144157.3515-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-2-trond.myklebust@hammerspace.com>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid taking the global auth_domain_lock in most lookups of the auth domain
by adding an RCU protected lookup.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/svcauth.h    |  1 +
 net/sunrpc/auth_gss/svcauth_gss.c |  9 ++++++++-
 net/sunrpc/svcauth.c              | 22 +++++++++++++++++++---
 net/sunrpc/svcauth_unix.c         | 10 ++++++++--
 4 files changed, 36 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index 04e404a07882..3e53a6e2ada7 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -82,6 +82,7 @@ struct auth_domain {
 	struct hlist_node	hash;
 	char			*name;
 	struct auth_ops		*flavour;
+	struct rcu_head		rcu_head;
 };
 
 /*
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 860f2a1bbb67..87c71fb0f0ea 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1764,14 +1764,21 @@ svcauth_gss_release(struct svc_rqst *rqstp)
 }
 
 static void
-svcauth_gss_domain_release(struct auth_domain *dom)
+svcauth_gss_domain_release_rcu(struct rcu_head *head)
 {
+	struct auth_domain *dom = container_of(head, struct auth_domain, rcu_head);
 	struct gss_domain *gd = container_of(dom, struct gss_domain, h);
 
 	kfree(dom->name);
 	kfree(gd);
 }
 
+static void
+svcauth_gss_domain_release(struct auth_domain *dom)
+{
+	call_rcu(&dom->rcu_head, svcauth_gss_domain_release_rcu);
+}
+
 static struct auth_ops svcauthops_gss = {
 	.name		= "rpcsec_gss",
 	.owner		= THIS_MODULE,
diff --git a/net/sunrpc/svcauth.c b/net/sunrpc/svcauth.c
index f83443856cd1..775b8c94265b 100644
--- a/net/sunrpc/svcauth.c
+++ b/net/sunrpc/svcauth.c
@@ -143,10 +143,11 @@ static struct hlist_head	auth_domain_table[DN_HASHMAX];
 static DEFINE_SPINLOCK(auth_domain_lock);
 
 static void auth_domain_release(struct kref *kref)
+	__releases(&auth_domain_lock)
 {
 	struct auth_domain *dom = container_of(kref, struct auth_domain, ref);
 
-	hlist_del(&dom->hash);
+	hlist_del_rcu(&dom->hash);
 	dom->flavour->domain_release(dom);
 	spin_unlock(&auth_domain_lock);
 }
@@ -175,7 +176,7 @@ auth_domain_lookup(char *name, struct auth_domain *new)
 		}
 	}
 	if (new)
-		hlist_add_head(&new->hash, head);
+		hlist_add_head_rcu(&new->hash, head);
 	spin_unlock(&auth_domain_lock);
 	return new;
 }
@@ -183,6 +184,21 @@ EXPORT_SYMBOL_GPL(auth_domain_lookup);
 
 struct auth_domain *auth_domain_find(char *name)
 {
-	return auth_domain_lookup(name, NULL);
+	struct auth_domain *hp;
+	struct hlist_head *head;
+
+	head = &auth_domain_table[hash_str(name, DN_HASHBITS)];
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(hp, head, hash) {
+		if (strcmp(hp->name, name)==0) {
+			if (!kref_get_unless_zero(&hp->ref))
+				hp = NULL;
+			rcu_read_unlock();
+			return hp;
+		}
+	}
+	rcu_read_unlock();
+	return NULL;
 }
 EXPORT_SYMBOL_GPL(auth_domain_find);
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index af7f28fb8102..84cf39021a03 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -37,20 +37,26 @@ struct unix_domain {
 extern struct auth_ops svcauth_null;
 extern struct auth_ops svcauth_unix;
 
-static void svcauth_unix_domain_release(struct auth_domain *dom)
+static void svcauth_unix_domain_release_rcu(struct rcu_head *head)
 {
+	struct auth_domain *dom = container_of(head, struct auth_domain, rcu_head);
 	struct unix_domain *ud = container_of(dom, struct unix_domain, h);
 
 	kfree(dom->name);
 	kfree(ud);
 }
 
+static void svcauth_unix_domain_release(struct auth_domain *dom)
+{
+	call_rcu(&dom->rcu_head, svcauth_unix_domain_release_rcu);
+}
+
 struct auth_domain *unix_domain_find(char *name)
 {
 	struct auth_domain *rv;
 	struct unix_domain *new = NULL;
 
-	rv = auth_domain_lookup(name, NULL);
+	rv = auth_domain_find(name);
 	while(1) {
 		if (rv) {
 			if (new && rv != &new->h)
-- 
2.17.1
