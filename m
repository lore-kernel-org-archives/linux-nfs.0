Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4133 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742Ab1FCPOC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jun 2011 11:14:02 -0400
Message-ID: <4DE8FA35.4010606@RedHat.com>
Date: Fri, 03 Jun 2011 11:13:57 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs4: v4 mounts should not need rpcbind running
References: <1307110290-30672-1-git-send-email-steved@redhat.com> <A51F73EF-B137-4279-91BC-4B7E868CDCB6@oracle.com>
In-Reply-To: <A51F73EF-B137-4279-91BC-4B7E868CDCB6@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/03/2011 10:41 AM, Chuck Lever wrote:
> Hey-
> 
> On Jun 3, 2011, at 10:11 AM, Steve Dickson wrote:
> 
>> When RPC services are created with svc_create() an
>> svc_unregister() is done to remove any stale registrations.
>>
>> This unregister is not needed with the v4 callback
>> service and will cause the mount to hang if rpcbind
>> is not running.
> 
> This should no longer be the case.  The kernel uses connected transports to contact rpcbind these days, and should be able to tell immediately that there is no rpcbind running.  If there is still a hang, something else is wrong.
Ok... The hang was just an theory... I didn't test it out... but I do know
for a fact that when a v4 mount is done, a PMAP_UNSET is set to rpcbind 
which obviously is not needed.  
> 
>> This patch makes the nfs4 callback service a hide service
>> by setting the vs_hidden flag in the nfs4_callback_version4
>> structure
> 
> One reason to continue to do this is to have some assurance that no-one else takes the same RPC program number.  Not a big deal.
Personally I think its a waste of cycles especially when a large
number of mounts are happening at once... Its completely overkill IMHO...

steved.

> 
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> fs/nfs/callback_xdr.c |    1 +
>> 1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
>> index c6c86a7..7c8b800 100644
>> --- a/fs/nfs/callback_xdr.c
>> +++ b/fs/nfs/callback_xdr.c
>> @@ -996,4 +996,5 @@ struct svc_version nfs4_callback_version4 = {
>> 	.vs_proc = nfs4_callback_procedures1,
>> 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
>> 	.vs_dispatch = NULL,
>> +	.vs_hidden = 1,
>> };
> 
