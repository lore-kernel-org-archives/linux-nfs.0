Return-Path: linux-nfs-owner@vger.kernel.org
Received: from kms.syseleven.de ([176.74.58.26]:43765 "EHLO kms.syseleven.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672Ab2ICJBm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2012 05:01:42 -0400
Subject: Re: KVM disk problem with NFS over RDMA
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Andrew Holway <a.holway@syseleven.de>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F7F604@SACEXCMBX04-PRD.hq.netapp.com>
Date: Mon, 3 Sep 2012 11:01:34 +0200
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <585413CA-234C-4F55-9165-D5D1CE5885F0@syseleven.de>
References: <BF836CCD-701A-40F6-B776-01B49742943C@syseleven.de> <4FA345DA4F4AE44899BD2B03EEEC2FA908F7F604@SACEXCMBX04-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 3, 2012, at 1:35 AM, Myklebust, Trond wrote:

> On Sun, 2012-09-02 at 12:46 +0200, Andrew Holway wrote:
>> Hi,
>> 
>> I am trying to host KVM machines on an NFSoRDMA mount.
>> 
>> This works:
>> 
>> -drive file=/mnt/vm001.img,if=none,id=drive-virtio-disk0,format=raw -device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x5,drive=drive-virtio-disk0,id=virtio-disk0
>> 
>> This Doesn't!
>> 
>> -drive file=/mnt/vm001.img,if=none,id=drive-virtio-disk0,format=raw,cache=none -device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x5,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=2
>> 
>> Any ideas why this could be? I have tried various kernel / ofed combinations.
> 
> I'm guessing that the NFSoRDMA code is broken for the case of O_DIRECT,
> and has been for a while. Unfortunately the RDMA code gets little
> testing these days.
> 
> Do all the other 'cache=' options work?

Yes, Writeback cache also works.

When I test writethrough and do lots of heavy DIRECT_IO with iozone this seems to work correctly.

ta

Andrew

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 


