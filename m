Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:52066 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759260Ab2CTX0r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2012 19:26:47 -0400
Message-ID: <4F691217.5070108@panasas.com>
Date: Tue, 20 Mar 2012 16:26:15 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Andrew Morton <akpm@linux-foundation.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, <keyrings@linux-nfs.org>,
        <linux-security-module@vger.kernel.org>
CC: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg Kroah-Hartman <gregkh@suse.de>,
        Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 2/4] kmod: Convert two call sites to call_usermodehelper_fns()
References: <4F691059.30405@panasas.com>
In-Reply-To: <4F691059.30405@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Both   kernel/sys.c && security/keys/request_key.c where inlining the exact same
code as call_usermodehelper_fns(); So simply convert these sites to directly
use  call_usermodehelper_fns().

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 kernel/sys.c                |   11 ++---------
 security/keys/request_key.c |   13 +++----------
 2 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 4070153..9947fb0 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2013,15 +2013,8 @@ int orderly_poweroff(bool force)
 		goto out;
 	}
 
-	info = call_usermodehelper_setup(argv[0], argv, envp, GFP_ATOMIC);
-	if (info == NULL) {
-		argv_free(argv);
-		goto out;
-	}
-
-	call_usermodehelper_setfns(info, NULL, argv_cleanup, NULL);
-
-	ret = call_usermodehelper_exec(info, UMH_NO_WAIT);
+	ret = call_usermodehelper_fns(argv[0], argv, envp, UMH_NO_WAIT,
+				      NULL, argv_cleanup, NULL);
 
   out:
 	if (ret && force) {
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 8246532..b8cc38c 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -93,16 +93,9 @@ static void umh_keys_cleanup(struct subprocess_info *info)
 static int call_usermodehelper_keys(char *path, char **argv, char **envp,
 			 struct key *session_keyring, enum umh_wait wait)
 {
-	gfp_t gfp_mask = (wait == UMH_NO_WAIT) ? GFP_ATOMIC : GFP_KERNEL;
-	struct subprocess_info *info =
-		call_usermodehelper_setup(path, argv, envp, gfp_mask);
-
-	if (!info)
-		return -ENOMEM;
-
-	call_usermodehelper_setfns(info, umh_keys_init, umh_keys_cleanup,
-					key_get(session_keyring));
-	return call_usermodehelper_exec(info, wait);
+	return call_usermodehelper_fns(path, argv, envp, wait,
+				       umh_keys_init, umh_keys_cleanup,
+				       key_get(session_keyring));
 }
 
 /*
-- 
1.7.6.2

