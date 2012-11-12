Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f170.google.com ([209.85.212.170]:40574 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254Ab2KLVIn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 16:08:43 -0500
Received: by mail-wi0-f170.google.com with SMTP id hm9so2631801wib.1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2012 13:08:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50A16144.1040708@netapp.com>
References: <1352745355-31157-1-git-send-email-bjschuma@netapp.com>
	<CAHVgHyWyKhjOc4AFY3LvK57k8JK5zNJDkRGwUjqNA4LMYcSzdw@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9092D7F52@SACEXCMBX04-PRD.hq.netapp.com>
	<CAHVgHyWzO6UxnQEBoBFY4uHxTx9PBHKxP+hvJfYaW-OTqWLgMA@mail.gmail.com>
	<50A16144.1040708@netapp.com>
Date: Mon, 12 Nov 2012 16:08:41 -0500
Message-ID: <CAHVgHyVjerCE6X-fP-CJEAYZdVvvK2NLu=8JuDHa9P+G8L5yzg@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFS: Add sequence_priviliged_ops for nfs4_proc_sequence()
From: Andy Adamson <androsadamson@gmail.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 12, 2012 at 3:51 PM, Bryan Schumaker <bjschuma@netapp.com> wrote:
> On 11/12/2012 03:49 PM, Andy Adamson wrote:
>> On Mon, Nov 12, 2012 at 3:29 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>>> On Mon, 2012-11-12 at 15:22 -0500, Andy Adamson wrote:
>>>> On Mon, Nov 12, 2012 at 1:35 PM,  <bjschuma@netapp.com> wrote:
>>>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>>>>
>>>>> During recovery the NFS4_SESSION_DRAINING flag might be set on the
>>>>> client structure.  This can cause lease renewal to abort when
>>>
>>> Not lease renewal. It is lease verification (i.e. checking that we have
>>> a valid lease and session) that will deadlock.
>>>
>>>>> nfs41_setup_sequence sees that we are doing recovery.  As a result, the
>>>>> client never recovers and all activity with the NFS server halts.
>>>>
>>>>
>>>> When does this happen? Say the session is draining, and an RPC returns
>>>> from one of the compounds such as nfs_open, nfs_locku etc whose
>>>> rpc_call_done routine calls renew_lease after freeing it's slot.  Like
>>>> all calls on a draining session, the renew_lease sleeps on the session
>>>> slot_tbl_waitq - is this what you mean by "causes lease renewal to
>>>> abort"? How does this cause the client to never recover?
>>>>
>>>> The only other call to renew_lease is from the state manager itself
>>>> which runs one function at a time, and will not call renew_lease until
>>>> the recovery is over....
>>>>
>>>> What am I missing....?
>>>
>>> nfs4_check_lease() is run exclusively by the state manager thread in
>>> order to check that the clientid (and session id on NFSv4.1) are valid.
>>> It will deadlock the state manager thread if NFS4_SESSION_DRAINING is
>>> already set.
>>
>> OK. NFS4_SESSION_DRAINING is also set exclusively by the state manager
>> thread. Why is the state manager told to check the lease when it's
>> also draining a session?

Here is the call in the state manager.

                if (test_and_clear_bit(NFS4CLNT_BIND_CONN_TO_SESSION,
                                &clp->cl_state)) {
                        section = "bind conn to session";
                        status = nfs4_bind_conn_to_session(clp);
                        if (status < 0)
                                goto out_error;
                        continue;
                }

nfs4_bind_conn_to_session calls nfs4_begin_drain_session. The error
case is fine - nfs4_end_drain_session is called in out_error.

But the continue when nfs4_bind_conn_to_session succeeds can send the
state manager to process other flags (such as NFS4CLNT_CHECK_LEASE)
without a call to nfs4_end_drain_session.

That looks like a bug to me. The same can occur with
NFS4CLNT_RECALL_SLOT. Why not just call nfs4_end_drain_session prior
to the continue, or perhaps remove the continue and hit the
nfs4_end_drain_session call further down in the state manager loop?

-->Andy

>>
>> No matter what the answer, please update the patch description to
>> better explain the problem being solved.
>
> Yeah, I was just thinking about doing that.  Give me a few minutes...


>
> - Bryan
>
>>
>> -->Andy
>>
>>>
>>>> -->Andy
>>>>
>>>>
>>>>>
>>>>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>>>>> ---
>>>>>  fs/nfs/nfs4proc.c | 21 +++++++++++++++++----
>>>>>  1 file changed, 17 insertions(+), 4 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>>> index 5eec442..537181c 100644
>>>>> --- a/fs/nfs/nfs4proc.c
>>>>> +++ b/fs/nfs/nfs4proc.c
>>>>> @@ -6138,13 +6138,26 @@ static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
>>>>>         rpc_call_start(task);
>>>>>  }
>>>>>
>>>>> +static void nfs41_sequence_prepare_privileged(struct rpc_task *task, void *data)
>>>>> +{
>>>>> +       rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
>>>>> +       nfs41_sequence_prepare(task, data);
>>>>> +}
>>>>> +
>>>>>  static const struct rpc_call_ops nfs41_sequence_ops = {
>>>>>         .rpc_call_done = nfs41_sequence_call_done,
>>>>>         .rpc_call_prepare = nfs41_sequence_prepare,
>>>>>         .rpc_release = nfs41_sequence_release,
>>>>>  };
>>>>>
>>>>> -static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
>>>>> +static const struct rpc_call_ops nfs41_sequence_privileged_ops = {
>>>>> +       .rpc_call_done = nfs41_sequence_call_done,
>>>>> +       .rpc_call_prepare = nfs41_sequence_prepare_privileged,
>>>>> +       .rpc_release = nfs41_sequence_release,
>>>>> +};
>>>>> +
>>>>> +static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred,
>>>>> +                                            const struct rpc_call_ops *seq_ops)
>>>>>  {
>>>>>         struct nfs4_sequence_data *calldata;
>>>>>         struct rpc_message msg = {
>>>>> @@ -6154,7 +6167,7 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_
>>>>>         struct rpc_task_setup task_setup_data = {
>>>>>                 .rpc_client = clp->cl_rpcclient,
>>>>>                 .rpc_message = &msg,
>>>>> -               .callback_ops = &nfs41_sequence_ops,
>>>>> +               .callback_ops = seq_ops,
>>>>>                 .flags = RPC_TASK_ASYNC | RPC_TASK_SOFT,
>>>>>         };
>>>>>
>>>>> @@ -6181,7 +6194,7 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cr
>>>>>
>>>>>         if ((renew_flags & NFS4_RENEW_TIMEOUT) == 0)
>>>>>                 return 0;
>>>>> -       task = _nfs41_proc_sequence(clp, cred);
>>>>> +       task = _nfs41_proc_sequence(clp, cred, &nfs41_sequence_ops);
>>>>>         if (IS_ERR(task))
>>>>>                 ret = PTR_ERR(task);
>>>>>         else
>>>>> @@ -6195,7 +6208,7 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
>>>>>         struct rpc_task *task;
>>>>>         int ret;
>>>>>
>>>>> -       task = _nfs41_proc_sequence(clp, cred);
>>>>> +       task = _nfs41_proc_sequence(clp, cred, &nfs41_sequence_privileged_ops);
>>>>>         if (IS_ERR(task)) {
>>>>>                 ret = PTR_ERR(task);
>>>>>                 goto out;
>>>>> --
>>>>> 1.8.0
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> --
>>> Trond Myklebust
>>> Linux NFS client maintainer
>>>
>>> NetApp
>>> Trond.Myklebust@netapp.com
>>> www.netapp.com
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
