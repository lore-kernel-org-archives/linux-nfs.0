Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bn1bon0080.outbound.protection.outlook.com ([157.56.111.80]:25955
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932875AbbI3U3u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Sep 2015 16:29:50 -0400
Subject: Re: [PATCH v1 00/24] New fast registration API
To: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Sagi Grimberg <sagig@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <560AE099.2080004@sandisk.com> <560AFB71.3010003@dev.mellanox.co.il>
 <560C30F4.50900@sandisk.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <560C42CE.6090000@sandisk.com>
Date: Wed, 30 Sep 2015 13:15:10 -0700
MIME-Version: 1.0
In-Reply-To: <560C30F4.50900@sandisk.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/30/2015 11:59 AM, Bart Van Assche wrote:
> On 09/29/2015 01:58 PM, Sagi Grimberg wrote:
>> On 9/29/2015 10:03 PM, Bart Van Assche wrote:
>>> On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
>>>> - Converted SRP initiator and RDS iwarp ULPs to the new API
>>> How has the converted SRP initiator driver been tested ? With the kernel
>>> tree that is available on branch reg_api.4
>>
>> That's odd. Although I haven't formally submitted reg_api.4 yet, I did
>> test ib_srp initiator against upstream srpt over CX3 (mlx4) and CX4
>> (mlx5). I ran connect, disconnect, stress IO of all block sizes and
>> some unaligned block-IO and SG_IO test utilities. It all seems to pass
>> for me.
>>
>> Just this morning (my morning) I tested the v2 set on iser, srp, nfs. I
>> placed that in branch reg_api.5. Would you mind running reg_api.5 and
>> see if this issue persist (I would be surprised because I haven't seen
>> any sign of it)?
>
> Sorry but I still see these messages with the reg_api.5 branch.
> [root@ib-ini linux-kernel]# git show HEAD | grep ^commit
> commit 3b5b34777d3cd606433f0aca51e3885323648e07
> [root@ib-ini linux-kernel]# uname -a
> Linux ib-ini 4.2.0-rc6-debug+ #1 SMP Wed Sep 30 11:38:36 PDT 2015 x86_64
> x86_64 x86_64 GNU/Linux
>
> I will try to run a bisect.

(replying to my own e-mail)

Apparently this behavior got introduced through the patch "IB/srp: 
Convert to new registration API" (commit 
ad66cbace5ca8c60673bedf35e5027868b0dd2d7). Without that patch SRP I/O 
works fine. With that patch I see receive failures being reported. The 
SRP initiator was loaded on my setup with the following kernel driver 
options:

# cat /etc/modprobe.d/ib_srp.conf
options ib_srp cmd_sg_entries=255 prefer_fr=1 register_always=1

Bart.
