Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51971 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835Ab2CTXYi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2012 19:24:38 -0400
Message-ID: <4F691175.3020604@panasas.com>
Date: Tue, 20 Mar 2012 16:23:33 -0700
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
        Greg Kroah-Hartman <gregkh@suse.de>
Subject: [PATCH 1/4] kmod: Un-export call_usermodehelper_freeinfo()
References: <4F691059.30405@panasas.com>
In-Reply-To: <4F691059.30405@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


call_usermodehelper_freeinfo() is not used outside of kmod.c. So
unexport it, and make it static to kmod.c

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/kmod.h |    4 ----
 kernel/kmod.c        |    3 +--
 2 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/include/linux/kmod.h b/include/linux/kmod.h
index 722f477..936d197 100644
--- a/include/linux/kmod.h
+++ b/include/linux/kmod.h
@@ -80,10 +80,6 @@ void call_usermodehelper_setfns(struct subprocess_info *info,
 /* Actually execute the sub-process */
 int call_usermodehelper_exec(struct subprocess_info *info, enum umh_wait wait);
 
-/* Free the subprocess_info. This is only needed if you're not going
-   to call call_usermodehelper_exec */
-void call_usermodehelper_freeinfo(struct subprocess_info *info);
-
 static inline int
 call_usermodehelper_fns(char *path, char **argv, char **envp,
 			enum umh_wait wait,
diff --git a/kernel/kmod.c b/kernel/kmod.c
index a0a8854..c268f34 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -191,13 +191,12 @@ fail:
 	do_exit(0);
 }
 
-void call_usermodehelper_freeinfo(struct subprocess_info *info)
+static void call_usermodehelper_freeinfo(struct subprocess_info *info)
 {
 	if (info->cleanup)
 		(*info->cleanup)(info);
 	kfree(info);
 }
-EXPORT_SYMBOL(call_usermodehelper_freeinfo);
 
 /* Keventd can't block, but this (a child) can. */
 static int wait_for_helper(void *data)
-- 
1.7.6.2

