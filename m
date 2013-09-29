Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.4lin.net ([212.224.84.186]:57550 "EHLO mail.4lin.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754213Ab3I2RPy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Sep 2013 13:15:54 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.4lin.net (Postfix) with ESMTP id 20F9F21BA5
	for <linux-nfs@vger.kernel.org>; Sun, 29 Sep 2013 19:07:16 +0200 (CEST)
Received: from mail.4lin.net ([127.0.0.1])
	by localhost (mail.4lin.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id V4CXW1_CJBnX for <linux-nfs@vger.kernel.org>;
	Sun, 29 Sep 2013 19:06:58 +0200 (CEST)
Received: from [192.168.3.34] (ip-84-118-108-47.unity-media.net [84.118.108.47])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.4lin.net (Postfix) with ESMTPSA id 8C735201F5
	for <linux-nfs@vger.kernel.org>; Sun, 29 Sep 2013 19:06:58 +0200 (CEST)
From: Denny Fuchs <linuxmail@4lin.net>
Content-Type: text/plain; charset=us-ascii
Subject: Debian Wheezy: Problems getting quota over NFS4 on live system
Message-Id: <F41A2460-D0B4-4026-8442-607281E90B07@4lin.net>
Date: Sun, 29 Sep 2013 19:06:58 +0200
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi,

I have problems on my live system with getting the quota over NFSv4 on Debian Wheezy systems. On my test environment - Wheezy too - it works.

On my fileserver:

$ LANG="C" quota -u denny
Disk quotas for user denny (uid 14103): 
     Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
/dev/mapper/userdatavg-disc05
                  87796  490000  500000            6043       0       0

Filesystem is Ext4:

$ mount | grep disc05 
/dev/mapper/userdatavg-disc05 on /export/disc05 type ext4 (rw,nodev,noatime,user_xattr,barrier=1,data=ordered,usrquota,grpquota)

/etc/exports:

/export 192.168.1.0/24(ro,no_subtree_check,fsid=0,)
/export/disc05 192.168.1.0/24(root_squash,async,no_subtree_check,rw)

# rpcinfo -p localhost
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  44745  nlockmgr
    100021    3   udp  44745  nlockmgr
    100021    4   udp  44745  nlockmgr
    100021    1   tcp  35417  nlockmgr
    100021    3   tcp  35417  nlockmgr
    100021    4   tcp  35417  nlockmgr
    100011    1   udp    726  rquotad
    100011    2   udp    726  rquotad
    100011    1   tcp    727  rquotad
    100011    2   tcp    727  rquotad
    100024    1   udp  46773  status
    100024    1   tcp  59135  status
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    2   tcp   2049
    100227    3   tcp   2049
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    2   udp   2049
    100227    3   udp   2049
    100005    1   udp  59020  mountd
    100005    1   tcp  57777  mountd
    100005    2   udp  57300  mountd
    100005    2   tcp  33704  mountd
    100005    3   udp  55339  mountd
    100005    3   tcp  49912  mountd


$ ps ax | grep -E '(rpc|nfs)'
 3802 ?        Ss     0:01 /sbin/rpcbind -w
 3839 ?        S<     0:00 [rpciod]
 3896 ?        S<     0:00 [nfsiod]
13018 ?        S      0:00 [nfsv4.0-svc]
14543 ?        Ss     0:00 /usr/sbin/rpc.rquotad -S
21590 ?        Ss     0:00 /sbin/rpc.statd
27405 ?        Ss     0:00 /usr/sbin/rpc.idmapd
27516 ?        S<     0:00 [nfsd4]
27517 ?        S<     0:00 [nfsd4_callbacks]
27518 ?        S      0:00 [nfsd]
27519 ?        S      0:00 [nfsd]
27520 ?        S      0:00 [nfsd]
27521 ?        S      0:00 [nfsd]
27522 ?        S      0:00 [nfsd]
27523 ?        S      0:00 [nfsd]
27524 ?        S      0:00 [nfsd]
27525 ?        S      0:00 [nfsd]
27530 ?        Ss     0:00 /usr/sbin/rpc.mountd --manage-gids

>From the client:


# rpcinfo -p files
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  44745  nlockmgr
    100021    3   udp  44745  nlockmgr
    100021    4   udp  44745  nlockmgr
    100021    1   tcp  35417  nlockmgr
    100021    3   tcp  35417  nlockmgr
    100021    4   tcp  35417  nlockmgr
    100011    1   udp    726  rquotad
    100011    2   udp    726  rquotad
    100011    1   tcp    727  rquotad
    100011    2   tcp    727  rquotad
    100024    1   udp  46773  status
    100024    1   tcp  59135  status
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    2   tcp   2049
    100227    3   tcp   2049
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    2   udp   2049
    100227    3   udp   2049
    100005    1   udp  59020  mountd
    100005    1   tcp  57777  mountd
    100005    2   udp  57300  mountd
    100005    2   tcp  33704  mountd
    100005    3   udp  55339  mountd
    100005    3   tcp  49912  mountd


$ mount | grep disc05:

files:/disc05 on /mnt type nfs4 (rw,relatime,vers=4,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.1.10,minorversion=0,local_lock=none,addr=192.168.1.1)

$ quota -u denny
<empty return>

$ quota -u denny -v -F rpc
<empty return>

the very strange thing: I have also a test environment (Wheezy too, one client, one fileserver)  system, both with identical settings ( I think and checked) and it works, as expected.

Very frustration :-/

Any suggestions?


cu denny



