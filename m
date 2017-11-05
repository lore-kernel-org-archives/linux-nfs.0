Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44381 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750748AbdKEQsV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 5 Nov 2017 11:48:21 -0500
Subject: Re: [PATCH 06/21] nfs client: exit_net cleanup check added
To: Trond Myklebust <trondmy@primarydata.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <5cbecaf0-dbb6-4140-43ed-ae94fc161941@virtuozzo.com>
 <1509897719.5851.2.camel@primarydata.com>
From: Vasily Averin <vvs@virtuozzo.com>
Message-ID: <297fee4f-3cef-9bd4-d683-a14559939b65@virtuozzo.com>
Date: Sun, 5 Nov 2017 19:48:10 +0300
MIME-Version: 1.0
In-Reply-To: <1509897719.5851.2.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-11-05 19:02, Trond Myklebust wrote:
> On Sun, 2017-11-05 at 13:00 +0300, Vasily Averin wrote:
>> Be sure that nfs_client_list and nfs_volume_list lists initialized
>> in net_init hook were return to initial state in net_exit hook.
>>
>> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
>> ---
>>  fs/nfs/client.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index 22880ef..7c0691c 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -204,6 +204,10 @@ void nfs_cleanup_cb_ident_idr(struct net *net)
>>  	struct nfs_net *nn = net_generic(net, nfs_net_id);
>>  
>>  	idr_destroy(&nn->cb_ident_idr);
>> +	WARN(!list_empty(&nn->nfs_client_list),
>> +	     "net %p exit: nfs_client_list is not empty\n", net);
>> +	WARN(!list_empty(&nn->nfs_volume_list),
>> +	     "net %p exit: nfs_volume_list is not empty\n", net);
>>  }
>>  
> 
> Why do we need these? Is there a specific bug that you are trying to
> track down?

I hope such checks allows to detect leaked per-netns objects.
Also I hope that all new pernet_operations will inherit such checks too.

I assume that elements added into per-net lists should not live longer than net namespace,
and should be deleted from the list. I think exit_net hook is good place for such check.

Recently I've found lost list_entry and enabled timer on stop of net namespace.
Then I've reviewed all existing pernet_operations and found that many drivers
have such checks already. So I decided to complete this task and add such checks
into all affected subsystems.
