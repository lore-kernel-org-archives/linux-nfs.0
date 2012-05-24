Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:54175 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757417Ab2EXTr4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 May 2012 15:47:56 -0400
Message-ID: <4FBE9069.6050602@parallels.com>
Date: Thu, 24 May 2012 23:47:53 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v2 01/12] NFS: pass net to nfs_callback_down()
References: <20120522073320.20602.87130.stgit@localhost.localdomain> <20120522073555.20602.12874.stgit@localhost.localdomain> <20120524160905.GB21776@fieldses.org>
In-Reply-To: <20120524160905.GB21776@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

24.05.2012 20:09, J. Bruce Fields написал:
> I can see that you're passing net to nfs_callback_down().  Could you
> please remind me why?  What problem does this solve?

Callback in a kernel thread and this thread is one for all NFSv4.{0,1} 
clients.
Thus, is have to be cantainerized as Lockd kthread.
This patch set does containerization in the same way as Lockd done.
I forgot about it when I was working on NFS client containerization. So, 
it really hope, that this patch set will be a part of 3.5 kernel.

> --b.
>
> On Tue, May 22, 2012 at 11:35:55AM +0400, Stanislav Kinsbursky wrote:
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>> ---
>>   fs/nfs/callback.c |    4 ++--
>>   fs/nfs/callback.h |    2 +-
>>   fs/nfs/client.c   |    2 +-
>>   3 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
>> index 970659d..f3d7ee2 100644
>> --- a/fs/nfs/callback.c
>> +++ b/fs/nfs/callback.c
>> @@ -322,7 +322,7 @@ out_err:
>>   /*
>>    * Kill the callback thread if it's no longer being used.
>>    */
>> -void nfs_callback_down(int minorversion)
>> +void nfs_callback_down(int minorversion, struct net *net)
>>   {
>>   	struct nfs_callback_data *cb_info =&nfs_callback_info[minorversion];
>>
>> @@ -330,7 +330,7 @@ void nfs_callback_down(int minorversion)
>>   	cb_info->users--;
>>   	if (cb_info->users == 0&&  cb_info->task != NULL) {
>>   		kthread_stop(cb_info->task);
>> -		svc_shutdown_net(cb_info->serv, current->nsproxy->net_ns);
>> +		svc_shutdown_net(cb_info->serv, net);
>>   		svc_exit_thread(cb_info->rqst);
>>   		cb_info->serv = NULL;
>>   		cb_info->rqst = NULL;
>> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
>> index a5527c9..6d900cf 100644
>> --- a/fs/nfs/callback.h
>> +++ b/fs/nfs/callback.h
>> @@ -194,7 +194,7 @@ extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
>>   				   struct cb_process_state *cps);
>>   #ifdef CONFIG_NFS_V4
>>   extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
>> -extern void nfs_callback_down(int minorversion);
>> +extern void nfs_callback_down(int minorversion, struct net *net);
>>   extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
>>   					    const nfs4_stateid *stateid);
>>   extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index da7b5e4..44cd70f 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -222,7 +222,7 @@ static void nfs4_shutdown_session(struct nfs_client *clp)
>>   static void nfs4_destroy_callback(struct nfs_client *clp)
>>   {
>>   	if (__test_and_clear_bit(NFS_CS_CALLBACK,&clp->cl_res_state))
>> -		nfs_callback_down(clp->cl_mvops->minor_version);
>> +		nfs_callback_down(clp->cl_mvops->minor_version, clp->net);
>>   }
>>
>>   static void nfs4_shutdown_client(struct nfs_client *clp)
>>

