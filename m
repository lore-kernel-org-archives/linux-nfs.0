Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:31508 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756201Ab2GQSJ6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jul 2012 14:09:58 -0400
Subject: Re: [PATCH 15/15] NFS: Slow down state manager after an unhandled error
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1342548381.2646.11.camel@lade.trondhjem.org>
Date: Tue, 17 Jul 2012 14:09:53 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <C7BB89A0-1DBA-4ED6-8D6A-ED3B74E08906@oracle.com>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net> <20120711203151.3767.79006.stgit@degas.1015granger.net> <1342548381.2646.11.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 17, 2012, at 2:06 PM, Myklebust, Trond wrote:

> On Wed, 2012-07-11 at 16:31 -0400, Chuck Lever wrote:
>> If the state manager thread is not actually able to fully recover from
>> some situation, it wakes up waiters, who kick off a new state manager
>> thread.  Quite often the fresh invocation of the state manager is just
>> as successful.
>> 
>> This results in a livelock as the client dumps thousands of NFS
>> requests a second on the network in a vain attempt to recover.  Not
>> very friendly.
>> 
>> To mitigate this situation, add a delay in the state manager after
>> an unhandled error, so that the client sends just a few requests
>> every second in this case.
> 
> 
> I assume that this was intended to have a s-o-b line?

Yes.  Actually it was submitted mainly for discussion, which is why the S-O-B was accidentally omitted.  But if you feel it is appropriate for mainline now, I'm happy to see it merged.

> 
>> ---
>> 
>> fs/nfs/nfs4state.c |    1 +
>> 1 files changed, 1 insertions(+), 0 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 5e3bebc..38959eb 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -2151,6 +2151,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
>> out_error:
>> 	pr_warn_ratelimited("NFS: state manager failed on NFSv4 server %s"
>> 			" with error %d\n", clp->cl_hostname, -status);
>> +	ssleep(1);
>> 	nfs4_end_drain_session(clp);
>> 	nfs4_clear_state_manager_bit(clp);
>> }
>> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




