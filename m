Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34541 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754789AbcLNCt1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Dec 2016 21:49:27 -0500
From: Jia He <hejianet@gmail.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Serge Hallyn <serge@hallyn.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mel Gorman <mgorman@techsingularity.net>,
        Kees Cook <keescook@chromium.org>, Hugh Dickins <hughd@google.com>,
        Daniel Bristot de Oliveira <bristot@redhat.com>,
        Daniel Cashman <dcashman@google.com>, Arnd Bergmann <arnd@arndb.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jia He <hejianet@gmail.com>
Subject: [RESEND PATCH v4 2/2] lockd: change the proc_handler for nsm_use_hostnames
Date: Wed, 14 Dec 2016 10:49:16 +0800
Message-Id: <1481683756-29276-3-git-send-email-hejianet@gmail.com>
In-Reply-To: <1481683756-29276-1-git-send-email-hejianet@gmail.com>
References: <1481683756-29276-1-git-send-email-hejianet@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nsm_use_hostnames is a module parameter and it will be exported to sysctl
procfs. This is to let user sometimes change it from userspace. But the
minimal unit for sysctl procfs read/write it sizeof(int).
In big endian system, the converting from/to  bool to/from int will cause
error for proc items.

This patch use a new proc_handler proc_dobool.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 fs/lockd/svc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index fc4084e..bd6fcf9 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -561,7 +561,7 @@ static struct ctl_table nlm_sysctls[] = {
 		.data		= &nsm_use_hostnames,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dobool,
 	},
 	{
 		.procname	= "nsm_local_state",
-- 
2.5.5

