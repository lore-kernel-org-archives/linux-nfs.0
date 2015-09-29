Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36146 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338AbbI2U63 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Sep 2015 16:58:29 -0400
Received: by wicgb1 with SMTP id gb1so167102613wic.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2015 13:58:28 -0700 (PDT)
Subject: Re: [PATCH v1 00/24] New fast registration API
To: Bart Van Assche <bart.vanassche@sandisk.com>,
        Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <560AE099.2080004@sandisk.com>
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <560AFB71.3010003@dev.mellanox.co.il>
Date: Tue, 29 Sep 2015 23:58:25 +0300
MIME-Version: 1.0
In-Reply-To: <560AE099.2080004@sandisk.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/29/2015 10:03 PM, Bart Van Assche wrote:
> On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
>> - Converted SRP initiator and RDS iwarp ULPs to the new API
>
> Hello Sagi,
>

Hi Bart,

> How has the converted SRP initiator driver been tested ? With the kernel
> tree that is available on branch reg_api.4

That's odd. Although I haven't formally submitted reg_api.4 yet, I did
test ib_srp initiator against upstream srpt over CX3 (mlx4) and CX4
(mlx5). I ran connect, disconnect, stress IO of all block sizes and
some unaligned block-IO and SG_IO test utilities. It all seems to pass
for me.

Just this morning (my morning) I tested the v2 set on iser, srp, nfs. I
placed that in branch reg_api.5. Would you mind running reg_api.5 and 
see if this issue persist (I would be surprised because I haven't seen
any sign of it)?

Thanks,
Sagi.
