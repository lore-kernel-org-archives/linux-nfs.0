Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35315 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753773AbcLKPgx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2016 10:36:53 -0500
From: Jia He <hejianet@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-kernel@vger.kernel.org, Jia He <hejianet@gmail.com>
Subject: [PATCH v2 0/1] lockd: Change nsm_use_hostnames from bool to u32
Date: Sun, 11 Dec 2016 23:36:48 +0800
Message-Id: <1481470609-31488-1-git-send-email-hejianet@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nsm_use_hostnames is a module parameter and it will be exported to sysctl
procfs. This is to let user sometimes change it from userspace. But the
minimal unit for sysctl procfs read/write it sizeof(int).
In big endian system, the converting from/to  bool to/from int will cause
error for proc items.

This patch changes the type definition of nsm_use_hostnames.

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

After I change the bool to int:
[root@bigendian my]# insmod -f /root/my/hello.ko nsm_use_hostnames=1
[root@bigendian my]# cat /proc/sys/mysysctl/nsm_use_hostnames
1

In little endian system, there is no such issue.

Jia He (1):
  lockd: Change nsm_use_hostnames from bool to u32

 fs/lockd/mon.c              | 2 +-
 fs/lockd/svc.c              | 2 +-
 include/linux/lockd/lockd.h | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

-- 
2.5.5

