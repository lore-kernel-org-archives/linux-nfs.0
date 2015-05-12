Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:33502 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbbELKCA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 May 2015 06:02:00 -0400
Received: by wgin8 with SMTP id n8so3119388wgi.0
        for <linux-nfs@vger.kernel.org>; Tue, 12 May 2015 03:01:59 -0700 (PDT)
Message-ID: <5551CF93.4070501@dev.mellanox.co.il>
Date: Tue, 12 May 2015 13:01:55 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: "Hefty, Sean" <sean.hefty@intel.com>, Chuck Lever <chuck.lever@oracle.com>
CC: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 04/14] xprtrdma: Use ib_device pointer safely
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175720.3483.80356.stgit@manet.1015granger.net> <554B37CF.2070206@dev.mellanox.co.il> <E1ADA91B-45DA-46B6-A114-E2600613969A@oracle.com> <554B6F2A.6000608@dev.mellanox.co.il> <BDE22240-DC37-4C54-B71E-D88EF54D3119@oracle.com> <554B80B7.8090900@dev.mellanox.co.il> <1828884A29C6694DAF28B7E6B8A82373A8FCE01F@ORSMSX109.amr.corp.intel.com>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FCE01F@ORSMSX109.amr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/11/2015 9:26 PM, Hefty, Sean wrote:
>>> ia->ri_device is never updated. The only place it is set is in
>>> rpcrdma_ia_open().
>>
>> So you assume that each ri_id that you will recreate contains the
>> same device handle?
>>
>> I think that for ADDR_CHANGE event when the slave belongs to another
>> device you will hit a mismatch. CC'ing Sean for more info...
>
> I'm not familiar with the xprtrdma code.  From the perspective of the rdma_cm, if a listen is associated with a specific IP address, then it will also be associated with a specific device.  If an address change occurs, and the address moves to another device, then the app is essentially left with an unusable listen.  Received connection requests will not find a matching listen and be dropped.
>
> If the address moves ports on the same device, then I think this works out fine in the case where the app ignores the ADDR_CHANGE event.
>
>>> It might be saner to construct a virtual ib_device in this
>>> case that consumers can depend on.
>>
>> I'm not sure how does a virtual ib_device can work - that goes
>> to the verbs themselves... Seems like a layering mis-match to me...
>
> I interpreted Chuck as asking for some lower-level way of handling this, so that all ULPs don't need to re-implement this.

It's not really a re-implementation, address resolution attaches the
the ib device. The assumption that for the same address the same ib
device will be attached is wrong for bonding over more than one device.

It's just something that rdma_cm user needs to be aware of if/when
trying to cache the device handle.

> I agree that this would be hard (impossible?) without ULPs operating at a slightly higher level of abstraction.
> Maybe the rdma_cm could be extended for this purpose, for example, by exposing its own devices, which either map directly to a verbs device, or handle a virtual mapping.

I guess it can be done, but it will require port all the ULPs to
use some sort of abstraction layer. Something that I'm not very 
enthusiastic about...

Sagi.

