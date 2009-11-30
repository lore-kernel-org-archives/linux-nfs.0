From: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: 2.6.31.6, unresponsiveness and something with nfs
Date: Mon, 30 Nov 2009 18:07:51 +0100
Message-ID: <4B13FBE7.9040304@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.0.fullrate.dk ([90.184.12.24]:36818 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbZK3RHv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2009 12:07:51 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

I have a system running 2.6.31.6 that when running a particular process
become "unresponsive". I cannot really tell what it is but the effect is
that logins as ordinary users hangs, when that user has its home on a
remote NFS-server.

so from root "su - localuser" works excellent. But su - user-with-home
on-nfs doesnt.

It is not as if NIS/NFS doesnt work, since i can get a directory-listing
from the NFS-share as root without problems.

But here is the last 10 lines from "strace -f su -
user-with-home-on-nfs" .. it get into an un-interruptible hang.

[pid 24599] close(3)                    = 0
[pid 24599] open("/etc/localtime", O_RDONLY) = 3
[pid 24599] fstat(3, {st_mode=S_IFREG|0644, st_size=2134, ...}) = 0
[pid 24599] fstat(3, {st_mode=S_IFREG|0644, st_size=2134, ...}) = 0
[pid 24599] mmap(NULL, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f6b0c5b2000
[pid 24599] read(3,
"TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\6\0\0\0\6\0\0"..., 4096) = 2134
[pid 24599] lseek(3, -1368, SEEK_CUR)   = 766
[pid 24599] read(3,
"TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\10\0\0\0\10\0"..., 4096) = 1368
[pid 24599] close(3)                    = 0
[pid 24599] munmap(0x7f6b0c5b2000, 4096) = 0
[pid 24599] stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2134,
...}) = 0
[pid 24599] fstat(1,

^C^C^C^C


or at least not uninterruptable, because I have a process merging 20,
1.5GB presorted files using "sort -m" from GNU-coreutils.. on an ext4
volume, a few seconds after I kill -9 the sorting process.. all hanging
login continues.. the above process continues(and the system returns to
"normal state"):

{st_mode=S_IFREG|0664, st_size=246138, ...}) = 0
[pid 24599] --- SIGINT (Interrupt) @ 0 (0) ---
Process 24542 resumed
Process 24599 detached
[pid 24542] <... wait4 resumed> 0x7fffa656c5a4, 0, NULL) = ? ERESTARTSYS
(To be restarted)
[pid 24542] --- SIGINT (Interrupt) @ 0 (0) ---

The merging process is on an ext4 volume of 8TB in size. strace of the
sorting process, shows it progresses nicely.

The system is running 2.6.31.6 with
59a252ff8c0f2fa32c896f69d56ae33e641ce7ad reverted as suggested by J.
Bruce Fields, to me it seems unrelated.

Jesper
-- 
Jesper
