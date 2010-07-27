Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp13.ono.com ([62.42.230.16]:59357 "EHLO resmaa13.ono.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751518Ab0G0WvQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Jul 2010 18:51:16 -0400
Date: Wed, 28 Jul 2010 00:46:11 +0200
From: "J.A. =?ISO-8859-1?B?TWFnYWxs824=?=" <jamagallon@ono.com>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Questions and problems with NFS4
Message-ID: <20100728004611.00c46b13@werewolf.home>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all...

I'm beginning to move my boxen to use nfs4, and have some questions...

First of all, versions of my software: kernel 2.6.33.5, nfs-utils 1.2.2
(perhaps some of my doubts are solved in newer versions)

Questions:

- Is it mandatory to use a setup with a common root for exported filesystems ?
  In my setup I first did not use it, no fsid=0 root, and everything
  worked fine, just change the mount type in the clients. In fact, new
  nfs-utils just try first version 4 and you dont have to do anything.
  You loose the ability to use simple paths inside /export, for example, 
  and have to use full paths like in V3, but that is not so bad.
  Am I loosing something else wrt functionality ?

- If you have a common root, is it mandatory to mount it in the client ?

- If I setup a common root (say /export), and aoutomount some folders:
  
  /scratch/local
  /scratch/node/00
  /scratch/node/01
  ......
  /export/scratch -> /scratch/local (bind mount).

  /scratch/node/?? is automounted from node ??, in which it is its own
  /scratch/local. When I acess scratch for local node, it backs to a local
  mount and mounts the REAL /scratch, not /export/scratch.
  Any ideas ?

- AFAIK, with NFS4 the only needed daemons are nfsd and idmapd. And the
  only accesible port from the outside is 2049, for nfsd.
  I have tried to strip down my nfs server (-N 2 -N 3 -U),
  but rpcinfo still gives me:

annwn:~# rpcinfo -p localhost
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  48461  status
    100024    1   tcp  37515  status
    100021    1   udp  38583  nlockmgr
    100021    3   udp  38583  nlockmgr
    100021    4   udp  38583  nlockmgr
    100021    1   tcp  37873  nlockmgr
    100021    3   tcp  37873  nlockmgr
    100021    4   tcp  37873  nlockmgr
    100003    4   tcp   2049  nfs
    100005    1   udp  45341  mountd
    100005    1   tcp  58639  mountd

  disabling portampper and mountd is just a matter of initscripts
  requirements, but how can I disable nlockmgr ? It isn't needed for
  NFS4, isn't it ? Nor portmapper nor mountd...

TIA

--
J.A. Magallon <jamagallon()ono!com>     \               Software is like sex:
                                         \         It's better when it's free
