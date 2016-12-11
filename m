Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:48365 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753578AbcLKR4y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2016 12:56:54 -0500
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBBHrsKI127820
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2016 12:56:54 -0500
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
        by mx0a-001b2d01.pphosted.com with ESMTP id 278f3ddwx6-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2016 12:56:53 -0500
Received: from localhost
        by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <xinhui@linux.vnet.ibm.com>;
        Sun, 11 Dec 2016 23:26:48 +0530
Subject: Re: [PATCH v2 0/1] lockd: Change nsm_use_hostnames from bool to u32
To: Jia He <hejianet@gmail.com>, linux-nfs@vger.kernel.org
References: <1481470609-31488-1-git-send-email-hejianet@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-kernel@vger.kernel.org
From: Pan Xinhui <xinhui@linux.vnet.ibm.com>
Date: Mon, 12 Dec 2016 01:56:46 +0800
MIME-Version: 1.0
In-Reply-To: <1481470609-31488-1-git-send-email-hejianet@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Message-Id: <4757a896-6eb8-9d9a-fde0-bb9caa6e541e@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



在 2016/12/11 23:36, Jia He 写道:
> nsm_use_hostnames is a module parameter and it will be exported to sysctl
> procfs. This is to let user sometimes change it from userspace. But the
> minimal unit for sysctl procfs read/write it sizeof(int).
> In big endian system, the converting from/to  bool to/from int will cause
> error for proc items.
hi, Jia

not only in BE system. :)
Current code is just touching a wrong pointer.

some tests based on yours

u8 __read_mostly nsm_use_hostnames[4]={1,2,3,4}; // an arrary of u8, and [0] passed to ctl_table as data

static struct ctl_table my_sysctl[] = {
         {
                 .procname       = "nsm_use_hostnames",
                 .data           = &nsm_use_hostnames[0],//u8,
                 .maxlen         = sizeof(int),
                 .mode           = 0644,
                 .proc_handler   = &proc_dointvec,
         },
         {}
};

then run your tests and result will be

root@ltcalpine2-lp13:~/linux/bench# cat /proc/sys/mysysctl/nsm_use_hostnames
67305985( This is 0x4030201, expected be 0x1)

So your fix patch work around it. But I suggest we can support u8/u16, not only int/double int.

thanks
xinhui
  
>
> This patch changes the type definition of nsm_use_hostnames.
>
> The test case I used:
> /***************************************************************/
> #include <linux/kernel.h>
> #include <linux/module.h>
> #include <linux/sysctl.h>
>
> bool __read_mostly nsm_use_hostnames;
> module_param(nsm_use_hostnames, bool, 0644);
>
> static struct ctl_table my_sysctl[] = {
>         {
>                 .procname       = "nsm_use_hostnames",
>                 .data           = &nsm_use_hostnames,
>                 .maxlen         = sizeof(int),
>                 .mode           = 0644,
>                 .proc_handler   = &proc_dointvec,
>         },
>         {}
> };
>
> static struct ctl_table my_root[] = {
>         {
>         .procname       = "mysysctl",
>         .mode           = 0555,
>         .child          = my_sysctl,
>         },
>         {}
> };
>
> static struct ctl_table_header * my_ctl_header;
>
> static int __init sysctl_exam_init(void)
> {
>         my_ctl_header = register_sysctl_table(&my_root);
>         if (my_ctl_header == NULL)
>                 printk("error regiester sysctl");
>
>         return 0;
> }
>
> static void __exit sysctl_exam_exit(void)
> {
>         unregister_sysctl_table(my_ctl_header);
> }
>
> module_init(sysctl_exam_init);
> module_exit(sysctl_exam_exit);
> MODULE_LICENSE("GPL");
> /****************************************************************/
>
> [root@bigendian my]# insmod -f /root/my/hello.ko nsm_use_hostnames=1
> [root@bigendian my]# cat /proc/sys/mysysctl/nsm_use_hostnames
> 16777216
>
> After I change the bool to int:
> [root@bigendian my]# insmod -f /root/my/hello.ko nsm_use_hostnames=1
> [root@bigendian my]# cat /proc/sys/mysysctl/nsm_use_hostnames
> 1
>
> In little endian system, there is no such issue.
>
> Jia He (1):
>   lockd: Change nsm_use_hostnames from bool to u32
>
>  fs/lockd/mon.c              | 2 +-
>  fs/lockd/svc.c              | 2 +-
>  include/linux/lockd/lockd.h | 2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
>

