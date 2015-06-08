Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17011 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbbFHPy3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 11:54:29 -0400
Message-ID: <5575BAAD.4040600@oracle.com>
Date: Mon, 08 Jun 2015 08:54:21 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Jeff Layton <jeff.layton@primarydata.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH V3 2/7] nfsd/sunrpc: move sv_function into sv_ops
References: <5575276A.4030305@oracle.com> <20150608074213.2c70a37c@synchrony.poochiereds.net>
In-Reply-To: <20150608074213.2c70a37c@synchrony.poochiereds.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oops, I made a mistake. Yes, I will resend them.

Thanks
Shirley

On 06/08/2015 04:42 AM, Jeff Layton wrote:
> On Sun, 07 Jun 2015 22:26:02 -0700
> Shirley Ma <shirley.ma@oracle.com> wrote:
> 
>> sunrpc: move sv_module parm into sv_ops
>>     
>> ...not technically an operation, but it's more convenient and cleaner
>> to pass the module pointer in this struct.
>>     
>> Author: Jeff Layton <jlayton@primarydata.com>
>> Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
>> Tested-by: Shirley Ma <shirley.ma@oracle.com>
>> ---
>> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
>> index bd03968..17ceaad 100644
>> --- a/fs/nfsd/nfssvc.c
>> +++ b/fs/nfsd/nfssvc.c
>> @@ -394,6 +394,7 @@ static int nfsd_get_default_max_blksize(void)
>>  static struct svc_serv_ops nfsd_sv_ops = {
>>  	.svo_shutdown = nfsd_last_thread,
>>  	.svo_function = nfsd,
>> +	.svo_module = THIS_MODULE,
>>  };
>>  
>>  int nfsd_create_serv(struct net *net)
>> @@ -410,7 +411,7 @@ int nfsd_create_serv(struct net *net)
>>  		nfsd_max_blksize = nfsd_get_default_max_blksize();
>>  	nfsd_reset_versions();
>>  	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
>> -				      &nfsd_sv_ops, THIS_MODULE);
>> +						&nfsd_sv_ops);
>>  	if (nn->nfsd_serv == NULL)
>>  		return -ENOMEM;
>>  
>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>> index 68103a6..2ec741a 100644
>> --- a/include/linux/sunrpc/svc.h
>> +++ b/include/linux/sunrpc/svc.h
>> @@ -54,7 +54,12 @@ struct svc_serv;
>>  struct svc_serv_ops {
>>  	/* Callback to use when last thread exits. */
>>  	void		(*svo_shutdown)(struct svc_serv *, struct net *);
>> +
>> +	/* function for service threads to run */
>>  	int		(*svo_function)(void *);
>> +
>> +	/* optional module to count when adding threads (pooled svcs only) */
>> +	struct module	*svo_module;
>>  };
>>  
>>  /*
>> @@ -89,8 +94,6 @@ struct svc_serv {
>>  	unsigned int		sv_nrpools;	/* number of thread pools */
>>  	struct svc_pool *	sv_pools;	/* array of thread pools */
>>  	struct svc_serv_ops *	sv_ops;		/* server operations */
>> -	struct module *		sv_module;	/* optional module to count when
>> -						 * adding threads */
>>  #if defined(CONFIG_SUNRPC_BACKCHANNEL)
>>  	struct list_head	sv_cb_list;	/* queue for callback requests
>>  						 * that arrive over the same
>> @@ -430,7 +433,7 @@ struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
>>  					struct svc_pool *pool, int node);
>>  void		   svc_exit_thread(struct svc_rqst *);
>>  struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
>> -			struct svc_serv_ops *, struct module *);
>> +			struct svc_serv_ops *);
>>  int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
>>  int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
>>  void		   svc_destroy(struct svc_serv *);
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index 25d7b92..5ae9d63 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -494,7 +494,7 @@ EXPORT_SYMBOL_GPL(svc_create);
>>  
>>  struct svc_serv *
>>  svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
>> -		  struct svc_serv_ops *ops, struct module *mod)
>> +		  struct svc_serv_ops *ops)
>>  {
>>  	struct svc_serv *serv;
>>  	unsigned int npools = svc_pool_map_get();
>> @@ -502,8 +502,6 @@ svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
>>  	serv = __svc_create(prog, bufsize, npools, ops);
>>  	if (!serv)
>>  		goto out_err;
>> -
>> -	serv->sv_module = mod;
>>  	return serv;
>>  out_err:
>>  	svc_pool_map_put();
>> @@ -737,12 +735,12 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
>>  			break;
>>  		}
>>  
>> -		__module_get(serv->sv_module);
>> +		__module_get(serv->sv_ops->svo_module);
>>  		task = kthread_create_on_node(serv->sv_ops->svo_function, rqstp,
>>  					      node, "%s", serv->sv_name);
>>  		if (IS_ERR(task)) {
>>  			error = PTR_ERR(task);
>> -			module_put(serv->sv_module);
>> +			module_put(serv->sv_ops->svo_module);
>>  			svc_exit_thread(rqstp);
>>  			break;
>>  		}
> 
> Hmmm...there are two patch #2's in this series and one looks like a dup
> of #3? It'd be good to clean that up and resend eventually once
> everyone has commented...
> 
> Anyway, ACK from me on merging this part of the work. It's unlikely to
> hurt anything performance-wise, and having an ops container for the serv
> makes a lot of sense, IMO.
> 
