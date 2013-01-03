Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33866 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753074Ab3ACOmf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2013 09:42:35 -0500
Message-ID: <50E598B9.4000109@RedHat.com>
Date: Thu, 03 Jan 2013 09:42:01 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?UTF-8?B?UGF3ZcWCIFNpa29yYQ==?= <pawel.sikora@agmk.net>
CC: linux-nfs@vger.kernel.org, baggins@pld-linux.org,
        Trond.Myklebust@netapp.com
Subject: Re: mount.nfs: cannot allocate memory.
References: <2891788.0SBnrhN2VX@pawels>
In-Reply-To: <2891788.0SBnrhN2VX@pawels>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/01/13 04:27, Paweł Sikora wrote:
> Hi,
> 
> with the latest nfs-1.2.7/kernel-3.7.1 tools i've noticed an error during autofs mounting.
> reduced testcase shows that mount.nfs with 'vers=4' has a problem:
> 
> [root@chufu ~]# mount.nfs -v -o vers=4 192.168.2.100:/home/atest/farm-local /mnt
> mount.nfs: timeout set for Thu Jan  3 10:22:00 2013
> mount.nfs: trying text-based options 'vers=4,addr=192.168.2.100,clientaddr=192.168.2.103'
> mount.nfs: mount(2): Cannot allocate memory
> mount.nfs: Cannot allocate memory
> 
> while the vers=3 works fine:
> 
> [root@chufu ~]# mount.nfs -v -o vers=3 192.168.2.100:/home/atest/farm-local /mnt
> mount.nfs: timeout set for Thu Jan  3 10:22:04 2013
> mount.nfs: trying text-based options 'vers=3,addr=192.168.2.100'
> mount.nfs: prog 100003, trying vers=3, prot=6
> mount.nfs: trying 192.168.2.100 prog 100003 vers 3 prot TCP port 2049
> mount.nfs: prog 100005, trying vers=3, prot=17
> mount.nfs: trying 192.168.2.100 prog 100005 vers 3 prot UDP port 42412
> 
> no obvious errors in logs on nfs server/client side :(
> i can provide more info if you need to diagnose this issue.

Please set the kernel debugging with 'rpcdebug -m nfs -s mount' then post the out put found in /var/log/messages.

steved.

