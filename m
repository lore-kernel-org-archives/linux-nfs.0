Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42199 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932657AbdIFPMH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Sep 2017 11:12:07 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <6dcdcc25-2613-cdb5-1db2-6c944f05242b@grimberg.me>
Date: Wed, 6 Sep 2017 11:11:44 -0400
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4E2E5580-69A5-4C3B-9FCA-E61AE2042E6B@oracle.com>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net> <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me> <890CC58C-7F8F-4B7E-8620-21F07007D3AA@oracle.com> <6dcdcc25-2613-cdb5-1db2-6c944f05242b@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 6, 2017, at 10:29 AM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> 
>>> Question, what happens in direct-io for example? Can a mapped buffer be
>>> reclaimed/free'd before the send completion arrives?
>> Good Q! RPC completion allows memory containing the arguments and
>> results to be re-used. IIRC our conclusion was that a retransmitted
>> Send could expose the wrong argument data on the wire in this case.
>> Buffer re-use implies that the RPC has completed. Either a matching
>> RPC Reply was received, or the RPC was terminated via a POSIX signal.
>> If the client has already received an RPC Reply for this transaction,
>> a previous transmission of the RPC Call has already executed on the
>> server, and this retransmission will be ignored. It's only purpose is
>> to generate an appropriate RDMA ACK.
>> A re-used buffer might be subsequently used for data that is sensitive,
>> and the retransmission will expose that data on the wire.
> 
> That was where I was going with this...
> 
>> To protect
>> against that, RPC can use a GSS flavor that protects confidentiality
>> of RPC arguments and results. This would also require RPC-over-RDMA
>> to use only RDMA Read to convey RPC Call messages. Send would be used
>> only to convey the chunk lists, never data.
>> Note that the buffers used to construct RPC Calls are always mapped
>> and Send uses the local DMA key to post them. These can also be
>> re-used immediately after RPC completion. The exposure risk there is
>> of RPC headers and non-data arguments.
> 
> I see, but how can the user know that that it needs to use RPCSEC_GSS
> otherwise nfs/rdma might compromise sensitive data? And is this
> a valid constraint? (just asking, you're the expert)

sec=krb5p is used in cases where data on the wire must remain
confidential. Otherwise, sensitive or no, data on the wire goes
in the clear.

But an administrator might not expect that other sensitive data
on the client (not involved with NFS) can be placed on the wire
by the vagaries of memory allocation and hardware retransmission,
as exceptionally rare as that might be.

Memory in which Send data resides is donated to the device until
the Send completion fires: the ULP has no way to get it back in
the meantime. ULPs can invalidate memory used for RDMA Read at
any time, but Send memory is registered with the local DMA key
(as anything else is just as expensive as an RDMA data transfer).

The immediate solution is to never use Send to move file data
directly. It will always have to be copied into a buffer or
we use RDMA Read. These buffers contain only data that is
destined for the wire. Does that close the unwanted exposure
completely?

If the HCA can guarantee that all Sends complete quickly (either
successful, flush, or time out after a few seconds) then it could
be fair to make RPC completion also wait for Send completion.
Otherwise, a ^C on a file operation targeting an unreachable
server will hang indefinitely.


--
Chuck Lever



