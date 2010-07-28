Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59858 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751439Ab0G1C3T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Jul 2010 22:29:19 -0400
Message-ID: <4C4F95BC.3060200@cn.fujitsu.com>
Date: Wed, 28 Jul 2010 10:28:12 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: =?UTF-8?B?IkouQS4g77+9Ig==?= <jamagallon@ono.com>
CC: Linux Kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: Questions and problems with NFS4
References: <20100728004611.00c46b13@werewolf.home>
In-Reply-To: <20100728004611.00c46b13@werewolf.home>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> - If you have a common root, is it mandatory to mount it in the client ?
> 
> - If I setup a common root (say /export), and aoutomount some folders:
>   
>   /scratch/local
>   /scratch/node/00
>   /scratch/node/01
>   ......
>   /export/scratch -> /scratch/local (bind mount).
> 
>   /scratch/node/?? is automounted from node ??, in which it is its own
>   /scratch/local. When I acess scratch for local node, it backs to a local
>   mount and mounts the REAL /scratch, not /export/scratch.
>   Any ideas ?
> 

    I'm not sure i have understand your means, is it like this?

    # cat /etc/exports
      /nfsroot	*(fsid=0,insecure,no_root_squash,rw)

    # mkdir -p /nfsroot/nfsroot
    # touch /nfsroot/tstfile
    # service nfs restart
    # mount -t nfs 127.0.0.1:/nfsroot  /mnt

    # ls /mnt <== Here, we access real /nfsroot/nfsroot, not /nfsroot,
                  so we can not find "tstfile", right?

    Actually, when we use "-t nfs", nfs-utils try to mount NFSv4 first,
    if you want use NFSv3, you should use "-t nfs -o vers=3" in the nfs-utils-1.2.2.

> - AFAIK, with NFS4 the only needed daemons are nfsd and idmapd. And the
>   only accesible port from the outside is 2049, for nfsd.
>   I have tried to strip down my nfs server (-N 2 -N 3 -U),
>   but rpcinfo still gives me:
> 

    ... snip ...

>   disabling portampper and mountd is just a matter of initscripts
>   requirements, but how can I disable nlockmgr ? It isn't needed for
>   NFS4, isn't it ? Nor portmapper nor mountd...
> 

    As i see, there's no way to disabe nlockmgr, it's start by lockd,
    and lockd will be up when we start nfsd. It's always work until the
    last nfsd thread stop.

-- 
Best Regards
 Bian Naimeng

