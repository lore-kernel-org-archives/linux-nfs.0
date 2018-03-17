Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:40115 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751348AbeCQA6U (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2018 20:58:20 -0400
Received: by mail-vk0-f42.google.com with SMTP id x5so6173268vkd.7
        for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2018 17:58:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a4168fd0-dcbf-65c3-f715-a51b30261c5b@Netapp.com>
References: <643b19f35980727fbf9a1756c33a59981b538dd0.1519862053.git.e@nanocritical.com>
 <a4168fd0-dcbf-65c3-f715-a51b30261c5b@Netapp.com>
From: Eric Rannaud <e@nanocritical.com>
Date: Fri, 16 Mar 2018 17:57:58 -0700
Message-ID: <CAH_=xobmsY_fUhFBCMFVUNN+jwgaOuo71rpEKSf7+Yn0xnikTA@mail.gmail.com>
Subject: Re: [PATCH] nfs: nfs_fileid_valid() is wrong on NFSv3 and incomplete
 on NFSv4
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jessica Peters <jessica.peters@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna,

On Wed, Mar 14, 2018 at 12:36 PM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
>> The condition should be written as an if / else if:
>>
>>       if (fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID)
>>       else if (fattr->valid & NFS_ATTR_FATTR_FILEID)
>
> We're requesting both of these attributes as part of the READDIR operatio=
n, so won't this return the wrong answer in some cases?
>
> I'm running xfstests "quick" tests with NFS v4.1, and my server is export=
ing an xfs filesystem for both test and scratch directories (they're on the=
 same partition, but different exported directories using the fsid=3DX expo=
rt option).  I'm seeing the following message fairly frequently in my dmesg=
 log once I apply your patch:
>
>       [  222.093367] NFS: server 192.168.100.215 error: fileid changed
>                      fsid 0:48: expected fileid 0x60, got 0x60
>
> So I'm thinking that the server is replying with both FATTR_MOUNTED_ON_FI=
LEID and FATTR_FILEID, and then returning false in the mounted-on check whe=
n the plain fileid should be compared instead.
>
> I wonder if it would make sense to add another field to the nfs inode to =
keep track of which fileid is being used.
>

Thanks for testing. I was able to reproduce by using the following
setup (which I believe is similar enough to yours).

  # server
  /mnt/xfs/  # mount point of XFS filesystem
  /mnt/xfs/test  # normal directory
  /mnt/xfs/scratch  # normal directory
  # /etc/exports
  /mnt/xfs *(rw,sync,insecure,no_root_squash,fsid=3D0)
  /mnt/xfs/test *(rw,sync,insecure,no_root_squash,fsid=3D1)
  /mnt/xfs/scratch *(rw,sync,insecure,no_root_squash,fsid=3D2)
  # client
  mount 10.0.2.2:/test /mnt/test
  mount 10.0.2.2:/scratch /mnt/scratch
  # dmesg client
  NFS: server 10.0.2.2 error: fileid changed
  fsid 0:34: expected fileid 0x60, got 0x60

Just mounting both /test and /scratch is enough to get the error message.

0x60 is the root of the XFS filesystem, which is not itself mounted,
but the nfs4 client first gets the export root FH (the
root-of-all-exports) and then follows the export path to the actual
export being mounted. This is why this filehandle gets loaded at all.
On the second mount, the inode for the export root gets revalidated
and we get the error.

I was getting confused as I thought the following invariant held:

        fattr->mounted_on_fileid !=3D fattr->fileid  # fattr as returned
by the server
    <=3D> super_block->fsid !=3D fattr->fsid  # which is how nfs_fhget()
chooses whether to use mounted_on_fileid

as the server only returns a different mounted_on_fileid if the target
FH is itself a mount point on the server (leading to a different
fsid).

But that's not true for the export root when it happens to be a mount
point on the server:
  - the server does return a different mounted_on_fileid for it,
because it is a mount point;
  - but the client sees that its fsid =3D=3D super_block->fsid and does
not use mounted_on_fileid.

So you're correct that we need to more accurately choose whether we
want to compare against fileid or mounted_on_fileid when revalidating.

We could try to write in nfs_fileid_valid() the full logic that is
used elsewhere to decide whether to use fileid or mounted_on_fileid
(assuming we have access to the needed information -- I think so? --
but are all code paths consistent?), or we could remember in the NFS
inode which one was used to set fileid, which is your suggestion (can
we use nfs_inode's flags?).

As an experiment, I implemented your suggestion with a flag in the NFS
inode, and xfstests nfs/quick does not generate that error anymore.

I do think it would be better to have nfs_fileid_valid() be capable of
figuring out on its own which one to compare against, using a
(side-effect free) version of the logic (confusingly) spread across
nfs_attr_check_mountpoint() and nfs_attr_use_mounted_on_fileid(). And
make sure that everybody is using the same helper in the client.
What's your preference?

As an aside, nfs_fhget() overwrites fattr->fileid with
fattr->mounted_on_fileid if it decides to use mounted_on_fileid (so
that nfs_find_actor() and nfs_init_locked() do the right thing) which
to my eye is quite confusing for callers of nfs_fhget() which may be
entitled to think that fattr will be left untouched.

Also, the error message is not printing which of fileid or
mounted_on_fileid we compared against, and we get something asinine
like "expected 0x60, but got 0x60". I'll fix that in the next version
of this patch.

Thanks,
Eric
