Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:38597 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754571AbbIXNEN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 09:04:13 -0400
Received: by wiclk2 with SMTP id lk2so111838259wic.1
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 06:04:12 -0700 (PDT)
Subject: Re: [PATCH rdma-rc v2 1/4] xprtrdma: Replace global lkey with lkey
 local to PD
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Sagi Grimberg <sagig@mellanox.com>, Doug Ledford <dledford@redhat.com>
References: <1443080064-28760-1-git-send-email-sagig@mellanox.com>
 <1443080064-28760-2-git-send-email-sagig@mellanox.com>
 <5603F34F.3050505@Netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <5603F4C8.5080500@dev.mellanox.co.il>
Date: Thu, 24 Sep 2015 16:04:08 +0300
MIME-Version: 1.0
In-Reply-To: <5603F34F.3050505@Netapp.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/24/2015 3:57 PM, Anna Schumaker wrote:
> Hi Sagi,

Hey Anna,

>
> On 09/24/2015 03:34 AM, Sagi Grimberg wrote:
>> From: Chuck Lever <chuck.lever@oracle.com>
>>
>> The core API has changed so that devices that do not have a global
>> DMA lkey automatically create an mr, per-PD, and make that lkey
>> available. The global DMA lkey interface is going away in favor of
>> the per-PD DMA lkey.
>>
>> The per-PD DMA lkey is always available. Convert xprtrdma to use the
>> device's per-PD DMA lkey for regbufs, no matter which memory
>> registration scheme is in use.
>
> This is going through an RDMA tree somewhere, correct?

Yes, this was from Chuck's 4.4 RFC series. I just included it
in this set as it is related to a driver fix that should go to
4.3-rc.

>  You can add my:
>
> Acked-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Thanks!
