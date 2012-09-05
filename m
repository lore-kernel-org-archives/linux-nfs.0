Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16215 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469Ab2IEOCw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Sep 2012 10:02:52 -0400
Message-ID: <50475B77.7090304@redhat.com>
Date: Wed, 05 Sep 2012 17:02:31 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Andrew Holway <a.holway@syseleven.de>,
        "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
        "libvir-list@redhat.com" <libvir-list@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS over RDMA small block DIRECT_IO bug
References: <F416961E-A33A-44D3-A788-5EF598A0AAFE@syseleven.de> <4FA345DA4F4AE44899BD2B03EEEC2FA908F82C6C@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F82C6C@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/04/2012 03:04 PM, Myklebust, Trond wrote:
> On Tue, 2012-09-04 at 11:31 +0200, Andrew Holway wrote:
>> Hello.
>> 
>> # Avi Kivity avi(a)redhat recommended I copy kvm in on this. It would also seem relevent to libvirt. #
>> 
>> I have a Centos 6.2 server and Centos 6.2 client.
>> 
>> [root@store ~]# cat /etc/exports 
>> /dev/shm				10.149.0.0/16(rw,fsid=1,no_root_squash,insecure)    (I have tried with non tempfs targets also)
>> 
>> 
>> [root@node001 ~]# cat /etc/fstab 
>> store.ibnet:/dev/shm             /mnt                 nfs          rdma,port=2050,defaults 0 0
>> 
>> 
>> I wrote a little for loop one liner that dd'd the centos net install image to a file called 'hello' then checksummed that file. Each iteration uses a different block size.
>> 
>> Non DIRECT_IO seems to work fine. DIRECT_IO with 512byte, 1K and 2K block sizes get corrupted.
> 
> 
> That is expected behaviour. DIRECT_IO over RDMA needs to be page aligned
> so that it can use the more efficient RDMA READ and RDMA WRITE memory
> semantics (instead of the SEND/RECEIVE channel semantics).

Shouldn't subpage requests fail then?  O_DIRECT block requests fail for
subsector writes, instead of corrupting your data.

Hopefully this is documented somewhere.

-- 
error compiling committee.c: too many arguments to function
