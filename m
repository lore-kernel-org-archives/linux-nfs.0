Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:6306 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752337AbdEPM5d (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 May 2017 08:57:33 -0400
From: Gu Zheng <guzheng1@huawei.com>
Subject: nfs+ext4,can not umount the ext4 mountpoint
To: <bfields@fieldses.org>, <jlayton@poochiereds.net>
CC: <linux-nfs@vger.kernel.org>, <houtao1@huawei.com>,
        Zhaohongjiang <zhaohongjiang@huawei.com>, <miaoxie@huawei.com>
Message-ID: <591AF71F.1040703@huawei.com>
Date: Tue, 16 May 2017 20:57:03 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="gbk"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all:
we have a test about nfs on linux 4.11.
the detailed process as follow:
server ip:9.81.231.141                    		client
mount -t ext4 /dev/vdb /home/nfs/aa
							mount -t nfs -o sync,tcp,vers=3,noac,timeo=70,retrans=3 9.81.231.141:/home/nfs  /tmp/aa/
							ls /tmp/aa
umount /home/nfs/aa

the umount remind "target is busy".
so we analyze the code , a reference count which is named "mnt_count" add 1 in rqst_exp_get_by_name() after execute the "ls" order.
the detailed call is nfsd3_proc_lookup->nfsd_lookup->nfsd_lookup_dentry->nfsd_cross_mnt->rqst_exp_get_by_name->exp_get_by_name->svc_export_lookup->sunrpc_cache_lookup->svc_export_init->path_get
the reference count can't be subtracted untill we stop nfsd or tcp idle timeout on server. the system call the cache_flush() to subtract the count.
then we can umount successfully.

do dou have some patches can umount immediately or some suggestions?

