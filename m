From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/6] NSM: Support IPv6 version of mon_name
Date: Wed, 3 Dec 2008 16:24:38 -0500
Message-ID: <DFF74C20-CCD9-4BCC-A22E-5D05B4E6E3CD@oracle.com>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net> <20081201185749.10600.38468.stgit@ingres.1015granger.net> <20081203210150.GO16846@fieldses.org> <CB4FD195-83F5-4C5A-BF38-29FC93871E17@oracle.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:19096 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbYLCVZA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Dec 2008 16:25:00 -0500
In-Reply-To: <CB4FD195-83F5-4C5A-BF38-29FC93871E17@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 3, 2008, at 4:19 PM, Chuck Lever wrote:

> On Dec 3, 2008, at 4:01 PM, J. Bruce Fields wrote:
>> On Mon, Dec 01, 2008 at 01:57:50PM -0500, Chuck Lever wrote:
>>> The "mon_name" argument of the NSMPROC_MON and NSMPROC_UNMON upcalls
>>> is a string that contains the hostname or IP address of the remote  
>>> peer
>>> to be notified when this host has rebooted.  The sm-notify command  
>>> uses
>>> this identifier to contact the peer when we reboot, so it must be
>>> either a well-qualified DNS hostname or a presentation format IP
>>> address string.
>>>
>>> When the "nsm_use_hostnames" sysctl is set to zero, the kernel's NSM
>>> provides a presentation format IP address in the "mon_name"  
>>> argument.
>>> Otherwise, the "caller_name" argument from NLM requests is used,
>>> which is usually just the DNS hostname of the peer.
>>>
>>> To support IPv6 addresses for the mon_name argument, we use the
>>> nsm_handle's address eye-catcher, which already contains an  
>>> appropriate
>>> presentation format address string.  Using the eye-catcher string
>>> obviates the need to use a large buffer on the stack to form the
>>> presentation address string for the upcall.
>>>
>>> This patch also addresses a subtle bug.
>>>
>>> An NSMPROC_MON request and the subsequent NSMPROC_UNMON request  
>>> for the
>>> same peer are required to use the same value for the "mon_name"
>>> argument.  Otherwise, rpc.statd's NSMPROC_UNMON processing cannot
>>> locate the database entry for that peer and remove it.
>>
>> At some point we need to grep for each read of nsm_use_hostnames and
>> think about what would happen if it changed there.
>>
>> For example, the check of nsm_use_hostnames when searching for a  
>> match
>> in nsm_find() could cause a spurious failure to find a host.  If the
>> nsm_find() came from nlm_host_rebooted(), we could fail to release  
>> locks
>> from some dead host.
>
> Agreed.  A subsequent patch in this series removes that particular  
> use of nsm_use_hostnames.  An audit of the other use(s) is a good  
> future work item.

I'll clarify: a subsequent patch in my for-2.6.29 series that I  
haven't posted yet removes that use of nsm_use_hostnames.

>> Probably we should just forbid changing nsm_use_hostnames while the
>> server is running or an nfs filesystem is mounted.  Or, if that's not
>> possible, allow changing the sysctl at any time, but only actually  
>> look
>> at it (and store it) once on server startup or first mount (whichever
>> comes first).
>
> Actually, "when lockd comes up" might be an appropriate moment to  
> copy the value of this variable.
>
>> As this requires a root user doing something wrong,
>
> Or a bug in rpc.statd or sm-notify...
>
>> fixing this bug
>> probably isn't high priority enough to block the rest of the ipv6
>> patches, so we could make a note of the problem and move on for now.
>>
>> --b.
>>
>>> If the setting of nsm_use_hostnames is changed between the time the
>>> kernel sends an NSMPROC_MON request and the time it sends the
>>> NSMPROC_UNMON request for the same peer, the "mon_name" argument for
>>> these two requests may not be the same.  This is because the value  
>>> of
>>> "mon_name" is currently chosen at the moment the call is made  
>>> based on
>>> the setting of nsm_use_hostnames
>>>
>>> To ensure both requests pass identical contents in the "mon_name"
>>> argument, we now select which string to use for the argument in the
>>> nsm_monitor() function.  A pointer to this string is saved in the
>>> nsm_handle so it can be used for the subsequent NSMPROC_UNMON  
>>> upcall.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> fs/lockd/mon.c              |   45 ++++++++++++++++ 
>>> +--------------------------
>>> include/linux/lockd/lockd.h |    1 +
>>> 2 files changed, 19 insertions(+), 27 deletions(-)
>>>
>>> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
>>> index 4e7e958..a606fbb 100644
>>> --- a/fs/lockd/mon.c
>>> +++ b/fs/lockd/mon.c
>>> @@ -18,8 +18,6 @@
>>>
>>> #define NLMDBG_FACILITY		NLMDBG_MONITOR
>>>
>>> -#define XDR_ADDRBUF_LEN		(20)
>>> -
>>> static struct rpc_clnt *	nsm_create(void);
>>>
>>> static struct rpc_program	nsm_program;
>>> @@ -37,7 +35,13 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc,  
>>> struct nsm_res *res)
>>> {
>>> 	struct rpc_clnt	*clnt;
>>> 	int		status;
>>> -	struct nsm_args	args;
>>> +	struct nsm_args args = {
>>> +		.addr		= nsm_addr_in(nsm)->sin_addr.s_addr,
>>> +		.prog		= NLM_PROGRAM,
>>> +		.vers		= 3,
>>> +		.proc		= NLMPROC_NSM_NOTIFY,
>>> +		.mon_name	= nsm->sm_mon_name,
>>> +	};
>>> 	struct rpc_message msg = {
>>> 		.rpc_argp	= &args,
>>> 		.rpc_resp	= res,
>>> @@ -46,22 +50,18 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32  
>>> proc, struct nsm_res *res)
>>> 	clnt = nsm_create();
>>> 	if (IS_ERR(clnt)) {
>>> 		status = PTR_ERR(clnt);
>>> +		dprintk("lockd: failed to create NSM upcall transport, "
>>> +				"status=%d\n", status);
>>> 		goto out;
>>> 	}
>>>
>>> -	memset(&args, 0, sizeof(args));
>>> -	args.mon_name = nsm->sm_name;
>>> -	args.addr = nsm_addr_in(nsm)->sin_addr.s_addr;
>>> -	args.prog = NLM_PROGRAM;
>>> -	args.vers = 3;
>>> -	args.proc = NLMPROC_NSM_NOTIFY;
>>> 	memset(res, 0, sizeof(*res));
>>>
>>> 	msg.rpc_proc = &clnt->cl_procinfo[proc];
>>> 	status = rpc_call_sync(clnt, &msg, 0);
>>> 	if (status < 0)
>>> -		printk(KERN_DEBUG "nsm_mon_unmon: rpc failed, status=%d\n",
>>> -			status);
>>> +		dprintk("lockd: NSM upcall RPC failed, status=%d\n",
>>> +				status);
>>> 	else
>>> 		status = 0;
>>> 	rpc_shutdown_client(clnt);
>>> @@ -85,6 +85,12 @@ nsm_monitor(struct nlm_host *host)
>>> 	if (nsm->sm_monitored)
>>> 		return 0;
>>>
>>> +	/*
>>> +	 * Choose whether to record the caller_name or IP address of
>>> +	 * this peer in the local rpc.statd's database.
>>> +	 */
>>> +	nsm->sm_mon_name = nsm_use_hostnames ? nsm->sm_name : nsm- 
>>> >sm_addrbuf;
>>> +
>>> 	status = nsm_mon_unmon(nsm, SM_MON, &res);
>>>
>>> 	if (status < 0 || res.status != 0)
>>> @@ -165,25 +171,10 @@ static __be32 *xdr_encode_nsm_string(__be32  
>>> *p, char *string)
>>>
>>> /*
>>> * "mon_name" specifies the host to be monitored.
>>> - *
>>> - * Linux uses a text version of the IP address of the remote
>>> - * host as the host identifier (the "mon_name" argument).
>>> - *
>>> - * Linux statd always looks up the canonical hostname first for
>>> - * whatever remote hostname it receives, so this works alright.
>>> */
>>> static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
>>> {
>>> -	char	buffer[XDR_ADDRBUF_LEN + 1];
>>> -	char	*name = argp->mon_name;
>>> -
>>> -	if (!nsm_use_hostnames) {
>>> -		snprintf(buffer, XDR_ADDRBUF_LEN,
>>> -			 NIPQUAD_FMT, NIPQUAD(argp->addr));
>>> -		name = buffer;
>>> -	}
>>> -
>>> -	return xdr_encode_nsm_string(p, name);
>>> +	return xdr_encode_nsm_string(p, argp->mon_name);
>>> }
>>>
>>> /*
>>> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/ 
>>> lockd.h
>>> index 307a8f0..de9ea7b 100644
>>> --- a/include/linux/lockd/lockd.h
>>> +++ b/include/linux/lockd/lockd.h
>>> @@ -73,6 +73,7 @@ struct nsm_handle {
>>> 	char *			sm_name;
>>> 	struct sockaddr_storage	sm_addr;
>>> 	size_t			sm_addrlen;
>>> +	char *			sm_mon_name;
>>> 	unsigned int		sm_monitored : 1,
>>> 				sm_sticky : 1;	/* don't unmonitor */
>>> 	char			sm_addrbuf[63];	/* presentation address */
>>>
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



