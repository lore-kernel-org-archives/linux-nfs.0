Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42286 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753814AbdCOOAl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Mar 2017 10:00:41 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Chuck Lever" <chuck.lever@oracle.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: git "make test" fails in t9200-git-cvsexportcommit.sh
Date: Wed, 15 Mar 2017 10:00:33 -0400
Message-ID: <EEDA8B03-DB54-47BA-A6FD-AF293BFEDE8E@redhat.com>
In-Reply-To: <5E4A3C66-5123-446D-9556-0E59E546283D@redhat.com>
References: <12A85CA0-A715-4379-81D5-58A9CB001266@oracle.com>
 <5E4A3C66-5123-446D-9556-0E59E546283D@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14 Mar 2017, at 18:25, Benjamin Coddington wrote:

> Hi Chuck,
>
> On 14 Mar 2017, at 11:07, Chuck Lever wrote:
>
>> Hi Ben!
>>
>> After addressing some IB stack issues that arose in v4.11-rc1,
>> I was finally able to run my standard suite of NFS tests with
>> v4.11-rc2. I found that part of the git regression suite fails
>> with this kernel.
>> ...
>> A wire capture shows that some GETATTR operations receive
>> an NFS3ERR_STALE response from the server. I looked at one
>> of these, and it's against a renamed file "index.lock".
>>
>> So I reverted:
>>
>> commit 920b4530fb80430ff30ef83efe21ba1fa5623731
>> Author:     Benjamin Coddington <bcodding@redhat.com>
>> Date: Wed Feb 1 00:00:07 2017 -0500
>>
>> NFS: nfs_rename() handle -ERESTARTSYS dentry left behind
>>
>> And t9200 now passes:
>
> Yep, something seems to be wrong with calling
> nfs_mark_for_revalidate(old_inode) in rpc_call_done instead of after
> rpc_release.  Thanks for catching this.  I'm out of time today, and 
> will
> look at this in the morning.

I found the test was doing something like:

  rename("/mnt/localhost/attic_gremlin,", 
"/mnt/localhost/attic_gremlin,v") = 0
  open("attic_gremlin", O_RDONLY) = 7
  open("attic_gremlin,v", O_RDONLY) = 8

So, I think the problem is that patch moved the d_move() before
d_rehash(new_inode).. so it's actually rehasing the old dentry's name.  
I'm testing
the following fix:

 From 425f85c59142fe0821d30b11ba0df7704ebf6de6 Mon Sep 17 00:00:00 2001
Message-Id: 
<425f85c59142fe0821d30b11ba0df7704ebf6de6.1489586013.git.bcodding@redhat.com>
 From: Benjamin Coddington <bcodding@redhat.com>
Date: Wed, 15 Mar 2017 08:06:38 -0400
Subject: [PATCH] NFS: Fix old dentry rehash after move

Now that nfs_rename()'s d_move has moved within the RPC task's 
rpc_call_done
callback, rehashing new_dentry will actually rehash the old dentry's 
name
in nfs_rename().  d_move() is going to rehash the new dentry for us 
anyway,
so doing it again here is unnecessary.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Fixes: 920b4530fb80 ("NFS: nfs_rename() handle -ERESTARTSYS dentry left 
behind")
---
  fs/nfs/dir.c | 9 ++-------
  1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index fb499a3f21b5..f92ba8d6c556 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2055,7 +2055,7 @@ int nfs_rename(struct inode *old_dir, struct 
dentry *old_dentry,
  {
     struct inode *old_inode = d_inode(old_dentry);
     struct inode *new_inode = d_inode(new_dentry);
-   struct dentry *dentry = NULL, *rehash = NULL;
+   struct dentry *dentry = NULL;
     struct rpc_task *task;
     int error = -EBUSY;

@@ -2078,10 +2078,8 @@ int nfs_rename(struct inode *old_dir, struct 
dentry *old_dentry,
          * To prevent any new references to the target during the
          * rename, we unhash the dentry in advance.
          */
-       if (!d_unhashed(new_dentry)) {
+       if (!d_unhashed(new_dentry))
             d_drop(new_dentry);
-           rehash = new_dentry;
-       }

         if (d_count(new_dentry) > 2) {
             int err;
@@ -2098,7 +2096,6 @@ int nfs_rename(struct inode *old_dir, struct 
dentry *old_dentry,
                 goto out;

             new_dentry = dentry;
-           rehash = NULL;
             new_inode = NULL;
         }
     }
@@ -2119,8 +2116,6 @@ int nfs_rename(struct inode *old_dir, struct 
dentry *old_dentry,
         error = task->tk_status;
     rpc_put_task(task);
  out:
-   if (rehash)
-       d_rehash(rehash);
     trace_nfs_rename_exit(old_dir, old_dentry,
             new_dir, new_dentry, error);
     /* new dentry created? */
-- 
2.9.3
