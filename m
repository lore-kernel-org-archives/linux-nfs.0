Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:23976 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102Ab3FZAPO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 20:15:14 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH 5/5] NFS: Save FSID's root FH in nfs_server
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1372198247.17600.17.camel@leira.trondhjem.org>
Date: Tue, 25 Jun 2013 20:15:09 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <0A7A018C-54AA-4945-876C-16ABB7CA771C@oracle.com>
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net> <20130625162405.36416.83658.stgit@seurat.1015granger.net> <1372178216.5968.30.camel@leira.trondhjem.org> <3B05A214-E7E5-474B-8F51-12E64A608B8A@oracle.com> <1372194900.17600.6.camel@leira.trondhjem.org> <2EFD4576-C5AA-4295-9DB2-A5E6BAD5061B@oracle.com> <1372198247.17600.17.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 25, 2013, at 6:10 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-06-25 at 17:51 -0400, Chuck Lever wrote:
>> On Jun 25, 2013, at 5:15 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>> 
>>> On Tue, 2013-06-25 at 13:22 -0700, Chuck Lever wrote:
>>>> On Jun 25, 2013, at 12:37 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>>> 
>>>>> On Tue, 2013-06-25 at 12:24 -0400, Chuck Lever wrote:
>>>>>> Save each FSID's root file handle in the FSID's nfs_server structure
>>>>>> on the client.  This is needed for NFSv4 migration recovery.
>>>>> 
>>>>> Please just use sb->s_root.
>>>> 
>>>> The migration recovery procedures do not take an inode or dentry argument.  All we have is an nfs_server.  I see
>>>> 
>>>> struct nfs_server *server = NFS_SB(sb);
>>>> 
>>>> but what is the preferred method for going the other way?  A naive approach would be to plant a super_block back-pointer in each nfs_server.
>>> 
>>> Why do you not have an inode or dentry?
>> 
>> That's the way the APIs happen to be architected.  I wasn't certain that exception->inode in nfs4_handle_exception(), and state->inode in nfs4_async_handle_error(), would always be non-NULL when I needed an inode pointer.
> 
> That should be fixable.

I seem to recall some cases where the proc itself didn't have an inode to pass to the exception handler.  But I'll go back and look through them again.  Those cases may be irrelevant.

Passing an inode will probably make for a better API.

> 
>>> Surely the migration must have
>>> been triggered either by an operation involving a filehandle, in which
>>> case you have an inode, or by a LEASE_MOVED, in which case there is open
>>> state on the target filesystem.
>> 
>> It's quite convenient to always use the FSID's root FH, but I agree, it's not required by the protocol.
> 
> The problem is that there is no single root FH in NFSv4. The existence
> of the pseudofs means that you can have several points of entry to the
> same filesystem. Then there are Linux bind mounts...

Fair enough.

> 
>> Re: LEASE_MOVED, I'm not confident the client stops sending RENEW operations when it has no more open state.
> 
> That shouldn't matter. The server isn't allowed to reply with
> LEASE_MOVED in that situation.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

