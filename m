Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932481Ab1DNTUV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2011 15:20:21 -0400
Subject: Re: [PATCH] NFS: dont restart loop in nfs_delegation_reap_unclaimed
Content-Type: text/plain; charset=us-ascii
From: Dros Adamson <dros@netapp.com>
In-Reply-To: <F6E1551C-3A7B-4BD4-8C31-62996BEE2ACC@oracle.com>
Date: Thu, 14 Apr 2011 15:20:18 -0400
Cc: trond@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <538B0B51-537C-47A8-8F52-52C293E033A1@netapp.com>
References: <1302807855-84959-1-git-send-email-dros@netapp.com> <F6E1551C-3A7B-4BD4-8C31-62996BEE2ACC@oracle.com>
To: Chuck Lever <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 14, 2011, at 3:10 PM, Chuck Lever wrote:

> 
> On Apr 14, 2011, at 3:04 PM, Weston Andros Adamson wrote:
> 
>> The loop was being restarted after each delegation that has NFS_DELEGATION_NEED_RECLAIM
>> set.  Instead, build a temporary list of delegations that need to be freed and free
>> them after the for-each-delegation loop.
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> fs/nfs/delegation.c |   16 +++++++++++-----
>> 1 files changed, 11 insertions(+), 5 deletions(-)
>> 
>> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
>> index bbbc6bf..c87fad8 100644
>> --- a/fs/nfs/delegation.c
>> +++ b/fs/nfs/delegation.c
>> @@ -645,8 +645,8 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp)
>> 	struct nfs_delegation *delegation;
>> 	struct nfs_server *server;
>> 	struct inode *inode;
>> +	LIST_HEAD(tmplist);
>> 
>> -restart:
>> 	rcu_read_lock();
>> 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>> 		list_for_each_entry_rcu(delegation, &server->delegations,
>> @@ -659,15 +659,21 @@ restart:
>> 				continue;
>> 			delegation = nfs_detach_delegation(NFS_I(inode),
>> 								server);
>> -			rcu_read_unlock();
>> -
>> +			/* super_list is unused now that deleg is detached */
>> 			if (delegation != NULL)
>> -				nfs_free_delegation(delegation);
>> +				list_add(&delegation->super_list, &tmplist);
>> +
>> 			iput(inode);
> 
> /me idly wonders if that iput() is safe to do inside rcu_read_lock() / rcu_read_unlock().

Hrm, I think you're right.  I take this patch back!

-dros

