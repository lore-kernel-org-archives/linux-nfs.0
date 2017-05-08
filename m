Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36601 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755513AbdEHPKK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 May 2017 11:10:10 -0400
Received: by mail-wm0-f49.google.com with SMTP id u65so88108830wmu.1
        for <linux-nfs@vger.kernel.org>; Mon, 08 May 2017 08:10:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Mon, 8 May 2017 17:10:07 +0200
Message-ID: <CAOssrKe-_VJ6C0Gtv0fzDW3j1QBVqPUEXPCcbFvvq13Bp1-Heg@mail.gmail.com>
Subject: Re: [PATCH 4/9] Implement fsopen() to prepare for a mount
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 3, 2017 at 6:05 PM, David Howells <dhowells@redhat.com> wrote:
> Provide an fsopen() system call that starts the process of preparing to
> mount, using an fd as a context handle.  fsopen() is given the name of the
> filesystem that will be used:
>
>         int mfd = fsopen(const char *fsname, int reserved,
>                          int open_flags);
>
> where reserved should be -1 for the moment (it will be used to pass the
> namespace information in future) and open_flags can be 0 or O_CLOEXEC.

Someone also suggested using /dev/fs/${FSTYPE} to open the fsfd.  I
realize that does not have the namespace info that you also want to
add, but wondering if that really has to come from open and cannot be
set later?

Alternatives are /proc/fs/${FSTYPE}/dev or /sys/fs/${FSTYPE}/dev.

Obviously neither can be used for bootstraping but there's still old
mount(2) for that.

I haven't convinced myself whether using plain open(2) or a new
fsopen(2) syscall is better, just mentioning that this is a
possibility as well.

Thanks,
Miklos
