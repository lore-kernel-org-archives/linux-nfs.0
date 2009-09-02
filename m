From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1 v2] nfs41: pass state recovery error back to caller
Date: Wed, 02 Sep 2009 21:06:43 +0300
Message-ID: <4A9EB433.6070506@panasas.com>
References: <1251877725-12113-1-git-send-email-bhalevy@panasas.com> <1251913960.26601.41.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-67.z220-152-67.customer.algx.net ([67.152.220.67]:19255
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751326AbZIBSGn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 14:06:43 -0400
In-Reply-To: <1251913960.26601.41.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 02, 2009, 20:52 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Wed, 2009-09-02 at 10:48 +0300, Benny Halevy wrote:
>> Currently the error returned from create_session
>> is ignored by nfs4_check_client_ready and mis-translated to
>> -EPROTONOSUPPORT if the client has a session.
>> Record the error returned from create_session to the state manager
>> in cl_cons_state via nfs_mark_client_ready and pass it upstream
>> in nfs4_recover_expired_lease.
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
> 
> Firstly, if you're out to save 4 bytes by sharing storage with an object
> of an entirely different type, then please use an explicit union. Then
> use a special state NFS4CLNT_LEASE_RECLAIM_FAILED in order to clearly
> label what is being stored in that union.
> 

OK.  Just to make sure, will it be acceptable by you to add a field
to struct nfs_client to explicitly keep this status or would you prefer to
save these 4 bytes using the union and extra state?

> Secondly, I'd say that it is more natural to share storage with the
> client id, cl_ex_clid, rather than using the lease time. The latter is
> read via an entirely separate RPC call _after_ you are done establishing
> the lease and the first session.
> 

I (ab?)used cl_lease_time for this reason as nobody cares about its
value at the session establishment phase.

(cl_ex_clid is defined under #ifdef CONFIG_NFS_V4_1
so using it for this purpose will be cumbersome...)

Benny
