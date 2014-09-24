Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:63298 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbaIXWMc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 18:12:32 -0400
Received: by mail-ie0-f172.google.com with SMTP id rp18so10513108iec.17
        for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 15:12:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtTYCPOK_Cq0BPVdfXQ9C=8sCU47R83-m52-6P5VOSq8Tg@mail.gmail.com>
References: <1411574911-19269-1-git-send-email-kolga@netapp.com>
	<CAHQdGtTfUYoU+0LRqS6eao5Z-uVqHoGkXO9HcU+Wmo=vZobvew@mail.gmail.com>
	<CAN-5tyHhXMzJd60ASes1zMYSEaSiwAqry5_4zE=LHZw_3Lbv9w@mail.gmail.com>
	<CAHQdGtTYCPOK_Cq0BPVdfXQ9C=8sCU47R83-m52-6P5VOSq8Tg@mail.gmail.com>
Date: Wed, 24 Sep 2014 18:12:32 -0400
Message-ID: <CAN-5tyFLxHivtgjiiRqvhfmrR53qmd4j2oveERVihxz-rMLQYQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] Fixing lease renewal
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 24, 2014 at 4:11 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Wed, Sep 24, 2014 at 2:29 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> Before I go ahead with the change, does it make sense to move "both"
>> of the migration sections NFS4CLNT_MOVED and NFS4CLNT_LEASE_MOVED
>> before the check lease section?
>
> Actually. Never mind. Thinking about this, and looking at the code, we
> definitely do want to ensure that lease recovery is performed before
> migration recovery.
> Let's just put the 'continue;' back into the CHECK_LEASE section for
> now so that we enforce that.
>

Ok. Another one submitted.

>> On Wed, Sep 24, 2014 at 2:05 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> Hi Olga,
>>>
>>> On Wed, Sep 24, 2014 at 12:08 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
>>>> Commit c9fdeb28 removed a 'continue' after checking if the lease needs
>>>> to be renewed. However, if client hasn't moved, the code falls down to
>>>> starting reboot recovery erroneously (ie., sends open reclaim and gets
>>>> back stale_clientid error) before recovering from getting stale_clientid
>>>> on the renew operation.
>>>>
>>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>>> ---
>>>>  fs/nfs/nfs4state.c | 4 +++-
>>>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>>>> index 22fe351..4616598 100644
>>>> --- a/fs/nfs/nfs4state.c
>>>> +++ b/fs/nfs/nfs4state.c
>>>> @@ -2340,11 +2340,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
>>>>                         continue;
>>>>                 }
>>>>
>>>> -               if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
>>>> +               if (!test_bit(NFS4CLNT_MOVED, &clp->cl_state) &&
>>>> +                    test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
>>>>                         section = "check lease";
>>>>                         status = nfs4_check_lease(clp);
>>>>                         if (status < 0)
>>>>                                 goto out_error;
>>>> +                       continue;
>>>>                 }
>>>>
>>>>                 if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
>>>> --
>>>> 1.8.5.2 (Apple Git-48)
>>>>
>>>
>>> I think you misunderstood me. I was proposing that we move the entire
>>> code section that currently reads
>>>
>>>                 if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
>>>                         section = "migration";
>>>                         status = nfs4_handle_migration(clp);
>>>                         if (status < 0)
>>>                                 goto out_error;
>>>                 }
>>>
>>> so that it occurs before the section
>>>
>>>                 if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
>>>                         section = "check lease";
>>>                         status = nfs4_check_lease(clp);
>>>                         if (status < 0)
>>>                                 goto out_error;
>>> +                      continue;
>>>                 }
>>>
>>> That way we only need to test once for NFS4CLNT_MOVED.
>>>
>>> Cheers
>>>   Trond
>>> --
>>> Trond Myklebust
>>>
>>> Linux NFS client maintainer, PrimaryData
>>>
>>> trond.myklebust@primarydata.com
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
> --
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com
