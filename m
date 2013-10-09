Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55980 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136Ab3JIVua (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Oct 2013 17:50:30 -0400
Date: Wed, 9 Oct 2013 17:50:29 -0400
To: Denny Fuchs <linuxmail@4lin.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Debian Wheezy: Problems getting quota over NFS4 on live system
Message-ID: <20131009215028.GC23877@fieldses.org>
References: <F41A2460-D0B4-4026-8442-607281E90B07@4lin.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F41A2460-D0B4-4026-8442-607281E90B07@4lin.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 29, 2013 at 07:06:58PM +0200, Denny Fuchs wrote:
> hi,
> 
> I have problems on my live system with getting the quota over NFSv4 on Debian Wheezy systems. On my test environment - Wheezy too - it works.
> 
> On my fileserver:
> 
> $ LANG="C" quota -u denny
> Disk quotas for user denny (uid 14103): 
>      Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
> /dev/mapper/userdatavg-disc05
>                   87796  490000  500000            6043       0       0
> 
> Filesystem is Ext4:
> 
> $ mount | grep disc05 
> /dev/mapper/userdatavg-disc05 on /export/disc05 type ext4 (rw,nodev,noatime,user_xattr,barrier=1,data=ordered,usrquota,grpquota)
> 
> /etc/exports:
> 
> /export 192.168.1.0/24(ro,no_subtree_check,fsid=0,)
> /export/disc05 192.168.1.0/24(root_squash,async,no_subtree_check,rw)

The fsid=0 messes up the export paths, so that v2/v3 (and quota) clients
see /export/disc05 while v4 clients see /disc05.

Just drop the fsid=0 and mount /export/disc05, and everything should
work.

The fsid=0 stuff was needed on earlier kernels and nfs-utils, but with
anything recent (wheezy will do), you can just leave it off and v4 will
work just like v2/v3.


Long term nfsv4 may need its own quota extension instead of continuing
to depend on the extra sideband protocol.

--b.

> 
> # rpcinfo -p localhost
>    program vers proto   port  service
>     100000    4   tcp    111  portmapper
>     100000    3   tcp    111  portmapper
>     100000    2   tcp    111  portmapper
>     100000    4   udp    111  portmapper
>     100000    3   udp    111  portmapper
>     100000    2   udp    111  portmapper
>     100021    1   udp  44745  nlockmgr
>     100021    3   udp  44745  nlockmgr
>     100021    4   udp  44745  nlockmgr
>     100021    1   tcp  35417  nlockmgr
>     100021    3   tcp  35417  nlockmgr
>     100021    4   tcp  35417  nlockmgr
>     100011    1   udp    726  rquotad
>     100011    2   udp    726  rquotad
>     100011    1   tcp    727  rquotad
>     100011    2   tcp    727  rquotad
>     100024    1   udp  46773  status
>     100024    1   tcp  59135  status
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100003    4   tcp   2049  nfs
>     100227    2   tcp   2049
>     100227    3   tcp   2049
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100003    4   udp   2049  nfs
>     100227    2   udp   2049
>     100227    3   udp   2049
>     100005    1   udp  59020  mountd
>     100005    1   tcp  57777  mountd
>     100005    2   udp  57300  mountd
>     100005    2   tcp  33704  mountd
>     100005    3   udp  55339  mountd
>     100005    3   tcp  49912  mountd
> 
> 
> $ ps ax | grep -E '(rpc|nfs)'
>  3802 ?        Ss     0:01 /sbin/rpcbind -w
>  3839 ?        S<     0:00 [rpciod]
>  3896 ?        S<     0:00 [nfsiod]
> 13018 ?        S      0:00 [nfsv4.0-svc]
> 14543 ?        Ss     0:00 /usr/sbin/rpc.rquotad -S
> 21590 ?        Ss     0:00 /sbin/rpc.statd
> 27405 ?        Ss     0:00 /usr/sbin/rpc.idmapd
> 27516 ?        S<     0:00 [nfsd4]
> 27517 ?        S<     0:00 [nfsd4_callbacks]
> 27518 ?        S      0:00 [nfsd]
> 27519 ?        S      0:00 [nfsd]
> 27520 ?        S      0:00 [nfsd]
> 27521 ?        S      0:00 [nfsd]
> 27522 ?        S      0:00 [nfsd]
> 27523 ?        S      0:00 [nfsd]
> 27524 ?        S      0:00 [nfsd]
> 27525 ?        S      0:00 [nfsd]
> 27530 ?        Ss     0:00 /usr/sbin/rpc.mountd --manage-gids
> 
> >From the client:
> 
> 
> # rpcinfo -p files
>    program vers proto   port  service
>     100000    4   tcp    111  portmapper
>     100000    3   tcp    111  portmapper
>     100000    2   tcp    111  portmapper
>     100000    4   udp    111  portmapper
>     100000    3   udp    111  portmapper
>     100000    2   udp    111  portmapper
>     100021    1   udp  44745  nlockmgr
>     100021    3   udp  44745  nlockmgr
>     100021    4   udp  44745  nlockmgr
>     100021    1   tcp  35417  nlockmgr
>     100021    3   tcp  35417  nlockmgr
>     100021    4   tcp  35417  nlockmgr
>     100011    1   udp    726  rquotad
>     100011    2   udp    726  rquotad
>     100011    1   tcp    727  rquotad
>     100011    2   tcp    727  rquotad
>     100024    1   udp  46773  status
>     100024    1   tcp  59135  status
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100003    4   tcp   2049  nfs
>     100227    2   tcp   2049
>     100227    3   tcp   2049
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100003    4   udp   2049  nfs
>     100227    2   udp   2049
>     100227    3   udp   2049
>     100005    1   udp  59020  mountd
>     100005    1   tcp  57777  mountd
>     100005    2   udp  57300  mountd
>     100005    2   tcp  33704  mountd
>     100005    3   udp  55339  mountd
>     100005    3   tcp  49912  mountd
> 
> 
> $ mount | grep disc05:
> 
> files:/disc05 on /mnt type nfs4 (rw,relatime,vers=4,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.1.10,minorversion=0,local_lock=none,addr=192.168.1.1)
> 
> $ quota -u denny
> <empty return>
> 
> $ quota -u denny -v -F rpc
> <empty return>
> 
> the very strange thing: I have also a test environment (Wheezy too, one client, one fileserver)  system, both with identical settings ( I think and checked) and it works, as expected.
> 
> Very frustration :-/
> 
> Any suggestions?
> 
> 
> cu denny
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
