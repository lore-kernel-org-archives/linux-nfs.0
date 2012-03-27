Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:59252 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755999Ab2C0CBV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Mar 2012 22:01:21 -0400
Message-ID: <4F711F4C.7030902@panasas.com>
Date: Mon, 26 Mar 2012 19:00:44 -0700
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
Subject: [PATCH 1/6] kmod: Unexport call_usermodehelper_freeinfo()
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com>
In-Reply-To: <4F711EA2.4030608@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


call_usermodehelper_freeinfo() is not used outside of kmod.c. So
unexport it, and make it static to kmod.c

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/kmod.h |    4 ----
 kernel/kmod.c        |    2 +-
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/include/linux/kmod.h b/include/linux/kmod.h
index 9efeae6..ba89dc2 100644
--- a/include/linux/kmod.h
+++ b/include/linux/kmod.h
@@ -79,10 +79,6 @@ void call_usermodehelper_setfns(struct subprocess_info *info,
 /* Actually execute the sub-process */
 int call_usermodehelper_exec(struct subprocess_info *info, int wait);
 
-/* Free the subprocess_info. This is only needed if you're not going
-   to call call_usermodehelper_exec */
-void call_usermodehelper_freeinfo(struct subprocess_info *info);
-
 static inline int
 call_usermodehelper_fns(char *path, char **argv, char **envp, int wait,
 			int (*init)(struct subprocess_info *info, struct cred *new),
diff --git a/kernel/kmod.c b/kernel/kmod.c
index 957a7aa..c5af66a 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -221,13 +221,13 @@ static int ____call_usermodehelper(void *data)
 	return 0;
 }
 
+static
 void call_usermodehelper_freeinfo(struct subprocess_info *info)
 {
 	if (info->cleanup)
 		(*info->cleanup)(info);
 	kfree(info);
 }
-EXPORT_SYMBOL(call_usermodehelper_freeinfo);
 
 static void umh_complete(struct subprocess_info *sub_info)
 {
-- 
1.7.6.5


