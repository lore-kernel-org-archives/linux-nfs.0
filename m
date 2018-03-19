Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:64618 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S969754AbeCSTws (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 15:52:48 -0400
Subject: Re: [PATCH] nfs: nfs_fileid_valid() is wrong on NFSv3 and incomplete
 on NFSv4
To: Eric Rannaud <e@nanocritical.com>
CC: <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jessica Peters <jessica.peters@netapp.com>
References: <643b19f35980727fbf9a1756c33a59981b538dd0.1519862053.git.e@nanocritical.com>
 <a4168fd0-dcbf-65c3-f715-a51b30261c5b@Netapp.com>
 <CAH_=xobmsY_fUhFBCMFVUNN+jwgaOuo71rpEKSf7+Yn0xnikTA@mail.gmail.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <b085998a-5414-4089-8e30-a1b9af282d80@Netapp.com>
Date: Mon, 19 Mar 2018 15:52:30 -0400
MIME-Version: 1.0
In-Reply-To: <CAH_=xobmsY_fUhFBCMFVUNN+jwgaOuo71rpEKSf7+Yn0xnikTA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/16/2018 08:57 PM, Eric Rannaud wrote:
> Hi Anna,
> 
> On Wed, Mar 14, 2018 at 12:36 PM, Anna Schumaker
> <Anna.Schumaker@netapp.com> wrote:
>>> The condition should be written as an if / else if:
>>>
>>>       if (fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID)
>>>       else if (fattr->valid & NFS_ATTR_FATTR_FILEID)
>>
>> We're requesting both of these attributes as part of the READDIR operation, so won't this return the wrong answer in some cases?
>>
>> I'm running xfstests "quick" tests with NFS v4.1, and my server is exporting an xfs filesystem for both test and scratch directories (they're on the same partition, but different exported directories using the fsid=X export option).  I'm seeing the following message fairly frequently in my dmesg log once I apply your patch:
>>
>>       [  222.093367] NFS: server 192.168.100.215 error: fileid changed
>>                      fsid 0:48: expected fileid 0x60, got 0x60
>>
>> So I'm thinking that the server is replying with both FATTR_MOUNTED_ON_FILEID and FATTR_FILEID, and then returning false in the mounted-on check when the plain fileid should be compared instead.
>>
>> I wonder if it would make sense to add another field to the nfs inode to keep track of which fileid is being used.
>>
> 
> Thanks for testing. I was able to reproduce by using the following
> setup (which I believe is similar enough to yours).
> 
>   # server
>   /mnt/xfs/  # mount point of XFS filesystem
>   /mnt/xfs/test  # normal directory
>   /mnt/xfs/scratch  # normal directory
>   # /etc/exports
>   /mnt/xfs *(rw,sync,insecure,no_root_squash,fsid=0)
>   /mnt/xfs/test *(rw,sync,insecure,no_root_squash,fsid=1)
>   /mnt/xfs/scratch *(rw,sync,insecure,no_root_squash,fsid=2)
>   # client
>   mount 10.0.2.2:/test /mnt/test
>   mount 10.0.2.2:/scratch /mnt/scratch
>   # dmesg client
>   NFS: server 10.0.2.2 error: fileid changed
>   fsid 0:34: expected fileid 0x60, got 0x60
> 
> Just mounting both /test and /scratch is enough to get the error message.
> 
> 0x60 is the root of the XFS filesystem, which is not itself mounted,
> but the nfs4 client first gets the export root FH (the
> root-of-all-exports) and then follows the export path to the actual
> export being mounted. This is why this filehandle gets loaded at all.
> On the second mount, the inode for the export root gets revalidated
> and we get the error.
> 
> I was getting confused as I thought the following invariant held:
> 
>         fattr->mounted_on_fileid != fattr->fileid  # fattr as returned
> by the server
>     <=> super_block->fsid != fattr->fsid  # which is how nfs_fhget()
> chooses whether to use mounted_on_fileid
> 
> as the server only returns a different mounted_on_fileid if the target
> FH is itself a mount point on the server (leading to a different
> fsid).
> 
> But that's not true for the export root when it happens to be a mount
> point on the server:
>   - the server does return a different mounted_on_fileid for it,
> because it is a mount point;
>   - but the client sees that its fsid == super_block->fsid and does
> not use mounted_on_fileid.
> 
> So you're correct that we need to more accurately choose whether we
> want to compare against fileid or mounted_on_fileid when revalidating.
> 
> We could try to write in nfs_fileid_valid() the full logic that is
> used elsewhere to decide whether to use fileid or mounted_on_fileid
> (assuming we have access to the needed information -- I think so? --
> but are all code paths consistent?), or we could remember in the NFS
> inode which one was used to set fileid, which is your suggestion (can
> we use nfs_inode's flags?).
> 
> As an experiment, I implemented your suggestion with a flag in the NFS
> inode, and xfstests nfs/quick does not generate that error anymore.
> 
> I do think it would be better to have nfs_fileid_valid() be capable of
> figuring out on its own which one to compare against, using a
> (side-effect free) version of the logic (confusingly) spread across
> nfs_attr_check_mountpoint() and nfs_attr_use_mounted_on_fileid(). And
> make sure that everybody is using the same helper in the client.
> What's your preference?

I wonder if it would be easier in the long run just to add a mounted-on-fileid field to the nfs_inode, removing the need to guess which one we're supposed to compare against.  It might also help with the overwriting issue / potential confusion you mention in the next paragraph.

What do you think?
Anna

> 
> As an aside, nfs_fhget() overwrites fattr->fileid with
> fattr->mounted_on_fileid if it decides to use mounted_on_fileid (so
> that nfs_find_actor() and nfs_init_locked() do the right thing) which
> to my eye is quite confusing for callers of nfs_fhget() which may be
> entitled to think that fattr will be left untouched.
> 
> Also, the error message is not printing which of fileid or
> mounted_on_fileid we compared against, and we get something asinine
> like "expected 0x60, but got 0x60". I'll fix that in the next version
> of this patch.
> 
> Thanks,
> Eric
> 
