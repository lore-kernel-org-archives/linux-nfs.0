Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39263 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751113AbdEDKkv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 May 2017 06:40:51 -0400
Date: Thu, 4 May 2017 12:40:45 +0200
From: Karel Zak <kzak@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Subject: Re: [PATCH 4/9] Implement fsopen() to prepare for a mount
Message-ID: <20170504104045.6sh3dqofcii6kk2e@ws.net.home>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 03, 2017 at 05:05:08PM +0100, David Howells wrote:
> 	mfd = fsopen("ext4", -1, O_CLOEXEC);
> 	write(mfd, "d /dev/sdb1"); // note I'm ignoring write's length arg

Not sure about 'd', in many cases it is not device, for mount(2)
syscall we call it "source".

> 	write(mfd, "o noatime");
> 	write(mfd, "o acl");
> 	write(mfd, "o user_attr");
> 	write(mfd, "o iversion");
> 	write(mfd, "o ");
> 	write(mfd, "r /my/container"); // root inside the fs
> 	fsmount(mfd, container_fd, "/mnt", AT_NO_FOLLOW);
> 
> 	mfd = fsopen("afs", -1);
> 	write(mfd, "d %grand.central.org:root.cell");
> 	write(mfd, "o cell=grand.central.org");
> 	write(mfd, "r /");
> 	fsmount(mfd, AT_FDCWD, "/mnt", 0);
> 
> If an error is reported at any step, an error message may be available to be
> read() back (ENODATA will be reported if there isn't an error available) in
> the form:
> 
> 	"e <subsys>:<problem>"
> 	"e SELinux:Mount on mountpoint not permitted"
> 
> Once fsmount() has been called, further write() calls will incur EBUSY,
> even if the fsmount() fails.  read() is still possible to retrieve error
> information.

The very basic mount(2) problem is that you have to parse
/proc/self/mountinfo to get information about the mounted filesystem.
It seems that your read() is also one way communication.

What we really need is to have a way how to specify *what* you want to
read. The error message is not enough, I want to know the finally used
mount options, mount ID, etc. It would be nice to have something like


   fsmount(mfd, AT_FDCWD, "/mnt", 0);

   write(mfd, "o");
   read(mfd, ....);     // read mount options

   write(mdf, "i");
   read(mfd, ....);     // read mount ID


but it seems ugly. Maybe introduce another function like 

    fsinfo(mdf, "o", buf, bufsz)

to get mount options (etc.) and to avoid separate write & read.


> Netlink is not used because it is optional.

 +1

    Karel
-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
