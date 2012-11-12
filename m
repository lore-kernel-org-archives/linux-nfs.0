Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:1298 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753637Ab2KLVDD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Nov 2012 16:03:03 -0500
Message-ID: <50A163E6.9020604@netapp.com>
Date: Mon, 12 Nov 2012 16:02:30 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Andy Adamson <androsadamson@gmail.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFS: Add sequence_priviliged_ops for nfs4_proc_sequence()
References: <1352745355-31157-1-git-send-email-bjschuma@netapp.com>  <CAHVgHyWyKhjOc4AFY3LvK57k8JK5zNJDkRGwUjqNA4LMYcSzdw@mail.gmail.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA9092D7F52@SACEXCMBX04-PRD.hq.netapp.com>  <CAHVgHyWzO6UxnQEBoBFY4uHxTx9PBHKxP+hvJfYaW-OTqWLgMA@mail.gmail.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092D80BB@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092D80BB@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/12/2012 03:54 PM, Myklebust, Trond wrote:
> On Mon, 2012-11-12 at 15:49 -0500, Andy Adamson wrote:
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
> 
> NFS4_SESSION_DRAINING does not just mean that the session is being
> drained; it remains set until open and lock state recovery is completed.
> 
> IOW: if something happens during state recovery that requires us to
> check the lease (e.g. something returns NFS4ERR_EXPIRED) then the
> current code will deadlock.
> 
>> No matter what the answer, please update the patch description to
>> better explain the problem being solved.
> 
> ACK. I agree that the changelog entry can be improved.
> 

Does this read any better (and should I resend the patch)?

NFS: Add sequence_priviliged_ops for nfs4_proc_sequence()

If I mount an NFS v4.1 server to a single client multiple times and then
run xfstests over each mountpoint I usually get the client into a state
where recovery deadlocks.  The server informs the client of a
cb_path_down sequence error, the client then does a
bind_connection_to_session and checks the status of the lease.

I found that bind_connection_to_session sets the NFS4_SESSION_DRAINING
flag on the client, but this flag is never unset before
nfs4_check_lease() reaches nfs4_proc_sequence().  This causes the client
to deadlock, halting all NFS activity to the server.


