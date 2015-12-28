Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.molgen.mpg.de ([141.14.17.9]:58183 "EHLO mx1.molgen.mpg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134AbbL1TjN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Dec 2015 14:39:13 -0500
From: Donald Buczek <buczek@molgen.mpg.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Donald Buczek <buczek@molgen.mpg.de>, Al Viro <viro@zeniv.linux.org.uk>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs: revalidate inode before access checks
Date: Mon, 28 Dec 2015 20:38:50 +0100
Message-Id: <1451331530-3748-1-git-send-email-buczek@molgen.mpg.de>
In-Reply-To: <CAHQdGtRSPrV=eV_VEGbpp47qfpW93GSouoEzaseHDq5enMtCDg@mail.gmail.com>
References: <CAHQdGtRSPrV=eV_VEGbpp47qfpW93GSouoEzaseHDq5enMtCDg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 27.12.2015 17:23, Trond Myklebust wrote:
> On Sun, Dec 27, 2015 at 7:18 AM, Donald Buczek <buczek@molgen.mpg.de> wrote:
>>
>> On 27.12.2015 04:06, Trond Myklebust wrote:
>>> Donald Buczek reports that a nfs4 client incorrectly denies
>>> execute access based on outdated file mode (missing 'x' bit).
>>> After the mode on the server is 'fixed' (chmod +x) further execution
>>> attempts continue to fail, because the nfs ACCESS call updates
>>> the access parameter but not the mode parameter or the mode in
>>> the inode.
>>>
>>> The root cause is ultimately that the VFS is calling may_open()
>>> before the NFS client has a chance to OPEN the file and hence revalidate
>>> the access and attribute caches.
>>>
>>> Al Viro suggests:
>>>>>> Make nfs_permission() relax the checks when it sees MAY_OPEN, if you
>>>>>> know
>>>>>> that things will be caught by server anyway?
>>>>> That can work as long as we're guaranteed that everything that calls
>>>>> inode_permission() with MAY_OPEN on a regular file will also follow up
>>>>> with a vfs_open() or dentry_open() on success. Is this always the
>>>>> case?
>>>> 1) in do_tmpfile(), followed by do_dentry_open() (not reachable by NFS
>>>> since
>>>> it doesn't have ->tmpfile() instance anyway)
>>>>
>>>> 2) in atomic_open(), after the call of ->atomic_open() has succeeded.
>>>>
>>>> 3) in do_last(), followed on success by vfs_open()
>>>>
>>>> That's all.  All calls of inode_permission() that get MAY_OPEN come from
>>>> may_open(), and there's no other callers of that puppy.
>>> Reported-by: Donald Buczek <buczek@molgen.mpg.de>
>>> Link: https://bugzilla.kernel.org/show_bug.cgi?id=109771
>>> Link:
>>> http://lkml.kernel.org/r/1451046656-26319-1-git-send-email-buczek@molgen.mpg.de
>>> Cc: Al Viro <viro@zeniv.linux.org.uk>
>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>> ---
>>> Hi Donald,
>>> Can you check if this fixes the issue for you?
>>>
>>>   fs/nfs/dir.c | 3 +++
>>>   1 file changed, 3 insertions(+)
>>>
>>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>>> index ce5a21861074..44e519c21e18 100644
>>> --- a/fs/nfs/dir.c
>>> +++ b/fs/nfs/dir.c
>>> @@ -2449,6 +2449,9 @@ int nfs_permission(struct inode *inode, int mask)
>>>                 case S_IFLNK:
>>>                         goto out;
>>>                 case S_IFREG:
>>> +                       if ((mask & MAY_OPEN) &&
>>> +                          nfs_server_capable(inode, NFS_CAP_ATOMIC_OPEN))
>>> +                               return 0;
>>>                         break;
>>>                 case S_IFDIR:
>>>                         /*
>>
>>
>> I can confirm that this fixes the original issue. However, even with this
>> patch, calls to the access syscall would continue to deliver failure based
>> on obsolete modes forever. This can be seen as a bug, too.
> No. What happens now is that the OPEN compound executes before any
> ACCESS calls, and so it refreshes the inode attributes and the access
> cache.

No? If we come here by access() instead of execve(), we don't have MAY_OPEN but MAY_ACCESS. So we are going the old route, and permission is denied. An open will never be attempted. Of course, I've tested that before making the claim, that the problem continues to exist with access() instead of execve().  But perhaps you are referring to something else?

I think, it has to be decided, whether the ancient rule "Not even root gets to execute a binary that doesn't have a single exec bit
on it" should be enforced nowadays or not. How to decide that?

If no, the check can just be removed (from other filesystems, too)
If yes, then we want to deny execute access based on the client visible mode. In that case we'd have to ensure that the cache is properly aged out. I append the trivial patch here which worked for me.

Cheers
  Donald

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=109771
Signed-off-by: Donald Buczek <buczek@molgen.mpg.de>


---
 fs/nfs/dir.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ce5a218..60d42b4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2439,6 +2439,8 @@ int nfs_permission(struct inode *inode, int mask)
 
 	nfs_inc_stats(inode, NFSIOS_VFSACCESS);
 
+	nfs_revalidate_inode(NFS_SERVER(inode),inode);
+
 	if ((mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) == 0)
 		goto out;
 	/* Is this sys_access() ? */
-- 
2.4.1

