From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 12/12] lockd: remove redundant rpc_shutdown_client()
Date: Thu, 6 Nov 2008 09:32:31 -0500
Message-ID: <DA6C66B8-73D0-4E57-B273-E64BE0713493@oracle.com>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net> <1225915611-2401-1-git-send-email-bfields@citi.umich.edu> <1225915611-2401-2-git-send-email-bfields@citi.umich.edu> <1225915611-2401-3-git-send-email-bfields@citi.umich.edu> <1225915611-2401-4-git-send-email-bfields@citi.umich.edu> <1225915611-2401-5-git-send-email-bfields@citi.umich.edu> <1225915611-2401-6-git-send-email-bfields@citi.umich.edu> <1225915611-2401-7-git-send-email-bfields@citi.umich.edu> <1225915611-2401-8-git-send-email-bfields@citi.umich.edu> <1225915611-2401-9-git-send-email-bfields@citi.umich.edu> <1225915611-2401-10-git-send-email-bfields@citi.umich.edu> <1225915611-2401-11-git-send-email-bfields@citi.umich.edu> <1225915611-2401-12-git-send-email-bfields@citi.umich.edu> <20081106071733.6d4983ce@barsoom
 .rdu.redhat.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:30939 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbYKFOgB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2008 09:36:01 -0500
In-Reply-To: <20081106071733.6d4983ce-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 6, 2008, at Nov 6, 2008, 7:17 AM, Jeff Layton wrote:
> On Wed,  5 Nov 2008 15:06:51 -0500
> "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
>
>> These clients will all be shut down by nlm_destroy_host() when we do
>> garbage collection a little later, so this is redundant.
>>
>> XXX: Ask Jeff Layton why he added this again?
>>
>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>> ---
>> fs/lockd/host.c |    8 +-------
>> 1 files changed, 1 insertions(+), 7 deletions(-)
>>
>> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
>> index 73c2be2..0387c6b 100644
>> --- a/fs/lockd/host.c
>> +++ b/fs/lockd/host.c
>> @@ -602,14 +602,8 @@ static void expire_hosts(struct host_table  
>> *table)
>> 	struct hlist_node *pos;
>> 	struct nlm_host	*host;
>>
>> -	dprintk("lockd: nuking all hosts...\n");
>> -	for_each_host(host, pos, chain, table) {
>> +	for_each_host(host, pos, chain, table)
>> 		host->h_expires = jiffies - 1;
>> -		if (host->h_rpcclnt) {
>> -			rpc_shutdown_client(host->h_rpcclnt);
>> -			host->h_rpcclnt = NULL;
>> -		}
>> -	}
>> }
>>
>> /*
>
> Thank goodness for my OC commenting in the BZ I was using to track  
> this!
>
> https://bugzilla.redhat.com/show_bug.cgi?id=254195#c4
>
> IIRC, there is a chicken and egg problem with refcounting -- at
> least in the code at the time that I did this. If there is still
> an active grant callback in queue at the time that nlm_shutdown_hosts
> is called, the h_count will stay high and nlm_destroy_host won't be
> called. This can happen if we try to bring down lockd while trying to
> do a grant callback to an unresponsive client.

If that's the case, it seems to me what we want is, during lockd  
shutdown, a way to forcibly retire all outstanding grant callbacks  
before walking the host cache.  Isn't that what  
nlmsvc_invalidate_all() does?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
