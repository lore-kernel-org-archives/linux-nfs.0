Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linode.aoot.com ([69.164.194.13]:46250 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754550AbbGZUPi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 Jul 2015 16:15:38 -0400
Subject: Re: [PATCH V6 6/9] isert: Rename IO functions to more descriptive
 names
To: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Christoph Hellwig <hch@infradead.org>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161848.25617.26092.stgit@build2.ogc.int>
 <55B4B190.7070305@dev.mellanox.co.il> <20150726104328.GB18944@infradead.org>
 <55B4BDE3.8040801@dev.mellanox.co.il>
 <55B519C6.2030205@opengridcomputing.com>
 <55B51B7A.8030008@dev.mellanox.co.il>
Cc: dledford@redhat.com, infinipath@intel.com, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
From: Steve Wise <swise@opengridcomputing.com>
Message-ID: <55B53FE6.1030509@opengridcomputing.com>
Date: Sun, 26 Jul 2015 15:15:34 -0500
MIME-Version: 1.0
In-Reply-To: <55B51B7A.8030008@dev.mellanox.co.il>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/26/2015 12:40 PM, Sagi Grimberg wrote:
>
>>> Ideally, the post contains a chain of all 4 registrations and the
>>> rdma_read (and an opportunistic good scsi response).
>>
>> Just to be clear: This example is for IB only, correct?  IW would
>> require rkeys with REMOTE_WRITE and 4 read wrs.
>
> My assumption is that it would depend on max_sge_rd.
>

yea.

> IB only? iWARP by definition isn't capable of doing rdma_read to
> more than one scatter? Anyway, we'll need to calculate the number
> of RDMA_READs.
>

The wire protocol limits the destination to a single stg/to/len (aka 
rkey/addr/len).  Devices/fw/sw could implement some magic to support a 
single stg/to/len that maps to a scatter gather list of stags/tos/lens.

>> And you're ignoring invalidation wrs (or read-with-inv) in the 
>> example...
>
> Yes, didn't want to inflate the example too much...

