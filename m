Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:44502 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248Ab3FZFc6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jun 2013 01:32:58 -0400
Message-ID: <51CA7CD9.1050209@parallels.com>
Date: Wed, 26 Jun 2013 09:32:09 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH v3 2/4] SUNRPC: fix races on PipeFS UMOUNT notifications
References: <20130624075131.17104.55399.stgit@localhost.localdomain>  <20130624075245.17104.6279.stgit@localhost.localdomain> <1372176778.5968.29.camel@leira.trondhjem.org>
In-Reply-To: <1372176778.5968.29.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

25.06.2013 20:13, Myklebust, Trond пишет:
> On Mon, 2013-06-24 at 11:52 +0400, Stanislav Kinsbursky wrote:
>> CPU#0                                   CPU#1
>> -----------------------------           -----------------------------
>> rpc_kill_sb
>> sn->pipefs_sb = NULL                    rpc_release_client
>> (UMOUNT_EVENT)                          rpc_free_auth
>> rpc_pipefs_event
>> rpc_get_client_for_event
>> !atomic_inc_not_zero(cl_count)
>> <skip the client>
>>                                          atomic_inc(cl_count)
>>                                          rpc_free_client
>>                                          rpc_clnt_remove_pipedir
>>                                          <skip client dir removing>
>>
>> To fix this, this patch does the following:
>>
>> 1) Calls RPC_PIPEFS_UMOUNT notification with sn->pipefs_sb_lock being held.
>> 2) Removes SUNRPC client from the list AFTER pipes destroying.
>> 3) Doesn't hold RPC client on notification: if client in the list, then it
>> can't be destroyed while sn->pipefs_sb_lock in hold by notification caller.
>>
>> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
>> Cc: stable@vger.kernel.org
>> ---
>>   net/sunrpc/clnt.c     |    5 +----
>>   net/sunrpc/rpc_pipe.c |    2 +-
>>   2 files changed, 2 insertions(+), 5 deletions(-)
>
> <snip>
>
>> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
>> index c512448..efca2f7 100644
>> --- a/net/sunrpc/rpc_pipe.c
>> +++ b/net/sunrpc/rpc_pipe.c
>> @@ -1165,7 +1165,6 @@ static void rpc_kill_sb(struct super_block *sb)
>>   		goto out;
>>   	}
>>   	sn->pipefs_sb = NULL;
>> -	mutex_unlock(&sn->pipefs_sb_lock);
>>   	dprintk("RPC:       sending pipefs UMOUNT notification for net %p%s\n",
>>   		net, NET_NAME(net));
>>   	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
>> @@ -1173,6 +1172,7 @@ static void rpc_kill_sb(struct super_block *sb)
>>   					   sb);
>>   	put_net(net);
>>   out:
>> +	mutex_unlock(&sn->pipefs_sb_lock);
>
> Is this safe to do after the put_net()?
>

Sure it's not. Sorry.
Will send the patch once more.

>>   	kill_litter_super(sb);
>>   }
>>
>>
>
>


-- 
Best regards,
Stanislav Kinsbursky
