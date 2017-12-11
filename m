Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:42918 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751628AbdLKPOx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Dec 2017 10:14:53 -0500
From: Thiago Rafael Becker <thiago.becker@gmail.com>
To: viro@zeniv.linux.org.uk, schwidefsky@de.ibm.com,
        willy@infradead.org, bfields@fieldses.org, neilb@suse.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Thiago Rafael Becker <thiago.becker@gmail.com>
Subject: [PATCH v5] kernel: make groups_sort calling a responsibility group_info allocators
Date: Mon, 11 Dec 2017 13:14:20 -0200
Message-Id: <20171211151420.18655-1-thiago.becker@gmail.com>
In-Reply-To: <20171211142708.GA23284@bombadil.infradead.org>
References: <20171211142708.GA23284@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In testing, we found that nfsd threads may call set_groups in parallel for
the same entry cached in auth.unix.gid, racing in the call of groups_sort,
corrupting the groups for that entry and leading to permission denials for
the client.

This patch:
 - Make groups_sort globally visible.
 - Move the call to groups_sort to the modifiers of group_info
 - Remove the call to groups_sort from set_groups

Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>
---
 arch/s390/kernel/compat_linux.c   | 1 +
 fs/nfsd/auth.c                    | 3 +++
 include/linux/cred.h              | 1 +
 kernel/groups.c                   | 5 +++--
 kernel/uid16.c                    | 1 +
 net/sunrpc/auth_gss/gss_rpc_xdr.c | 1 +
 net/sunrpc/auth_gss/svcauth_gss.c | 1 +
 net/sunrpc/svcauth_unix.c         | 2 ++
 8 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index f04db37..59eea9c 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -263,6 +263,7 @@ COMPAT_SYSCALL_DEFINE2(s390_setgroups16, int, gidsetsize, u16 __user *, grouplis
 		return retval;
 	}
 
+	groups_sort(group_info);
 	retval = set_current_groups(group_info);
 	put_group_info(group_info);
 
diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index 697f8ae..f650e47 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -60,6 +60,9 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 				gi->gid[i] = exp->ex_anon_gid;
 			else
 				gi->gid[i] = rqgi->gid[i];
+
+			/* Each thread allocates its own gi, no race */
+			groups_sort(gi);
 		}
 	} else {
 		gi = get_group_info(rqgi);
diff --git a/include/linux/cred.h b/include/linux/cred.h
index 099058e..6312865 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -83,6 +83,7 @@ extern int set_current_groups(struct group_info *);
 extern void set_groups(struct cred *, struct group_info *);
 extern int groups_search(const struct group_info *, kgid_t);
 extern bool may_setgroups(void);
+extern void groups_sort(struct group_info *);
 
 /*
  * The security context of a task
diff --git a/kernel/groups.c b/kernel/groups.c
index e357bc8..daae2f2 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -86,11 +86,12 @@ static int gid_cmp(const void *_a, const void *_b)
 	return gid_gt(a, b) - gid_lt(a, b);
 }
 
-static void groups_sort(struct group_info *group_info)
+void groups_sort(struct group_info *group_info)
 {
 	sort(group_info->gid, group_info->ngroups, sizeof(*group_info->gid),
 	     gid_cmp, NULL);
 }
+EXPORT_SYMBOL(groups_sort);
 
 /* a simple bsearch */
 int groups_search(const struct group_info *group_info, kgid_t grp)
@@ -122,7 +123,6 @@ int groups_search(const struct group_info *group_info, kgid_t grp)
 void set_groups(struct cred *new, struct group_info *group_info)
 {
 	put_group_info(new->group_info);
-	groups_sort(group_info);
 	get_group_info(group_info);
 	new->group_info = group_info;
 }
@@ -206,6 +206,7 @@ SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
 		return retval;
 	}
 
+	groups_sort(group_info);
 	retval = set_current_groups(group_info);
 	put_group_info(group_info);
 
diff --git a/kernel/uid16.c b/kernel/uid16.c
index ce74a49..ef1da2a 100644
--- a/kernel/uid16.c
+++ b/kernel/uid16.c
@@ -192,6 +192,7 @@ SYSCALL_DEFINE2(setgroups16, int, gidsetsize, old_gid_t __user *, grouplist)
 		return retval;
 	}
 
+	groups_sort(group_info);
 	retval = set_current_groups(group_info);
 	put_group_info(group_info);
 
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index c4778ca..444380f 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -231,6 +231,7 @@ static int gssx_dec_linux_creds(struct xdr_stream *xdr,
 			goto out_free_groups;
 		creds->cr_group_info->gid[i] = kgid;
 	}
+	groups_sort(creds->cr_group_info);
 
 	return 0;
 out_free_groups:
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 5dd4e6c..2653119 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -481,6 +481,7 @@ static int rsc_parse(struct cache_detail *cd,
 				goto out;
 			rsci.cred.cr_group_info->gid[i] = kgid;
 		}
+		groups_sort(rsci.cred.cr_group_info);
 
 		/* mech name */
 		len = qword_get(&mesg, buf, mlen);
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 740b67d..af7f28f 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -520,6 +520,7 @@ static int unix_gid_parse(struct cache_detail *cd,
 		ug.gi->gid[i] = kgid;
 	}
 
+	groups_sort(ug.gi);
 	ugp = unix_gid_lookup(cd, uid);
 	if (ugp) {
 		struct cache_head *ch;
@@ -819,6 +820,7 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 		kgid_t kgid = make_kgid(&init_user_ns, svc_getnl(argv));
 		cred->cr_group_info->gid[i] = kgid;
 	}
+	groups_sort(cred->cr_group_info);
 	if (svc_getu32(argv) != htonl(RPC_AUTH_NULL) || svc_getu32(argv) != 0) {
 		*authp = rpc_autherr_badverf;
 		return SVC_DENIED;
-- 
2.9.5

