Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34198 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755843AbaIRNRp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Sep 2014 09:17:45 -0400
Message-ID: <541ADB75.7030504@RedHat.com>
Date: Thu, 18 Sep 2014 09:17:41 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: nfs4_state_manager() vs. nfs_server_remove_lists()
References: <1410965448-6110-1-git-send-email-steved@redhat.com> <CAHQdGtQv4BPmD5s77=sFmyjT+64+65A8j3nEu_z-woNOGkGAng@mail.gmail.com> <5419A20D.8070805@Netapp.com>
In-Reply-To: <5419A20D.8070805@Netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/17/2014 11:00 AM, Anna Schumaker wrote:
> On 09/17/2014 10:55 AM, Trond Myklebust wrote:
>> On Wed, Sep 17, 2014 at 10:50 AM, Steve Dickson <steved@redhat.com> wrote:
>>> There is a race between nfs4_state_manager() and
>>> nfs_server_remove_lists() that happens during a nfsv3 mount.
>>>
>>> The v3 mount notices there is already a supper block so
>>> nfs_server_remove_lists() called which uses the nfs_client_lock
>>> spin lock to synchronize access to the client list.
>>>
>>> At the same time nfs4_state_manager() is running through
>>> the client list looking for work to do, using the same
>>> lock. When nfs4_state_manager() wins the race to the
>>> list, a v3 client pointer is found and not ignored
>>> properly which causes the panic.
>>>
>>> Moving some protocol checks before the state checking
>>> avoids the panic.
>>>
>>> CC: Stable Tree <stable@vger.kernel.org>
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>>  fs/nfs/nfs4client.c | 19 ++++++++++---------
>>>  1 file changed, 10 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>>> index 53e435a..7ff4c02 100644
>>> --- a/fs/nfs/nfs4client.c
>>> +++ b/fs/nfs/nfs4client.c
>>> @@ -622,6 +622,16 @@ int nfs41_walk_client_list(struct nfs_client *new,
>>>
>>>         spin_lock(&nn->nfs_client_lock);
>>>         list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
>>> +
>>> +               if (pos->rpc_ops != new->rpc_ops)
>>> +                       continue;
>>> +
>>> +               if (pos->cl_proto != new->cl_proto)
>>> +                       continue;
>>> +
>>> +               if (pos->cl_minorversion != new->cl_minorversion)
>>> +                       continue;
>>> +
>>>                 /* If "pos" isn't marked ready, we can't trust the
>>>                  * remaining fields in "pos", especially the client
>>>                  * ID and serverowner fields.  Wait for CREATE_SESSION
>>> @@ -647,15 +657,6 @@ int nfs41_walk_client_list(struct nfs_client *new,
>>>                 if (pos->cl_cons_state != NFS_CS_READY)
>>>                         continue;
>>>
>>> -               if (pos->rpc_ops != new->rpc_ops)
>>> -                       continue;
>>> -
>>> -               if (pos->cl_proto != new->cl_proto)
>>> -                       continue;
>>> -
>>> -               if (pos->cl_minorversion != new->cl_minorversion)
>>> -                       continue;
>>> -
>>>                 if (!nfs4_match_clientids(pos, new))
>>>                         continue;
>>>
>>> --
>>> 1.8.3.1
>>>
>> Don't we need the same fix in nfs40_walk_client_list?
> Bonus points for finding a way to merge these functions, since they do similar comparisons in the beginning :)
I did talk a look at merging these functions... The start
of the functions are similar but the do differ after the state
check enough to keep them separate... IMHO... 

steved.

