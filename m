From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs_file_flush() question
Date: Mon, 18 Aug 2008 12:04:01 -0400
Message-ID: <309543F5-E522-44CC-B114-C9652328FE0F@oracle.com>
References: <20080817002342.GA17223@yahoo-inc.com> <1218992641.7999.2.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:23301 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbYHRQE0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Aug 2008 12:04:26 -0400
In-Reply-To: <1218992641.7999.2.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 17, 2008, at 1:04 PM, Trond Myklebust wrote:
> On Sat, 2008-08-16 at 19:23 -0500, Quentin Barnes wrote:
>> I've been coming up to speed on the NFS protocol and its NFS client
>> support in Linux.  I've been comparing performance of NFS on RHEL4
>> and RHEL5 vs. FreeBSD 6.2.  (Okay, we're on an old base, but I don't
>> think it matters here for this question.)
>>
>> In watching the NFS protocols fly back and forth between BSD
>> and Linux clients to an NFS server, I noticed that Linux is
>> doing an extra GETATTR over FreeBSD when closing a read-write
>> file.  I tracked this back to nfs_file_flush() which is
>> doing a __nfs_revalidate_inode() (or in current kernels
>> nfs_revalidate_inode()).  Why do we want nfs_file_flush() to force
>> a revalidate of an inode we're closing?  Why not instead just
>> invalidate the inode's attribute?
>>
>> I looked at the FreeBSD 6.2 code.  In its nfs_close(), it does an
>> "np->n_attrstamp = 0;" to invalidate the inode's attribute cache.
>>
>> The current Linux kernel code in question in nfs_file_flush() is:
>> ==========
>>   /* Ensure that data+attribute caches are up to date after close()  
>> */
>>   status = nfs_do_fsync(ctx, inode);
>>   if (!status)
>>           nfs_revalidate_inode(NFS_SERVER(inode), inode);
>> ==========
>>
>> I would imagine this better as:
>> ==========
>>   /* Ensure that data+attribute caches are up to date after close()  
>> */
>>   status = nfs_do_fsync(ctx, inode);
>>   if (!status && !(NFS_SERVER(inode)->flags & NFS_MOUNT_NOCTO))
>>           NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
>> ==========
>>
>> Is there a reason I'm missing that the revalidate and GETATTR are
>> required?
>
> Yes: It is required for correct close-to-open cache consistency
> semantics.
>
> If I don't know the correct mtime attribute of the file when I close  
> it,
> then I can't compare it with the mtime of the file when I open it  
> again.
> If so, close-to-open semantics forbid me from assuming that my cached
> data is still valid, and so I have to throw out the entire page cache
> contents for that file.

For NFSv3, a WRITE operation can return post-op attributes which  
reflect the updated mtime on the server.  In that case, we get the  
updated mtime for free, and don't need the additional GETATTR.

However, there are corner cases:

1.  The client had to send multiple WRITEs to finish flushing the  
file's dirty data, and the replies returned out of order.  In this  
case, the client can't know which mtime is the final value.

2.  The server chose not to return post-op attributes.

Does the Linux NFS client optimize away the GETATTR when it has sent  
only a single WRITE and the server has returned post-op attributes?   
Using a large wsize with a modern server implementation might make  
this a fairly common scenario.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
