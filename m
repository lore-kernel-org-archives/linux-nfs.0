From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 4/6] NLM: Clean up nsm_monitor() call
Date: Wed, 3 Dec 2008 16:20:16 -0500
Message-ID: <EB908F53-3AA1-451A-815C-F55EE0F43665@oracle.com>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net> <20081201185757.10600.38854.stgit@ingres.1015granger.net> <20081203210843.GP16846@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:21425 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbYLCVUg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Dec 2008 16:20:36 -0500
In-Reply-To: <20081203210843.GP16846@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 3, 2008, at 4:08 PM, J. Bruce Fields wrote:

> On Mon, Dec 01, 2008 at 01:57:58PM -0500, Chuck Lever wrote:
>> Clean up: A few minor clean-ups for nsm_monitor():
>
> All looks fine, thanks, however:
>
>>
>> o  Make sure to return an error if the SM_MON call result is not  
>> zero.
>
> I'd prefer to have a change in behavior split out into a separate  
> patch
> from pure cleanup.

That's fine.  I will probably end up reposting this series with your  
comments addressed, so I will split this one out.

> --b.
>
>>
>> o  Remove the BUG_ON() -- the code will die anyway if nsm is NULL.
>>
>> o  Use nsm->sm_name instead of host->h_name to be consistent with
>>    other functions in fs/lockd/mon.c.
>>
>> o  Collect the public declaration of nsm_monitor() in lockd.h with
>>    other NSM public function declarations (eg. nsm_release).
>>
>> o  Add documenting comments.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/lockd/mon.c                 |   29 ++++++++++++++++++-----------
>> include/linux/lockd/lockd.h    |    4 ++++
>> include/linux/lockd/sm_inter.h |    1 -
>> 3 files changed, 22 insertions(+), 12 deletions(-)
>>
>> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
>> index a606fbb..78d5f59 100644
>> --- a/fs/lockd/mon.c
>> +++ b/fs/lockd/mon.c
>> @@ -69,18 +69,24 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc,  
>> struct nsm_res *res)
>> 	return status;
>> }
>>
>> -/*
>> - * Set up monitoring of a remote host
>> +/**
>> + * nsm_monitor - Notify a peer in case we reboot
>> + * @host: pointer to nlm_host of peer to notify
>> + *
>> + * If this peer is not already monitored, this function sends an
>> + * upcall to the local rpc.statd to record the name/address of
>> + * the peer to notify in case we reboot.
>> + *
>> + * Returns zero if the peer is monitored by the local rpc.statd;
>> + * otherwise a negative errno value is returned.
>>  */
>> -int
>> -nsm_monitor(struct nlm_host *host)
>> +int nsm_monitor(const struct nlm_host *host)
>> {
>> 	struct nsm_handle *nsm = host->h_nsmhandle;
>> -	struct nsm_res	res;
>> -	int		status;
>> +	struct nsm_res res;
>> +	int status;
>>
>> -	dprintk("lockd: nsm_monitor(%s)\n", host->h_name);
>> -	BUG_ON(nsm == NULL);
>> +	dprintk("lockd: nsm_monitor(%s)\n", nsm->sm_name);
>>
>> 	if (nsm->sm_monitored)
>> 		return 0;
>> @@ -92,9 +98,10 @@ nsm_monitor(struct nlm_host *host)
>> 	nsm->sm_mon_name = nsm_use_hostnames ? nsm->sm_name : nsm- 
>> >sm_addrbuf;
>>
>> 	status = nsm_mon_unmon(nsm, SM_MON, &res);
>> -
>> -	if (status < 0 || res.status != 0)
>> -		printk(KERN_NOTICE "lockd: cannot monitor %s\n", host->h_name);
>> +	if (res.status != 0)
>> +		status = -EIO;
>> +	if (status < 0)
>> +		printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
>> 	else
>> 		nsm->sm_monitored = 1;
>> 	return status;
>> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/ 
>> lockd.h
>> index de9ea7b..4ca6f39 100644
>> --- a/include/linux/lockd/lockd.h
>> +++ b/include/linux/lockd/lockd.h
>> @@ -233,6 +233,10 @@ extern void	  nlm_host_rebooted(const struct  
>> sockaddr_in *, const char *,
>> 					unsigned int, u32);
>> void		  nsm_release(struct nsm_handle *);
>>
>> +/*
>> + * Host monitoring
>> + */
>> +int		  nsm_monitor(const struct nlm_host *host);
>>
>> /*
>>  * This is used in garbage collection and resource reclaim
>> diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/ 
>> sm_inter.h
>> index 5a5448b..546b610 100644
>> --- a/include/linux/lockd/sm_inter.h
>> +++ b/include/linux/lockd/sm_inter.h
>> @@ -41,7 +41,6 @@ struct nsm_res {
>> 	u32		state;
>> };
>>
>> -int		nsm_monitor(struct nlm_host *);
>> int		nsm_unmonitor(struct nlm_host *);
>> extern int	nsm_local_state;
>>
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



