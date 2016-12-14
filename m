Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33056 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754583AbcLNCtZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Dec 2016 21:49:25 -0500
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
Subject: [RESEND PATCH v4 0/2] change the proc handler for nsm_use_hostnames
Date: Wed, 14 Dec 2016 10:49:14 +0800
Message-Id: <1481683756-29276-1-git-send-email-hejianet@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Resend the v4 since I didn't add --to=linux-kernel@vger.kernel.org,sorry about
it

nsm_use_hostnames is a module parameter and it will be exported to sysctl
procfs. This is to let user sometimes change it from userspace. But the
minimal unit for sysctl procfs read/write it sizeof(int).
In big endian system, the converting from/to  bool to/from int will cause
error for proc items.

This patch introduces a new proc handler proc_dobool for nsm_use_hostnames.

Changes:
v4: Change (u8 *) to (bool *)
v3: Introduce a new proc handler proc_dou8vec(suggested by Xinhui Pan)
v2: Change extern type in lockd.h

The test case I used:
/***************************************************************/
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/sysctl.h>

bool __read_mostly nsm_use_hostnames;
module_param(nsm_use_hostnames, bool, 0644);

static struct ctl_table my_sysctl[] = {
        {
                .procname       = "nsm_use_hostnames",
                .data           = &nsm_use_hostnames,
                .maxlen         = sizeof(int),
                .mode           = 0644,
                .proc_handler   = &proc_dointvec,
        },
        {}
};

static struct ctl_table my_root[] = {
        {
        .procname       = "mysysctl",
        .mode           = 0555,
        .child          = my_sysctl,
        },
        {}
};

static struct ctl_table_header * my_ctl_header;

static int __init sysctl_exam_init(void)
{
        my_ctl_header = register_sysctl_table(&my_root);
        if (my_ctl_header == NULL)
                printk("error regiester sysctl");

        return 0;
}

static void __exit sysctl_exam_exit(void)
{
        unregister_sysctl_table(my_ctl_header);
}

module_init(sysctl_exam_init);
module_exit(sysctl_exam_exit);
MODULE_LICENSE("GPL");
/****************************************************************/

[root@bigendian my]# insmod -f /root/my/hello.ko nsm_use_hostnames=1   
[root@bigendian my]# cat /proc/sys/mysysctl/nsm_use_hostnames 
16777216

After I change the proc_dointvec to new handler proc_dou8vec with the
patch:
[root@bigendian my]# insmod -f /root/my/hello.ko nsm_use_hostnames=1
[root@bigendian my]# cat /proc/sys/mysysctl/nsm_use_hostnames
1

In little endian system, there is no such issue.
Already tested v4 in both of big and little endian(ppc64 and ppc64le)

Jia He (2):
  sysctl: introduce new proc handler proc_dobool
  lockd: change the proc_handler for nsm_use_hostnames

 fs/lockd/svc.c         |  2 +-
 include/linux/sysctl.h |  2 ++
 kernel/sysctl.c        | 35 +++++++++++++++++++++++++++++++++++
 3 files changed, 38 insertions(+), 1 deletion(-)

-- 
2.5.5

