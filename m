From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 4/4] NFS: Move cl_delegations to the nfs_server struct
Date: Thu, 23 Dec 2010 17:14:35 -0500
Message-ID: <33BF9604-521D-4422-9FE6-51E44DAC149F@oracle.com>
References: <20101223214503.2344.79300.stgit@matisse.1015granger.net> <20101223215444.2344.27617.stgit@matisse.1015granger.net> <1293142182.9718.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:53719 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493Ab0LWWPw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Dec 2010 17:15:52 -0500
In-Reply-To: <1293142182.9718.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 23, 2010, at 5:09 PM, Trond Myklebust wrote:

> On Thu, 2010-12-23 at 16:54 -0500, Chuck Lever wrote:
>> Delegations are per-inode, not per-nfs_client.  When a server file
>> system is migrated, delegations on the client must be moved from the
>> source to the destination nfs_server.  Make it easier to manage a
>> mount point's delegation list across a migration event by moving the
>> list to the nfs_server struct.
>> 
>> Clean up: I added documenting comments to public functions I changed
>> in this patch.  For consistency I added comments to all the other
>> public functions in fs/nfs/delegation.c.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> fs/nfs/client.c           |    4 -
>> fs/nfs/delegation.c       |  337 +++++++++++++++++++++++++++++++++------------
>> fs/nfs/delegation.h       |    1 
>> fs/nfs/nfs4renewd.c       |    2 
>> include/linux/nfs_fs_sb.h |    2 
>> 5 files changed, 253 insertions(+), 93 deletions(-)
>> 
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index 05e2ee2..d112887 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -144,7 +144,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>> 	clp->cl_proto = cl_init->proto;
>> 
>> #ifdef CONFIG_NFS_V4
>> -	INIT_LIST_HEAD(&clp->cl_delegations);
>> 	spin_lock_init(&clp->cl_lock);
>> 	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
>> 	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
>> @@ -1025,6 +1024,9 @@ static struct nfs_server *nfs_alloc_server(void)
>> 	/* Zero out the NFS state stuff */
>> 	INIT_LIST_HEAD(&server->client_link);
>> 	INIT_LIST_HEAD(&server->master_link);
>> +#ifdef CONFIG_NFS_V4
>> +	INIT_LIST_HEAD(&server->delegations);
>> +#endif
> 
> As I said earlier, can we please avoid this? Just define the
> 'delegations' field unconditionally in struct nfs_server, and get rid of
> the CONFIG_NFS_V4 above.

Sorry, dude.  I forgot that one.

> 
> Cheers
>  Trond
> 
>> 	atomic_set(&server->active, 0);
> 
> 
> 
>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>> index e96ec55..2ddf7aa 100644
>> --- a/include/linux/nfs_fs_sb.h
>> +++ b/include/linux/nfs_fs_sb.h
>> @@ -47,7 +47,6 @@ struct nfs_client {
>> 	u64			cl_clientid;	/* constant */
>> 	unsigned long		cl_state;
>> 
>> -	struct list_head	cl_delegations;
>> 	spinlock_t		cl_lock;
>> 
>> 	unsigned long		cl_lease_time;
>> @@ -149,6 +148,7 @@ struct nfs_server {
>> 	struct rb_root		state_owners;
>> 	struct rb_root		openowner_id;
>> 	struct rb_root		lockowner_id;
>> +	struct list_head	delegations;
>> #endif
>> 	void (*destroy)(struct nfs_server *);
>> 
>> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




