Return-Path: linux-nfs-owner@vger.kernel.org
Received: from kms.syseleven.de ([176.74.58.26]:53888 "EHLO kms.syseleven.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752855Ab2IFKOv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Sep 2012 06:14:51 -0400
Subject: Re: NFS over RDMA small block DIRECT_IO bug
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Andrew Holway <a.holway@syseleven.de>
In-Reply-To: <50475B77.7090304@redhat.com>
Date: Thu, 6 Sep 2012 12:14:41 +0200
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
        "libvir-list@redhat.com" <libvir-list@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <6F777077-D7FC-4F51-8806-C89A5F973DFA@syseleven.de>
References: <F416961E-A33A-44D3-A788-5EF598A0AAFE@syseleven.de> <4FA345DA4F4AE44899BD2B03EEEC2FA908F82C6C@SACEXCMBX04-PRD.hq.netapp.com> <50475B77.7090304@redhat.com>
To: Avi Kivity <avi@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 5, 2012, at 4:02 PM, Avi Kivity wrote:

> On 09/04/2012 03:04 PM, Myklebust, Trond wrote:
>> On Tue, 2012-09-04 at 11:31 +0200, Andrew Holway wrote:
>>> Hello.
>>> 
>>> # Avi Kivity avi(a)redhat recommended I copy kvm in on this. It would also seem relevent to libvirt. #
>>> 
>>> I have a Centos 6.2 server and Centos 6.2 client.
>>> 
>>> [root@store ~]# cat /etc/exports 
>>> /dev/shm				10.149.0.0/16(rw,fsid=1,no_root_squash,insecure)    (I have tried with non tempfs targets also)
>>> 
>>> 
>>> [root@node001 ~]# cat /etc/fstab 
>>> store.ibnet:/dev/shm             /mnt                 nfs          rdma,port=2050,defaults 0 0
>>> 
>>> 
>>> I wrote a little for loop one liner that dd'd the centos net install image to a file called 'hello' then checksummed that file. Each iteration uses a different block size.
>>> 
>>> Non DIRECT_IO seems to work fine. DIRECT_IO with 512byte, 1K and 2K block sizes get corrupted.
>> 
>> 
>> That is expected behaviour. DIRECT_IO over RDMA needs to be page aligned
>> so that it can use the more efficient RDMA READ and RDMA WRITE memory
>> semantics (instead of the SEND/RECEIVE channel semantics).
> 
> Shouldn't subpage requests fail then?  O_DIRECT block requests fail for
> subsector writes, instead of corrupting your data.

But silent data corruption is so much fun!!
