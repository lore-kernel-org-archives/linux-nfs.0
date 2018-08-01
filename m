Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34253 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731897AbeHAICZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 04:02:25 -0400
MIME-Version: 1.0
In-Reply-To: <CAJfpegtyTnYdqYmwG5Jqn6rhDMhjdrkOO5Ziu91f5E+sEgyZoQ@mail.gmail.com>
References: <1531491744-13277-1-git-send-email-amir73il@gmail.com>
 <8fc65417ebda26a198e01e8c82f41ae08ab3c803.camel@kernel.org>
 <CAOQ4uxhvLVLLh_DyXp4q27NNo-+55tbdHOCu3=p8pNin66vv-g@mail.gmail.com> <CAJfpegtyTnYdqYmwG5Jqn6rhDMhjdrkOO5Ziu91f5E+sEgyZoQ@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 1 Aug 2018 09:18:24 +0300
Message-ID: <CAOQ4uxg+kuAuZ=o7U+77mrYO5zkFAGCkNpiZSVDdYKcdm631_w@mail.gmail.com>
Subject: Re: [PATCH] nfsd: fix leaked file lock with nfs exported overlayfs
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Jeff Layton <jlayton@kernel.org>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Eddie Horng <eddiehorng.tw@gmail.com>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 17, 2018 at 5:24 PM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> On Fri, Jul 13, 2018 at 6:05 PM, Amir Goldstein <amir73il@gmail.com> wrote:
>> On Fri, Jul 13, 2018 at 6:40 PM, Jeff Layton <jlayton@kernel.org> wrote:
>>> On Fri, 2018-07-13 at 17:22 +0300, Amir Goldstein wrote:
>>>> nfsd and lockd call vfs_lock_file() to lock/unlock the inode
>>>> returned by locks_inode(file).
>>>>
>>>> Many places in nfsd/lockd code use the inode returned by
>>>> file_inode(file) for lock manipulation. With Overlayfs, file_inode()
>>>> (the underlying inode) is not the same object as locks_inode() (the
>>>> overlay inode). This can result in "Leaked POSIX lock" messages
>>>> and eventually to a kernel crash as reported by Eddie Horng:
>>>> https://marc.info/?l=linux-unionfs&m=153086643202072&w=2
>>>>
>>>> Fix all the call sites in nfsd/lockd that should use locks_inode().
>>>> This is a correctness bug that manifested when overlayfs gained
>>>> NFS export support in v4.16.
>>>>
>>>> Reported-by: Eddie Horng <eddiehorng.tw@gmail.com>
>>>> Tested-by: Eddie Horng <eddiehorng.tw@gmail.com>
>>>> Cc: Jeff Layton <jlayton@kernel.org>
>>>> Fixes: 8383f1748829 ("ovl: wire up NFS export operations")
>>>> Signed-off-by: Amir Goldstein <amir73il@gmail.com>
>>>> ---
>>>>
>>>> Hi Bruce,
>>>>
>>>> For the purpose of locks, nfsd/lockd should look at locks_inode()
>>>> just like vfs lock functions.
>>>>
>>>> Hopefully, Miklos's work on stacked overlayfs file operations will
>>>> be merged soon and locks_inode() will become the same as file_inode(),
>>>> but we will still need this fix for stable kernels v4.16 through v4.18.
>
> Needs a Cc: stable@... tag then.
>
> Should I take this patch (based on the fact that it only affects
> overlayfs exports)?
>
> Or will you take it, Bruce?
>

Bruce? Jeff?

It's probably a good time for someone to put this patch in -next.

Should Miklos do it?

Thanks,
Amir.
