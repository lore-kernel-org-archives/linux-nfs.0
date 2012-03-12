Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:37674 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397Ab2CLRRK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 13:17:10 -0400
Subject: Re: [PATCH] NFS: Always use the same SETCLIENTID boot verifier
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <EBAE3482-7129-493E-A19B-0F671B009657@oracle.com>
Date: Mon, 12 Mar 2012 13:17:06 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <F566A615-1F86-46F0-B47B-AC8B80E830F9@oracle.com>
References: <20120309223445.4005.78869.stgit@degas.1015granger.net> <1331336152.2763.88.camel@lade.trondhjem.org> <EBAE3482-7129-493E-A19B-0F671B009657@oracle.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 12, 2012, at 1:14 PM, Chuck Lever wrote:

> Hi-
> 
> On Mar 9, 2012, at 6:35 PM, Myklebust, Trond wrote:
> 
>> On Fri, 2012-03-09 at 17:35 -0500, Chuck Lever wrote:
>>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>>> index 4db330d..a2b7c47 100644
>>> --- a/fs/nfs/nfs4state.c
>>> +++ b/fs/nfs/nfs4state.c
>>> @@ -1570,7 +1570,6 @@ void nfs41_handle_recall_slot(struct nfs_client *clp)
>>> static void nfs4_reset_all_state(struct nfs_client *clp)
>>> {
>>> 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
>>> -		clp->cl_boot_time = CURRENT_TIME;
>>> 		nfs4_state_start_reclaim_nograce(clp);
>> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>> This line is now problematic. If we don't declare a reboot, then we may
>> end up with all sorts of BAD_SEQID errors above.
>> 
>> Hmm... Thinking about this, the best solution might be simply to declare
>> 2 reboots:
>>    1. Reboot using a CURRENT_TIME based verifier
>>    2. Reboot again using the nfs_boot_time based verifier.
>> 
>> That guarantees that the server clears out all the state that we weren't
>> interested in keeping, while ensuring that in the end, we continue to
>> use the nfs_boot_time verifier for all future state generation attempts.
> 
> Add a new cl_state flag, call it, say, NFS4CLNT_RESET_SERVER_STATE.  Set that flag in nfs4_reset_all_state().
> 
> In nfs4_proc_setclientid(), have it use CURRENT_TIME for the boot verifier if NFS4CLNT_RESET_SERVER_STATE is set.

Well, add this somewhere that will effect nfs4_proc_exchange_id() as well.

> 
> Add logic at the top of the loop in nfs4_state_manager() that, if NFS4CLNT_RESET_SERVER_STATE is set, invokes nfs4_reclaim_lease(), then it sets the NFS4CLNT_LEASE_EXPIRED flag and does a "continue;".
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




