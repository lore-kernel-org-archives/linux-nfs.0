Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40672 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750884AbdEHXJ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 May 2017 19:09:58 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKe-_VJ6C0Gtv0fzDW3j1QBVqPUEXPCcbFvvq13Bp1-Heg@mail.gmail.com>
References: <CAOssrKe-_VJ6C0Gtv0fzDW3j1QBVqPUEXPCcbFvvq13Bp1-Heg@mail.gmail.com> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 4/9] Implement fsopen() to prepare for a mount
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 09 May 2017 00:09:55 +0100
Message-ID: <11118.1494284995@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> Someone also suggested using /dev/fs/${FSTYPE} to open the fsfd.

The downside of using open() for this is that you then have a chicken-and-egg
problem with respect to booting as you point out.

> I realize that does not have the namespace info that you also want to add,
> but wondering if that really has to come from open and cannot be set later?

When do you do the security checks?  Those are going to be affected by the
namespaces.  Other things are as well, such as setting hostnames, IP
addresses, device file paths and default UIDs/GIDs, but these are probably
more okay with being deferred to the parameter validation step.

> ALTERNATIVES are /proc/fs/${FSTYPE}/dev or /sys/fs/${FSTYPE}/dev.
> 
> Obviously neither can be used for bootstraping but there's still old
> mount(2) for that.

It should also be possible to build-time disable mount(2) in future.
Obviously, this would mean providing other vectors for the other functions of
mount(2).

David
