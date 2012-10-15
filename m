Return-Path: linux-nfs-owner@vger.kernel.org
Received: from science.horizon.com ([71.41.210.146]:26134 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750754Ab2JOIFk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Oct 2012 04:05:40 -0400
Date: 15 Oct 2012 04:05:39 -0400
Message-ID: <20121015080539.23088.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Cc: linux@horizon.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond.Myklebust@netapp.com wrote:
> We should probably aim to remove it entirely in the next 1-2 years.
> There is no place in today's world for a protocol that can only deal
> with a 2GB maximum file size...

Today's world includes a lot of yesterday's world.

I'm still running a SunOS 4.1.4 machine.  Yes, it does real (dusty
deck) work; I just had to resurrect it when its HDD died.

I got to rediscover its 2 GB maximum FILESYSTEM size.

(When the hardware finally craps out for real, I'll probably
punt to QEMU.  But I either have to add SunOS system call
emulation to QEMU, or run the whole OS under hardware emulation.)

Anyway, most of its files are actually on a Linux NFS server
with a proper RAID and backup system.

I'd kind of like to keep NFSv2 working, if you don't mind.

("I do mind; install unfsd" is perhaps a legitimate response.)
