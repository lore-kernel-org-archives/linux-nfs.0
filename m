Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.xtronics.com ([139.146.185.26]:59527 "EHLO
	smtp.xtronics.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031057Ab3HIUow (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 16:44:52 -0400
Message-ID: <520554A5.3060401@xtronics.com>
Date: Fri, 09 Aug 2013 15:44:21 -0500
From: Karl Schmidt <karl@xtronics.com>
MIME-Version: 1.0
To: Ben Hutchings <ben@decadent.org.uk>
CC: jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org,
        714974@bugs.debian.org, Jonathan McDowell <noodles@earth.li>
Subject: Re: NFS 'readdir loop' error on JFS
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk>
In-Reply-To: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This problem is still alive - took a while for it to show up again:

(From the client - but speaks of the server )

Aug  9 14:32:20 singapore kernel: [497500.291867] NFS: directory timeless/JFK-prep contains a 
readdir loop.Please contact your server vendor.  The file: 234t.jpg has duplicate cookie 18
Aug  9 14:32:20 singapore kernel: [497500.291930] NFS: directory timeless/JFK-prep contains a 
readdir loop.Please contact your server vendor.  The file: 234t.jpg has duplicate cookie 18
Aug  9 14:32:20 singapore kernel: [497500.346824] NFS: directory pictures/wells_index contains a 
readdir loop.Please contact your server vendor.  The file: img_1260.jpgQ▒J@K���j�^ has duplicate 
cookie 24
Aug  9 14:32:20 singapore kernel: [497500.346884] NFS: directory pictures/wells_index contains a 
readdir loop.Please contact your server vendor.  The file: img_1260.jpgQ▒J@K���j�^ has duplicate 
cookie 24


This is a wheezy production server - I can run tests, provide information, but I'm about to purchase 
some spare drives and move the server to ext4 to protect the data. So if anyone wants information, 
now is the time to ask.

I will reboot this system in a few hours - waiting for your response.

( this problem took 25 days to reappear - so you might want to get some information ).

I'm an aging assembly programmer - I can do most things from the shell in Debian - I once did a 
little C programming - but digging into this code is beyond me.  On the other had, I am able and 
willing to supply what every I can to help.

Server has:
# uname -a
Linux malaysia 3.2.0-4-amd64 #1 SMP Debian 3.2.46-1 x86_64 GNU/Linux
# wajig list nfs
ii  libnfsidmap2:amd64                    0.25-4                             amd64        NFS 
idmapping library
ii  nfs-common                            1:1.2.6-4                          amd64        NFS 
support files common to client and server
ii  nfs-kernel-server                     1:1.2.6-4                          amd64        support 
for NFS kernel server

Export with loop:
/home/content           192.168.1.0/22(rw,sync,no_root_squash)

-


Client has:
# uname -a
Linux singapore 3.2.0-4-amd64 #1 SMP Debian 3.2.46-1 x86_64 GNU/Linux


# wajig list nfs
ii  libnfsidmap2:amd64                     0.25-4                             amd64        NFS 
idmapping library
ii  nfs-common                             1:1.2.6-4                          amd64        NFS 
support files common to client and server

fstab mount with loop:
malaysia:/home/content       /mnt/content    nfs     defaults,rsize=8192,wsize=8192,intr 0 0





--------------------------------------------------------------------------------
Karl Schmidt                                  EMail Karl@xtronics.com
Transtronics, Inc.                              WEB http://secure.transtronics.com
3209 West 9th Street                             Ph (785) 841-3089
Lawrence, KS 66049                              FAX (785) 841-0434

Wrapping people up in the symbols of success when they are unearned, is very destructive. kps

--------------------------------------------------------------------------------
