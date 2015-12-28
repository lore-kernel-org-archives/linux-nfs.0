Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:36595 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbbL1VKN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Dec 2015 16:10:13 -0500
Received: by mail-ob0-f171.google.com with SMTP id ba1so148074506obb.3
        for <linux-nfs@vger.kernel.org>; Mon, 28 Dec 2015 13:10:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1451331530-3748-1-git-send-email-buczek@molgen.mpg.de>
References: <CAHQdGtRSPrV=eV_VEGbpp47qfpW93GSouoEzaseHDq5enMtCDg@mail.gmail.com>
	<1451331530-3748-1-git-send-email-buczek@molgen.mpg.de>
Date: Mon, 28 Dec 2015 16:10:12 -0500
Message-ID: <CAHQdGtTOSw9gDFWo6nwfr=bSo9aXAHVHeRX0XMdeDGkfvzqQjw@mail.gmail.com>
Subject: Re: [PATCH] nfs: revalidate inode before access checks
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Donald Buczek <buczek@molgen.mpg.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 28, 2015 at 2:38 PM, Donald Buczek <buczek@molgen.mpg.de> wrote:
> On 27.12.2015 17:23, Trond Myklebust wrote:
>> On Sun, Dec 27, 2015 at 7:18 AM, Donald Buczek <buczek@molgen.mpg.de> wrote:
>>>
>>> On 27.12.2015 04:06, Trond Myklebust wrote:
>>>> Donald Buczek reports that a nfs4 client incorrectly denies
>>>> execute access based on outdated file mode (missing 'x' bit).
>>>> After the mode on the server is 'fixed' (chmod +x) further execution
>>>> attempts continue to fail, because the nfs ACCESS call updates
>>>> the access parameter but not the mode parameter or the mode in
>>>> the inode.
>>>>
>>>> The root cause is ultimately that the VFS is calling may_open()
>>>> before the NFS client has a chance to OPEN the file and hence revalidate
>>>> the access and attribute caches.
>>>>
>>>> Al Viro suggests:
>>>>>>> Make nfs_permission() relax the checks when it sees MAY_OPEN, if you
>>>>>>> know
>>>>>>> that things will be caught by server anyway?
>>>>>> That can work as long as we're guaranteed that everything that calls
>>>>>> inode_permission() with MAY_OPEN on a regular file will also follow up
>>>>>> with a vfs_open() or dentry_open() on success. Is this always the
>>>>>> case?
>>>>> 1) in do_tmpfile(), followed by do_dentry_open() (not reachable by NFS
>>>>> since
>>>>> it doesn't have ->tmpfile() instance anyway)
>>>>>
>>>>> 2) in atomic_open(), after the call of ->atomic_open() has succeeded.
>>>>>
>>>>> 3) in do_last(), followed on success by vfs_open()
>>>>>
>>>>> That's all.  All calls of inode_permission() that get MAY_OPEN come from
>>>>> may_open(), and there's no other callers of that puppy.
>>>> Reported-by: Donald Buczek <buczek@molgen.mpg.de>
>>>> Link: https://bugzilla.kernel.org/show_bug.cgi?id=109771
>>>> Link:
>>>> http://lkml.kernel.org/r/1451046656-26319-1-git-send-email-buczek@molgen.mpg.de
>>>> Cc: Al Viro <viro@zeniv.linux.org.uk>
>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>>> ---
>>>> Hi Donald,
>>>> Can you check if this fixes the issue for you?
>>>>
>>>>   fs/nfs/dir.c | 3 +++
>>>>   1 file changed, 3 insertions(+)
>>>>
>>>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>>>> index ce5a21861074..44e519c21e18 100644
>>>> --- a/fs/nfs/dir.c
>>>> +++ b/fs/nfs/dir.c
>>>> @@ -2449,6 +2449,9 @@ int nfs_permission(struct inode *inode, int mask)
>>>>                 case S_IFLNK:
>>>>                         goto out;
>>>>                 case S_IFREG:
>>>> +                       if ((mask & MAY_OPEN) &&
>>>> +                          nfs_server_capable(inode, NFS_CAP_ATOMIC_OPEN))
>>>> +                               return 0;
>>>>                         break;
>>>>                 case S_IFDIR:
>>>>                         /*
>>>
>>>
>>> I can confirm that this fixes the original issue. However, even with this
>>> patch, calls to the access syscall would continue to deliver failure based
>>> on obsolete modes forever. This can be seen as a bug, too.
>> No. What happens now is that the OPEN compound executes before any
>> ACCESS calls, and so it refreshes the inode attributes and the access
>> cache.
>
> No? If we come here by access() instead of execve(), we don't have MAY_OPEN but MAY_ACCESS. So we are going the old route, and permission is denied. An open will never be attempted. Of course, I've tested that before making the claim, that the problem continues to exist with access() instead of execve().  But perhaps you are referring to something else?
>
> I think, it has to be decided, whether the ancient rule "Not even root gets to execute a binary that doesn't have a single exec bit
> on it" should be enforced nowadays or not. How to decide that?
>
> If no, the check can just be removed (from other filesystems, too)
> If yes, then we want to deny execute access based on the client visible mode. In that case we'd have to ensure that the cache is properly aged out. I append the trivial patch here which worked for me.
>
> Cheers
>   Donald
>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=109771
> Signed-off-by: Donald Buczek <buczek@molgen.mpg.de>
>
>
> ---
>  fs/nfs/dir.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index ce5a218..60d42b4 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2439,6 +2439,8 @@ int nfs_permission(struct inode *inode, int mask)
>
>         nfs_inc_stats(inode, NFSIOS_VFSACCESS);
>
> +       nfs_revalidate_inode(NFS_SERVER(inode),inode);
> +
>         if ((mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) == 0)
>                 goto out;
>         /* Is this sys_access() ? */
> --
> 2.4.1
>

Sorry, but that patch is not at all acceptable. It does not respect
the MAY_NOT_BLOCK flag, and so can end up deadlocking your system. It
also adds further unwanted slowness to open().

To fix access(), chdir() and their ilk, I suggest adding a helper
nfs_execute_ok() that does the right thing depending on the value of
MAY_NOT_BLOCK. Something like:

static int nfs_execute_ok(struct inode *inode, int mask)
{
        struct nfs_server *server = NFS_SERVER(inode);
        int ret;

        if (mask & MAY_NOT_BLOCK)
                ret = nfs_revalidate_inode_rcu(server, inode);
        else
                ret = nfs_revalidate_inode(server, inode);
        if (ret == 0 && !execute_ok(inode))
                ret = -EACCES;
        return ret;
}

However for the open() fast path, optimising out the entire shebang is
the right thing to do if we can.
