Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:41376 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbaD3Utu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2014 16:49:50 -0400
Message-ID: <536161D0.3000600@oracle.com>
Date: Wed, 30 Apr 2014 13:49:20 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Or Gerlitz <or.gerlitz@gmail.com>, Chuck Lever <chuck.lever@oracle.com>
CC: Jeff Becker <jeffrey.c.becker@nasa.gov>,
        "<yanb@mellanox.com>" <yanb@mellanox.com>,
        "Cayton, Phil" <phil.cayton@intel.com>,
        "Coulter, Susan K" <skc@lanl.gov>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "<Devesh.Sharma@emulex.com>" <Devesh.Sharma@emulex.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Allen Andrews <Allen.Andrews@emulex.com>,
        Jeff Layton <jlayton@redhat.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "<emossman@iol.unh.edu>" <emossman@iol.unh.edu>
Subject: Re: NFSoRDMA developers bi-weekly meeting announcement (4/30)
References: <53614C03.80606@oracle.com>	<CAJZOPZJioYdcbDGsk7278sZS7kD9W1dcGEGtYfsFk=Mm7DW3fQ@mail.gmail.com>	<BBF761A6-2407-4457-92D5-8C2EC736BC9D@oracle.com> <CAJZOPZJgp-QdxR+PmwACWOSc4h_167J0iBjfmMrPX8sek600WA@mail.gmail.com>
In-Reply-To: <CAJZOPZJgp-QdxR+PmwACWOSc4h_167J0iBjfmMrPX8sek600WA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/30/2014 01:00 PM, Or Gerlitz wrote:
> On Wed, Apr 30, 2014 at 10:47 PM, Chuck Lever <chuck.lever@oracle.com>
>
>> If I understood Yan, he is trying to use NFS/RDMA in guests (kvm?).  We
>> are pretty sure that is not working at the moment,
> can you provide a short 1-2 liner why/what is broken there? the only
> thing which I can think of to be not-supported over mlx4 VFs is the
> proprietary FMRs, but AFAIK, the nfs-rdma code doesn't even have a
> mode which uses them, right?
I've created Xen guest on DomU. Dom0 PF works which has no mtts been 
enabled, however DomU I hit this problem by just mounting the file system:
mlx4_core 0000:00:04.0: Failed to allocate mtts for 66 pages(order 7)
mlx4_core 0000:00:04.0: Failed to allocate mtts for 4096 pages(order 12)
mlx4_core 0000:00:04.0: Failed to allocate mtts for 4096 pages(order 12)

RDMA microbenchmark perftest works ok. I enabled mtts scripts when 
booting the Xen guest. cat /proc/mtrr:

[root@ca-nfsdev1vm1 log]# cat /proc/mtrr
reg00: base=0x0f0000000 ( 3840MB), size=  128MB, count=1: uncachable
reg01: base=0x0f8000000 ( 3968MB), size=   64MB, count=1: uncachable

lspci -v
00:04.0 InfiniBand: Mellanox Technologies MT25400 Family [ConnectX-2 
Virtual Function] (rev b0)
     Subsystem: Mellanox Technologies Device 61b0
     Physical Slot: 4
     Flags: bus master, fast devsel, latency 0
     Memory at f0000000 (64-bit, prefetchable) [size=128M]
     Capabilities: [60] Express Endpoint, MSI 00
     Capabilities: [9c] MSI-X: Enable+ Count=4 Masked-
     Kernel driver in use: mlx4_core
     Kernel modules: mlx4_core

I will need to find another machine to try KVM guest. Yan might hit a 
different problem.

I have ConnectX-2, FW level is 2.11.2012. Yan has ConnectX-3, he tried 
it on KVM guest.
>> but that is a priority
>> to get fixed. Shirley has a lab set up and has been looking into it.
Shirley
