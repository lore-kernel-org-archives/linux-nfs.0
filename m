Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:45867 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751855AbdJYRLs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Oct 2017 13:11:48 -0400
Received: by mail-it0-f41.google.com with SMTP id n195so1964547itg.0
        for <linux-nfs@vger.kernel.org>; Wed, 25 Oct 2017 10:11:48 -0700 (PDT)
Received: from ola-842mrw1.ad.garmin.com ([204.77.163.55])
        by smtp.googlemail.com with ESMTPSA id 191sm1524721itb.21.2017.10.25.10.11.47
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Oct 2017 10:11:47 -0700 (PDT)
From: Joshua Watt <jpewhacker@gmail.com>
Message-ID: <1508951506.2542.51.camel@gmail.com>
Subject: NFS Force Unmounting
To: linux-nfs@vger.kernel.org
Date: Wed, 25 Oct 2017 12:11:46 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm working on a networking embedded system where NFS servers can come
and go from the network, and I've discovered that the Kernel NFS server
make it difficult to cleanup applications in a timely manner when the
server disappears (and yes, I am mounting with "soft" and relatively
short timeouts). I currently have a user space mechanism that can
quickly detect when the server disappears, and does a umount() with the
MNT_FORCE and MNT_DETACH flags. Using MNT_DETACH prevents new accesses
to files on the defunct remote server, and I have traced through the
code to see that MNT_FORCE does indeed cancel any current RPC tasks
with -EIO. However, this isn't sufficient for my use case because if a
user space application isn't currently waiting on an RCP task that gets
canceled, it will have to timeout again before it detects the
disconnect. For example, if a simple client is copying a file from the
NFS server, and happens to not be waiting on the RPC task in the read()
call when umount() occurs, it will be none the wiser and loop around to
call read() again, which must then try the whole NFS timeout + recovery
before the failure is detected. If a client is more complex and has a
lot of open file descriptor, it will typical have to wait for each one
to timeout, leading to very long delays.

The (naive?) solution seems to be to add some flag in either the NFS
client or the RPC client that gets set in nfs_umount_begin(). This
would cause all subsequent operations to fail with an error code
instead of having to be queued as an RPC task and the and then timing
out. In our example client, the application would then get the -EIO
immediately on the next (and all subsequent) read() calls.

There does seem to be some precedence for doing this (especially with
network file systems), as both cifs (CifsExiting) and ceph
(CEPH_MOUNT_SHUTDOWN) appear to implement this behavior (at least from
looking at the code. I haven't verified runtime behavior).

Are there any pitfalls I'm oversimplifying?

Thanks,
Joshua Watt
