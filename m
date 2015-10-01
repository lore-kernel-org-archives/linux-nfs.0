Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:33360 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755336AbbJAHQP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Oct 2015 03:16:15 -0400
Received: by wiclk2 with SMTP id lk2so18821927wic.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Oct 2015 00:16:14 -0700 (PDT)
Subject: Re: [PATCH v1 00/24] New fast registration API
To: Bart Van Assche <bart.vanassche@sandisk.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <560AE099.2080004@sandisk.com> <560AFB71.3010003@dev.mellanox.co.il>
 <560C30F4.50900@sandisk.com> <560C42CE.6090000@sandisk.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <560CDDBC.8000400@dev.mellanox.co.il>
Date: Thu, 1 Oct 2015 10:16:12 +0300
MIME-Version: 1.0
In-Reply-To: <560C42CE.6090000@sandisk.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>>> Just this morning (my morning) I tested the v2 set on iser, srp, nfs. I
>>> placed that in branch reg_api.5. Would you mind running reg_api.5 and
>>> see if this issue persist (I would be surprised because I haven't seen
>>> any sign of it)?
>>
>> Sorry but I still see these messages with the reg_api.5 branch.
>> [root@ib-ini linux-kernel]# git show HEAD | grep ^commit
>> commit 3b5b34777d3cd606433f0aca51e3885323648e07
>> [root@ib-ini linux-kernel]# uname -a
>> Linux ib-ini 4.2.0-rc6-debug+ #1 SMP Wed Sep 30 11:38:36 PDT 2015 x86_64
>> x86_64 x86_64 GNU/Linux
>>
>> I will try to run a bisect.
>
> (replying to my own e-mail)
>
> Apparently this behavior got introduced through the patch "IB/srp:
> Convert to new registration API" (commit
> ad66cbace5ca8c60673bedf35e5027868b0dd2d7). Without that patch SRP I/O
> works fine. With that patch I see receive failures being reported. The
> SRP initiator was loaded on my setup with the following kernel driver
> options:
>
> # cat /etc/modprobe.d/ib_srp.conf
> options ib_srp cmd_sg_entries=255 prefer_fr=1 register_always=1

Strange. I don't see that.

options ib_srp prefer_fr=1 register_always=1 are set by default.

When I try to connect srp initiator against upstream srpt with
cmd_sg_entries=255 I get CM reject on iu max size:
kernel: scsi host17: ib_srp: REJ received
kernel: scsi host17: ib_srp: SRP_LOGIN_REJ: requested max_it_iu_len too 
large
kernel: scsi host17: ib_srp: Connection 0/8 failed
kernel: scsi host17: ib_srp: Sending CM DREQ failed

When I connect with cmd_sg_entries=128 I successfully connect:
kernel: scsi host18: SRP.T10:F452140300117400
kernel: scsi 18:0:0:0: Direct-Access     LIO-ORG  RAMDISK-MCP      4.0 
PQ: 0 ANSI: 5
kernel: scsi host18: ib_srp: new target: id_ext f452140300117400 
ioc_guid f452140300117400 pkey ffff service_id f452140300117400 sgid 
fe80:0000:0000:0000:f452:1403:0011:7411 dgid 
fe80:0000:0000:0000:f452:1403:0011:7401
kernel: sd 18:0:0:0: [sdy] 20480 512-byte logical blocks: (10.4 MB/10.0 MiB)
kernel: sd 18:0:0:0: [sdy] Write Protect is off
kernel: sd 18:0:0:0: [sdy] Mode Sense: 43 00 00 08
kernel: sd 18:0:0:0: [sdy] Write cache: disabled, read cache: enabled, 
doesn't support DPO or FUA
kernel: sd 18:0:0:0: [sdy] Attached SCSI disk

I wander what is the difference between our test environments? I can't
look into this if I'm not able to reproduce.

Sagi.

