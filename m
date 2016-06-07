Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25476 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162332AbcFGVJ5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 17:09:57 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 09/20] xprtrdma: Limit the number of rpcrdma_mws
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160607204941.GA7991@obsidianresearch.com>
Date: Tue, 7 Jun 2016 17:09:47 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F1820E16-A2BF-4529-A5C9-59C9AD57369A@oracle.com>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net> <20160607194732.18401.71941.stgit@manet.1015granger.net> <20160607204941.GA7991@obsidianresearch.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 7, 2016, at 4:49 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
> 
> On Tue, Jun 07, 2016 at 03:47:32PM -0400, Chuck Lever wrote:
>> The fixed part of an R_key is 24 bits, but the variant part is only
>> 8 bits, allowing 256 unique R_keys concurrenly in flight on one QP.
>> 
>> Thus an rpcrdma_xprt cannot use more than 256 rpcrdma_mws at a time.
>> 
>> Capping the number of rpcrdma_mws should prevent ro_map from
>> re-using an R_key, which could change the MR co-ordinates or access
>> settings while an RPC is still in progress. It also reduces the
>> number of pre-allocated FRMRs per transport, allowing more
>> transports per device.
>> 
>> To get more R_keys in flight at once, additional QPs will be
>> necessary.
> 
> ??
> 
> The 24 bit / 8 bit thing doesn't create new MRs, it just disambiguates
> the life cycle of a single MR.

Right.


> Further, the MR is connected to a PD,
> not a QP, there is no such thing as '256 unique R_keys concurrenly in
> flight on one QP' ???

OK, fair enough, but...


> This is why no ULP has ever needed this constant before:
> 
>> +enum {
>> +	RPCRDMA_RKEYS_PER_QP	= 256
>> +};
> 
> Because you never need to care when working with FRMRs.
> 
> Either the number in queue is limited by the invalidation
> synchronization point to 2, or in the case of iwarp read, it doesn't
> matter since everything executes serially in order and the value can
> safely wrap.

I don't understand this. How does invalidation prevent
the ULP from registering more R_keys?

And, I'd like to limit the number of pre-allocated MRs
to no more than each transport endpoint can use. For
xprtrdma, a transport is one QP and PD. What is that
number?

--
Chuck Lever



