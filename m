Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f172.google.com ([209.85.220.172]:57847 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756073AbaGVQkk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 12:40:40 -0400
Received: by mail-vc0-f172.google.com with SMTP id im17so15024239vcb.31
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 09:40:36 -0700 (PDT)
MIME-Version: 1.0
From: Jeff Terrace <jterrace@gmail.com>
Date: Tue, 22 Jul 2014 09:40:16 -0700
Message-ID: <CAC-XtuMBuis6ssSd0gjdU541YPhkJK+1aD-HfqY5oO-fh2YiMA@mail.gmail.com>
Subject: sync mount option not applied to subdirectories
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using kernel 3.8.0-28-generic on Ubuntu, if I mount the root of my
server with the sync option:

  mount -o vers=4,sync,sec=none -t nfs 192.168.1.198:/ /mnt/self

it gets applied properly:

  $ cat /proc/mounts | grep nfs
  192.168.1.198:/ /mnt/self nfs4
rw,sync,relatime,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=null,clientaddr=192.168.1.198,local_lock=none,addr=192.168.1.198
0 0

but if I try to mount a subdirectory:

  mount -o vers=4,sync,sec=none -t nfs 192.168.1.198:/js.js /mnt/self

the sync option is lost:

  $ cat /proc/mounts | grep nfs
  192.168.1.198:/js.js /mnt/self nfs4
rw,relatime,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=null,clientaddr=192.168.1.198,local_lock=none,addr=192.168.1.198
0 0

If I mount the subdirectory with the noac option, which implies sync:

  mount -o vers=4,noac,sec=none -t nfs 192.168.1.198:/js.js /mnt/self

then the sync option gets applied:

  $ cat /proc/mounts | grep nfs
  192.168.1.198:/js.js /mnt/self nfs4
rw,sync,relatime,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,noac,proto=tcp,port=0,timeo=600,retrans=2,sec=null,clientaddr=192.168.1.198,local_lock=none,addr=192.168.1.198
0 0

The same subdirectory mount command using 2.6.32 on CentOS correctly
applies the sync option. Running the mount command with -vvv doesn't
show anything suspect. Is this a regression bug? Any idea what's going
on here?

Thanks,
Jeff
