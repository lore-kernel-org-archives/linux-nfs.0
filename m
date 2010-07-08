From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFSD: Return full WCC data for NFSv3 metadata operations
Date: Thu, 08 Jul 2010 15:59:15 -0400
Message-ID: <4C362E13.4080509@oracle.com>
References: <20100708154037.2820.51702.stgit@ellison.1015granger.net> <20100708195335.GB31173@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:22938 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758543Ab0GHUAU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jul 2010 16:00:20 -0400
In-Reply-To: <20100708195335.GB31173@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/ 8/10 03:53 PM, J. Bruce Fields wrote:
> On Thu, Jul 08, 2010 at 11:43:46AM -0400, Chuck Lever wrote:
>> NFSv3 WCC data, or "weak cache consistency" data, is an attempt to
>> reduce the number of on-the-wire transactions needed by NFS clients
>> to keep their caches up to date.  WCC data consists of two parts:
>>
>>    o  pre-op data, which is a subset of file metadata as it was before
>>       a procedure starts, and
>>
>>    o  post-op data, which is a full set of NFSv3 file attribute data as
>>       it is after a procedure finishes.
>>
>> For an NFSv3 procedure that returns wcc_data, an NFSv3 server is free
>> to return either, both, or neither of these.  Define "full WCC data"
>> as a reply that contains both pre-op and post-op data.
>>
>> To make this data useful, a server must ensure that file metadata is
>> captured atomically around the requested operation.  If the pre-op
>> data in a reply matches the file metadata that the client already has
>> cached, the client can assume that no other operation on that file
>> occurred while the server was fulfilling the current request, and that
>> therefore the post-op metadata is the latest version, and can be
>> cached.
>>
>> Conversely, NFSv3 clients invalidate their metadata caches when they
>> receive replies to metadata altering operations that do not contain
>> full WCC data.  When a server presents a reply that does not have both
>> pre-op and post-op WCC data, clients must employ extra LOOKUP and
>> GETATTR requests to ensure their metadata caches are up to date,
>> causing performance to suffer needlessly.  For example, untarring a
>> large tar file can take almost an order of magnitude longer in this
>> case, depending on the client implementation.
>>
>> In the Linux NFS server implementation, to ensure that WCC data
>> reflects only changes made during the current file system operation,
>> the file's inode mutex is held in order to serialize metadata altering
>> operations on that inode.  Our server saves pre-op data for a file
>> handle just after the target inode's mutex is taken, and saves post-op
>> data just before the inode's mutex is dropped (see fh_lock() and
>> fh_unlock()).
>>
>> In order to return full WCC data to clients, our server must have both
>> the saved pre-op and the saved post-op attribute data for a file
>> handle filled in before it starts XDR encoding the reply.
>> Unfortunately, for the NFSv3 MKDIR, MKNOD, REMOVE, RMDIR procedures,
>> our server does not unlock the parent directory inode until well after
>> the reply has been XDR encoded.
>>
>> In these cases, encode_wcc_data() does have saved pre-op WCC data
>> available, since the fh is locked, but does not have saved post-op WCC
>> data for the parent directory, since it hasn't yet been unlocked.  In
>> this situation, encode_wcc_data() simply grabs the parent's current
>> metadata, uses that as the post-op WCC data, and returns no pre-op
>> WCC data to the client.
>>
>> By instead unlocking the parent directory file handle immediately
>> after the internal operations for each of these NFS procedures is
>> complete, saved post-op WCC data for the file handle is filled in
>> before XDR encoding starts, so full WCC data for that procedure can
>> be returned to clients.
>>
>> Note that the NFSv4 CREATE and REMOVE procedures already invoke
>> fh_unlock() explicitly on the parent directory in order to fill in the
>> NFSv4 post change attribute.
>>
>> Note also that NFSv3 CREATE, RENAME, SETATTR, and SYMLINK already
>> perform explicit file handle unlocking.
>>
>> Signed-off-by: Chuck Lever<chuck.lever@oracle.com>
>> ---
>>
>> Bruce-
>>
>> This patch is mechanically the same as the previous one, but the patch
>> description has a more accurate and clearly stated rationale for the
>> change.
>>
>> Please use this one instead of the previous one.
>
> Thanks.  The first is already committed, though.

And you can't use "git reset --soft ..." to fix the commit message 
because....?
