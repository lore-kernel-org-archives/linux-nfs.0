Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:51396 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab0HMSZv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 14:25:51 -0400
Date: Fri, 13 Aug 2010 11:25:49 -0700
Message-ID: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
Subject: Proposal: Use hi-res clock for file timestamps
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For concreteness, let me start with the patch I have in mind.  Call it
"patch version 1".


--- linux-2.6.32.13-0.4/kernel/time.c.orig      2010-08-13
10:52:50.000000000 -0700
+++ linux-2.6.32.13-0.4/kernel/time.c   2010-08-13 10:53:20.000000000 -0700
@@ -229,7 +229,7 @@ SYSCALL_DEFINE1(adjtimex, struct timex _
  */
 struct timespec current_fs_time(struct super_block *sb)
 {
-        struct timespec now = current_kernel_time();
+       struct timespec now = getnstimeofday();
        return timespec_trunc(now, sb->s_time_gran);
 }
 EXPORT_SYMBOL(current_fs_time);

...

I recently spent nearly a week tracking down an NFS cache coherence
problem in an application:

http://www.spinics.net/lists/linux-nfs/msg14974.html

Here is what caused my problem:

1) File dir/A is created locally on NFS server.
2) NFS client does LOOKUP on file dir/B, gets ENOENT.
3) File dir/B is created locally on NFS server.

In my case, these all happened in less than 4 milliseconds (much less,
actually).  Since HZ on my system is 250, the file creation in step
(3) failed to update the ctime/mtime on the directory.  The result is
that the NFS client's "dentry lookup cache" became stale, but did not
know it was stale (since it relies on the directory ctime/mtime to
detect that).  Worse, the staleness persists even if additional
changes are made to the directory from the NFS client, thanks to NFS
v3's "weak cache consistency" optimizations.

Why did this take me a week to diagnose?  Because I am using XFS, and
I know XFS and NFS use nanosecond resolution for file timestamps.  It
never occurred to me that, here in 2010, Linux would have an actual
file timestamp resolution 6.5 orders of magnitude worse.

I know, I know, "use NFS v4 and i_version".  But that is not the
point.  The point is that 4 milliseconds is a very long time these
days; an awful lot of file system operations can happen in such an
interval.

I am guessing the objection to the above patch will be:  "Waaah it's
slow!"  My responses would be:

1) Anybody who cares about file system performance is already using
"noatime" or "relatime", which mitigates the hit greatly.

2) Correctness is more important than performance, and 4 milliseconds
is just embarrassing.

3) On the 99.99% of Linux systems that are post-1990 x86, it is not
slow at all, and the performance difference will be utterly
undetectable in the real world.

When was XFS designed?  It has nanosecond timestamps.  When was NFS
designed?  It has nanosecond timestamps.  Even ext4 has nanosecond
timestamps...  But what is the point if 22 bits' worth will forever be
meaningless?

If the above patch is too slow for some architectures, how about
making it a configuration option?  Call it "CONFIG_1980S_FILE_TICK",
have it default to YES on the architectures that care and NO on
anything remotely modern and sane.

OK that's my proposal.  Bash away.

 - Pat
