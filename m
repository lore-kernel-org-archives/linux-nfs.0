Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E5F32264AB
	for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 16:07:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789315637; cv=none; b=GugY7vax9yYcNQhEyBl1gg19ndyZ5gGK1Rbx1YUUzFrZcbvZ4EJeQ1GieWkkmeEMP5aQQ4MPmwvSYZFyQ04OMYtGdhMMkn1OsbKh03UChCWXYjZW9Bxh6akqixBQhUZyMsOjGd5Nsz+LmVzpco50XXjLnEQ+ScWyYCbJ/TjjGok=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789315637; c=relaxed/simple;
	bh=i0a1Pckm5SqEdqRYO9xsO3F9ZHyuhZhu8IFcsoj71zA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=GfnHMAUcBhnfXJl0f9STq83Dl1u7Fwzr0Gdw4U+KNodw4pHjn3VW4tcM/21Ngm+eP5FwzxD2rD/rREgBqZerFwAU+4JVF7rvaVXe5ukrRrccm0IBhVBg994hDIAPqnhGUy4LGBVQY9kjgvJ7jWu8rYo5+7vttRwq50pRDmAIo68=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NO5nukTe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NO5nukTe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2BB331F000FF;
	Sun, 13 Sep 2026 16:07:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789315629;
	bh=DYDfT2nlr+gN/kSVTi4sJUQRUbNP/oGStpmo3OVpCqA=;
	h=From:To:Cc:Subject:Date;
	b=NO5nukTexIOAPn5LAw9wCvrsOOf2fzkCZOvu/Bg7wjhIUXyUR8LiBn1dqvkeA9Ap/
	 0NV1EcCMS+M7aQQ1vkdtn/4m+BHm0ctC+9wzQpl9DFolOOWmvZ1FPV5uPPscgzvY0N
	 if0/lHoxpgsfYq5Z7uijFV6EAGTx7AqLJp9Sxe9D9wUUduIE4KKIBFYy5z6Z+1gCPy
	 /A++NKx+qnm2Yh7OZmTBwrKj86pY4jKxa9I2qlQFbuczpcK5rQq0mDr4KRZWeu2K3g
	 gWsUGrI95m+QPvppJLSxrMO8OcQ+nl8zVfgN8t3yk1S/5IWM8TUluoroFS/SQgDsJa
	 Iad01vUKQlIEQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chris Mason <clm@meta.com>
Subject: [PATCH v1] sunrpc: pin gss module across auth_domain RCU free
Date: Sun, 13 Sep 2026 12:07:06 -0400
Message-ID: <20260913160706.384180-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chris Mason <clm@meta.com>

A gss auth_domain stores a raw pointer to svcauthops_gss in
dom->flavour, and its release queues svcauth_gss_domain_release_rcu()
via call_rcu(). Both live in auth_rpcgss.ko text, and nothing pins the
module while a domain referencing it is reachable. rmmod auth_rpcgss
can therefore unmap that text while an NFSD export still holds a
reference to the domain.

The export cache is one such holder. When the export is finally
released, the domain reference drops from module text:

    svc_export_put()
      auth_domain_put(exp->ex_client)
        auth_domain_release()
          dom->flavour->domain_release(dom)   /* into module text */
            svcauth_gss_domain_release()
              call_rcu(&dom->rcu_head,
                       svcauth_gss_domain_release_rcu)

Once auth_rpcgss is unloaded, the domain_release call lands in
unmapped memory. The rcu_barrier() in exit_rpcsec_gss() does not
help: it waits only for callbacks already queued, and this one is
not queued until the export goes away.

NFSD's NFSv4 objects import symbols from auth_rpcgss.ko, so only a
server built without CONFIG_NFSD_V4 can unload auth_rpcgss while
exports still name a gss domain.

Take a module reference in svcauth_gss_register_pseudoflavor() before
publishing the domain and drop it at the end of
svcauth_gss_domain_release_rcu(). The rcu_barrier() then holds the
module image until this callback has returned.

Fixes: 608a0ab2f54a ("SUNRPC: Add lockless lookup of the server's auth domain")
Assisted-by: kres:claude-opus-4-7
Signed-off-by: Chris Mason <clm@meta.com>
[ cel: rewrote description ]
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index b319c4423d78..43839e805531 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -824,12 +824,18 @@ svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name)
 	new->h.flavour = &svcauthops_gss;
 	new->pseudoflavor = pseudoflavor;
 
+	if (!try_module_get(svcauthops_gss.owner)) {
+		stat = -ENODEV;
+		goto out_free_name;
+	}
+
 	test = auth_domain_lookup(name, &new->h);
 	if (test != &new->h) {
 		pr_warn("svc: duplicate registration of gss pseudo flavour %s.\n",
 			name);
 		stat = -EADDRINUSE;
 		auth_domain_put(test);
+		module_put(svcauthops_gss.owner);
 		goto out_free_name;
 	}
 	return test;
@@ -2004,9 +2010,11 @@ svcauth_gss_domain_release_rcu(struct rcu_head *head)
 {
 	struct auth_domain *dom = container_of(head, struct auth_domain, rcu_head);
 	struct gss_domain *gd = container_of(dom, struct gss_domain, h);
+	struct module *owner = dom->flavour->owner;
 
 	kfree(dom->name);
 	kfree(gd);
+	module_put(owner);
 }
 
 static void
-- 
2.55.0

