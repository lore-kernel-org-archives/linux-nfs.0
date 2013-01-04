Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.agmk.net ([91.192.224.71]:49524 "EHLO mail.agmk.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752360Ab3ADFRF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2013 00:17:05 -0500
From: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, baggins@pld-linux.org,
        Trond.Myklebust@netapp.com
Subject: Re: mount.nfs: cannot allocate memory.
Date: Fri, 04 Jan 2013 06:16:58 +0100
Message-ID: <14289664.zy0he5HnEB@localhost>
In-Reply-To: <50E598B9.4000109@RedHat.com>
References: <2891788.0SBnrhN2VX@pawels> <50E598B9.4000109@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday 03 of January 2013 09:42:01 Steve Dickson wrote:
> 
> On 03/01/13 04:27, Paweł Sikora wrote:
> > Hi,
> > 
> > with the latest nfs-1.2.7/kernel-3.7.1 tools i've noticed an error during autofs mounting.
> > reduced testcase shows that mount.nfs with 'vers=4' has a problem:
> > 
> > [root@chufu ~]# mount.nfs -v -o vers=4 192.168.2.100:/home/atest/farm-local /mnt
> > mount.nfs: timeout set for Thu Jan  3 10:22:00 2013
> > mount.nfs: trying text-based options 'vers=4,addr=192.168.2.100,clientaddr=192.168.2.103'
> > mount.nfs: mount(2): Cannot allocate memory
> > mount.nfs: Cannot allocate memory
> > 
> > while the vers=3 works fine:
> > 
> > [root@chufu ~]# mount.nfs -v -o vers=3 192.168.2.100:/home/atest/farm-local /mnt
> > mount.nfs: timeout set for Thu Jan  3 10:22:04 2013
> > mount.nfs: trying text-based options 'vers=3,addr=192.168.2.100'
> > mount.nfs: prog 100003, trying vers=3, prot=6
> > mount.nfs: trying 192.168.2.100 prog 100003 vers 3 prot TCP port 2049
> > mount.nfs: prog 100005, trying vers=3, prot=17
> > mount.nfs: trying 192.168.2.100 prog 100005 vers 3 prot UDP port 42412
> > 
> > no obvious errors in logs on nfs server/client side :(
> > i can provide more info if you need to diagnose this issue.
> 
> Please set the kernel debugging with 'rpcdebug -m nfs -s mount' then post the out put found in /var/log/messages.
>

rpcdebug can't find the /proc/sys/sunrpc/nfs_debug file in my system. how can i enable it?

