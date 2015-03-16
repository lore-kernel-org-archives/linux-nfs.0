Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:19155 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754386AbbCPRm4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2015 13:42:56 -0400
Message-ID: <5507161D.8050304@Netapp.com>
Date: Mon, 16 Mar 2015 13:42:53 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] NFS: Don't zap caches on fallocate()
References: <1425571566-3117-1-git-send-email-Anna.Schumaker@Netapp.com> <1426175859.15787.1.camel@primarydata.com>
In-Reply-To: <1426175859.15787.1.camel@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/12/2015 11:57 AM, Trond Myklebust wrote:
> Hi Anna,
> 
> On Thu, 2015-03-05 at 11:06 -0500, Anna Schumaker wrote:
>> This patch adds a GETATTR to the end of ALLOCATE and DEALLOCATE
>> operations so we can set the updated inode size and change attribute
>> directly.  DEALLOCATE will still need to release pagecache pages, so
>> nfs42_proc_deallocate() now calls truncate_pagecache_range() before
>> contacting the server.
>>
>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>> ---
>>  fs/nfs/inode.c          |  1 -
>>  fs/nfs/nfs42proc.c      | 23 +++++++++++++++++++----
>>  fs/nfs/nfs42xdr.c       | 20 ++++++++++++++++----
>>  fs/nfs/nfs4file.c       |  1 -
>>  include/linux/nfs_xdr.h |  4 ++++
>>  5 files changed, 39 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index d42dff6..e92386f 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -192,7 +192,6 @@ void nfs_zap_caches(struct inode *inode)
>>         nfs_zap_caches_locked(inode);
>>         spin_unlock(&inode->i_lock);
>>  }
>> -EXPORT_SYMBOL_GPL(nfs_zap_caches);
> 
> This patch appears to be completely whitespace-borked. Can you please
> fix up your mailer and resend?

I sent this with git, so I don't know what happened.  I'll resend soon!  (I'm tacking on an additional patch to reduce time spent under the i_mutex anyway)

Anna
> 
> Thanks
>   Trond
> 

