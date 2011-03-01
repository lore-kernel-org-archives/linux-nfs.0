Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44375 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754095Ab1CAPxJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 10:53:09 -0500
Date: Tue, 1 Mar 2011 10:53:08 -0500
To: Rick Koshi <nfs-bug-report@more-right-rudder.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Possible NFSv4 locking bug
Message-ID: <20110301155308.GB20599@fieldses.org>
References: <201102281527.p1SFRNst010559@hope.more-right-rudder.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201102281527.p1SFRNst010559@hope.more-right-rudder.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 28, 2011 at 10:27:23AM -0500, Rick Koshi wrote:
> 
> Hi all, I hope this is the right place for this.
> 
> I'm using NFSv4, server and client both running 2.6.36.
> 
> I've found that when I lock an NFS-mounted file on a client, the server
> reserves an open file descriptor (as seen in /proc/sys/fs/file-nr).

So it looks like that's the total number of allocated struct file's
across the system?

> The server never releases this descriptor, even if the client process
> explictly releases the lock or exits.
> 
> In my case, I noticed this because I have a monitoring process which
> runs every 5 seconds and runs 'rrdtool' to log some status to a file
> on an NFS-mounted filesystem.  This allocated 720 files per hour, and
> eventually caused my server to run out of file descriptors and become
> unusable.  I experimented with a test program, and found that it's the
> fcntl64(3, F_SETLK, {type=F_WRLCK, ...}) system call that triggers
> the behavior, and that unlocking the file explictly doesn't help.
> 
> Stopping the NFS service (including the lockd) does not release the
> open files.  Only rebooting resets the state.
> 
> I'm no kernel expert.  Perhaps you can tell me if this is a necessary
> side effect of some part of the NFS implementation.  But to me, it looks
> like a bug.

Looks like I can reproduce something similar.  Yes, looks like a bug to
me.

Is there any earlier kernel where you know this problem *didn't* occur?

--b.
