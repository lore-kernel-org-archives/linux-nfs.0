Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44836 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752259AbdEPRmQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 May 2017 13:42:16 -0400
Date: Tue, 16 May 2017 13:42:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Gu Zheng <guzheng1@huawei.com>
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org,
        houtao1@huawei.com, Zhaohongjiang <zhaohongjiang@huawei.com>,
        miaoxie@huawei.com
Subject: Re: nfs+ext4,can not umount the ext4 mountpoint
Message-ID: <20170516174215.GA15232@fieldses.org>
References: <591AF71F.1040703@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <591AF71F.1040703@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 16, 2017 at 08:57:03PM +0800, Gu Zheng wrote:
> Hi all:
> we have a test about nfs on linux 4.11.
> the detailed process as follow:
> server ip:9.81.231.141                    		client
> mount -t ext4 /dev/vdb /home/nfs/aa
> 							mount -t nfs -o sync,tcp,vers=3,noac,timeo=70,retrans=3 9.81.231.141:/home/nfs  /tmp/aa/
> 							ls /tmp/aa
> umount /home/nfs/aa

This is as expected.  There's actually no guarantee you'll be able to
unmount the filesystem till nfsd is stopped (even unexporting won't
always do the job).

--b.

> 
> the umount remind "target is busy".
> so we analyze the code , a reference count which is named "mnt_count" add 1 in rqst_exp_get_by_name() after execute the "ls" order.
> the detailed call is nfsd3_proc_lookup->nfsd_lookup->nfsd_lookup_dentry->nfsd_cross_mnt->rqst_exp_get_by_name->exp_get_by_name->svc_export_lookup->sunrpc_cache_lookup->svc_export_init->path_get
> the reference count can't be subtracted untill we stop nfsd or tcp idle timeout on server. the system call the cache_flush() to subtract the count.
> then we can umount successfully.
> 
> do dou have some patches can umount immediately or some suggestions?
