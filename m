From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 6/6] NSM: Serialize SM_MON and SM_UNMON upcalls
Date: Wed, 3 Dec 2008 19:38:07 -0500
Message-ID: <F8B221DF-53B9-4F2C-B547-C6F556436B74@oracle.com>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net> <20081201185812.10600.92501.stgit@ingres.1015granger.net> <20081203214142.GS16846@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:52012 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbYLDAi0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Dec 2008 19:38:26 -0500
In-Reply-To: <20081203214142.GS16846@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 3, 2008, at Dec 3, 2008, 4:41 PM, J. Bruce Fields wrote:
> On Mon, Dec 01, 2008 at 01:58:13PM -0500, Chuck Lever wrote:
>> The Linux NSM implementation currently does nothing to prevent
>> concurrent SM_MON and SM_UNMON upcalls regarding the same peer.   
>> Races
>> could cause duplicate SM_MON upcalls for the same peer, or locking
>> activity during server shutdown might cause SM_MON and SM_UNMON  
>> upcalls
>> to occur in an arbitrary order.
>>
>> To avoid confusing rpc.statd, add a per-nsm_handle mutex to serialize
>> the upcalls.  To prevent duplicate upcalls, the mutex is held while  
>> the
>> upcall is outstanding, and is not released until we can tell if the
>> upcall succeeded.
>>
>> The nsm_monitor() function is called frequently.  The extra inline
>> function mitigates the overhead of taking the mutex.  It is only  
>> taken
>> if the nsm_handle is not already monitored.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ...
>> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/ 
>> lockd.h
>> index e2fa968..bf6c1c1 100644
>> --- a/include/linux/lockd/lockd.h
>> +++ b/include/linux/lockd/lockd.h
>> @@ -76,6 +76,7 @@ struct nsm_handle {
>> 	char *			sm_mon_name;
>> 	unsigned int		sm_monitored : 1,
>> 				sm_sticky : 1;	/* don't unmonitor */
>> +	struct mutex		sm_mutex;
>> 	char			sm_addrbuf[63];	/* presentation address */
>> };
>>
>> @@ -236,9 +237,18 @@ void		  nsm_release(struct nsm_handle *);
>> /*
>>  * Host monitoring
>>  */
>> -int		  nsm_monitor(const struct nlm_host *host);
>> +int		  __nsm_monitor(struct nsm_handle *nsm);
>> void		  nsm_unmonitor(struct nsm_handle *nsm);
>>
>> +static inline int nsm_monitor(const struct nlm_host *host)
>> +{
>> +	struct nsm_handle *nsm = host->h_nsmhandle;
>> +
>> +	if (likely(nsm->sm_monitored))
>> +		return 0;
>
> We also need to grep for places where sm_monitored is cleared, and
> think about what happens in a race between one of those cases and
> __nsm_monitor().

It's cleared in nlm_host_rebooted(), and in nsm_unmonitor().

The nlm_host_mutex already provides much the same serialization that  
is added in this patch, and at least on the server, nlm_lookup_host()  
and nlm_destroy_host() both run under the BKL.

The problem (if there is one) is really in nlm_host_rebooted(), which  
this patch does nothing about.

Let's drop this one for now.  I think there is a way to get rpc.statd  
to report duplicates instead of ignoring them as it does now.  We  
should get an idea of how pervasive this problem really is.

> --b.
>
>> +	return __nsm_monitor(nsm);
>> +}
>> +
>> /*
>>  * This is used in garbage collection and resource reclaim
>>  * A return value != 0 means destroy the lock/block/share
>>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




