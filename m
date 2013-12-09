Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:53497 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761017Ab3LIKoz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Dec 2013 05:44:55 -0500
Message-ID: <52A59EAB.20200@huawei.com>
Date: Mon, 9 Dec 2013 18:42:51 +0800
From: Rui Xiang <rui.xiang@huawei.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfs: fix return err if inode exiting in nfs_instantiate
References: <1386322217-27436-1-git-send-email-rui.xiang@huawei.com> <1386322217-27436-2-git-send-email-rui.xiang@huawei.com> <E04FAC94-F109-4F37-8077-A39F3C386899@primarydata.com>
In-Reply-To: <E04FAC94-F109-4F37-8077-A39F3C386899@primarydata.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013/12/6 21:46, Trond Myklebust wrote:
> 
> On Dec 6, 2013, at 4:30, Rui Xiang <rui.xiang@huawei.com> wrote:
> 
>> In common function nfs_instantiate to create, mkdir, and mknod,
>> if dentry->d_inode exits, it should return -EEXIST instead of
>> -EACCES.
>>
>> Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
>> ---
>> fs/nfs/dir.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>> index 2518865..e570b37 100644
>> --- a/fs/nfs/dir.c
>> +++ b/fs/nfs/dir.c
>> @@ -1547,7 +1547,7 @@ int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
>> 	struct dentry *parent = dget_parent(dentry);
>> 	struct inode *dir = parent->d_inode;
>> 	struct inode *inode;
>> -	int error = -EACCES;
>> +	int error = -EEXIST;
>>
>> 	d_drop(dentry);
>>
> 
> That looks like it should rather be a WARN_ON(). If the caller has set the dentry's inode before creating the file, then something is really wrong.
It can return -EEXIST to say that the file already exits, then will exit. But why does it need a WARN_ON(). Please give me some advise.

Thanks
 Rui
> 
> Cheers
>   Trond
> 


