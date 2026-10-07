Received: from mail-oa1-f53.google.com (mail-oa1-f53.google.com [209.85.160.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C910B4E780D
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 19:59:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791403186; cv=none; b=g7lP92M676slMDTsWmQnpM4RuOzD3GKjGC3rvvBvSHeOwSk3/RuBskueRlpVrusCvEFfZfy1MqibIgofpMq7vPbqO0rP5CRXtWc1rp0siSUZH5oCMIb44W0YYtz09xMBSPtnhB012+wWJ0/8E8uka5q4k2FOSwDlXtjxWZZf/e8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791403186; c=relaxed/simple;
	bh=EK1zeNb8sTfIf36JzFiBKb5UW3sCxWtotr6m5+yejkc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TobzFyM6E7gqd60F5xdsuUm8+9ZtseDzo/lMAZCFZZDRQXiDZ3bLl+dpGLFk8d5c3ClCkRusu4S73hNEdVQKWIyBJvTFDxyMmzuK3jCu+LW5AuN8hpVD6QgJv7o+dGdb9/xKuRIfZWDVpEy47qRKU8j6aon0hlCpCqIpX6QPZYM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=oeh1CS9b; arc=none smtp.client-ip=209.85.160.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="oeh1CS9b"
Received: by mail-oa1-f53.google.com with SMTP id 586e51a60fabf-483d290f398so1225668fac.2
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2026 12:59:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791403182; x=1792007982; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=M2QNpsCC1cNKN14sgObo10I1kJuux/DlvVD2dSC+OQ4=;
        b=oeh1CS9bxCX6KW7RN+JpiwgO2qWvAD1xywlLqEfgN83KP57vZTFyUC1qmYTi/9D4Uj
         myTue6tHyUxiCTQcmzBZO4d/zsaqY8gb/9vALGv65XY6llJ5JsFUaDayE0HTBjmBPZu+
         iYQptDXr1HvluFk2kmhj5IcyLvEWchJ7UWOZLhSqsa70R6gv1Ugu5vceLTVL03myHT8/
         kf7VZ+XLT2tA5HTZK6OxLEAfOExRgSEwG/Z0w24LVwaOx0qkyXHSofZ1IO9OM1ADqwET
         Me9A2PNG8E1gIip/FzcrR8tVlhlMK0yq8n5Shma9OmYQBh8ZJ9Bfxp1ThHhpCZTEgL0t
         V8Dw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791403182; x=1792007982;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=M2QNpsCC1cNKN14sgObo10I1kJuux/DlvVD2dSC+OQ4=;
        b=fOqLla7jgqBPazopm9LKB8U0eZ7H8tPKvdxUP6q099uXPBCTj0QFdqJ54Bh2Rlqiia
         4yMDkcBMj6PIYA4dY9uzrx3pVKY/3HWFU8iYNDPcU5MTsnLj3fiEF40MRNe+voZyKBBm
         mL21Ym9itxDFMj1NtMa3tX1mX8istBdJ6kKuAj6X6JJGchmgXkGSxl6+jfK6wNhI7tvI
         jvbyHVflRx4qgpkhMAajvDVWQGXpQ/XOW11/VzfMiAlOwtiSCr/jQUg1iBXWDJoRVMlv
         W5cbS/F+SuA7zfkcBZuTZngZdoHVsAN7JfIYZJdQtuOWyH74E7A1OhYHqa5avx2SCi5d
         SimA==
X-Gm-Message-State: AFuF++liH18ByogPh/q8Inqs9Drd07Hl8r++5MVFUJ496/HIfx0c/zON
	vedncI15WJ1NZAlqXTFvxn5xkIqqkh3KEXvyNZ0vkWia0d3mvYIVC544wBCAkBCQmQIL1UQUrmn
	2hHd7
X-Gm-Gg: AYBFou0uiOJ/Fy5dGg4sMUFrb3k/GhoinpnfzBrKc9ieKdYSWYrKDZ7xLl9NAiHcc6g
	CT33jdR3tJFiegzDiE4EeUm08MVZGr9U3Bd1Ah3losdNjMvagb6A459bQzjy/8iELunI/MWXsoP
	nih4C+UvJH6+GXdbA5CfbNWkmDj+krh1rQ1lhCCpy1F7SDIesALRV63x7mGKNheB5s6bh5GpTjL
	mJieoT8YAoFZhMjIAuFSRF+raOQR9CSDYrTUSOALETzGqb2ZJNHbFBCqfaUC88bNjJc32Te33LC
	C8fZQIfhMe7OTW4h+0gIWYNMNM+mEXoq8Bi7bi6rJrZ4Xr6rKlJst6CbzKm0sEYc1cJhJTGhwSb
	hKZQVV5tlun6Wi+D1Le0QXe/ZKlGN/7hLExSeEYICsUUIrwHIIqn2mlPVDalHhzIs3jBb4c8jmG
	YXnppIJZpdxeBMLgOzNM7x4TD+SC22vm/KD/nbypVmphos6nwGnhi670aWqG8Cw7PBfyeLlzzXI
	xXA23DLTBka7/hBIF9PfoAZV2SnEUEUaqySwJrROg==
X-Received: by 2002:a05:6870:46a8:b0:49d:cc3f:a9e1 with SMTP id 586e51a60fabf-4a2595ec6e9mr3051906fac.45.1791403182288;
        Wed, 07 Oct 2026 12:59:42 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a274c9c520sm1084285fac.16.2026.10.07.12.59.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Oct 2026 12:59:41 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>,
	bpf@vger.kernel.org,
	Martin KaFai Lau <martin.lau@linux.dev>
Subject: [PATCH RFC v2 3/9] SUNRPC: add a BPF struct_ops hook to classify accepted transports
Date: Wed,  7 Oct 2026 15:59:28 -0400
Message-ID: <e4ad144ab880f7fffba5b0b27adb11710098fc01.1791402701.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1791402701.git.bcodding@hammerspace.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

Which transports should share turns at a service is site policy: one
server wants every host served alike, another wants a set of bulk
movers to count as one peer while its interactive clients are served
per host, and a server behind a NAT or a re-export gateway wants the
gateway's address split some other way.  The kernel has no good basis
for choosing, and the address table this started as would need its own
configuration interface and a userspace tool to fill it.

Let the administrator supply the classification instead.  Add
struct svc_classifier, a BPF struct_ops with one callback that is
handed each accepted svc_xprt, in process context with its peer and
local addresses set, and returns an SVC_CLASS_* value: SVC_CLASS_NONE
to leave the transport on the anonymous client, a class number shared
by every transport in that class, or a class number with
SVC_CLASS_PER_ADDR set for one client per peer address within the
class.  A program keyed on an address-prefix map does the whole job in
a few lines.  The callback runs under rcu_read_lock(), so sleepable
programs are refused.

Attaching a classifier (a struct_ops link) binds it to the attaching
task's network namespace, one per namespace and one namespace per
instance; a second attach fails with -EBUSY, a link update replaces
it, detaching or closing the link removes it, and a namespace that
exits leaves its link with nothing behind it.  The classifier applies
to every RPC service in the namespace; a program that cares which one
reads xpt_server->sv_name.  Transports keep the class they were given
at accept, so a change of classifier affects new connections only.

With no classifier attached, or with CONFIG_SUNRPC_BPF_CLASSIFY off,
svc_classify() returns SVC_CLASS_NONE and nothing changes.  The
struct_ops registers from sunrpc's module init; a module without BTF
registers nothing, and the BPF core says so when the configuration
promised module BTF.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 include/linux/sunrpc/svc.h      |  24 ++++
 include/linux/sunrpc/svc_xprt.h |  15 +++
 net/sunrpc/Kconfig              |  12 ++
 net/sunrpc/Makefile             |   1 +
 net/sunrpc/netns.h              |   4 +
 net/sunrpc/sunrpc_syms.c        |   4 +
 net/sunrpc/svc_classify.c       | 200 ++++++++++++++++++++++++++++++++
 7 files changed, 260 insertions(+)
 create mode 100644 net/sunrpc/svc_classify.c

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index a27dc2942167..5d8e35c5379e 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -96,6 +96,30 @@ struct svc_client {
 #define SVC_CLASS_NONE		0
 #define SVC_CLASS_PER_ADDR	BIT_U32(31)
 
+#define SVC_CLASSIFIER_NAME_MAX	16
+
+struct svc_xprt;
+
+/**
+ * struct svc_classifier - BPF struct_ops that classifies accepted transports
+ * @name: a label for the instance, set by the program and not interpreted
+ * @classify: called once per accepted transport, in process context, under
+ *	rcu_read_lock(), with the peer and local addresses set; returns an
+ *	SVC_CLASS_* value
+ *
+ * Attaching one binds it to the attaching task's network namespace, where
+ * it classifies every service's transports until it is detached; one per
+ * namespace.  Transports keep the class they were given when accepted.
+ */
+struct svc_classifier {
+	/* private: */
+	struct net	*net;
+
+	/* public: */
+	char		name[SVC_CLASSIFIER_NAME_MAX];
+	u32		(*classify)(const struct svc_xprt *xprt);
+};
+
 
 struct svc_rqst;
 
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index d4f6dd5c8db3..10c18e948b42 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -180,11 +180,26 @@ void	svc_xprt_destroy_all(struct svc_serv *serv, struct net *net,
 void	svc_xprt_received(struct svc_xprt *xprt);
 
 /* The class of an accepted transport; SVC_CLASS_* in svc.h. */
+#if IS_ENABLED(CONFIG_SUNRPC_BPF_CLASSIFY)
+u32	svc_classify(const struct svc_xprt *xprt);
+void	svc_classifier_exit_net(struct net *net);
+int	svc_classifier_init_module(void);
+#else
 static inline u32 svc_classify(const struct svc_xprt *xprt)
 {
 	return SVC_CLASS_NONE;
 }
 
+static inline void svc_classifier_exit_net(struct net *net)
+{
+}
+
+static inline int svc_classifier_init_module(void)
+{
+	return 0;
+}
+#endif
+
 void	svc_xprt_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_put(struct svc_xprt *xprt);
 void	svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt);
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index e7808e5714dc..2b96ac8d1ba2 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -16,6 +16,18 @@ config SUNRPC_SWAP
 	bool
 	depends on SUNRPC
 
+config SUNRPC_BPF_CLASSIFY
+	bool "BPF classification of RPC service transports"
+	depends on SUNRPC && BPF_SYSCALL && BPF_JIT
+	default y
+	help
+	  Let a BPF struct_ops program attached in a network namespace say
+	  which accepted transports of an RPC service (NFS, NLM, the NFSv4
+	  callback service) share turns at the service's threads.  With no
+	  program attached, dispatch is unchanged.
+
+	  If unsure, say Y.
+
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism"
 	depends on SUNRPC && CRYPTO
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 96727df3aa85..fdcb860b616e 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -19,3 +19,4 @@ sunrpc-$(CONFIG_SUNRPC_DEBUG) += debugfs.o
 sunrpc-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel_rqst.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
+sunrpc-$(CONFIG_SUNRPC_BPF_CLASSIFY) += svc_classify.o
diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index 4efb5f28d881..ed01bc5296dd 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -34,6 +34,10 @@ struct sunrpc_net {
 	atomic_t pipe_users;
 	struct proc_dir_entry *use_gssp_proc;
 	struct proc_dir_entry *gss_krb5_enctypes;
+
+#if IS_ENABLED(CONFIG_SUNRPC_BPF_CLASSIFY)
+	struct svc_classifier __rcu *svc_classifier;
+#endif
 };
 
 extern unsigned int sunrpc_net_id;
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 1a3884a0376a..4fdb676baa30 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -74,6 +74,7 @@ static __net_exit void sunrpc_exit_net(struct net *net)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
+	svc_classifier_exit_net(net);
 	rpc_pipefs_exit_net(net);
 	unix_gid_cache_destroy(net);
 	ip_map_cache_destroy(net);
@@ -122,6 +123,9 @@ init_sunrpc(void)
 #endif
 	svc_init_xprt_sock();	/* svc sock transport */
 	init_socket_xprt();	/* clnt sock transport */
+	err = svc_classifier_init_module();
+	if (err)
+		pr_warn("RPC: no BPF transport classifier (%d)\n", err);
 	return 0;
 
 out6:
diff --git a/net/sunrpc/svc_classify.c b/net/sunrpc/svc_classify.c
new file mode 100644
index 000000000000..aa63e0a3cb95
--- /dev/null
+++ b/net/sunrpc/svc_classify.c
@@ -0,0 +1,200 @@
+// SPDX-License-Identifier: GPL-2.0-only
+/*
+ * BPF struct_ops classification of accepted RPC service transports.
+ */
+
+#include <linux/bpf.h>
+#include <linux/bpf_verifier.h>
+#include <linux/btf.h>
+#include <linux/nsproxy.h>
+#include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/svc_xprt.h>
+
+#include "netns.h"
+
+/* Orders attach, detach and replacement against namespace exit. */
+static DEFINE_SPINLOCK(svc_classifier_lock);
+
+/**
+ * svc_classify - ask the namespace's classifier for a transport's class
+ * @xprt: an accepted transport, peer and local addresses set
+ *
+ * Return: an SVC_CLASS_* value; %SVC_CLASS_NONE when no classifier is
+ * attached in the transport's network namespace.
+ */
+u32 svc_classify(const struct svc_xprt *xprt)
+{
+	struct sunrpc_net *sn = net_generic(xprt->xpt_net, sunrpc_net_id);
+	struct svc_classifier *c;
+	u32 class = SVC_CLASS_NONE;
+
+	rcu_read_lock();
+	c = rcu_dereference(sn->svc_classifier);
+	if (c)
+		class = c->classify(xprt);
+	rcu_read_unlock();
+	return class;
+}
+
+/* Caller holds svc_classifier_lock. */
+static void svc_classifier_detach(struct svc_classifier *c)
+{
+	struct sunrpc_net *sn;
+
+	if (!c->net)
+		return;
+	sn = net_generic(c->net, sunrpc_net_id);
+	RCU_INIT_POINTER(sn->svc_classifier, NULL);
+	c->net = NULL;
+}
+
+/**
+ * svc_classifier_exit_net - forget the classifier of a dying namespace
+ * @net: the network namespace being torn down
+ *
+ * The attached link, if any, survives with nothing behind it.
+ */
+void svc_classifier_exit_net(struct net *net)
+{
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+	struct svc_classifier *c;
+
+	spin_lock(&svc_classifier_lock);
+	c = rcu_dereference_protected(sn->svc_classifier,
+				      lockdep_is_held(&svc_classifier_lock));
+	if (c)
+		svc_classifier_detach(c);
+	spin_unlock(&svc_classifier_lock);
+}
+
+static int svc_classifier_reg(void *kdata, struct bpf_link *link)
+{
+	struct svc_classifier *c = kdata;
+	struct net *net = current->nsproxy->net_ns;
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+	int err = 0;
+
+	if (!link)
+		return -EOPNOTSUPP;
+
+	spin_lock(&svc_classifier_lock);
+	/* one namespace per classifier, one classifier per namespace */
+	if (c->net || rcu_access_pointer(sn->svc_classifier)) {
+		err = -EBUSY;
+	} else {
+		c->net = net;
+		rcu_assign_pointer(sn->svc_classifier, c);
+	}
+	spin_unlock(&svc_classifier_lock);
+	return err;
+}
+
+static void svc_classifier_unreg(void *kdata, struct bpf_link *link)
+{
+	spin_lock(&svc_classifier_lock);
+	svc_classifier_detach(kdata);
+	spin_unlock(&svc_classifier_lock);
+	synchronize_rcu();
+}
+
+static int svc_classifier_update(void *kdata, void *old_kdata,
+				 struct bpf_link *link)
+{
+	struct svc_classifier *c = kdata, *old = old_kdata;
+	struct sunrpc_net *sn;
+	int err = 0;
+
+	if (c == old)
+		return 0;
+
+	spin_lock(&svc_classifier_lock);
+	if (c->net) {
+		err = -EBUSY;
+	} else if (!old->net) {
+		err = -ENOENT;
+	} else {
+		c->net = old->net;
+		old->net = NULL;
+		sn = net_generic(c->net, sunrpc_net_id);
+		rcu_assign_pointer(sn->svc_classifier, c);
+	}
+	spin_unlock(&svc_classifier_lock);
+	if (!err)
+		synchronize_rcu();
+	return err;
+}
+
+static int svc_classifier_validate(void *kdata)
+{
+	struct svc_classifier *c = kdata;
+
+	return c->classify ? 0 : -EINVAL;
+}
+
+/* classify() runs under rcu_read_lock() */
+static int svc_classifier_check_member(const struct btf_type *t,
+				       const struct btf_member *member,
+				       const struct bpf_prog *prog)
+{
+	return prog->sleepable ? -EINVAL : 0;
+}
+
+static int svc_classifier_init_member(const struct btf_type *t,
+				      const struct btf_member *member,
+				      void *kdata, const void *udata)
+{
+	const struct svc_classifier *uc = udata;
+	struct svc_classifier *kc = kdata;
+	u32 moff = __btf_member_bit_offset(t, member) / 8;
+
+	if (moff == offsetof(struct svc_classifier, name)) {
+		if (bpf_obj_name_cpy(kc->name, uc->name, sizeof(uc->name)) <= 0)
+			return -EINVAL;
+		return 1;
+	}
+	return 0;
+}
+
+static int svc_classifier_init(struct btf *btf)
+{
+	return 0;
+}
+
+static u32 __svc_classifier_stub_classify(const struct svc_xprt *xprt)
+{
+	return SVC_CLASS_NONE;
+}
+
+static struct svc_classifier __svc_classifier_stubs = {
+	.classify	= __svc_classifier_stub_classify,
+};
+
+static const struct bpf_func_proto *
+svc_classifier_func_proto(enum bpf_func_id func_id, const struct bpf_prog *prog)
+{
+	return bpf_base_func_proto(func_id, prog);
+}
+
+static const struct bpf_verifier_ops svc_classifier_verifier_ops = {
+	.get_func_proto		= svc_classifier_func_proto,
+	.is_valid_access	= bpf_tracing_btf_ctx_access,
+};
+
+static struct bpf_struct_ops bpf_svc_classifier_ops = {
+	.verifier_ops	= &svc_classifier_verifier_ops,
+	.init		= svc_classifier_init,
+	.check_member	= svc_classifier_check_member,
+	.init_member	= svc_classifier_init_member,
+	.reg		= svc_classifier_reg,
+	.unreg		= svc_classifier_unreg,
+	.update		= svc_classifier_update,
+	.validate	= svc_classifier_validate,
+	.cfi_stubs	= &__svc_classifier_stubs,
+	.name		= "svc_classifier",
+	.owner		= THIS_MODULE,
+};
+
+int __init svc_classifier_init_module(void)
+{
+	return register_bpf_struct_ops(&bpf_svc_classifier_ops, svc_classifier);
+}
-- 
2.53.0

