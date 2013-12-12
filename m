Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47123 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751886Ab3LLPqm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Dec 2013 10:46:42 -0500
Date: Thu, 12 Dec 2013 10:46:42 -0500
To: Sander Klein <roedie@roedie.nl>
Cc: linux-nfs@vger.kernel.org
Subject: Re: rpc.mountd high cpu usage
Message-ID: <20131212154642.GA11521@fieldses.org>
References: <889b64df295ba04d47f941762ebe0bac@roedie.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <889b64df295ba04d47f941762ebe0bac@roedie.nl>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 12, 2013 at 11:13:11AM +0100, Sander Klein wrote:
> Hi,
> 
> We have an NFS server with about 186 exports currently. Every time
> we add an export or mount an export the rpc.mountd starts eating
> 100% of the CPU for a long time and clients get timeouts during
> mounts.
> 
> At first I thought this was because of a mount storm so I created
> more rpc.mountd threads (16 currently on a 16 core CPU) to see if
> that would help. We also made sure that not all of our clients mount
> the export at the same time. But it didn't help.
> 
> After attaching a strace to one of the rpc.mountd processes I found
> out that a lot of newfstatat's are being done. For every export we
> create a newfstatat is being done for every way the a harddisk is
> seen the OS. Our system has 180 harddisks which are all multipathed
> so a these are a *LOT* of stats. 7206 per export in our case. Just a
> small part from the strace (sorry for the big paste):

That sounds like somewhat of an extreme setup, and I suspect the current
behavior is by design, but I agree that we should fix it.  I'm not
volunteering for now....

I think what happens is that exportfs flushes the kernel's export cache
at which point every use of an uncached export triggers an upcall to
mountd.  That upcall is probably visible in the strace as a read of a
file descriptor associated with /proc/net/sunrpc/nfsd.fh/content.

That upcall is handled by nfs-utils/utils/mountd/cache.c:nfsd_fh(),
which is given a filehandle fragment identifying the filesystem in
question and has to match it to an export.

That's done by match_fsid().  Which does do a stat of the export path,
but not of all the devices....  That's probably happening in one of the
libblkid calls in uuid_by_path()?  I wonder if there's something wrong
with libblkid configuration or with the way we're using it?

--b.

> 
> 
> statfs("/some/export", {f_type=0x2fc12fc1, f_bsize=131072,
> f_blocks=50331648, f_bfree=8355553, f_bavail=8355553,
> f_files=2139121087, f_ffree=2139021753, f_fsid={1912623216,
> 10933642}, f_namelen=255, f_frsize=131072}) = 0
> stat("/some/export", {st_mode=S_IFDIR|0775, st_size=15, ...}) = 0
> lstat("/some/export", {st_mode=S_IFDIR|0775, st_size=15, ...}) = 0
> lstat("/some/export/..", {st_mode=S_IFDIR|0755, st_size=12288, ...}) = 0
> stat("/some/export", {st_mode=S_IFDIR|0775, st_size=15, ...}) = 0
> open("/sys/dev/block/0:187", O_RDONLY)  = -1 ENOENT (No such file or
> directory)
> open("/dev", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 21
> getdents(21, /* 1093 entries */, 32768) = 30680
> newfstatat(21, "dm-185", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 185), ...}, 0) = 0
> newfstatat(21, "dm-184", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 184), ...}, 0) = 0
> newfstatat(21, "dm-183", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 183), ...}, 0) = 0
> newfstatat(21, "dm-182", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 182), ...}, 0) = 0
> newfstatat(21, "dm-181", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 181), ...}, 0) = 0
> newfstatat(21, "dm-180", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 180), ...}, 0) = 0
> [...]
> newfstatat(21, "dm-3", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 3), ...}, 0) = 0
> newfstatat(21, "dm-2", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 2), ...}, 0) = 0
> newfstatat(21, "loop7", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(7, 7), ...}, 0) = 0
> newfstatat(21, "loop6", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(7, 6), ...}, 0) = 0
> newfstatat(21, "loop5", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(7, 5), ...}, 0) = 0
> newfstatat(21, "loop4", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(7, 4), ...}, 0) = 0
> newfstatat(21, "loop3", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(7, 3), ...}, 0) = 0
> newfstatat(21, "loop2", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(7, 2), ...}, 0) = 0
> newfstatat(21, "loop1", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(7, 1), ...}, 0) = 0
> newfstatat(21, "shm", {st_mode=S_IFDIR|S_ISVTX|0777, st_size=60,
> ...}, 0) = 0
> newfstatat(21, "sndstat", {st_mode=S_IFREG|0444, st_size=0, ...}, 0) = 0
> newfstatat(21, "root", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 0), ...}, 0) = 0
> newfstatat(21, "MAKEDEV", {st_mode=S_IFREG|0755, st_size=22880,
> ...}, 0) = 0
> newfstatat(21, "dvdrw", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(11, 0), ...}, 0) = 0
> newfstatat(21, "dvd", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(11, 0), ...}, 0) = 0
> newfstatat(21, "cdrw", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(11, 0), ...}, 0) = 0
> newfstatat(21, "cdrom", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(11, 0), ...}, 0) = 0
> newfstatat(21, "hpilo", {st_mode=S_IFDIR|0755, st_size=200, ...}, 0) = 0
> newfstatat(21, "snd", {st_mode=S_IFDIR|0755, st_size=80, ...}, 0) = 0
> newfstatat(21, "loop0", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(7, 0), ...}, 0) = 0
> newfstatat(21, "dm-1", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 1), ...}, 0) = 0
> newfstatat(21, "os", {st_mode=S_IFDIR|0755, st_size=160, ...}, 0) = 0
> newfstatat(21, "dm-0", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 0), ...}, 0) = 0
> newfstatat(21, "sdnc", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(70, 480), ...}, 0) = 0
> newfstatat(21, "sdnb", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(70, 464), ...}, 0) = 0
> newfstatat(21, "sdna", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(70, 448), ...}, 0) = 0
> newfstatat(21, "sdmz", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(70, 432), ...}, 0) = 0
> newfstatat(21, "sdmy", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(70, 416), ...}, 0) = 0
> newfstatat(21, "sdmx", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(70, 400), ...}, 0) = 0
> newfstatat(21, "sdmw", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(70, 384), ...}, 0) = 0
> [...]
> newfstatat(21, "sdd", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(8, 48), ...}, 0) = 0
> newfstatat(21, "sdc", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(8, 32), ...}, 0) = 0
> newfstatat(21, "sdb", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(8, 16), ...}, 0) = 0
> newfstatat(21, "bus", {st_mode=S_IFDIR|0755, st_size=60, ...}, 0) = 0
> newfstatat(21, "bsg", {st_mode=S_IFDIR|0755, st_size=15280, ...}, 0) = 0
> newfstatat(21, "rtc", {st_mode=S_IFCHR|0600, st_rdev=makedev(254,
> 0), ...}, 0) = 0
> newfstatat(21, "char", {st_mode=S_IFDIR|0755, st_size=25320, ...},
> 0) = 0
> newfstatat(21, "mapper", {st_mode=S_IFDIR|0755, st_size=3780, ...},
> 0) = 0
> newfstatat(21, "net", {st_mode=S_IFDIR|0755, st_size=60, ...}, 0) = 0
> newfstatat(21, "cpu", {st_mode=S_IFDIR|0755, st_size=60, ...}, 0) = 0
> newfstatat(21, "stderr", {st_mode=S_IFCHR|0666, st_rdev=makedev(1,
> 3), ...}, 0) = 0
> newfstatat(21, "stdout", {st_mode=S_IFCHR|0666, st_rdev=makedev(1,
> 3), ...}, 0) = 0
> newfstatat(21, "stdin", {st_mode=S_IFCHR|0666, st_rdev=makedev(1,
> 3), ...}, 0) = 0
> newfstatat(21, "fd", {st_mode=S_IFDIR|0500, st_size=0, ...}, 0) = 0
> newfstatat(21, "core", {st_mode=S_IFREG|0400,
> st_size=140737486262272, ...}, 0) = 0
> newfstatat(21, "pts", {st_mode=S_IFDIR|0755, st_size=0, ...}, 0) = 0
> newfstatat(21, "input", {st_mode=S_IFDIR|0755, st_size=120, ...}, 0) = 0
> getdents(21, /* 0 entries */, 32768)    = 0
> close(21)                               = 0
> open("/devfs", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = -1
> ENOENT (No such file or directory)
> open("/devices", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = -1
> ENOENT (No such file or directory)
> open("/dev/input", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 21
> getdents(21, /* 6 entries */, 32768)    = 168
> newfstatat(21, "by-path", {st_mode=S_IFDIR|0755, st_size=60, ...},
> 0) = 0
> getdents(21, /* 0 entries */, 32768)    = 0
> close(21)                               = 0
> open("/dev/pts", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 21
> getdents(21, /* 6 entries */, 32768)    = 144
> getdents(21, /* 0 entries */, 32768)    = 0
> close(21)                               = 0
> open("/dev/cpu", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 21
> getdents(21, /* 3 entries */, 32768)    = 80
> getdents(21, /* 0 entries */, 32768)    = 0
> close(21)                               = 0
> open("/dev/net", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 21
> getdents(21, /* 3 entries */, 32768)    = 72
> getdents(21, /* 0 entries */, 32768)    = 0
> close(21)                               = 0
> open("/dev/mapper", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 21
> getdents(21, /* 189 entries */, 32768)  = 7472
> newfstatat(21, "os-home", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 185), ...}, 0) = 0
> newfstatat(21, "os-var", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 184), ...}, 0) = 0
> newfstatat(21, "os-usr", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 183), ...}, 0) = 0
> newfstatat(21, "os-boot", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 182), ...}, 0) = 0
> newfstatat(21, "35000cca01a8db828", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 181), ...}, 0) = 0
> newfstatat(21, "35000cca01a9a63e8", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 180), ...}, 0) = 0
> newfstatat(21, "35000cca01a89cae4", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 179), ...}, 0) = 0
> newfstatat(21, "35000cca01a89dd04", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 178), ...}, 0) = 0
> [...]
> newfstatat(21, "35000cca03e40bd84", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 6), ...}, 0) = 0
> newfstatat(21, "35000cca03e4b0250", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 3), ...}, 0) = 0
> newfstatat(21, "35000cca03e368408", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 7), ...}, 0) = 0
> newfstatat(21, "os-swap", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 1), ...}, 0) = 0
> newfstatat(21, "os-root", {st_mode=S_IFBLK|S_ISVTX|0660,
> st_rdev=makedev(254, 0), ...}, 0) = 0
> getdents(21, /* 0 entries */, 32768)    = 0
> close(21)                               = 0
> open("/dev/char", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 21
> getdents(21, /* 1027 entries */, 32768) = 32768
> newfstatat(21, "10:237", {st_mode=S_IFCHR|S_ISVTX|0600,
> st_rdev=makedev(10, 237), ...}, 0) = 0
> newfstatat(21, "7:134", {st_mode=S_IFCHR|0600, st_rdev=makedev(7,
> 134), ...}, 0) = 0
> newfstatat(21, "7:6", {st_mode=S_IFCHR|0600, st_rdev=makedev(7, 6),
> ...}, 0) = 0
> newfstatat(21, "7:133", {st_mode=S_IFCHR|0600, st_rdev=makedev(7,
> 133), ...}, 0) = 0
> [...etc etc etc...]
> 
> 
> Is this expected behavour or is this some kind of bug?
> 
> I'm using nfs-utils 1.2.8 from Debian testing, but also had this
> problem with 1.2.6. The kernel is 3.2.51.
> 
> If any more info is needed please let me know.
> 
> Regards,
> 
> Sander Klein
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
