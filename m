Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:59282 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756063Ab2C0CCy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Mar 2012 22:02:54 -0400
Message-ID: <4F711FAB.3020408@panasas.com>
Date: Mon, 26 Mar 2012 19:02:19 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        <linux-security-module@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>,
        Thomas Gleixner <tglx@linutronix.de>
CC: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        "keyrings@linux-nfs.org" <keyrings@linux-nfs.org>
Subject: [PATCH 2/6] kmod: Convert two call sites to call_usermodehelper_fns()
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com>
In-Reply-To: <4F711EA2.4030608@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Both   kernel/sys.c && security/keys/request_key.c where inlining the exact same
code as call_usermodehelper_fns(); So simply convert these sites to directly
use  call_usermodehelper_fns().

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 kernel/sys.c                |   19 ++++++++-----------
 security/keys/request_key.c |   13 +++----------
 2 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 9eb7fca..37b1971 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2013,7 +2013,6 @@ int orderly_poweroff(bool force)
 		NULL
 	};
 	int ret = -ENOMEM;
-	struct subprocess_info *info;
 
 	if (argv == NULL) {
 		printk(KERN_WARNING "%s failed to allocate memory for \"%s\"\n",
@@ -2021,18 +2020,16 @@ int orderly_poweroff(bool force)
 		goto out;
 	}
 
-	info = call_usermodehelper_setup(argv[0], argv, envp, GFP_ATOMIC);
-	if (info == NULL) {
-		argv_free(argv);
-		goto out;
-	}
-
-	call_usermodehelper_setfns(info, NULL, argv_cleanup, NULL);
+	ret = call_usermodehelper_fns(argv[0], argv, envp, UMH_NO_WAIT,
+				      NULL, argv_cleanup, NULL);
+out:
+	if (likely(!ret))
+		return 0;
 
-	ret = call_usermodehelper_exec(info, UMH_NO_WAIT);
+	if (ret == -ENOMEM)
+		argv_free(argv);
 
-  out:
-	if (ret && force) {
+	if (force) {
 		printk(KERN_WARNING "Failed to start orderly shutdown: "
 		       "forcing the issue\n");
 
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index cc37903..000e750 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -93,16 +93,9 @@ static void umh_keys_cleanup(struct subprocess_info *info)
 static int call_usermodehelper_keys(char *path, char **argv, char **envp,
 					struct key *session_keyring, int wait)
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
1.7.6.5


