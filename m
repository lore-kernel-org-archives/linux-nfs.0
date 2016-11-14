Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60778 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751496AbcKNOyT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Nov 2016 09:54:19 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "jlayton@redhat.com" <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: CLOSE/OPEN race
Date: Mon, 14 Nov 2016 09:53:28 -0500
Message-ID: <8153C306-D6B6-442B-B565-BC6BAEE9993F@redhat.com>
In-Reply-To: <1479048471.3146.10.camel@primarydata.com>
References: <9E2B8A0D-7B0E-4AE5-800A-0EF3F7F7F694@redhat.com>
 <1478955250.2442.16.camel@redhat.com>
 <B050FA3F-5D9A-4053-BB9E-7668814846B7@redhat.com>
 <1478969565.2442.18.camel@redhat.com>
 <98C04570-5E22-4F6D-80AF-FA6EE48ED489@redhat.com>
 <1478985360.2442.29.camel@redhat.com> <1479005770.8210.4.camel@redhat.com>
 <1479048471.3146.10.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 13 Nov 2016, at 9:47, Trond Myklebust wrote:

> On Sat, 2016-11-12 at 21:56 -0500, Jeff Layton wrote:
>> On Sat, 2016-11-12 at 16:16 -0500, Jeff Layton wrote:
>>>
>>> On Sat, 2016-11-12 at 13:03 -0500, Benjamin Coddington wrote:
>>>>
>>>>
>>>> On 12 Nov 2016, at 11:52, Jeff Layton wrote:
>>>>
>>>>>
>>>>>
>>>>> On Sat, 2016-11-12 at 10:31 -0500, Benjamin Coddington wrote:
>>>>>>
>>>>>>
>>>>>> On 12 Nov 2016, at 7:54, Jeff Layton wrote:
>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> On Sat, 2016-11-12 at 06:08 -0500, Benjamin Coddington
>>>>>>> wrote:
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>> I've been seeing the following on a modified version of
>>>>>>>> generic/089
>>>>>>>> that gets the client stuck sending LOCK with
>>>>>>>> NFS4ERR_OLD_STATEID.
>>>>>>>>
>>>>>>>> 1. Client has open stateid A, sends a CLOSE
>>>>>>>> 2. Client sends OPEN with same owner
>>>>>>>> 3. Client sends another OPEN with same owner
>>>>>>>> 4. Client gets a reply to OPEN in 3, stateid is B.2
>>>>>>>> (stateid B
>>>>>>>> sequence 2)
>>>>>>>> 5. Client does LOCK,LOCKU,FREE_STATEID from B.2
>>>>>>>> 6. Client gets a reply to CLOSE in 1
>>>>>>>> 7. Client gets reply to OPEN in 2, stateid is B.1
>>>>>>>> 8. Client sends LOCK with B.1 - OLD_STATEID, now stuck in
>>>>>>>> a loop
>>>>>>>>
>>>>>>>> The CLOSE response in 6 causes us to clear
>>>>>>>> NFS_OPEN_STATE, so that
>>>>>>>> the OPEN
>>>>>>>> response in 7 is able to update the open_stateid even
>>>>>>>> though it has a
>>>>>>>> lower
>>>>>>>> sequence number.
>>>>>>>>
>>>>>>>> I think this case could be handled by never updating the
>>>>>>>> open_stateid
>>>>>>>> if the
>>>>>>>> stateids match but the sequence number of the new state
>>>>>>>> is less than
>>>>>>>> the
>>>>>>>> current open_state.
>>>>>>>>
>>>>>>>
>>>>>>> What kernel is this on?
>>>>>>
>>>>>> On v4.9-rc2 with a couple fixups.  Without them, I can't test
>>>>>> long
>>>>>> enough to
>>>>>> reproduce this race.  I don't think any of those are involved
>>>>>> in this
>>>>>> problem, though.
>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> Yes, that seems wrong. The client should be picking B.2 for
>>>>>>> the open
>>>>>>> stateid to use. I think that decision of whether to take a
>>>>>>> seqid is
>>>>>>> made
>>>>>>> in nfs_need_update_open_stateid. The logic in there looks
>>>>>>> correct to
>>>>>>> me
>>>>>>> at first glance though.
>>>>>>
>>>>>> nfs_need_update_open_stateid() will return true if
>>>>>> NFS_OPEN_STATE is
>>>>>> unset.
>>>>>> That's the precondition set up by steps 1-6.  Perhaps it
>>>>>> should not
>>>>>> update
>>>>>> the stateid if they match but the sequence number is less,
>>>>>> and still set
>>>>>> NFS_OPEN_STATE once more.  That will fix _this_ case.  Are
>>>>>> there other
>>>>>> cases
>>>>>> where that would be a problem?
>>>>>>
>>>>>> Ben
>>>>>
>>>>> That seems wrong.
>>>>
>>>> I'm not sure what you mean: what seems wrong?
>>>>
>>>
>>> Sorry, it seems wrong that the client would issue the LOCK with B.1
>>> there.
>>>
>>>>
>>>>>
>>>>>
>>>>> The only close was sent in step 1, and that was for a
>>>>> completely different stateid (A rather than B). It seems likely
>>>>> that
>>>>> that is where the bug is.
>>>>
>>>> I'm still not sure what point you're trying to make..
>>>>
>>>> Even though the close was sent in step 1, the response wasn't
>>>> processed
>>>> until step 6..
>>>
>>> Not really a point per-se, I was just saying where I think the bug
>>> might
>>> be...
>>>
>>> When you issue a CLOSE, you issue it vs. a particular stateid
>>> (stateid
>>> "A" in this case). Once the open stateid has been superseded by
>>> "B", the
>>> closing of "A" should have no effect.
>>>
>>> Perhaps nfs_clear_open_stateid needs to check and see whether the
>>> open
>>> stateid has been superseded before doing its thing?
>>>
>>
>> Ok, I see something that might be a problem in this call in
>> nfs4_close_done:
>>
>>        nfs_clear_open_stateid(state, &calldata->arg.stateid,
>>                         res_stateid, 
>> calldata->arg.fmode);
>>
>> Note that we pass two nfs4_stateids to this call. The first is the
>> stateid that got sent in the CLOSE call, and the second is the
>> stateid
>> that came back in the CLOSE response.
>>
>> RFC5661 and RFC7530 both indicate that the stateid in a CLOSE
>> response
>> should be ignored.
>>
>> So, I think a patch like this may be in order. As to whether it will
>> fix this bug, I sort of doubt it, but it might not hurt to test it
>> out?
>>
>> ----------------------8<--------------------------
>>
>> [RFC PATCH] nfs: properly ignore the stateid in a CLOSE response
>>
>> Signed-off-by: Jeff Layton 
>> ---
>>  fs/nfs/nfs4proc.c | 14 +++-----------
>>  1 file changed, 3 insertions(+), 11 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 7897826d7c51..58413bd0aae2 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1451,7 +1451,6 @@ static void
>> nfs_resync_open_stateid_locked(struct nfs4_state *state)
>>  }
>>  
>>  static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
>> -		nfs4_stateid *arg_stateid,
>>  		nfs4_stateid *stateid, fmode_t fmode)
>>  {
>>  	clear_bit(NFS_O_RDWR_STATE, &state->flags);
>> @@ -1467,12 +1466,8 @@ static void
>> nfs_clear_open_stateid_locked(struct nfs4_state *state,
>>  		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
>>  		clear_bit(NFS_OPEN_STATE, &state->flags);
>>  	}
>> -	if (stateid == NULL)
>> -		return;
>>  	/* Handle races with OPEN */
>> -	if (!nfs4_stateid_match_other(arg_stateid, &state-
>>> open_stateid) ||
>> -	    (nfs4_stateid_match_other(stateid, &state->open_stateid)
>> &&
>> -	    !nfs4_stateid_is_newer(stateid, &state->open_stateid)))
>> {
>> +	if (!nfs4_stateid_match_other(stateid, &state-
>>> open_stateid)) {
>
> No. I think what we should be doing here is
>
> 1) if (nfs4_stateid_match_other(arg_stateid, &state->open_stateid) 
> then

You must mean (!nfs4_stateid_match_other(arg_stateid, 
&state->open_stateid)

> just ignore the result and return immediately, because it applies to a
> completely different stateid.
>
> 2) if (nfs4_stateid_match_other(stateid, &state->open_stateid)
> && !nfs4_stateid_is_newer(stateid, &state->open_stateid))) then 
> resync,
> because this was likely an OPEN_DOWNGRADE that has raced with one or
> more OPEN calls.

OK, but these do not help the originally reported race because at the 
time
that the CLOSE response handling does a resync - I presume
nfs_resync_open_stateid_locked() - all the state counters are zero, 
which
bypasses resetting NFS_OPEN_STATE, which, if unset, allows any stateid 
to
update the open_stateid.

I need something like:

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a230764b7d07..c9aa166c45aa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1425,8 +1425,13 @@ static void 
nfs_test_and_clear_all_open_stateid(struct nfs4_state *state)
  static bool nfs_need_update_open_stateid(struct nfs4_state *state,
                 const nfs4_stateid *stateid, nfs4_stateid *freeme)
  {
-       if (test_and_set_bit(NFS_OPEN_STATE, &state->flags) == 0)
+       if (test_and_set_bit(NFS_OPEN_STATE, &state->flags) == 0) {
+               if (nfs4_stateid_match_other(stateid, 
&state->open_stateid) &&
+                       !nfs4_stateid_is_newer(stateid, 
&state->open_stateid))
+                       return false;
                 return true;
+       }
+
         if (!nfs4_stateid_match_other(stateid, &state->open_stateid)) {
                 nfs4_stateid_copy(freeme, &state->open_stateid);
                 nfs_test_and_clear_all_open_stateid(state);

I've got that in testing, and I'll let it run for a day or so.

Another way to simplify CLOSE/OPEN races might be to never reuse an
openowner if we send a close.  Any opens after a close would have to use 
a
new mutated openowner, so the state always proceeds from open to close 
and
never back again.  Any reason not to do that?

Ben
