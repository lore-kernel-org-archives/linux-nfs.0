Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:53279 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751970AbdJ3Iow (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Oct 2017 04:44:52 -0400
Received: by mail-qk0-f174.google.com with SMTP id y23so15124240qkb.10
        for <linux-nfs@vger.kernel.org>; Mon, 30 Oct 2017 01:44:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3054.1509120184@warthog.procyon.org.uk>
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
 <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk>
 <CAOssrKfNtKLskdPWS_p87uFzDsZCoN+4L+_bcWBvX18mRVVf_Q@mail.gmail.com>
 <28791.1509035055@warthog.procyon.org.uk> <CAOssrKdm-znRnR80rxvzH8WVWf=sEkL1EGMzV4c3dyp_FK2-rA@mail.gmail.com>
 <29611.1509114932@warthog.procyon.org.uk> <CAOssrKd2MX0ao7f2X32js=72YmZ0exn4KkwdgrXB9tKY7KiSXg@mail.gmail.com>
 <3054.1509120184@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Mon, 30 Oct 2017 09:44:50 +0100
Message-ID: <CAOssrKc8YzWybuuXvMOXgXT6Fqawj3J_sewW+88bxf+O9kTgvw@mail.gmail.com>
Subject: Re: [PATCH 03/14] VFS: Implement a filesystem superblock
 creation/configuration context [ver #6]
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 27, 2017 at 6:03 PM, David Howells <dhowells@redhat.com> wrote:
> Miklos Szeredi <mszeredi@redhat.com> wrote:
>
>> Yes I did mean vfs_parse_sb_flag_option().
>>
>> Yes, I understand its purpose, but it would be cleaner if all the
>> option parsing was done in fc->ops->parse_option().
>>
>> It might be worth introducing the vfs_parse_sb_flag_option(), to be
>> called from ->parse_option().
>
> I was trying to relieve the filesystem of the requirement to have to deal with
> common stuff and also the need to talk directly to the LSM.

No need to talk directly to the LSM:
security_fs_context_parse_option() will do that in VFS code.

How common is common stuff?

dirsync/sync/rw: not handled by all filesystems, those that don't
handle it should reject the option on the new interface

lazytime: handled by generic code, AFAICS, but makes no sense on
read-only fs so those should probably reject it

mand: handled by generic code, but does not make sense for some
filesystems (e.g. those that don't have all the unixy permission
bits).

posixacl: there's no such mount option now.  The options is "acl" and
does not get translated to MS_POSIXACL in mount(8).   Makes zero sense
to add a previously nonexistent option to the new interface.

silent: makes no sense on the new interface, since we should no longer
be putting error messages into the kernel log.

So that leaves async/ro/nolazytime/nomand options to be handled by all
filesystems.

Not sure how to best handle these differences, but the current code
definitely seems lacking, and I cannot imagine a better way than to
pass all options to filesystem's ->parse_option() and add helper(s) to
handle the generic options.

>> > Btw, how would it affect the LSM?
>>
>> LSM would have to reject a "reset" if not enough privileges to
>> *create* a new fs instance, since it essentially requires creating a
>> new config, which is what is done when creating an fs instance.
>
> That's not what I'm asking.  Would the reset change LSM state?  Reset security
> labels and options?

No.   And it wouldn't reset any other option that is immutable (e.g.
server IP address).

Thanks,
Miklos
