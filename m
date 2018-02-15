Return-Path: <tigran.mkrtchyan@desy.de>
Date: Thu, 15 Feb 2018 13:19:09 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
	linux-nfs <linux-nfs@vger.kernel.org>,
	Benjamin Coddington <bcodding@redhat.com>,
	Jeff Layton <jlayton@redhat.com>
Message-ID: <159288847.6126985.1518697149126.JavaMail.zimbra@desy.de>
In-Reply-To: <CAN-5tyGEn3vGJicR+00ATSp7PzUEm_6FzjBwYwiS-++OcqqfaA@mail.gmail.com>
References: <1479140396-17779-1-git-send-email-trond.myklebust@primarydata.com> <1479140396-17779-2-git-send-email-trond.myklebust@primarydata.com> <CAN-5tyGEn3vGJicR+00ATSp7PzUEm_6FzjBwYwiS-++OcqqfaA@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv4: Fix CLOSE races with OPEN
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Olga Kornievskaia" <aglo@umich.edu>
> To: "Trond Myklebust" <trond.myklebust@primarydata.com>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "Benjamin Coddington" <bcodding@redhat.com>, "Jeff Layton"
> <jlayton@redhat.com>
> Sent: Tuesday, February 13, 2018 9:08:01 PM
> Subject: Re: [PATCH 1/2] NFSv4: Fix CLOSE races with OPEN

> On Mon, Nov 14, 2016 at 11:19 AM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> If the reply to a successful CLOSE call races with an OPEN to the same
>> file, we can end up scribbling over the stateid that represents the
>> new open state.
>> The race looks like:
>>
>>   Client                                Server
>>   ======                                ======
>>
>>   CLOSE stateid A on file "foo"
>>                                         CLOSE stateid A, return stateid C
> 
> Hi folks,
> 
> I'd like to understand this particular issue. Specifically I don't
> understand how can server return stateid C to the close with stateid
> A.
> 
> As per RFC 7530 or 5661. It says that state is returned by the close
> shouldn't be used.
> 
> Even though CLOSE returns a stateid, this stateid is not useful to
>   the client and should be treated as deprecated.  CLOSE "shuts down"
>   the state associated with all OPENs for the file by a single
>   open-owner.  As noted above, CLOSE will either release all file
>   locking state or return an error.  Therefore, the stateid returned by
>   CLOSE is not useful for the operations that follow.
> 
> Is this because the spec says "should" and not a "must"?
> 
> Linux server increments a state's sequenceid on CLOSE. Ontap server
> does not. I'm not sure what other servers do. Are all these


Our server sends back invalid state id for v4.1 and v4.0.

Tigran.

> implementations equality correct?
> 
>>   OPEN file "foo"
>>                                         OPEN "foo", return stateid B
>>   Receive reply to OPEN
>>   Reset open state for "foo"
>>   Associate stateid B to "foo"
>>
>>   Receive CLOSE for A
>>   Reset open state for "foo"
>>   Replace stateid B with C
>>
>> The fix is to examine the argument of the CLOSE, and check for a match
>> with the current stateid "other" field. If the two do not match, then
>> the above race occurred, and we should just ignore the CLOSE.
>>
>> Reported-by: Benjamin Coddington <bcodding@redhat.com>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfs/nfs4_fs.h  |  7 +++++++
>>  fs/nfs/nfs4proc.c | 12 ++++++------
>>  2 files changed, 13 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>> index 9b3a82abab07..1452177c822d 100644
>> --- a/fs/nfs/nfs4_fs.h
>> +++ b/fs/nfs/nfs4_fs.h
>> @@ -542,6 +542,13 @@ static inline bool nfs4_valid_open_stateid(const struct
>> nfs4_state *state)
>>         return test_bit(NFS_STATE_RECOVERY_FAILED, &state->flags) == 0;
>>  }
>>
>> +static inline bool nfs4_state_match_open_stateid_other(const struct nfs4_state
>> *state,
>> +               const nfs4_stateid *stateid)
>> +{
>> +       return test_bit(NFS_OPEN_STATE, &state->flags) &&
>> +               nfs4_stateid_match_other(&state->open_stateid, stateid);
>> +}
>> +
>>  #else
>>
>>  #define nfs4_close_state(a, b) do { } while (0)
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index f550ac69ffa0..b7b0080977c0 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1458,7 +1458,6 @@ static void nfs_resync_open_stateid_locked(struct
>> nfs4_state *state)
>>  }
>>
>>  static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
>> -               nfs4_stateid *arg_stateid,
>>                 nfs4_stateid *stateid, fmode_t fmode)
>>  {
>>         clear_bit(NFS_O_RDWR_STATE, &state->flags);
>> @@ -1476,10 +1475,9 @@ static void nfs_clear_open_stateid_locked(struct
>> nfs4_state *state,
>>         }
>>         if (stateid == NULL)
>>                 return;
>> -       /* Handle races with OPEN */
>> -       if (!nfs4_stateid_match_other(arg_stateid, &state->open_stateid) ||
>> -           (nfs4_stateid_match_other(stateid, &state->open_stateid) &&
>> -           !nfs4_stateid_is_newer(stateid, &state->open_stateid))) {
>> +       /* Handle OPEN+OPEN_DOWNGRADE races */
>> +       if (nfs4_stateid_match_other(stateid, &state->open_stateid) &&
>> +           !nfs4_stateid_is_newer(stateid, &state->open_stateid)) {
>>                 nfs_resync_open_stateid_locked(state);
>>                 return;
>>         }
>> @@ -1493,7 +1491,9 @@ static void nfs_clear_open_stateid(struct nfs4_state
>> *state,
>>         nfs4_stateid *stateid, fmode_t fmode)
>>  {
>>         write_seqlock(&state->seqlock);
>> -       nfs_clear_open_stateid_locked(state, arg_stateid, stateid, fmode);
>> +       /* Ignore, if the CLOSE argment doesn't match the current stateid */
>> +       if (nfs4_state_match_open_stateid_other(state, arg_stateid))
>> +               nfs_clear_open_stateid_locked(state, stateid, fmode);
>>         write_sequnlock(&state->seqlock);
>>         if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
>>                 nfs4_schedule_state_manager(state->owner->so_server->nfs_client);
>> --
>> 2.7.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
