Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57468 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755224AbdJQUkI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 16:40:08 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: Prevent the reuse of a closed stateid
Date: Tue, 17 Oct 2017 16:40:05 -0400
Message-ID: <D68224FD-D466-4DF1-9CBF-EAF03976B9AF@redhat.com>
In-Reply-To: <1508264368.4747.17.camel@redhat.com>
References: <2087b4cab6c695a7df01c1135f1773c9b762f0b0.1508248427.git.bcodding@redhat.com>
 <1508258356.4747.6.camel@redhat.com>
 <F5CCE778-0A1E-4818-8D9B-7F45FC3E7F4B@redhat.com>
 <1508264368.4747.17.camel@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 17 Oct 2017, at 14:19, Jeff Layton wrote:

> On Tue, 2017-10-17 at 13:46 -0400, Benjamin Coddington wrote:
>> On 17 Oct 2017, at 12:39, Jeff Layton wrote:
>>
>>> On Tue, 2017-10-17 at 09:55 -0400, Benjamin Coddington wrote:
>>>> While running generic/089 on NFSv4.1, the following on-the-wire
>>>> exchange
>>>> occurs:
>>>>
>>>> Client                  Server
>>>> ----------              ----------
>>>> OPEN (owner A)  ->
>>>>                     <-  OPEN response: state A1
>>>> CLOSE (state A1)->
>>>> OPEN (owner A)  ->
>>>>                     <-  CLOSE response: state A2
>>>>                     <-  OPEN response: state A3
>>>> LOCK (state A3) ->
>>>>                     <-  LOCK response: NFS4_BAD_STATEID
>>>>
>>>> The server should not be returning state A3 in response to the second
>>>> OPEN
>>>> after processing the CLOSE and sending back state A2.  The problem is
>>>> that
>>>> nfsd4_process_open2() is able to find an existing open state just
>>>> after
>>>> nfsd4_close() has incremented the state's sequence number but before
>>>> calling unhash_ol_stateid().
>>>>
>>>> Fix this by using the state's sc_type field to identify closed state,
>>>> and
>>>> protect the update of that field with st_mutex.
>>>> nfsd4_find_existing_open()
>>>> will return with the st_mutex held, so that the state will not
>>>> transition
>>>> between being looked up and then updated in nfsd4_process_open2().
>>>>
>>>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>>>> ---
>>>>  fs/nfsd/nfs4state.c | 29 +++++++++++++++++++----------
>>>>  1 file changed, 19 insertions(+), 10 deletions(-)
>>>>
>>>
>>> The problem is real, but I'm not thrilled with the fix. It seems more
>>> lock thrashy...
>>
>> Really?  I don't think I increased any call counts to spinlocks or mutex
>> locks.  The locking overhead should be equivalent.
>>
>
> init_open_stateid will now end up taking fi_lock twice.

Yes, that's true unless there's an existing state.

> Also we now have to take the st_mutex in nfsd4_find_existing_open, just to
> check sc_type.  Neither of those are probably unreasonable, it's just
> messier than I'd like.

It is indeed messy.. no argument.  I'll spin up your suggestion to unhash
the stateid before updating and take it for a ride and let you know the
results.  Thanks for looking at this.

Ben
