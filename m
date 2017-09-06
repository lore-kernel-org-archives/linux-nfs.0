Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37103 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932263AbdIFPXV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Sep 2017 11:23:21 -0400
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
 <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me>
 <890CC58C-7F8F-4B7E-8620-21F07007D3AA@oracle.com>
 <6dcdcc25-2613-cdb5-1db2-6c944f05242b@grimberg.me>
 <4E2E5580-69A5-4C3B-9FCA-E61AE2042E6B@oracle.com>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <9059315f-1985-042e-a59f-26a66fbece3e@grimberg.me>
Date: Wed, 6 Sep 2017 18:23:18 +0300
MIME-Version: 1.0
In-Reply-To: <4E2E5580-69A5-4C3B-9FCA-E61AE2042E6B@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> I see, but how can the user know that that it needs to use RPCSEC_GSS
>> otherwise nfs/rdma might compromise sensitive data? And is this
>> a valid constraint? (just asking, you're the expert)
> 
> sec=krb5p is used in cases where data on the wire must remain
> confidential. Otherwise, sensitive or no, data on the wire goes
> in the clear.
> 
> But an administrator might not expect that other sensitive data
> on the client (not involved with NFS) can be placed on the wire
> by the vagaries of memory allocation and hardware retransmission,
> as exceptionally rare as that might be.
> 
> Memory in which Send data resides is donated to the device until
> the Send completion fires: the ULP has no way to get it back in
> the meantime. ULPs can invalidate memory used for RDMA Read at
> any time, but Send memory is registered with the local DMA key
> (as anything else is just as expensive as an RDMA data transfer).
> 
> The immediate solution is to never use Send to move file data
> directly. It will always have to be copied into a buffer or
> we use RDMA Read. These buffers contain only data that is
> destined for the wire. Does that close the unwanted exposure
> completely?

It would, but is that a smaller sacrifice than signaling
send completions for small writes?

> If the HCA can guarantee that all Sends complete quickly (either
> successful, flush, or time out after a few seconds) then it could
> be fair to make RPC completion also wait for Send completion.
> Otherwise, a ^C on a file operation targeting an unreachable
> server will hang indefinitely.

You could set retry_count=0/1 which will fail with zero or one
send retries (a matter of seconds), but that would make the qp go to
error state which is probably not what we want...
