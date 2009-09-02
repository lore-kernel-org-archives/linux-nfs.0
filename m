From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1 v2] nfs41: pass state recovery error back to caller
Date: Thu, 03 Sep 2009 00:04:38 +0300
Message-ID: <4A9EDDE6.1090308@panasas.com>
References: <1251877725-12113-1-git-send-email-bhalevy@panasas.com>	 <1251913960.26601.41.camel@heimdal.trondhjem.org>	 <4A9EB433.6070506@panasas.com> <1251918574.26601.48.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-67.z220-152-67.customer.algx.net ([67.152.220.67]:60650
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751314AbZIBVEk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 17:04:40 -0400
In-Reply-To: <1251918574.26601.48.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 02, 2009, 22:09 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Wed, 2009-09-02 at 21:06 +0300, Benny Halevy wrote:
>> On Sep. 02, 2009, 20:52 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
>>> On Wed, 2009-09-02 at 10:48 +0300, Benny Halevy wrote:
>>>> Currently the error returned from create_session
>>>> is ignored by nfs4_check_client_ready and mis-translated to
>>>> -EPROTONOSUPPORT if the client has a session.
>>>> Record the error returned from create_session to the state manager
>>>> in cl_cons_state via nfs_mark_client_ready and pass it upstream
>>>> in nfs4_recover_expired_lease.
>>>>
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> ---
>>> Firstly, if you're out to save 4 bytes by sharing storage with an object
>>> of an entirely different type, then please use an explicit union. Then
>>> use a special state NFS4CLNT_LEASE_RECLAIM_FAILED in order to clearly
>>> label what is being stored in that union.
>>>
>> OK.  Just to make sure, will it be acceptable by you to add a field
>> to struct nfs_client to explicitly keep this status or would you prefer to
>> save these 4 bytes using the union and extra state?
> 
> For one thing, I'd like to know why we need to pass these errors up the
> stack. Normally, the state manager is supposed to be able to handle all
> recovery issues.
>

The error case I'd like to fix is that of the server returning an error
on OP_PUROOTFH.

In the nfsv4 case we get the error correctly on this path:
nfs4_create_server
nfs4_path_walk
nfs4_get_root: getroot error = 2

The error in this case is returned via the regular rpc path
and the state engine is not really involved.

However, in the nfsv4.1 case, the failure is different:
nfs4_create_server()
nfs4_init_session()
nfs4_recover_expired_lease()
	nfs4_schedule_state_recovery()
		# and the failure happens within the state engine
		nfs4_proc_create_session()
		nfs4_proc_get_lease_time() return -2


So, the reason I wanted to pass the status out of the
state engine is to return it from nfs4_recover_expired_lease
to nfs4_init_session and back to nfs4_create_server.

It might be possible to avoid this if we separate out
the lease time initialization

>>> Secondly, I'd say that it is more natural to share storage with the
>>> client id, cl_ex_clid, rather than using the lease time. The latter is
>>> read via an entirely separate RPC call _after_ you are done establishing
>>> the lease and the first session.
>>>
>> I (ab?)used cl_lease_time for this reason as nobody cares about its
>> value at the session establishment phase.
> 
> Are you able to guarantee that no other threads can race with the lease
> time RPC call?
> 

Hmm, good point.
If another thread runs the state manager on the same struct nfs_client
it might clear clp->cl_lease_time, but it does that after
atomically clearing NFS4CLNT_LEASE_EXPIRED in clp->cl_state.

Reversing the order and checking for a negative cl_lease_time
would have done a safer job (though not absolutely thread safe
and presuming cl_lease_time cannot normally be negative)...
		ret = clp->cl_lease_time;
		if (ret < 0 &&
		    test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
			break;

Benny
