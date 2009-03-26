From: David Howells <dhowells@redhat.com>
Subject: Re: NFS/AFS/Selinux issues with 2.26.29
Date: Thu, 26 Mar 2009 20:55:21 +0000
Message-ID: <17949.1238100921@redhat.com>
References: <49CAAB9B.5070104@linux.vnet.ibm.com>
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, openafs-devel-UX5vO7D78FVAfugRpC6u6w@public.gmane.org
To: Richard A Nelson <cowboy@linux.vnet.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38112 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760994AbZCZUzd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2009 16:55:33 -0400
In-Reply-To: <49CAAB9B.5070104@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Richard A Nelson <cowboy@linux.vnet.ibm.com> wrote:

> Mar 24 21:09:20 el-ghor kernel: IP: [<ffffffff803628b7>] inode_has_perm+0x2c/0x72
> ...
> Mar 24 14:33:54 bandit-hall kernel: IP: [<c021ba99>] selinux_key_alloc+0x26/0x3b

This looks suspiciously like current->cred->security might be NULL.  Can you
try running with the attached patch applied to your kernel?

David
---
diff --git a/kernel/cred.c b/kernel/cred.c
index 3a03918..67f4de9 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -157,6 +157,9 @@ struct cred *prepare_creds(void)
 
 	if (security_prepare_creds(new, old, GFP_KERNEL) < 0)
 		goto error;
+#ifdef CONFIG_SECURITY_SELINUX
+	WARN_ON(!new->security);
+#endif
 	return new;
 
 error:
@@ -250,6 +253,9 @@ struct cred *prepare_usermodehelper_creds(void)
 #endif
 	if (security_prepare_creds(new, &init_cred, GFP_ATOMIC) < 0)
 		goto error;
+#ifdef CONFIG_SECURITY_SELINUX
+	WARN_ON(!new->security);
+#endif
 
 	BUG_ON(atomic_read(&new->usage) != 1);
 	return new;
@@ -331,6 +337,9 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 
 	atomic_inc(&new->user->processes);
 	p->cred = p->real_cred = get_cred(new);
+#ifdef CONFIG_SECURITY_SELINUX
+	WARN_ON(!new->security);
+#endif
 	return 0;
 
 error_put:
@@ -360,6 +369,9 @@ int commit_creds(struct cred *new)
 	BUG_ON(task->cred != task->real_cred);
 	BUG_ON(atomic_read(&task->real_cred->usage) < 2);
 	BUG_ON(atomic_read(&new->usage) < 1);
+#ifdef CONFIG_SECURITY_SELINUX
+	WARN_ON(!new->security);
+#endif
 
 	old = task->real_cred;
 	security_commit_creds(new, old);
@@ -444,6 +456,10 @@ const struct cred *override_creds(const struct cred *new)
 {
 	const struct cred *old = current->cred;
 
+#ifdef CONFIG_SECURITY_SELINUX
+	WARN_ON(!old->security);
+	WARN_ON(!new->security);
+#endif
 	rcu_assign_pointer(current->cred, get_cred(new));
 	return old;
 }
@@ -460,6 +476,10 @@ void revert_creds(const struct cred *old)
 {
 	const struct cred *override = current->cred;
 
+#ifdef CONFIG_SECURITY_SELINUX
+	WARN_ON(!old->security);
+	WARN_ON(!override->security);
+#endif
 	rcu_assign_pointer(current->cred, old);
 	put_cred(override);
 }
@@ -507,6 +527,10 @@ struct cred *prepare_kernel_cred(struct task_struct *daemon)
 	else
 		old = get_cred(&init_cred);
 
+#ifdef CONFIG_SECURITY_SELINUX
+	WARN_ON(!old->security);
+#endif
+
 	*new = *old;
 	get_uid(new->user);
 	get_group_info(new->group_info);
@@ -527,6 +551,9 @@ struct cred *prepare_kernel_cred(struct task_struct *daemon)
 
 	atomic_set(&new->usage, 1);
 	put_cred(old);
+#ifdef CONFIG_SECURITY_SELINUX
+	WARN_ON(!new->security);
+#endif
 	return new;
 
 error:
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 7c52ba2..25bb304 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3236,7 +3236,7 @@ static int selinux_task_create(unsigned long clone_flags)
 static void selinux_cred_free(struct cred *cred)
 {
 	struct task_security_struct *tsec = cred->security;
-	cred->security = NULL;
+	cred->security = (void *) 0x7UL;
 	kfree(tsec);
 }
 
