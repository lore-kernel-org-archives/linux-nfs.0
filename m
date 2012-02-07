Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5716 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750825Ab2BGOfV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 09:35:21 -0500
Message-ID: <4F313694.8000008@netapp.com>
Date: Tue, 07 Feb 2012 09:35:00 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 4/4] NFS: make nfs_client_lock per net ns
References: <20120123172631.29637.17188.stgit@localhost6.localdomain6>  <1328622659.4124.3.camel@lade.trondhjem.org>  <4F31308B.1090002@parallels.com> <1328623906.4124.10.camel@lade.trondhjem.org> <4F313595.7090004@netapp.com>
In-Reply-To: <4F313595.7090004@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/07/12 09:30, Bryan Schumaker wrote:

> On 02/07/12 09:11, Myklebust, Trond wrote:
> 
>> On Tue, 2012-02-07 at 18:09 +0400, Stanislav Kinsbursky wrote:
>>> 07.02.2012 17:51, Myklebust, Trond пишет:
>>>> 8<-------------------------------------------------------------------------
>>>>  From 5a489156da4fd15dd143f2b21dd9657b97dcef88 Mon Sep 17 00:00:00 2001
>>>> From: Trond Myklebust<Trond.Myklebust@netapp.com>
>>>> Date: Tue, 7 Feb 2012 00:05:11 -0500
>>>> Subject: [PATCH] NFS: Initialise the nfs_net->nfs_client_lock
>>>>
>>>> Ensure that we initialise the nfs_net->nfs_client_lock spinlock.
>>>> Also ensure that nfs_server_remove_lists() doesn't try to
>>>> dereference server->nfs_client before that is initialised.
>>>>
>>>
>>> Sorry.
>>> Patch looks nice. Except one notice below.
>>>
>>>> Signed-off-by: Trond Myklebust<Trond.Myklebust@netapp.com>
>>>> Cc: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>> ---
>>>>   fs/nfs/client.c |    6 +++++-
>>>>   1 files changed, 5 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>>> index 1a5cd49..f0dacad 100644
>>>> --- a/fs/nfs/client.c
>>>> +++ b/fs/nfs/client.c
>>>> @@ -1055,8 +1055,11 @@ static void nfs_server_insert_lists(struct nfs_server *server)
>>>>   static void nfs_server_remove_lists(struct nfs_server *server)
>>>>   {
>>>>   	struct nfs_client *clp = server->nfs_client;
>>>> -	struct nfs_net *nn = net_generic(clp->net, nfs_net_id);
>>>> +	struct nfs_net *nn;
>>>>
>>>> +	if (clp == NULL)
>>>> +		return;
>>>> +	nn = net_generic(clp->net, nfs_net_id);
>>>>   	spin_lock(&nn->nfs_client_lock);
>>>>   	list_del_rcu(&server->client_link);
>>>>   	if (clp&&  list_empty(&clp->cl_superblocks))
>>>
>>> This check for clp != NULL can be removed.
>>>
>>
>> Yep... I'll add that in...
> 
> 
> 
> When I compile Trond's devel branch I get this:
> 
> make[1]: Nothing to be done for `all'.
>   CHK     include/linux/version.h
>   CHK     include/generated/utsrelease.h
>   CALL    scripts/checksyscalls.sh
>   CHK     include/generated/compile.h
>   CHK     kernel/config_data.h
>   CC [M]  fs/nfs/idmap.o
> fs/nfs/idmap.c: In function 'rpc_pipefs_event':
> fs/nfs/idmap.c:535:9: error: implicit declaration of function 'net_generic' [-Werror=implicit-function-declaration]
> fs/nfs/idmap.c:535:50: error: 'nfs_net_id' undeclared (first use in this function)
> fs/nfs/idmap.c:535:50: note: each undeclared identifier is reported only once for each function it appears in
> fs/nfs/idmap.c:540:82: error: dereferencing pointer to incomplete type
> fs/nfs/idmap.c:540:224: error: dereferencing pointer to incomplete type
> cc1: some warnings being treated as errors
> 
> make[2]: *** [fs/nfs/idmap.o] Error 1
> make[1]: *** [fs/nfs] Error 2
> make: *** [fs] Error 2
> 
> I bisected it to this patch, probably a missing #include?


Ignore that, I was in the middle of bisecting something else and got confused.  This was still something I kept seeing during the bisect, though.  I'll figure out which patch causes it in a few minutes...

> 
> - Bryan
> 
>>
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


