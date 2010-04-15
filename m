Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:59042 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757474Ab0DOVtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Apr 2010 17:49:05 -0400
Date: Thu, 15 Apr 2010 23:49:01 +0200
From: Stefan =?iso-8859-1?Q?Kr=FCger?= <stadtkind2@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: strange performance issues with OS X 10.6 client
Message-ID: <20100415214900.GA4143@web.de>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello list,

I have some really strange nfs performance issues

NFS server is Fedora 12, running
* kernel-2.6.32.11-99.fc12.x86_64 and
* nfs-utils-1.2.1-4.fc12.x86_64
* nfs shared /home is ext4 with default mount options

/etc/exports:
/home   192.168.1.0/255.255.255.0(rw,sync)

nfs and nfslock are up and running

Nothing else touched on the server nfs-wise.

NFS client is Mac OS X, version 10.6.3

My /home dir is automounted on the Mac with the following mount options:
* nosuid,nodev,resvport,rdirplus,rwsize=1048576
(nfsv3 and tcp are default, I have also tried udp, and with and without
rdirplus, with different read/write sizes (started with 32k, less for udp,
and then cranked it up to 1m to make the beachball appear less often), but I
still have issues no matter which options I chose)

Anyway, I'm stuck now, surfing the web with Safari is a very unpleasant
experience on nfs, beachball every now and then together with a huge amount
of network traffic (RX with 20MB/s+ peaks), not unusual to see several
gigabytes received after some minutes browsing, XCode shows a ''The
document "SomeFile.m" could not be saved.''-error after some edits, Opera
hangs for minutes when closing, etc etc.

It's horrible :(

Another example, extracting
http://www.bignerdranch.com/solutions/Cocoa-3rd.tgz took over 3min!

$ time tar xzf Cocoa-3rd.tgz
0.169u 3.198s 5:51.10 0.9%	0+0k 1+6972io 0pf+0w
$ time rm -rf Solutions-Cocoa-3rd/
0.014u 0.477s 0:45.59 1.0%	0+0k 1+1io 0pf+0w

So any help or hints really appreciated
