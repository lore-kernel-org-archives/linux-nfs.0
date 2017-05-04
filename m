Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35292 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751004AbdEDNGy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 May 2017 09:06:54 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170504104045.6sh3dqofcii6kk2e@ws.net.home>
References: <20170504104045.6sh3dqofcii6kk2e@ws.net.home> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
To: Karel Zak <kzak@redhat.com>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Subject: Re: [PATCH 4/9] Implement fsopen() to prepare for a mount
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 04 May 2017 14:06:51 +0100
Message-ID: <15169.1493903211@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Karel Zak <kzak@redhat.com> wrote:

> > 	write(mfd, "d /dev/sdb1"); // note I'm ignoring write's length arg
> 
> Not sure about 'd', in many cases it is not device, for mount(2)
> syscall we call it "source".

sys_mount() calls it devname.  But whatever - I'm not particularly attached to
the letter 'd' for this.

> The very basic mount(2) problem is that you have to parse
> /proc/self/mountinfo to get information about the mounted filesystem.
> It seems that your read() is also one way communication.
> 
> What we really need is to have a way how to specify *what* you want to
> read. The error message is not enough, I want to know the finally used
> mount options, mount ID, etc. It would be nice to have something like
> 
> 
>    fsmount(mfd, AT_FDCWD, "/mnt", 0);
> 
>    write(mfd, "o");
>    read(mfd, ....);     // read mount options
> 
>    write(mdf, "i");
>    read(mfd, ....);     // read mount ID
> 
> 
> but it seems ugly. Maybe introduce another function like 
> 
>     fsinfo(mdf, "o", buf, bufsz)
> 
> to get mount options (etc.) and to avoid separate write & read.

What is it you're trying to do?  Just read back the state of the new mount?
Or read back the state of a specified extant mount?

David
