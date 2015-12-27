Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.molgen.mpg.de ([141.14.17.9]:43999 "EHLO mx1.molgen.mpg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751421AbbL0MSx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Dec 2015 07:18:53 -0500
Subject: Re: [PATCH] NFSv4: Don't perform cached access checks before we've
 OPENed the file
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <CAHQdGtR1xE1dxjrBSGNY4hn6qKpmAhd+DAX=z=53mN0V84FiyQ@mail.gmail.com>
 <1451185588-69667-1-git-send-email-trond.myklebust@primarydata.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Donald Buczek <buczek@molgen.mpg.de>
Message-ID: <567FD72A.7090903@molgen.mpg.de>
Date: Sun, 27 Dec 2015 13:18:50 +0100
MIME-Version: 1.0
In-Reply-To: <1451185588-69667-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 27.12.2015 04:06, Trond Myklebust wrote:
> Donald Buczek reports that a nfs4 client incorrectly denies
> execute access based on outdated file mode (missing 'x' bit).
> After the mode on the server is 'fixed' (chmod +x) further execution
> attempts continue to fail, because the nfs ACCESS call updates
> the access parameter but not the mode parameter or the mode in
> the inode.
>
> The root cause is ultimately that the VFS is calling may_open()
> before the NFS client has a chance to OPEN the file and hence revalidate
> the access and attribute caches.
>
> Al Viro suggests:
>>>> Make nfs_permission() relax the checks when it sees MAY_OPEN, if you know
>>>> that things will be caught by server anyway?
>>> That can work as long as we're guaranteed that everything that calls
>>> inode_permission() with MAY_OPEN on a regular file will also follow up
>>> with a vfs_open() or dentry_open() on success. Is this always the
>>> case?
>> 1) in do_tmpfile(), followed by do_dentry_open() (not reachable by NFS since
>> it doesn't have ->tmpfile() instance anyway)
>>
>> 2) in atomic_open(), after the call of ->atomic_open() has succeeded.
>>
>> 3) in do_last(), followed on success by vfs_open()
>>
>> That's all.  All calls of inode_permission() that get MAY_OPEN come from
>> may_open(), and there's no other callers of that puppy.
> Reported-by: Donald Buczek <buczek@molgen.mpg.de>
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=109771
> Link: http://lkml.kernel.org/r/1451046656-26319-1-git-send-email-buczek@molgen.mpg.de
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> Hi Donald,
> Can you check if this fixes the issue for you?
>
>   fs/nfs/dir.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index ce5a21861074..44e519c21e18 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2449,6 +2449,9 @@ int nfs_permission(struct inode *inode, int mask)
>   		case S_IFLNK:
>   			goto out;
>   		case S_IFREG:
> +			if ((mask & MAY_OPEN) &&
> +			   nfs_server_capable(inode, NFS_CAP_ATOMIC_OPEN))
> +				return 0;
>   			break;
>   		case S_IFDIR:
>   			/*


I can confirm that this fixes the original issue. However, even with 
this patch, calls to the access syscall would continue to deliver 
failure based on obsolete modes forever. This can be seen as a bug, too.

PS:

I don't yet understand the point of execute_ok. It doesn't even consider 
the uid.

Apart from that two suggestions to consider:

   * If we go over the server for ACCESS anyway, we could combine it 
with a GETATTR compound operation. Then we would be ready for additional 
client-side checks against the inode.
   * If we look at the mode, we should validate it first ( 
nfs_revalidate_inode ? )

Regards
   Donald

