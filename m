Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f182.google.com ([209.85.213.182]:33115 "EHLO
        mail-yb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751503AbdLLGj6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Dec 2017 01:39:58 -0500
MIME-Version: 1.0
In-Reply-To: <87609dort0.fsf@notabene.neil.brown.name>
References: <151297214390.7818.7216826079527521005.stgit@noble>
 <151297224512.7818.18333908109878259066.stgit@noble> <CAOQ4uxj9VhiCtPSt+Lyv8qyUz2hJ=VQzSYCKZ_6yqvs2q7y6Qw@mail.gmail.com>
 <87609dort0.fsf@notabene.neil.brown.name>
From: Amir Goldstein <amir73il@gmail.com>
Date: Tue, 12 Dec 2017 08:39:56 +0200
Message-ID: <CAOQ4uxgYeqFtj=uVFDB84zUDu5-QrQLbH2DwgsJrXGtb2Fr9sA@mail.gmail.com>
Subject: Re: [PATCH 1/4] fs/notify: fdinfo can report unsupported file handles.
To: NeilBrown <neilb@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 11, 2017 at 11:52 PM, NeilBrown <neilb@suse.com> wrote:
> On Mon, Dec 11 2017, Amir Goldstein wrote:
>
>> On Mon, Dec 11, 2017 at 8:04 AM, NeilBrown <neilb@suse.com> wrote:
>>> If a filesystem does not set sb->s_export_op, then it
>>> does not support filehandles and export_fs_encode_fh()
>>> and exportfs_encode_inode_fh() should not be called.
>>> They will use export_encode_fh() is which is a default
>>> that uses inode number generation number, but in general
>>> they may not be stable.
>>>
>>> So change exportfs_encode_inode_fh() to return FILEID_INVALID
>>> if called on an unsupported Filesystem.  Currently only
>>> notify/fdinfo can do that.
>>>
>>
>> I wish you would leave this check to the caller, maybe add a helper
>> exportfs_can_decode_fh() for callers to use.
>>
>> Although there are no current uses for it in-tree, there is value in
>> being able to encode a unique file handle even when it cannot be
>> decoded back to an open file.
>>
>> I am using this property in my fanotify super block watch patches,
>> where the object identifier on the event is an encoded file handle
>> of the object, which delegates tracking filesystem objects to
>> userspace and prevents fanotify from keeping elevated refcounts
>> on inodes and dentries.
>>
>> There are quite a few userspace tools out there that are checking
>> that st_ino hasn't changed on a file between non atomic operations.
>> Those tools (or others) could benefit from a unique file handle if
>> we ever decide to provide a relaxed version of name_to_handle_at().
>
> If the filesystem doesn't define ->s_export_op, then you really cannot
> trust anything beyond the inode number (and maybe not even that), and
> the inode number is already easily available.
> What actual value do you think you get from this pretend-file-handle
> on filesystems that don't support file handles?
>

Sorry, I misread your patch. In my mind I thought you wanted to
eliminate the default export_encode_fh if there was no fh_to_dentry
operation like do_sys_name_to_handle() does. Just in my head...

FWIW, according to Pavel, if fdinfo would not export file handle
in case !fh_to_dentry op would probably be desirable, because
criu has no need for file handles that cannot be decoded.

Amir.
