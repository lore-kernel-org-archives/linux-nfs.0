From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/6] NLM: Remove address eye-catcher buffers from nlm_host
Date: Wed, 3 Dec 2008 14:10:03 -0500
Message-ID: <FB2A4E64-7F93-479D-BAE4-A97CCA689ADC@oracle.com>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net> <20081201185734.10600.88841.stgit@ingres.1015granger.net> <20081203190332.GK16846@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:24238 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558AbYLCTKW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Dec 2008 14:10:22 -0500
In-Reply-To: <20081203190332.GK16846@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 3, 2008, at 2:03 PM, J. Bruce Fields wrote:
> On Mon, Dec 01, 2008 at 01:57:34PM -0500, Chuck Lever wrote:
>> The h_name field in struct nlm_host is a just copy of
>> h_nsmhandle->sm_name.  Likewise, the contents of the h_addrbuf field
>> should be identical to the sm_addrbuf field.
>>
>> The h_srcaddrbuf field is used only in one place for debugging.  We  
>> can
>> live without this until we get %pI formatting for printk().
>>
>> Currently these buffers are 48 bytes, but we need to support scope  
>> IDs
>> in IPv6 presentation addresses, which means making the buffers even
>> larger.  Instead, let's find ways to eliminate them to save space.
>>
>> Finally, AF_UNSPEC support is no longer needed in  
>> nlm_display_address()
>> now that it is not used for the h_srcaddr field.
>
> As usual, whenever there's a "finally, ..." or "next, ..." I'd like a
> separate patch.
>
> Though this is distinct enough it's not really a problem to read.   
> Leave
> it as is, OK.

It seemed like a small change (one chunk) and is tightly related to  
what this patch does, so I left it in.

>> @@ -232,11 +229,6 @@ static struct nlm_host *nlm_lookup_host(struct  
>> nlm_lookup_host_info *ni)
>>
>> 	nrhosts++;
>>
>> -	nlm_display_address((struct sockaddr *)&host->h_addr,
>> -				host->h_addrbuf, sizeof(host->h_addrbuf));
>> -	nlm_display_address((struct sockaddr *)&host->h_srcaddr,
>> -				host->h_srcaddrbuf, sizeof(host->h_srcaddrbuf));
>> -
>> 	dprintk("lockd: nlm_lookup_host created host %s\n",
>> 			host->h_name);
>>
>> @@ -378,8 +370,8 @@ nlm_bind_host(struct nlm_host *host)
>> {
>> 	struct rpc_clnt	*clnt;
>>
>> -	dprintk("lockd: nlm_bind_host %s (%s), my addr=%s\n",
>> -			host->h_name, host->h_addrbuf, host->h_srcaddrbuf);
>> +	dprintk("lockd: nlm_bind_host %s (%s)\n",
>> +			host->h_name, host->h_nsmhandle->sm_addrbuf);
>
> Hm, just checking: so the only place I can see h_nsmhandle set NULL is
> in nsm_unmonitor(), which is called only from nlm_destroy_host(),
> shortly before a kfree(host), but before a possible
> rpc_shutdown_client()--and doesn't look like an rpc task could be
> calling rpc_bind_host()?  OK.

nsm_handles live longer than the nlm_hosts that reference them, so  
this shouldn't be a problem.

> And on the creation end, looks like h_nsmhandle is set on host  
> creation.
> So that won't be a NULL deference.  OK, looks fine.  Applied.
>
>
> --b.
>
>>
>> 	/* Lock host handle */
>> 	mutex_lock(&host->h_mutex);
>> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/ 
>> lockd.h
>> index 23da3fa..4467b83 100644
>> --- a/include/linux/lockd/lockd.h
>> +++ b/include/linux/lockd/lockd.h
>> @@ -65,9 +65,6 @@ struct nlm_host {
>> 	struct list_head	h_granted;	/* Locks in GRANTED state */
>> 	struct list_head	h_reclaim;	/* Locks in RECLAIM state */
>> 	struct nsm_handle *	h_nsmhandle;	/* NSM status handle */
>> -
>> -	char			h_addrbuf[48],	/* address eyecatchers */
>> -				h_srcaddrbuf[48];
>> };
>>
>> struct nsm_handle {
>>


--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
