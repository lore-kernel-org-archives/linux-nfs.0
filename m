Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esgaroth.petrovitsch.at ([78.47.184.11]:1677 "EHLO
	esgaroth.petrovitsch.priv.at" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752580Ab0E0LLE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 May 2010 07:11:04 -0400
Received: from [172.16.0.10] (chello062178036229.13.11.wu-wien.teleweb.at [62.178.36.229])
	(authenticated bits=0)
	by esgaroth.petrovitsch.priv.at (8.14.1/8.14.1) with ESMTP id o4RAB1rS019241
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 27 May 2010 12:11:01 +0200
Subject: Debugging fcntl() file locks
From: Bernd Petrovitsch <bernd@sysprog.at>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 27 May 2010 12:11:00 +0200
Message-ID: <1274955060.14002.40.camel@thorin>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all!

How can I debug fcntl() file locks on a NFSv3-client?
The server side is a NetApp-Box (no details at hand but I can ask).
The client side are stock-RHEL5.3/CentOS-5.3 kernels - 2.6.18-92.el5.

The file system in question is mounted on 2 clients. flock() on a file
succeeds but fcntl() fails with EAGAIN. From what I found in the
Internet and manual pages, this means that someone else already locked
that file (- the file is successfully open()ed read/write so it can't be
"your are not allowed to write-lock the file").
But how do I find out on which host and which process?

strace shows:
----  snip  ----
open("/... secret ...", O_RDWR) = 3
ioctl(3, SNDCTL_TMR_TIMEBASE or TCGETS, 0x7fff7925b400) = -1 ENOTTY (Inappropriate ioctl for device)
lseek(3, 0, SEEK_CUR)                   = 0
fstat(3, {st_mode=S_IFREG|0600, st_size=935, ...}) = 0
fcntl(3, F_SETFD, FD_CLOEXEC)           = 0
flock(3, LOCK_EX|LOCK_NB)               = 0
fcntl(3, F_SETLK, {type=F_WRLCK, whence=SEEK_SET, start=0, len=0}) = -1 EAGAIN (Resource temporarily unavailable)
----  snip  ---- 
[ This is a perl script using CPAN modules at the top. ]

/proc/mounts shows 
----  snip  ---- 
rw,nodiratime,vers=3,rsize=32768,wsize=32768,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=<ip-address>
----  snip  ---- 
as options for the filesystem.

Thanks in advance,
	Bernd
-- 
mobile: +43 664 4416156              http://www.sysprog.at/
    Linux Software Development, Consulting and Services

