Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:35381 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752214AbcIALWb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Sep 2016 07:22:31 -0400
Received: by mail-ua0-f194.google.com with SMTP id 2so5884835uax.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Sep 2016 04:22:30 -0700 (PDT)
MIME-Version: 1.0
From: james harvey <jamespharvey20@gmail.com>
Date: Thu, 1 Sep 2016 07:22:29 -0400
Message-ID: <CA+X5Wn7oiaPyO+dN4ARb+Y4JuOqR90283par7-2NQvOtO_HOiQ@mail.gmail.com>
Subject: nfs-server (v4.x only) takes extra 6 minutes to start without rpcbind
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Up to date Arch.  Kernel 4.7.2 (-1 Arch).  nfs-utils 1.3.4 (-1 Arch).
No firewall running on this system.

Arch doesn't have any distribution-specific patches - it uses the
sourceforge source -
https://git.archlinux.org/svntogit/packages.git/tree/trunk?h=packages/nfs-utils


I started writing that an nfs-server configured for v4.x only would
never start if there was no rpcbind, BUT wound up finding out it does
start, it just takes ~ 6 minutes when with rpcbind it's "instant" /
less than 1 second.

"This" has been occurring since I started with NFS v4.x using
nfs-utils 1.3.2 & 1.3.3.  By "this", I mean it looking to me like
nfs-server wouldn't start without rpcbind.  It was probably just
starting delayed and I was impatient before 6 minutes.


I've found several posts from people saying nfs-server won't start
without rpcbind on v4.x only, so others have definitely ran into this,
just never gave it 6 minutes to finish, or maybe theirs never
finished.

Looks like there was a similar issue patched in 12/2013.  Same issue
of rpcbind being needed for v4.x, but without rpcbind the problem was
a writing fd to kernel failure from rpc.nfsd, which appears to me to
have been fatal, and I'm not getting.
http://www.spinics.net/lists/linux-nfs/msg41053.html

This MAY answer the question - it's only visible for RedHat
subscribers, which I'm not - and I have no idea if on RHEL what
versions he has and if it includes the 12/2013 patch I mentioned -
https://access.redhat.com/solutions/902013



/run/sysconfig/nfs-utils is:
==========
RPCNFSDARGS="-N 2 -N 3 8"
RPCMOUNTDARGS="-N 2 -N 3"
STATDARGS=""
SMNOTIFYARGS=""
RPCIDMAPDARGS=""
RPCGSSDARGS=""
RPCSVCGSSDARGS=""
BLKMAPDARGS=""
GSS_USE_PROXY="yes"
==========

/proc/fs/nfsd/versions is: "-2 -3 +4 +4.1 +4.2"
/proc/fs/nfsd/threads is: "8"

Running defaults (just adding "-N 2 -N 3" to RPCNFSDARGS and
RPCMOUNTDOPTS in /etc/sysconfig/nfs), the NFS server starts fine like
this, with these enabled:
* proc-fs-nfsd.mount
* var-lib-nfs-rpc_pipefs.mount
* gssproxy.service
* nfs-blkmap.service
* nfs-config.service
* nfs-idmapd.service
* nfs-mountd.service
* nfs-server.service
* rpc-statd.service
* rpcbind.service
* rpcbind.socket

nfs-server starts right away:
==========
Sep 01 05:05:14 terra systemd[1]: Starting Preprocess NFS configuration...
Sep 01 05:05:14 terra systemd[1]: Started Preprocess NFS configuration.
==========



I'm running NFS v4.x only, and I'd like to be able to disable
everything not needed.

I can mask gssproxy.service, nfs-blkmap.service, and
rpc-statd.service, and the NFS server still starts instantly with just
these:
* proc-fs-nfsd.mount
* var-lib-nfs-rpc_pipefs.mount
* nfs-config.service
* nfs-idmapd.service
* nfs-mountd.service
* nfs-server.service
* rpcbind.service
* rpcbind.socket


Since I'm running NFS v4.x only, it's my understanding I should also
be able to mask rpcbind.service and rpcbind.socket and just run with
these:
* proc-fs-nfsd.mount
* var-lib-nfs-rpc_pipefs.mount
* nfs-config.service
* nfs-idmapd.service
* nfs-mountd.service
* nfs-server.service

But without rpcbind.service and rpcbind.socket, I get the 6 minute delay

# systemctl start nfs-config

# systemctl start proc-fs-nfsd.mount
[   45.907749] RPC: Registered named UNIX socket transport module.
[   45.907755] RPC: Registered udp transport module.
[   45.907757] RPC: Registered tcp transport module.
[   45.907759] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   45.943152] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).

# rpcdebug -m nfsd -s all

# systemctl start var-lib-nfs-rpc_pipefs.mount

# rpc.mountd --foreground --no-udp -N 2 -N 3
rpc.mountd: Version 1.3.3 starting

# rpc.idmapd -f -vvv
rpc.idmapd: Skipping configuration file "/etc/idmapd.conf": No such
file or directory
rpc.idmapd: libnfsidmap: Unable to determine the NFSv4 domain; Using
'localdomain' as the NFSv4 domain which means UIDs will be mapped to
the 'Nobody-User' user defined in /etc/idmapd.conf

rpc.idmapd: libnfsidmap: using (default) domain: localdomain
rpc.idmapd: libnfsidmap: Realms list: 'LOCALDOMAIN'
rpc.idmapd: libnfsidmap: loaded plugin
/usr/lib/libnfsidmap/nsswitch.so for method nsswitch

rpc.idmapd: Expiration time is 0 seconds.
rpc.idmapd: Opened /proc/net/rpc/nfs4.nametoid/channel
rpc.idmapd: Opened /proc/net/rpc/nfs4.idtoname/channel
rpc.idmapd: Unable to open '/proc/sys/fs/nfs/idmap_cache_timeout' to
set client cache expiration time to 0 seconds

{in journalctl}

Sep 01 06:37:19 terra rpc.idmapd[2342]: libnfsidmap: Unable to
determine the NFSv4 domain; Using 'localdomain' as the NFSv4 domain
which means UIDs will be mapped to the 'Nobody-User' user defined in
/etc/idmapd.conf
Sep 01 06:37:19 terra rpc.idmapd[2342]: libnfsidmap: using (default)
domain: localdomain
Sep 01 06:37:19 terra rpc.idmapd[2342]: libnfsidmap: Realms list: 'LOCALDOMAIN'
Sep 01 06:37:19 terra rpc.idmapd[2342]: libnfsidmap: loaded plugin
/usr/lib/libnfsidmap/nsswitch.so for method nsswitch
Sep 01 06:37:19 terra rpc.idmapd[2342]: Opened
/proc/net/rpc/nfs4.nametoid/channel
Sep 01 06:37:19 terra rpc.idmapd[2342]: Opened
/proc/net/rpc/nfs4.idtoname/channel
Sep 01 06:37:19 terra rpc.idmapd[2342]: Unable to open
'/proc/sys/fs/nfs/idmap_cache_timeout' to set client cache expiration
time to 0 seconds

# exportfs -r

# rpc.nfsd --debug --no-udp -N 2 -N 3 8
rpc.nfsd: knfsd is currently down
rpc.nfsd: Writing version string to kernel: -2 -3 +4
rpc.nfsd: Created AF_INET TCP socket.

{about 2 minutes later}
[  560.800037] set_max_drc nfsd_drc_max_mem 3948544

{then about 97 seconds later}
rpc.nfsd: Created AF_INET6 TCP socket.
[  657.120279] nfsd: creating service
[  657.120286] nfsd: allocating 32 readahead buffers.
[  657.120376] nfsd4_umh_cltrack_upcall: cmd: init
[  657.120381] nfsd4_umh_cltrack_upcall: arg: (null)
[  657.120383] nfsd4_umh_cltrack_upcall: env0:
NFSDCLTRACK_GRACE_START=1472726583
[  657.120385] nfsd4_umh_cltrack_upcall: env1: (null)
[  657.151076] NFSD: end of grace period
[  657.151086] nfsd4_umh_cltrack_upcall: cmd: gracedone
[  657.151088] nfsd4_umh_cltrack_upcall: arg: 1472726583
[  657.151090] nfsd4_umh_cltrack_upcall: env0:
NFSDCLTRACK_LEGACY_TOPDIR=/var/lib/nfs/v4recovery
[  657.151092] nfsd4_umh_cltrack_upcall: env1: (null)
[  657.153448] nfsd4_umh_cltrack_upcall: /sbin/nfsdcltrack return value: 0
[  657.153885] nfsd4_umh_cltrack_upcall: /sbin/nfsdcltrack return value: 0
[  657.153890] NFSD: starting 90-second grace period (net ffffffff818b8a40)
[  747.359945] NFSD: laundromat service - starting
[  747.359953] NFSD: laundromat_main - sleeping for 90 seconds
[  837.599965] NFSD: laundromat service - starting
[  837.599973] NFSD: laundromat_main - sleeping for 90 seconds

If I reboot and perform the same process, except running "strace
rpc.nfsd --no-udp -N 2 -N 3 8" then I see:

==========
execve("/usr/bin/rpc.nfsd", ["rpc.nfsd", "--no-udp", "-N", "2", "-N",
"3", "8"], [/* 33 vars */]) = 0
brk(NULL)                               = 0x1609000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=69980, ...}) = 0
mmap(NULL, 69980, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f8548f20000
close(3)                                = 0
open("/usr/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\3\2\0\0\0\0\0"...,
832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1951744, ...}) = 0
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7f8548f1e000
mmap(NULL, 3791152, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
0) = 0x7f8548972000
mprotect(0x7f8548b07000, 2093056, PROT_NONE) = 0
mmap(0x7f8548d06000, 24576, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x194000) = 0x7f8548d06000
mmap(0x7f8548d0c000, 14640, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f8548d0c000
close(3)                                = 0
arch_prctl(ARCH_SET_FS, 0x7f8548f1f440) = 0
mprotect(0x7f8548d06000, 16384, PROT_READ) = 0
mprotect(0x604000, 4096, PROT_READ)     = 0
mprotect(0x7f8548f32000, 4096, PROT_READ) = 0
munmap(0x7f8548f20000, 69980)           = 0
brk(NULL)                               = 0x1609000
brk(0x162a000)                          = 0x162a000
getpid()                                = 2156
rt_sigaction(SIGUSR1, {0x402b10, [USR1], SA_RESTORER|SA_RESTART,
0x7f85489a50b0}, {SIG_DFL, [], 0}, 8) = 0
rt_sigaction(SIGUSR2, {0x402b10, [USR2], SA_RESTORER|SA_RESTART,
0x7f85489a50b0}, {SIG_DFL, [], 0}, 8) = 0
chdir("/var/lib/nfs")                   = 0
stat("/proc/fs/nfsd/threads", {st_mode=S_IFREG|0600, st_size=0, ...}) = 0
open("/proc/fs/nfsd/portlist", O_RDONLY) = 3
read(3,

{{{ about 153 seconds later - yes the read line is split by this time
as shown }}}

"tcp 2049\n", 128)              = 9
close(3)                                = 0
open("/dev/null", O_RDWR)               = 3
dup2(3, 0)                              = 0
dup2(3, 1)                              = 1
dup2(3, 2)                              = 2
open("/proc/self/fd", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 4
fstat(4, {st_mode=S_IFDIR|0500, st_size=0, ...}) = 0
getdents(4, /* 7 entries */, 32768)     = 168
close(3)                                = 0
getdents(4, /* 0 entries */, 32768)     = 0
close(4)                                = 0
open("/proc/fs/nfsd/threads", O_WRONLY) = 3
write(3, "8\n", 2

{{{ about 193 seconds later }}}

)                      = 2
close(3)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++
==========

Now that it's completed, I can cat /proc/fs/nfsd/{portlist,threads} instantly.

But, if I stop nfsd and try restarting it, I get the delay again.
