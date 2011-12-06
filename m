Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56343 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043Ab1LFVrC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2011 16:47:02 -0500
Received: by bkbzv3 with SMTP id zv3so4032468bkb.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 13:47:00 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <20111206191000.GB10255@fieldses.org>
References: <1323000237-13565-1-git-send-email-tigran.mkrtchyan@desy.de>
	<1323000237-13565-3-git-send-email-tigran.mkrtchyan@desy.de>
	<4EDB6AA3.1030702@tonian.com>
	<20111206020851.GA4486@fieldses.org>
	<4EDDFBCD.3010608@tonian.com>
	<20111206124056.GA8657@fieldses.org>
	<4EDE2701.7020801@tonian.com>
	<20111206191000.GB10255@fieldses.org>
Date: Tue, 6 Dec 2011 22:47:00 +0100
Message-ID: <CAGue13pcH+ASY=fLFqg-F4v_0eyE9TZHr4ddgv4-5emeQh2nug@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfsv41: handle current stateid on open and close
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Benny Halevy <bhalevy@tonian.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 6, 2011 at 8:10 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Dec 06, 2011 at 04:30:25PM +0200, Benny Halevy wrote:
>> On 2011-12-06 14:40, J. Bruce Fields wrote:
>> > On Tue, Dec 06, 2011 at 01:26:05PM +0200, Benny Halevy wrote:
>> >> On 2011-12-06 04:08, J. Bruce Fields wrote:
>> >>> On Sun, Dec 04, 2011 at 02:42:11PM +0200, Benny Halevy wrote:
>> >>>> On 2011-12-04 14:03, tigran.mkrtchyan@desy.de wrote:
>> >>>>> From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> >>>>>
>> >>>>>
>> >>>>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> >>>>> ---
>> >>>>>  fs/nfsd/nfs4proc.c  |    6 ++++++
>> >>>>>  fs/nfsd/nfs4state.c |   26 ++++++++++++++++++++------
>> >>>>>  2 files changed, 26 insertions(+), 6 deletions(-)
>> >>>>>
>> >>>>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> >>>>> index fa38336..535aed2 100644
>> >>>>> --- a/fs/nfsd/nfs4proc.c
>> >>>>> +++ b/fs/nfsd/nfs4proc.c
>> >>>>> @@ -400,6 +400,12 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> >>>>>          */
>> >>>>>         status = nfsd4_process_open2(rqstp, &cstate->current_fh, open);
>> >>>>>         WARN_ON(status && open->op_created);
>> >>>>> +
>> >>>>> +       if(status)
>> >>>>> +               goto out;
>> >>>>> +
>> >>>>> +       /* set current state id */
>> >>>>> +       memcpy(&cstate->current_stateid, &open->op_stateid, sizeof(stateid_t));
>> >>>
>> >>> That comment is a bit redundant.
>> >>>
>> >>>> Since this should be done for all stateid-returning operations
>> >>>> I think that a cleaner approach could be to mark those as such in
>> >>>> nfsd4_ops by providing a per-op function to return the operation's
>> >>>> stateid.  You can then call this method from nfsd4_proc_compound()
>> >>>> after the call to nfsd4_encode_operation() and when status == 0.
>> >>>
>> >>> So the choice is between
>> >>>
>> >>> +       memcpy(&cstate->current_stateid, &open->op_stateid,
>> >>> sizeof(stateid_t));
>> >>>
>> >>> and
>> >>>
>> >>> +       static void get_open_stateid(stateid_t *s)
>> >>> +       {
>> >>> +               memcpy(s, open->op_stateid);
>> >>> +       }
>> >>> +
>> >>> +       [OP_OPEN] = {
>> >>> +               ...
>> >>> +               .op_get_stateid = get_open_stateid,
>> >>> +               ...
>> >>> +       }
>> >>>
>> >>> ?
>> >>>
>> >>> I'm not so sure.
>> >>
>> >> The point is to copy the result stateid into the current_stateid
>> >> in a centralized place: nfsd4_proc_compound() and do that for all
>> >> stateid-modifying operations.
>> >>
>> >>>
>> >>> Anyway, thanks Tigran for looking at this.
>> >>>
>> >>> Do we want to guarantee that the client can't expire as long as a
>> >>> compound references the stateid?  I think that's the case.
>> >>
>> >> The client can't time out while the 4.1 compound is in progress, see commit d768298.
>> >
>> > OK, you're right, and presumably it would be a bug for a compound to use
>> > a session from one client and a stateid from another, so this is taken
>> > care of.  (Except--I think we need to check for that case.  On a quick
>> > skim I don't see the current code doing that.)
>> >
>> > Thanks!
>> >
>> >> Are you thinking of explicit expiration of the client?
>> >> We may unhash the client and keep using it while it's referenced
>> >> so that's not a problem.  As far as the stateid goes, we're copying the
>> >> value of the stateid, not pointing to any stateid structure.  If the
>> >> actual state was destroyed, we will detect that when the current_stateid
>> >> is used by any successive operation and we cannot find the state using
>> >> the stateid.
>> >
>> > I *think* the concensus of the working group was that explicit
>> > destruction of a client should wait on in-progress compounds referencing
>> > any of the client's sessions:
>> >
>> >     http://www.ietf.org/mail-archive/web/nfsv4/current/msg08584.html
>>
>> I'm a bit confused, since the rfc5661 says that:
>>
>> DESTROY_CLIENTID:
>> If there are
>>    sessions (both idle and non-idle), opens, locks, delegations,
>>    layouts, and/or wants (Section 18.49) associated with the unexpired
>>    lease of the client ID, the server MUST return NFS4ERR_CLIENTID_BUSY.
>
> Hm.  The case Mike Eisler mentions in the message referenced above is
> EXCHANGE_ID/CREATE_SESSION.
>
> But he also proposes some text for DESTROY_CLIENTID that contradicts the
> text you quote above.
>
> I guess that's intentional--he's worried about not being able to shut
> down a client cleanly after a cluster node goes down.
>
> Still, whatever behavior we decide to implement on the server, we may
> want to run it by the ietf list before we're done to make sure there's
> an agreement here....
>
>> DESTROY_SESSION:
>> Locks, delegations, layouts, wants, and the lease, which
>>    are all tied to the client ID, are not affected by DESTROY_SESSION.
>
> But that doesn't explain what to do about in-progress operations.  So if
> you the DESTROY_SESSION comes while we're in the middle of processing a
> rename using that session, what do we do?
>
> In any case, Tigran's work doesn't need to block on any of this.

Please have a look at new patch. If it the line which you prefer I
will complete it.

Tigran.
>
> --b.
>
>>
>> >
>> > So we should probably fix this.  But we can fix it at the session level.
>> >
>> > So, OK, I can't see any practical objection to doing as Tigran as and
>> > just passing the value of stateid instead of a reference to some object.
>> >
>> > Well, except for performance--it seems unfortunate to have to redo the
>> > lookup on each use.  As long as there's no impact on the existing cases
>> > (so we're only doing the lookup when a client actually uses the current
>> > stateid), I can live with that until somebody actually demonstrates some
>> > harm.
>>
>> Great. I'm glad we're in agreement!
>>
>> Benny
>>
>> >
>> > --b.
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
