Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32837 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114Ab1ISOwm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 10:52:42 -0400
Message-ID: <4E7756F3.4080601@parallels.com>
Date: Mon, 19 Sep 2011 18:51:31 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Subject: Re: [PATCH v3 04/11] SUNRPC: parametrize svc creation calls with
 portmapper flag
References: <20110913180953.3961.69217.stgit@localhost6.localdomain6>	<20110913181351.3961.70207.stgit@localhost6.localdomain6> <20110919100811.0eaa39fe@tlielax.poochiereds.net>
In-Reply-To: <20110919100811.0eaa39fe@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

19.09.2011 18:08, Jeff Layton пишет:
> On Tue, 13 Sep 2011 22:13:51 +0400
> Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
>
>> This new flag ("setup_rpcbind) will be used to detect, that new service will
>> send portmapper register calls. For such services we will create rpcbind
>> clients and remove all stale portmap registrations.
>> Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for such services
>> in case of this field wasn't initialized earlier. This will allow to destroy
>> rpcbind clients when no other users of them left.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>> ---
>>   include/linux/sunrpc/svc.h |    2 ++
>>   net/sunrpc/svc.c           |   21 ++++++++++++++-------
>>   2 files changed, 16 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>> index 223588a..528952a 100644
>> --- a/include/linux/sunrpc/svc.h
>> +++ b/include/linux/sunrpc/svc.h
>> @@ -402,11 +402,13 @@ struct svc_procedure {
>>    * Function prototypes.
>>    */
>>   struct svc_serv *svc_create(struct svc_program *, unsigned int,
>> +			    int setup_rpcbind,
> 				^^^
> 			Instead of adding this parameter, why not
> 			base this on the vs_hidden flag in the
> 			svc_version? IOW, have a function that looks at
> 			all the svc_versions for a particular
> 			svc_program, and returns "true" if any of them
> 			have vs_hidden unset? The mechanism you're
> 			proposing here has the potential to be out of
> 			sync with the vs_hidden flag.
>

Could you, please, clarify me this vs_hidden flag?
I understand, that it's used to avoid portmap registration.
But as I see, it's set only for nfs_callback_version1. But this svc_version is a 
part of nfs4_callback_program with nfs_callback_version4, which is not hidden.
Does this flag is missed here? If not, how we can return "true" from your 
proposed function if any of them have vs_hidden unset?

Also sockets for this program are created with SVC_SOCK_ANONYMOUS flag and we 
will not register any of this program versions with portmapper.
Thus, from my pow, this vs_hidden flag affects only svc_unregister. And only 
nfs_callback_version1. This looks really strange.

I.e. if we use this flag only for passing through this versions during 
svc_(un)register, and we actually also want to pass through 
nfs_callback_version4 as well (but just missed this vs_hidden flag for it), then 
with current patch-set we can move this flag from (vs_hidden) svc_version to 
svc_program and check it during svc_create instead of my home-brew 
"setup_rpcbind" variable.

> 			Also, if you're adding an argument to a
> 			function like this, you you really ought to
> 			change the callers in the same patch. Otherwise
> 			you'll cause a build break if someone tries to
> 			bisect and ends up between the patch that
> 			changes the function and the one that changes
> 			the callers.
>
>>   			void (*shutdown)(struct svc_serv *));
>>   struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
>>   					struct svc_pool *pool);
>>   void		   svc_exit_thread(struct svc_rqst *);
>>   struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
>> +			int setup_rpcbind,
>>   			void (*shutdown)(struct svc_serv *),
>>   			svc_thread_fn, struct module *);
>>   int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index f31e5cc..03231d5 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -378,7 +378,7 @@ static void svc_rpcb_cleanup(struct svc_serv *serv)
>>    */
>>   static struct svc_serv *
>>   __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
>> -	     void (*shutdown)(struct svc_serv *serv))
>> +	     int setup_rpcbind, void (*shutdown)(struct svc_serv *serv))
>>   {
>>   	struct svc_serv	*serv;
>>   	unsigned int vers;
>> @@ -437,29 +437,36 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
>>   		spin_lock_init(&pool->sp_lock);
>>   	}
>>
>> -	/* Remove any stale portmap registrations */
>> -	svc_unregister(serv);
>> +	if (setup_rpcbind) {
>> +	       	if (svc_rpcb_setup(serv)<  0) {
>> +			kfree(serv->sv_pools);
>> +			kfree(serv);
>> +			return NULL;
>> +		}
>> +		if (!serv->sv_shutdown)
>> +			serv->sv_shutdown = svc_rpcb_cleanup;
>> +	}
>>
>>   	return serv;
>>   }
>>
>>   struct svc_serv *
>>   svc_create(struct svc_program *prog, unsigned int bufsize,
>> -	   void (*shutdown)(struct svc_serv *serv))
>> +	   int setup_rpcbind, void (*shutdown)(struct svc_serv *serv))
>>   {
>> -	return __svc_create(prog, bufsize, /*npools*/1, shutdown);
>> +	return __svc_create(prog, bufsize, /*npools*/1, setup_rpcbind, shutdown);
>>   }
>>   EXPORT_SYMBOL_GPL(svc_create);
>>
>>   struct svc_serv *
>>   svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
>> -		  void (*shutdown)(struct svc_serv *serv),
>> +		  int setup_rpcbind, void (*shutdown)(struct svc_serv *serv),
>>   		  svc_thread_fn func, struct module *mod)
>>   {
>>   	struct svc_serv *serv;
>>   	unsigned int npools = svc_pool_map_get();
>>
>> -	serv = __svc_create(prog, bufsize, npools, shutdown);
>> +	serv = __svc_create(prog, bufsize, npools, setup_rpcbind, shutdown);
>>
>>   	if (serv != NULL) {
>>   		serv->sv_function = func;
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


-- 
Best regards,
Stanislav Kinsbursky
