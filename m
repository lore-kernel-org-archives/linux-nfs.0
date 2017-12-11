Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f170.google.com ([209.85.213.170]:45104 "EHLO
        mail-yb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751274AbdLKHFv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Dec 2017 02:05:51 -0500
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxj9VhiCtPSt+Lyv8qyUz2hJ=VQzSYCKZ_6yqvs2q7y6Qw@mail.gmail.com>
References: <151297214390.7818.7216826079527521005.stgit@noble>
 <151297224512.7818.18333908109878259066.stgit@noble> <CAOQ4uxj9VhiCtPSt+Lyv8qyUz2hJ=VQzSYCKZ_6yqvs2q7y6Qw@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 11 Dec 2017 09:05:50 +0200
Message-ID: <CAOQ4uxiko+gWH5gLs6kjWU6mMzyxfzo08AfAAmTvqaxHGn_Ddw@mail.gmail.com>
Subject: Re: [PATCH 1/4] fs/notify: fdinfo can report unsupported file handles.
To: NeilBrown <neilb@suse.com>, Pavel Emelyanov <xemul@virtuozzo.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 11, 2017 at 8:41 AM, Amir Goldstein <amir73il@gmail.com> wrote:
> On Mon, Dec 11, 2017 at 8:04 AM, NeilBrown <neilb@suse.com> wrote:
>> If a filesystem does not set sb->s_export_op, then it
>> does not support filehandles and export_fs_encode_fh()
>> and exportfs_encode_inode_fh() should not be called.
>> They will use export_encode_fh() is which is a default
>> that uses inode number generation number, but in general
>> they may not be stable.
>>
>> So change exportfs_encode_inode_fh() to return FILEID_INVALID
>> if called on an unsupported Filesystem.  Currently only
>> notify/fdinfo can do that.
>>
>
> I wish you would leave this check to the caller, maybe add a helper
> exportfs_can_decode_fh() for callers to use.
>
> Although there are no current uses for it in-tree, there is value in
> being able to encode a unique file handle even when it cannot be
> decoded back to an open file.
>
> I am using this property in my fanotify super block watch patches,
> where the object identifier on the event is an encoded file handle
> of the object, which delegates tracking filesystem objects to
> userspace and prevents fanotify from keeping elevated refcounts
> on inodes and dentries.
>
> There are quite a few userspace tools out there that are checking
> that st_ino hasn't changed on a file between non atomic operations.
> Those tools (or others) could benefit from a unique file handle if
> we ever decide to provide a relaxed version of name_to_handle_at().
>

And this change need a clause about not breaking userspace.

Pavel,

Will this break any version of criu in the wild?

Amir.
