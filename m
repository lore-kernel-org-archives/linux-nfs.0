Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:41759 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349Ab0IUU2T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Sep 2010 16:28:19 -0400
Received: from esperi.org.uk (nix@spindle.srvr.nix [192.168.14.15])
	by mail.esperi.org.uk (8.14.4/8.14.3) with ESMTP id o8LKSFPA005252
	for <linux-nfs@vger.kernel.org>; Tue, 21 Sep 2010 21:28:15 +0100
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: persistent, quasi-random -ESTALE at mount time
From: Nix <nix@esperi.org.uk>
Date: Tue, 21 Sep 2010 21:28:13 +0100
Message-ID: <87mxra6duq.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've noticed since at least 2.6.34 and possibly before (I only booted
2.6.33 and .34 once, so it's hard to remember) that initial mounts from
my NFSv3 server are failing with -ESTALE.

This is only intermittent: sometimes, everything works. But, more often
than that, I get an -ESTALE on some or all of the filesystems (again,
the choice appears consistent but with no rhyme or reason to it:
/usr/info and /pkg/non-free? /var/log.real and /home/.spindle.srvr.nix? 
But /usr/doc always mounts OK, even though it is pretty much identical
to /usr/info in all respects: same server mount point and everything):
and, upon rebooting the server, I find that some of all of the
previously correctly mounted filesystems are now returning -ESTALE as
well. Unmounting and remounting them doesn't help: I just get more
ESTALEs, which leads to an endless sequence of e.g. this:

mount.nfs: trying 192.168.14.15 prog 100003 vers 3 prot TCP port 2049
mount.nfs: trying 192.168.14.15 prog 100005 vers 3 prot UDP port 33976
mount.nfs: timeout set for Tue Sep 21 20:40:06 2010
mount.nfs: trying text-based options 'hard,acl,vers=3,addr=192.168.14.15'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: prog 100005, trying vers=3, prot=17
spindle:/home/.spindle.srvr.nix on /home/.spindle.srvr.nix type nfs (rw,hard,acl,vers=3)

What *does* help is restarting rpc.mountd on the server. Everything
works after that. Further, it seems to work if the client is stuck in
the middle of rebooting for the entire time the server is rebooting:
i.e. if the client starts rebooting first and ends rebooting later.
(However, I do this very rarely, so I have few instances to reason from:
this may be erroneous.)

Daemon boot order is as recommended, i.e.

mount /proc/fs/nfsd
/usr/sbin/exportfs -ra
/usr/sbin/portmap -t /var/lib/portmap
/usr/sbin/rpc.mountd
/usr/sbin/rpc.statd --no-notify
/usr/sbin/rpc.nfsd 16
/usr/sbin/sm-notify

On the client, we have

/usr/sbin/portmap -t /var/lib/portmap
/usr/sbin/rpc.statd --no-notify
/usr/sbin/sm-notify

(then we mount away... and it often fails with -ESTALE)

The client and server are running identical kernels (from 2.6.34 to
2.6.35.5), and identical versions of the nfs-utils (seen with 1.2.2-rc7
up to tip-of-master). They're both nearly-identical 64-bit Nehalems (one
is an i7 920, the other an L5520) with bags of RAM (12Gb up, mostly
unused). All the filesystems being exported are ext4, all mounted with

defaults,nobarrier,relatime,nosuid,nodev,journal_async_commit,commit=30,user_xattr,acl

(yes, nobarrier is safe, the server has a battery-backed RAID array).

(Back in the day (pre-2.6.33) this problem wasn't present, and the
filesystems are all older than that, so I doubt it's purely FS-related.)


Debugging output from a failing rpc.mountd:

Sep 21 20:51:18 spindle info: v4root_create: path '/'
Sep 21 20:51:18 spindle info: v4root_create: path '/home'
Sep 21 20:51:18 spindle info: v4root_create: path '/'
Sep 21 20:51:18 spindle info: v4root_create: path '/home'
Sep 21 20:51:18 spindle info: v4root_create: path '/'
Sep 21 20:51:18 spindle info: v4root_create: path '/home'
Sep 21 20:51:18 spindle info: v4root_create: path '/home/.spindle.srvr.nix/nix'
Sep 21 20:51:18 spindle info: v4root_create: path '/home/.spindle.srvr.nix/nix/Mail'
Sep 21 20:51:18 spindle info: v4root_create: path '/home/.spindle.srvr.nix/nix/Mail/nnmh'
Sep 21 20:51:18 spindle info: v4root_create: path '/home/.spindle.srvr.nix/nix'
Sep 21 20:51:18 spindle info: v4root_create: path '/home/.spindle.srvr.nix/nix/Mail'
Sep 21 20:51:18 spindle info: v4root_create: path '/home/.spindle.srvr.nix/nix/Mail/nnmh'
Sep 21 20:51:18 spindle info: v4root_create: path '/home/.spindle.srvr.nix/nix/Graphics'
Sep 21 20:51:18 local@spindle info: Last message 'v4root_create: path ' repeated 1 times, supressed by syslog-ng on spindle.srvr.nix
Sep 21 20:51:18 spindle info: v4root_create: path '/usr'
Sep 21 20:51:18 spindle info: v4root_create: path '/usr/share'
Sep 21 20:51:18 spindle info: v4root_create: path '/pkg'
Sep 21 20:51:18 spindle info: v4root_create: path '/usr/lib'
Sep 21 20:51:18 spindle info: v4root_create: path '/usr/lib/X11'
Sep 21 20:51:18 spindle info: v4root_create: path '/var'
Sep 21 20:51:18 spindle info: v4root_create: path '/etc'
Sep 21 20:51:18 spindle info: v4root_create: path '/var/state'
Sep 21 20:51:18 spindle info: v4root_create: path '/usr/share/httpd'
Sep 21 20:51:18 spindle info: v4root_create: path '/usr/share/httpd/htdocs'
Sep 21 20:51:18 spindle info: v4root_create: path '/usr'
Sep 21 20:51:18 spindle info: v4root_create: path '/usr/share'
Sep 21 20:51:18 spindle info: v4root_create: path '/trees'
Sep 21 20:51:18 spindle info: v4root_create: path '/'
Sep 21 20:51:18 spindle info: v4root_create: path '/home'
Sep 21 20:51:18 spindle info: v4root_create: path '/home/.spindle.srvr.nix'
Sep 21 20:51:18 spindle info: v4root_create: path '/home/.spindle.srvr.nix/nix'
Sep 21 20:51:19 spindle notice: Version 1.2.2 starting
Sep 21 20:51:19 spindle warning: Flags: 
Sep 21 20:51:23 spindle notice: Version 1.2.2 starting

(now I started rebooting the client: I suspect this is unmounting
activity)

Sep 21 20:51:39 spindle info: auth_unix_ip: inbuf 'nfsd 192.168.16.20'
Sep 21 20:51:39 spindle info: auth_unix_ip: client 0x1f3dde0 'mutilate.wkstn.nix'
Sep 21 20:51:39 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x014000000000000095bd22c2253c456f8e36b6cfb9ecd4ef'
Sep 21 20:51:39 spindle info: nfsd_fh: found (nil) path (null)
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x01400000000000000d948b1b8091d09c0000000000000000'
Sep 21 20:51:42 spindle info: nfsd_fh: found 0x1f316c0 path /home/.spindle.srvr.nix
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x01c0000000000000b5cb6e6bed9d4345abd64535f56e2519'
Sep 21 20:51:42 spindle info: nfsd_fh: found (nil) path (null)
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x1ee00000000000006c0f7fa7d6c24054bff33a878460bdc7'
Sep 21 20:51:42 spindle info: nfsd_fh: found (nil) path (null)
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x01200100000000005cccc224a92440eeb44504473898c2ec'
Sep 21 20:51:42 spindle info: nfsd_fh: found (nil) path (null)
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x01a00000000000005cccc224a92440eeb44504473898c2ec'
Sep 21 20:51:42 spindle info: nfsd_fh: found 0x1f2f6e0 path /usr/doc
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x82650000000000005cccc224a92440eeb44504473898c2ec'
Sep 21 20:51:42 spindle info: nfsd_fh: found 0x1f2e6f0 path /usr/share/xemacs
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x85650000000000005cccc224a92440eeb44504473898c2ec'
Sep 21 20:51:42 spindle info: nfsd_fh: found 0x1f2e1a0 path /usr/share/xplanet
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x84510a00000000005cccc224a92440eeb44504473898c2ec'
Sep 21 20:51:42 spindle info: nfsd_fh: found 0x1f2ec40 path /usr/share/texlive
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \xe86d0800000000005cccc224a92440eeb44504473898c2ec'
Sep 21 20:51:42 spindle info: nfsd_fh: found 0x1f2d1b0 path /usr/lib/X11/fonts
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 6 \x07799ff5baef4492875dc73730d6149e'
Sep 21 20:51:42 spindle info: nfsd_fh: found (nil) path (null)
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 6 \x333950aa8e3f440abc94d0cc4adae198'
Sep 21 20:51:42 spindle info: nfsd_fh: found 0x1f2bc70 path /usr/src
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x02a0080000000000b5cb6e6bed9d4345abd64535f56e2519'
Sep 21 20:51:42 spindle info: nfsd_fh: found 0x1f2b720 path /var/state/munin
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \xaf750000000000005cccc224a92440eeb44504473898c2ec'
Sep 21 20:51:42 spindle info: nfsd_fh: found 0x1f2b1f0 path /usr/share/httpd/htdocs/munin
Sep 21 20:51:42 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x3d650000000000005cccc224a92440eeb44504473898c2ec'
Sep 21 20:51:42 spindle info: nfsd_fh: found 0x1f2ace0 path /usr/share/clamav

(client reboot underway. from here on, I'll only show one of the
filesystems that failed to mount, rather than all of them.)

Sep 21 20:51:53 mutilate info: Switching to runlevel: 6
Sep 21 20:52:56 spindle info: from_local: updating local if addr list
Sep 21 20:52:56 spindle info: from_local: checked 14 local if addrs; incoming address not found
Sep 21 20:52:56 spindle info: check_default: access by 192.168.16.20 ALLOWED
Sep 21 20:52:56 spindle info: Received NULL request from 192.168.16.20
Sep 21 20:52:56 spindle info: check_default: access by 192.168.16.20 ALLOWED (cached)
Sep 21 20:52:56 spindle info: Received NULL request from 192.168.16.20
Sep 21 20:52:56 spindle info: check_default: access by 192.168.16.20 ALLOWED (cached)
Sep 21 20:52:56 spindle info: Received MNT3(/home/.spindle.srvr.nix) request from 192.168.16.20
Sep 21 20:52:56 spindle notice: authenticated mount request from 192.168.16.20:673 for /home/.spindle.srvr.nix (/home/.spindle.srvr.nix)
[identical messages for all the other filesystems]
Sep 21 20:52:57 spindle info: check_default: access by 192.168.16.20 ALLOWED (cached)
Sep 21 20:52:57 spindle info: Received NULL request from 192.168.16.20
Sep 21 20:52:57 spindle info: check_default: access by 192.168.16.20 ALLOWED (cached)
Sep 21 20:52:57 spindle info: Received NULL request from 192.168.16.20
Sep 21 20:52:57 spindle info: check_default: access by 192.168.16.20 ALLOWED (cached)
Sep 21 20:52:57 spindle info: Received MNT3(/home/.spindle.srvr.nix) request from 192.168.16.20
Sep 21 20:52:57 spindle notice: authenticated mount request from 192.168.16.20:976 for /home/.spindle.srvr.nix (/home/.spindle.srvr.nix)
[identical messages for the subset of those mounts that got -ESTALE]
Sep 21 20:52:59 spindle notice: authenticated mount request from 192.168.16.20:820 for /home/.spindle.srvr.nix (/home/.spindle.srvr.nix)
Sep 21 20:52:59 spindle info: check_default: access by 192.168.16.20 ALLOWED (cached)
Sep 21 20:52:59 spindle info: Received NULL request from 192.168.16.20
Sep 21 20:52:59 spindle info: check_default: access by 192.168.16.20 ALLOWED (cached)
Sep 21 20:52:59 spindle info: Received NULL request from 192.168.16.20
Sep 21 20:52:59 spindle info: check_default: access by 192.168.16.20 ALLOWED (cached)
Sep 21 20:52:59 spindle info: Received MNT3(/var/log.real) request from 192.168.16.20
[repeat forever]

which all looks fine to me apart from the way the mount persistently
fails despite the server saying it's OK.

Upon restart, it Just Works.

Any idea what the cause of this one might be? It's... mystifying. The
'fails only if just rebooted' part is particularly bizarre, as if
rpc.mountd *really* wants to start after rpc.nfsd or something.


I'll try a packet capture next (time to use --port, I guess).
