Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:37999 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752410AbdLESzv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Dec 2017 13:55:51 -0500
From: Thiago Rafael Becker <thiago.becker@gmail.com>
To: bfields@fieldses.org, neilb@suse.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Thiago Rafael Becker <thiago.becker@gmail.com>
Subject: [PATCH 2/3] kernel: Move groups_sort to the caller of set_groups.
Date: Tue,  5 Dec 2017 16:55:23 -0200
Message-Id: <20171205185523.20600-1-thiago.becker@gmail.com>
In-Reply-To: <20171205140512.13349-3-thiago.becker@gmail.com>
References: <20171205140512.13349-3-thiago.becker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The responsibility for calling groups_sort is now on the caller
of set_groups.

Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>
---
 arch/s390/kernel/compat_linux.c   | 1 +
 fs/nfsd/auth.c                    | 3 +++
 kernel/groups.c                   | 1 +
 kernel/uid16.c                    | 1 +
 net/sunrpc/auth_gss/gss_rpc_xdr.c | 1 +
 net/sunrpc/auth_gss/svcauth_gss.c | 1 +
 net/sunrpc/svcauth_unix.c         | 8 ++++++++
 7 files changed, 16 insertions(+)

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
index 697f8ae..7b5099b 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -60,6 +60,9 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 				gi->gid[i] = exp->ex_anon_gid;
 			else
 				gi->gid[i] = rqgi->gid[i];
+
+			/* Should be race free as long as each thread allocates a new gi */
+			groups_sort(gi);
 		}
 	} else {
 		gi = get_group_info(rqgi);
diff --git a/kernel/groups.c b/kernel/groups.c
index 4c9c9ed..17073a9 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -208,6 +208,7 @@ SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
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
index 740b67d..99841e1 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -20,6 +20,7 @@
 
 
 #include "netns.h"
+void groups_sort(struct group_info *group_info);
 
 /*
  * AUTHUNIX and AUTHNULL credentials are both handled here.
@@ -520,6 +521,12 @@ static int unix_gid_parse(struct cache_detail *cd,
 		ug.gi->gid[i] = kgid;
 	}
 
+	/* Sort the groups before inserting this entry
+	 * into the cache to avoid future corrutpions
+	 * by multiple simultaneous attempts to sort this
+	 * entry.
+	 */
+	groups_sort(ug.gi);
 	ugp = unix_gid_lookup(cd, uid);
 	if (ugp) {
 		struct cache_head *ch;
@@ -819,6 +826,7 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 		kgid_t kgid = make_kgid(&init_user_ns, svc_getnl(argv));
 		cred->cr_group_info->gid[i] = kgid;
 	}
+	groups_sort(cred->cr_group_info);
 	if (svc_getu32(argv) != htonl(RPC_AUTH_NULL) || svc_getu32(argv) != 0) {
 		*authp = rpc_autherr_badverf;
 		return SVC_DENIED;
-- 
2.9.5

