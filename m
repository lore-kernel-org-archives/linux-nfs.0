Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:50331 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753579Ab1DONCm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Apr 2011 09:02:42 -0400
Date: Fri, 15 Apr 2011 08:59:41 -0400
To: "Hiroyuki Sato" <hiroysato@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [Q] NFS IPoIB , NFS/RDMA which is fast??
From: sfaibish <sfaibish@emc.com>
Content-Type: text/plain; format=flowed; delsp=yes; charset=utf-8
References: <BANLkTimnmqpEkggdBaJkX2xmdscSB2Yz7Q@mail.gmail.com>
Message-ID: <op.vtzc1rteunckof@usensfaibisl2e.eng.emc.com>
In-Reply-To: <BANLkTimnmqpEkggdBaJkX2xmdscSB2Yz7Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 15 Apr 2011 05:54:45 -0400, Hiroyuki Sato <hiroysato@gmail.com>  
wrote:

> Dear members.
>
> I'm measuring the performance NFS on IPoIB and NFS/RDMA.
> I would like to ask the following questions.
>
> 1) Benchmark result.
>
>   Does anyone tryied this benchmark??
>   If so , could you please tell me that result??
>
>  2) My test result and What is problem??
>
>   I compared that. Please see my test result at below.
>
>   I extpected NFS/RDMA faster than NFS IPoIB.
>   However, NFS/RDMA is slower than NFS IPoIB.
>   Expecially rsize,wsize larger equal 32768
>
>   Could you please what is problelm ??
>
> Thank you for your information.
>
>
> 1, Environment
First impression is that your IB switch is not configured to
support NFS/RDMA. In which case of course IPoIB is faster as
it can get all the BW from the switch.

>
>   (1) Server
>     CentOS 5.5 x86_64
>     Kernel: 2.36.8.2 (self build)
>     OFED: any kernel modules does not use.
>       Only startup script and nfs-utils used
>       from OFED-1.5.3
>     Memory: 8GB
>     HCA: Mellanox InfiniHost III Ex.
>
>
>   (2) Client
>     CentOS 5.5 x86_64
>     Kernel: 2.36.8.2 (self build)
>     OFED: any kernel modules does not use.
>       Only startup script and nfs-utils used.
>       from OFED-1.5.3
>     Memory: 8GB
>     HCA: Mellanox InfiniHost III Ex.
>
>
>   Client and Server connected directly with Infiniband CX4 cable.
>
>
> 2, Configurations
>
>   (1) NFS/RDMA
>
>     1-1) Server exports (/etc/exports)
>       /dev/shm	192.168.100.0/255.255.255.0(rw,no_root_squash,insecure,fsid=0,sync)
>
>     1-2) Client mount
>       mount.rnfs 192.168.100.231:/dev/shm /mnt -i -o
> rdma,port=20049,rsize=32768,wsize=32768,sync,rw
>
>   (2) IPoIB
>
>     2-1) Server exports(/etc/exports)
>       /dev/shm	192.168.100.0/255.255.255.0(rw,no_root_squash,insecure,fsid=0,sync)
>
>     2-2) Client mount
>       mount -t nfs  -o nfsvers=3,rsize=32768,wsize=32768,tcp,sync,rw
> 192.168.100.231:/dev/shm /mnt
>
>
> 3, test result
>
>   Please see attachement file. for more information.
>
>   Summary:
>    1GB write bs=(64MB) :
>       NFS IPoIB : 661.499MB/sec
>       NFS/RDMA  : 512.513MB/sec
>
>    1GB read bs=(64MB) :
>       NFS IPoIB : 592.250MB/sec
>       NFS/RDMA  : 1.353MB/sec ( very slow )
>
> 4, about test tool
>
>   This tool based on  blockdev-perftest which is included in SCST.
>
>   this tool is using fio benchmark tool internally.
>
>   I modified this script for file system,
>
>
>   This command execute fio like the follwoing
>
>      fio --rw=write # (and read)\
>       --directory=/mnt/fio-testing \
>       --bs=XXX \
>       --size=1073741824 \
>       --ioengine=psync \
>       --end_fsync=1 \
>       --invalidate=1 \
>       --direct=1 \
>       --name=writeperftest
>
>     XXX is
>
>       67108864
>       33554432
>       16777216
>       8388608
>       ...
>       ...
>
> Sincerely
>
> --
> Hiroyuki Sato.



-- 
Best Regards

Sorin Faibish
Corporate Distinguished Engineer
Unified Storage Division
         EMC²
where information lives

Phone: 508-249-5745
Cellphone: 617-510-0422
Email : sfaibish@emc.com
