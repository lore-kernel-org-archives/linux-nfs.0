Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54175 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760713Ab1LPUub (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Dec 2011 15:50:31 -0500
Received: by wgbdr13 with SMTP id dr13so6833023wgb.1
        for <linux-nfs@vger.kernel.org>; Fri, 16 Dec 2011 12:50:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EEA826D.2070200@oracle.com>
References: <1323903495-4084-1-git-send-email-maxim.uvarov@oracle.com>
	<1323903495-4084-2-git-send-email-maxim.uvarov@oracle.com>
	<20111214232254.GP2203@ZenIV.linux.org.uk>
	<4EEA469E.6070307@oracle.com>
	<20111215213256.GS2203@ZenIV.linux.org.uk>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430C863704@SACMVEXC2-PRD.hq.netapp.com>
	<4EEA75DD.9080601@oracle.com>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430C863744@SACMVEXC2-PRD.hq.netapp.com>
	<4EEA826D.2070200@oracle.com>
Date: Fri, 16 Dec 2011 21:50:30 +0100
Message-ID: <CANXojczvs7pJH+++dQQrfT3yFSNacAj7aU48g=mwKuzbKJV9bQ@mail.gmail.com>
Subject: Re: [PATCH] NFS/INOTIFY: inotify user when deleting files on nfs
From: Stef Bon <stefbon@gmail.com>
To: Maxim Uvarov <maxim.uvarov@oracle.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        bfields@fieldses.org, john@johnmccutchan.com, rlove@rlove.org,
        eparis@parisplace.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

not exactly the same topic, I'm looking how to make inotify possible
for filesystems like FUSE, cifs and nfs. As mentioned here earlier,
inotify is an internal kernel subsystem only, and it's not wise to
make userspace filesystems handle inotify the same way as the kernel
does.

But still (I think) that make the "external" filesystems handle notify
is a good thing. I think the way to go is:

a. create a new inotify netlink module (name VFS, subgroup notify),
which sends a message to userspace when a inotify watch is set (with
path (or inode) and mask)

b. filesystem (FUSE based, or nfs or cifs) listens to this

c. when inotify add watch message is received, the fs takes the right
action. In the case of cifs, this is probably something like:

http://msdn.microsoft.com/en-us/library/cc246553(v=PROT.13).aspx

with the mask translated to something that makes sense to the remote server.

in case of a simple overlay FUSE filesystem (backend is on the same
host, is an existing fs), the fs sets a inotify watch on this fs.

In the case of NFS I do not know, I do not have enough knowledge about it.

d. when the fs receives something on the backend specific "notify", it
translates it to a linux VFS operation, and notifies the kernel. FUSE
has recently added some calls which for example notify the kernel when
a directory is removed.
http://msdn.microsoft.com/en-us/library/cc246553(v=PROT.13).aspx

e. when on the netlink socket the notify remove action is received,
the fs removes the related things it has setup in step c.

Any comments please.

Stef
