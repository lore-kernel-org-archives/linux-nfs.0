Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29397 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758872Ab2IKRDC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Sep 2012 13:03:02 -0400
Message-ID: <504F6EE9.5070908@RedHat.com>
Date: Tue, 11 Sep 2012 13:03:37 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Andrew Holway <a.holway@syseleven.de>
CC: kvm@vger.kernel.org, libvir-list@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: NFS over RDMA small block DIRECT_IO bug
References: <F416961E-A33A-44D3-A788-5EF598A0AAFE@syseleven.de>
In-Reply-To: <F416961E-A33A-44D3-A788-5EF598A0AAFE@syseleven.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/04/2012 05:31 AM, Andrew Holway wrote:
> Hello.
> 
> # Avi Kivity avi(a)redhat recommended I copy kvm in on this. It would also seem relevent to libvirt. #
> 
> I have a Centos 6.2 server and Centos 6.2 client.
> 
> [root@store ~]# cat /etc/exports 
> /dev/shm				10.149.0.0/16(rw,fsid=1,no_root_squash,insecure)    (I have tried with non tempfs targets also)
> 
> 
> [root@node001 ~]# cat /etc/fstab 
> store.ibnet:/dev/shm             /mnt                 nfs          rdma,port=2050,defaults 0 0
> 
> 
> I wrote a little for loop one liner that dd'd the centos net install image to a file called 'hello' then checksummed that file. Each iteration uses a different block size.
> 
> Non DIRECT_IO seems to work fine. DIRECT_IO with 512byte, 1K and 2K block sizes get corrupted.
> 
> I want to run my KVM guests on top of NFS over RDMA. My guests cannot create filesystems.
> 
> Thanks,
> 
> Andrew.
> 
> bug report: https://bugzilla.linux-nfs.org/show_bug.cgi?id=228
Well it appears the RHEL6 kernels are lacking a couple patches that might
help with this....

5c635e09 RPCRDMA: Fix FRMR registration/invalidate handling.
9b78145c xprtrdma: Remove assumption that each segment is <= PAGE_SIZE

I can only image that Centos 6.2 might me lacking these too... ;-)

steved.
