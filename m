Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esgaroth.petrovitsch.at ([78.47.184.11]:5562 "EHLO
	esgaroth.petrovitsch.priv.at" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932262Ab0E1JgP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 May 2010 05:36:15 -0400
Subject: Re: Debugging fcntl() file locks
From: Bernd Petrovitsch <bernd@sysprog.at>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1274969927.2895.19.camel@heimdal.trondhjem.org>
References: <1274955060.14002.40.camel@thorin>
	 <1274963686.2895.7.camel@heimdal.trondhjem.org>
	 <1274967997.14002.42.camel@thorin>
	 <1274969927.2895.19.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 28 May 2010 11:36:10 +0200
Message-ID: <1275039370.20005.6.camel@thorin>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Don, 2010-05-27 at 10:18 -0400, Trond Myklebust wrote:
> On Thu, 2010-05-27 at 15:46 +0200, Bernd Petrovitsch wrote:
[...]
> > On Don, 2010-05-27 at 08:34 -0400, Trond Myklebust wrote:
> > > On Thu, 2010-05-27 at 12:11 +0200, Bernd Petrovitsch wrote:
> > [...]
> > > > How can I debug fcntl() file locks on a NFSv3-client?
> > > > The server side is a NetApp-Box (no details at hand but I can ask).
> > > > The client side are stock-RHEL5.3/CentOS-5.3 kernels - 2.6.18-92.el5.
> > > > 
> > > > The file system in question is mounted on 2 clients. flock() on a file
> > > > succeeds but fcntl() fails with EAGAIN. From what I found in the
> > > > Internet and manual pages, this means that someone else already locked
> > > > that file (- the file is successfully open()ed read/write so it can't be
> > > > "your are not allowed to write-lock the file").
> > > > But how do I find out on which host and which process?
> > > > 
> > > > strace shows:
> > > > ----  snip  ----
> > > > open("/... secret ...", O_RDWR) = 3
> > > > ioctl(3, SNDCTL_TMR_TIMEBASE or TCGETS, 0x7fff7925b400) = -1 ENOTTY (Inappropriate ioctl for device)
> > > > lseek(3, 0, SEEK_CUR)                   = 0
> > > > fstat(3, {st_mode=S_IFREG|0600, st_size=935, ...}) = 0
> > > > fcntl(3, F_SETFD, FD_CLOEXEC)           = 0
> > > > flock(3, LOCK_EX|LOCK_NB)               = 0
> > > > fcntl(3, F_SETLK, {type=F_WRLCK, whence=SEEK_SET, start=0, len=0}) = -1 EAGAIN (Resource temporarily unavailable)
> > > > ----  snip  ---- 
> > > > [ This is a perl script using CPAN modules at the top. ]
> > [...]
> > > The Linux NFS client does not allow you to lock a file using both
> > > flock() and POSIX locks. You should choose one or the other locking
> > > scheme. If you remove the flock() line above, then the POSIX lock will
> > > likely succeed.
> > 
> > Thanks.
> > Does flock() work on NFS these days on NFS?
> > Historically that was not the case IIRC.
> 
> Yes. flock() has worked since the early 2.6.x series, however it uses
> the same NFS byte range lock protocol as POSIX locks, so there is no way
> to avoid conflicts.

IMHO this is the saner approach - treat flock() and fcntl()-locking the
same with just different APIs/interfaces. But there are probably more
(historically grown) differences.

And other filesystems - especially ext3 - allow this "duplicate locking"
- at least for /dev/null.
Said script is trying that to check if fcntl() can be used after flock()
or not.
Not that I find that a particularly good solution because
- there is no check if /dev/null is on the same filesystem as the
  to-be-locked files and
- is locking a special char device the same as a plain file.

	Bernd
-- 
mobile: +43 664 4416156              http://www.sysprog.at/
    Linux Software Development, Consulting and Services

