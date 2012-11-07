Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53162 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751524Ab2KGTHa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 14:07:30 -0500
Date: Wed, 7 Nov 2012 14:07:24 -0500
To: Florian Pritz <bluewind@xinu.at>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS stalls when writing - linux 3.6.x
Message-ID: <20121107190724.GD7421@fieldses.org>
References: <50957087.6050008@xinu.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50957087.6050008@xinu.at>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 03, 2012 at 08:29:11PM +0100, Florian Pritz wrote:
> Hi,
> 
> Long text ahead.
> 
> 
> Since I have no idea what to look at/for, I tried to summarise all more
> or less relevant information. If you need any more, please tell me.
> 
> I've been trying to debug this for days now and might have mixed
> something up although I double checked as much as possible while writing
> this mail.
> 
> 
> # Overview
> 
> I've been experiencing stalls when trying to write big-ish files on my
> nfs mount for some time (few months) now. Rsync is also somewhat slow,
> transferring only like 1 file per second even if the files are only a
> few kilobytes in size. Sometimes it also stalls for a few seconds
> between files. I hardly run rsync over nfs so can't tell if this might
> be normal.
> 
> Sadly I don't know when this started happening.

It would be helpful to know that--especially if you find an easy way to
reproduce this, it would be worth booting to older kernels and seeing if
you can figure when the problem started.

> Server and client are both running Arch Linux with linux 3.6.5 and
> nfs-utils 1.2.6.
> 
> The server is running on a striped raid10 array with 4 disks using the
> deadline scheduler and connected via Gbit ethernet. The CPU is an Intel
> i3-530 and it has 2GB RAM. The raid10 is part of an LVM which contains
> the actual XFS file system exported by nfsd.
> 
> At first I assumed a problem with file system, but I switched from ext3
> to XFS and still experience the issue. Transferring large amounts
> (>80GB) of data over samba + cifs didn't cause any problems so I'm
> ruling out network and disks.
> 
> # Description
> 
> dd if=/dev/zero of=test bs=1M count=8000 (writing a 1GB file is also
> enough, sometimes)
> 
> Watch the network traffic (with "vnstat -l" or conky) and wait until it
> drops from 110MB/s to 0-5MB/s (you might need to run dd multiple times,
> wait a few minutes/hours or reboot the server)
> 
> top on the server now shows lots of nfsd threads in D state.

Next time you find in that state, could you try

	echo t >/proc/sysrq-trigger

on the server?  That will dump a bunch of data to the logs which we
might be able to use.

--b.

> iostat only
> shows the 0-5MB/s of network traffic going to the disk.
> 
> A local dd job on the server manages to write 160MB/s while nfsd
> continues to hang. Reading from the nfs share while nfsd is hanging is
> possible, but has a delay of up to ~20-30 seconds.
> 
> After some time the client displays "nfs: server levant not responding,
> still trying" in dmesg followed by a "nfs: server levant OK" 0 or more
> seconds later (yes, zero). Both messages sometimes appear more than once
> at the same time.
> 
> Apart from those messages dmesg is clean on either system even after
> waiting for a few minutes.
> 
> # Environment
> 
> ## Mount options (from /proc/mounts)
> 
> rw,nosuid,nodev,noexec,relatime,vers=4.0,rsize=65536,wsize=65536,
> namlen=255,hard,proto=tcp,port=0,timeo=14,retrans=2,sec=sys,
> clientaddr=192.168.4.247,local_lock=none,addr=192.168.4.103,user
> 
> ## /etc/exportsfs -v
> 
> /mnt/data/nfs
> 192.168.4.1/24(rw,wdelay,crossmnt,root_squash,all_squash,no_subtree_check,anonuid=999,anongid=999)
> 
> ## Programm versions
> 
> Those are all the same on both client and server.
> 
> acl 2.2.51-2
> libgssglue 0.4-1
> libevent 2.0.20-1
> librpcsecgss 0.19-7
> nfs-utils 1.2.6-2
> util-linux 2.22.1-2
> 
> # Other notes
> 
> I tried reproducing the issue with a virtual machine and it somehow
> worked, but I'm not really sure if I actually hit the same issue because
> the vm sometimes locks up too.
> 
> The VM was set up in qemu with one virtio disk which was directly
> partioned without the use of mdadm or lvm.
> 
> 
> Thank you for reading.
> 
> -- 
> Florian Pritz
> 


