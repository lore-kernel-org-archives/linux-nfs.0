Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linode.aoot.com ([69.164.194.13]:53018 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755199AbbGZSC7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 Jul 2015 14:02:59 -0400
Subject: Re: [PATCH V6 6/9] isert: Rename IO functions to more descriptive
 names
To: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Christoph Hellwig <hch@infradead.org>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161848.25617.26092.stgit@build2.ogc.int>
 <55B4B190.7070305@dev.mellanox.co.il> <20150726104328.GB18944@infradead.org>
 <55B4BDE3.8040801@dev.mellanox.co.il>
Cc: dledford@redhat.com, infinipath@intel.com, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
From: Steve Wise <swise@opengridcomputing.com>
Message-ID: <55B519C6.2030205@opengridcomputing.com>
Date: Sun, 26 Jul 2015 12:32:54 -0500
MIME-Version: 1.0
In-Reply-To: <55B4BDE3.8040801@dev.mellanox.co.il>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/26/2015 6:00 AM, Sagi Grimberg wrote:
> On 7/26/2015 1:43 PM, Christoph Hellwig wrote:
>> On Sun, Jul 26, 2015 at 01:08:16PM +0300, Sagi Grimberg wrote:
>>> I've given this some thought and I think we should avoid splitting
>>> logic from PI and iWARP. The reason (other than code duplication) is
>>> that currently the iser target support only up to 1MB IOs. I have some
>>> code (not done yet) to support larger IOs by using multiple
>>> registrations  per IO (with or without PI).
>>
>> Just curious: How is this going to work with iSER only having a single
>> rkey/offset/len field?
>>
>
> Good question,
>
> On the wire iser sends a single rkey, but the target is allowed to
> transfer the data however it wants to.
>
> Say that the local target HCA supports only 32 pages (128K bytes for 4K
> pages) registration and the initiator sent:
> rkey=0x1234
> address=0xffffaaaa
> length=512K
>
> The target would allocate a 512K buffer and:
> register offset 0-128K to lkey=0x1
> register offset 128K-256K to lkey=0x2
> register offset 256K-384K to lkey=0x3
> register offset 384K-512K to lkey=0x4
>
> then constructs sg_list as:
> sg_list[0] = {addr=buf, length=128K, lkey=0x1}
> sg_list[1] = {addr=buf+128K, length=128K, lkey=0x2}
> sg_list[2] = {addr=buf+256K, length=128K, lkey=0x3}
> sg_list[3] = {addr=buf+384K, length=128K, lkey=0x4}
>
> Then set rdma_read wr with:
> rdma_r_wr.sg_list=&sg_list
> rdma_r_wr.rdma.addr=0xffffaaaa
> rdma_r_wr.rdma.rkey=0x1234
>
> post_send(rdma_r_wr);
>
> Ideally, the post contains a chain of all 4 registrations and the
> rdma_read (and an opportunistic good scsi response).

Just to be clear: This example is for IB only, correct?  IW would 
require rkeys with REMOTE_WRITE and 4 read wrs.  And you're ignoring 
invalidation wrs (or read-with-inv) in the example...

