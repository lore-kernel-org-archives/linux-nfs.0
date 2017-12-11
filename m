Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [195.214.232.23] ([195.214.232.23]:46816 "EHLO
        US-EXCH2.sw.swsoft.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751956AbdLKPVg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Dec 2017 10:21:36 -0500
Subject: Re: [PATCH 1/4] fs/notify: fdinfo can report unsupported file
 handles.
To: Amir Goldstein <amir73il@gmail.com>
CC: NeilBrown <neilb@suse.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
References: <151297214390.7818.7216826079527521005.stgit@noble>
 <151297224512.7818.18333908109878259066.stgit@noble>
 <CAOQ4uxj9VhiCtPSt+Lyv8qyUz2hJ=VQzSYCKZ_6yqvs2q7y6Qw@mail.gmail.com>
 <CAOQ4uxiko+gWH5gLs6kjWU6mMzyxfzo08AfAAmTvqaxHGn_Ddw@mail.gmail.com>
 <a9da3da5-dd19-df2c-1c0e-1f029535ef39@virtuozzo.com>
 <CAOQ4uxgN_KXRzN2G_ANdAme13RJKJ8UsYyjFNUOYy5c_efCvNA@mail.gmail.com>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <3c1c7453-7bf5-e425-cd00-ae2a083104cc@virtuozzo.com>
Date: Mon, 11 Dec 2017 18:21:12 +0300
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxgN_KXRzN2G_ANdAme13RJKJ8UsYyjFNUOYy5c_efCvNA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/11/2017 05:08 PM, Amir Goldstein wrote:
> On Mon, Dec 11, 2017 at 3:46 PM, Pavel Emelyanov <xemul@virtuozzo.com> wrote:
>> On 12/11/2017 10:05 AM, Amir Goldstein wrote:
>>> On Mon, Dec 11, 2017 at 8:41 AM, Amir Goldstein <amir73il@gmail.com> wrote:
>>>> On Mon, Dec 11, 2017 at 8:04 AM, NeilBrown <neilb@suse.com> wrote:
>>>>> If a filesystem does not set sb->s_export_op, then it
>>>>> does not support filehandles and export_fs_encode_fh()
>>>>> and exportfs_encode_inode_fh() should not be called.
>>>>> They will use export_encode_fh() is which is a default
>>>>> that uses inode number generation number, but in general
>>>>> they may not be stable.
>>>>>
>>>>> So change exportfs_encode_inode_fh() to return FILEID_INVALID
>>>>> if called on an unsupported Filesystem.  Currently only
>>>>> notify/fdinfo can do that.
>>>>>
>>>>
>>>> I wish you would leave this check to the caller, maybe add a helper
>>>> exportfs_can_decode_fh() for callers to use.
>>>>
>>>> Although there are no current uses for it in-tree, there is value in
>>>> being able to encode a unique file handle even when it cannot be
>>>> decoded back to an open file.
>>>>
>>>> I am using this property in my fanotify super block watch patches,
>>>> where the object identifier on the event is an encoded file handle
>>>> of the object, which delegates tracking filesystem objects to
>>>> userspace and prevents fanotify from keeping elevated refcounts
>>>> on inodes and dentries.
>>>>
>>>> There are quite a few userspace tools out there that are checking
>>>> that st_ino hasn't changed on a file between non atomic operations.
>>>> Those tools (or others) could benefit from a unique file handle if
>>>> we ever decide to provide a relaxed version of name_to_handle_at().
>>>>
>>>
>>> And this change need a clause about not breaking userspace.
>>>
>>> Pavel,
>>>
>>> Will this break any version of criu in the wild?
>>
>> If there's no fliehandle in the output, it will make dump fail, but we're
>> already prepared for the fact, that there's no handle at hands. In the
>> worst case criu will exit with error.
>>
>> I also agree that it should only happen when current is OOM killed, and in
>> case of CRIU this means killing criu process itself.
>>
> 
> But this patch [1/4] changes behavior so you cannot dump fsnotify
> state if watched file system does not support *decoding* file handles.

That's OK :) After we get a filehandle we check it's accessible, so for
FSs that couldn't decode one, we'd fail the dump anyway.

> This means that criu anyway won't be able to restore the fsnotify state.
> Is it OK that criu dump state will fail in that case?
> 
> Amir.
> .
> 

