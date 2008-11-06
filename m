From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 12/12] lockd: remove redundant rpc_shutdown_client()
Date: Thu, 6 Nov 2008 17:21:05 -0500
Message-ID: <FDDB1A79-8267-4255-B4A2-3CF6C3D09C4F@oracle.com>
References: <1225915611-2401-4-git-send-email-bfields@citi.umich.edu> <1225915611-2401-5-git-send-email-bfields@citi.umich.edu> <1225915611-2401-6-git-send-email-bfields@citi.umich.edu> <1225915611-2401-7-git-send-email-bfields@citi.umich.edu> <1225915611-2401-8-git-send-email-bfields@citi.umich.edu> <1225915611-2401-9-git-send-email-bfields@citi.umich.edu> <1225915611-2401-10-git-send-email-bfields@citi.umich.edu> <1225915611-2401-11-git-send-email-bfields@citi.umich.edu> <1225915611-2401-12-git-send-email-bfields@citi.umich.edu> <20081106071733.6d4983ce@barsoom.rdu.redhat.com> <20081106221057.GF24916@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:45661 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbYKFWWY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2008 17:22:24 -0500
In-Reply-To: <20081106221057.GF24916@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 6, 2008, at Nov 6, 2008, 5:10 PM, J. Bruce Fields wrote:

> On Thu, Nov 06, 2008 at 07:17:33AM -0500, Jeff Layton wrote:
>> On Wed,  5 Nov 2008 15:06:51 -0500
>> "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
>>
>>> These clients will all be shut down by nlm_destroy_host() when we do
>>> garbage collection a little later, so this is redundant.
>>>
>>> XXX: Ask Jeff Layton why he added this again?
>>>
>>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>>> ---
>>> fs/lockd/host.c |    8 +-------
>>> 1 files changed, 1 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
>>> index 73c2be2..0387c6b 100644
>>> --- a/fs/lockd/host.c
>>> +++ b/fs/lockd/host.c
>>> @@ -602,14 +602,8 @@ static void expire_hosts(struct host_table  
>>> *table)
>>> 	struct hlist_node *pos;
>>> 	struct nlm_host	*host;
>>>
>>> -	dprintk("lockd: nuking all hosts...\n");
>>> -	for_each_host(host, pos, chain, table) {
>>> +	for_each_host(host, pos, chain, table)
>>> 		host->h_expires = jiffies - 1;
>>> -		if (host->h_rpcclnt) {
>>> -			rpc_shutdown_client(host->h_rpcclnt);
>>> -			host->h_rpcclnt = NULL;
>>> -		}
>>> -	}
>>> }
>>>
>>> /*
>>
>> Thank goodness for my OC commenting in the BZ I was using to track  
>> this!
>>
>> https://bugzilla.redhat.com/show_bug.cgi?id=254195#c4
>
> We should try to get that kind of comment out of scattered bugzillas  
> and
> in to the code....

Done.  I talked with Jeff today, who explained why this extra RPC  
client shutdown code is here.  A documentation patch will be included  
in the series that splits the host cache.

>> IIRC, there is a chicken and egg problem with refcounting -- at
>> least in the code at the time that I did this. If there is still
>> an active grant callback in queue at the time that nlm_shutdown_hosts
>> is called, the h_count will stay high and nlm_destroy_host won't be
>> called. This can happen if we try to bring down lockd while trying to
>> do a grant callback to an unresponsive client.
>>
>> -- 
>> Jeff Layton <jlayton@redhat.com>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




