Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:6398 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752858AbdEQHTd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 17 May 2017 03:19:33 -0400
Subject: Re: nfs+ext4,can not umount the ext4 mountpoint
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <591AF71F.1040703@huawei.com>
 <20170516174215.GA15232@fieldses.org>
CC: <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        <houtao1@huawei.com>, Zhaohongjiang <zhaohongjiang@huawei.com>,
        <miaoxie@huawei.com>
From: Gu Zheng <guzheng1@huawei.com>
Message-ID: <591BF94E.9000805@huawei.com>
Date: Wed, 17 May 2017 15:18:38 +0800
MIME-Version: 1.0
In-Reply-To: <20170516174215.GA15232@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear J. Bruce Fields
in nfs rfc wrote:
    "Every NFS version 3 protocol client can also potentially be a
    server, and remote and local mounted file systems can be
    freely mixed. This leads to some problems when a client
    travels down the directory tree of a remote file system and
    reaches the mount point on the server for another remote file
    system. Allowing the server to follow the second remote mount
    would require loop detection, server lookup, and user
    revalidation. Instead, both NFS version 2 protocol and NFS
    version 3 protocol implementations do not typically let
    clients cross a server's mount point. When a client does a
    LOOKUP on a directory on which the server has mounted a file
    system, the client sees the underlying directory instead of
    the mounted directory.

    For example, if a server has a file system called /usr and
    mounts another file system on /usr/src, if a client mounts
    /usr, it does not see the mounted version of /usr/src. A
    client could do remote mounts that match the server's mount
    points to maintain the server's view.  In this example, the
    client would also have to mount /usr/src in addition to /usr,
    even if they are from the same server."
	
and now we do not set the crossmnt ,so that we saw is the underlying directory .
the nfs mount have no relation to ext4 mountpoint, it can be umounted maybe better.

can we add some limits to let it do not enter the nfsd_cross_mnt() in nfsd_lookup_dentry()if the crossmnt is not set?

best wishes!

在 2017/5/17 1:42, J. Bruce Fields 写道:
> On Tue, May 16, 2017 at 08:57:03PM +0800, Gu Zheng wrote:
>> Hi all:
>> we have a test about nfs on linux 4.11.
>> the detailed process as follow:
>> server ip:9.81.231.141                    		client
>> mount -t ext4 /dev/vdb /home/nfs/aa
>> 							mount -t nfs -o sync,tcp,vers=3,noac,timeo=70,retrans=3 9.81.231.141:/home/nfs  /tmp/aa/
>> 							ls /tmp/aa
>> umount /home/nfs/aa
>
> This is as expected.  There's actually no guarantee you'll be able to
> unmount the filesystem till nfsd is stopped (even unexporting won't
> always do the job).
>
> --b.
>
>>
>> the umount remind "target is busy".
>> so we analyze the code , a reference count which is named "mnt_count" add 1 in rqst_exp_get_by_name() after execute the "ls" order.
>> the detailed call is nfsd3_proc_lookup->nfsd_lookup->nfsd_lookup_dentry->nfsd_cross_mnt->rqst_exp_get_by_name->exp_get_by_name->svc_export_lookup->sunrpc_cache_lookup->svc_export_init->path_get
>> the reference count can't be subtracted untill we stop nfsd or tcp idle timeout on server. the system call the cache_flush() to subtract the count.
>> then we can umount successfully.
>>
>> do dou have some patches can umount immediately or some suggestions?
>
> .
>

