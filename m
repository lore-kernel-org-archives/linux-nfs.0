Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9478 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410Ab0IHNKZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Sep 2010 09:10:25 -0400
Message-ID: <4C878B30.1010808@netapp.com>
Date: Wed, 08 Sep 2010 09:10:08 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/6] NFS: remove readdir plus limit
References: <4C869AA7.2030000@netapp.com> <14C46455-5738-4FBA-872D-0442B8DAB3C5@oracle.com>
In-Reply-To: <14C46455-5738-4FBA-872D-0442B8DAB3C5@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks for the advice.  I did some testing between my machine (server) and a virtual machine (client).  The command I ran was ls -l --color=none on a directory with 10,000 files.  With the directory cap, nfsstat had the following output for both a stock kernel and a kernel with these patches applied

Stock Kernel
---------------------
calls:		10101
getattr:	3
readdir:	89
lookup:		10002


My Kernel
----------------------
calls:		10169
getattr:	3
readdir:	157
lookup:		10002


Without the directory cap, I saw the following numbers

Trial 1
--------------------
calls:		1710
getattr:	1622
readdirplus:	79
lookup:		2

Trial 2
--------------------
calls:		1233
getattr:	1145
readdirplus:	79
lookup:		2

Trial 3
--------------------
calls:		217
getattr:	129
readdirplus:	79
lookup:		2


In each of these cases the number of lookups has dropped from 10,002 to 2.  The number of total calls has dropped significantly as well.  I suspect that the change in getattrs is caused by a race between items hitting the cache and the same items being used.

Let me know if I should run other tests.

Bryan

On 09/07/2010 04:33 PM, Chuck Lever wrote:
> Hi Bryan-
> 
> On Sep 7, 2010, at 4:03 PM, Bryan Schumaker wrote:
> 
>> NFS remove readdir plus limit
>>
>> We will now use readdir plus even on directories that are very large.
> 
> READDIRPLUS operations on some servers may be quite expensive, since the server usually treats directories as byte streams, and can be read sequentially; but inode attributes are read by random disk seeks.  So assembling a READDIRPLUS result on a large directory that isn't in the server's cache might be an awful lot of work on a busy server.
> 
> On large directories, there isn't much proven benefit to having all the dcache entries on hand on the client.  It can even hurt performance by pushing more useful entries out of the cache.
> 
> If we really want to take the directory size cap off, that seems like it could be a far-reaching change.  You should at least use the patch description to provide thorough rationale.  Even some benchmark results, with especially slow servers and networks, and small clients, would be nice.
> 
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 7d2d6c7..b2e12bc 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -234,9 +234,6 @@ nfs_init_locked(struct inode *inode, void *opaque)
>> 	return 0;
>> }
>>
>> -/* Don't use READDIRPLUS on directories that we believe are too large */
>> -#define NFS_LIMIT_READDIRPLUS (8*PAGE_SIZE)
>> -
>> /*
>>  * This is our front-end to iget that looks up inodes by file handle
>>  * instead of inode number.
>> @@ -291,8 +288,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
>> 		} else if (S_ISDIR(inode->i_mode)) {
>> 			inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->dir_inode_ops;
>> 			inode->i_fop = &nfs_dir_operations;
>> -			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS)
>> -			    && fattr->size <= NFS_LIMIT_READDIRPLUS)
>> +			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS))
>> 				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
>> 			/* Deal with crossing mountpoints */
>> 			if ((fattr->valid & NFS_ATTR_FATTR_FSID)
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

