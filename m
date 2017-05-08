Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37622 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752759AbdEHIn1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 May 2017 04:43:27 -0400
Received: by mail-wm0-f49.google.com with SMTP id m123so56549888wma.0
        for <linux-nfs@vger.kernel.org>; Mon, 08 May 2017 01:43:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <31871.1494232549@warthog.procyon.org.uk>
References: <CAOssrKdHn5SpxEXBZ5EQvCF9E8JTiMqJo+M3OKPXUHYXGeqMGg@mail.gmail.com>
 <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <22958.1493999242@warthog.procyon.org.uk> <31871.1494232549@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Mon, 8 May 2017 10:43:25 +0200
Message-ID: <CAOssrKcosqHsph8d7sWR_0+=9_E8-K2OAG3uwHcTkP85dQj-qA@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/9] VFS: Introduce mount context
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 8, 2017 at 10:35 AM, David Howells <dhowells@redhat.com> wrote:

>> Further, once you've created a superblock, what are you going to do with it
>> other than mount it?  I suppose you could statfs it and we could add other
>> superblock manipulation functions, but this is normally done by opening the
>> device directly (at least for bdev-based superblocks).
>
> How about sb_context, sb_config, sb_parameters or something like that?

I'd vote for sb_config.

Thanks,
Miklos
