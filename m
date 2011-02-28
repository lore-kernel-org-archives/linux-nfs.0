Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp102.sbc.mail.mud.yahoo.com ([68.142.198.201]:20598 "HELO
	smtp102.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753674Ab1B1P10 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Feb 2011 10:27:26 -0500
Received: from hope.more-right-rudder.com (localhost.localdomain [127.0.0.1])
	by hope.more-right-rudder.com (8.14.4/8.14.4) with ESMTP id p1SFRNst010559
	for <linux-nfs@vger.kernel.org>; Mon, 28 Feb 2011 10:27:23 -0500
Message-Id: <201102281527.p1SFRNst010559@hope.more-right-rudder.com>
To: linux-nfs@vger.kernel.org
Subject: Possible NFSv4 locking bug
From: "Rick Koshi" <nfs-bug-report@more-right-rudder.com>
Date: Mon, 28 Feb 2011 10:27:23 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Hi all, I hope this is the right place for this.

I'm using NFSv4, server and client both running 2.6.36.

I've found that when I lock an NFS-mounted file on a client, the server
reserves an open file descriptor (as seen in /proc/sys/fs/file-nr).
The server never releases this descriptor, even if the client process
explictly releases the lock or exits.

In my case, I noticed this because I have a monitoring process which
runs every 5 seconds and runs 'rrdtool' to log some status to a file
on an NFS-mounted filesystem.  This allocated 720 files per hour, and
eventually caused my server to run out of file descriptors and become
unusable.  I experimented with a test program, and found that it's the
fcntl64(3, F_SETLK, {type=F_WRLCK, ...}) system call that triggers
the behavior, and that unlocking the file explictly doesn't help.

Stopping the NFS service (including the lockd) does not release the
open files.  Only rebooting resets the state.

I'm no kernel expert.  Perhaps you can tell me if this is a necessary
side effect of some part of the NFS implementation.  But to me, it looks
like a bug.

Thanks for your time,

    -- Koshi
