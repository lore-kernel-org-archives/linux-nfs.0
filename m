Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:55285 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbaEWQlx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 12:41:53 -0400
Received: by mail-vc0-f180.google.com with SMTP id hy4so6405037vcb.25
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 09:41:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSLUVdC7XYTwUrME_kf_v_G+4qiyufTr-KYt-v_uSiz3w@mail.gmail.com>
References: <1400851379-34474-1-git-send-email-andros@netapp.com>
	<CAHQdGtR8A=O75V-oQnU8w9iTeFFrTMuFCTJgC_uGn6iZmOjeKA@mail.gmail.com>
	<CAHVgHyW8JsnD7s9fVvrOy6WFtKMiHVFdqyEivjna-=7i8NqNfw@mail.gmail.com>
	<CAHQdGtSLUVdC7XYTwUrME_kf_v_G+4qiyufTr-KYt-v_uSiz3w@mail.gmail.com>
Date: Fri, 23 May 2014 12:41:51 -0400
Message-ID: <CAHVgHyUb-_TEEXC3V=sTf+gDUhj8bwS3ndDEZdoxJC7ayX76vg@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv4: Use error handler on failed GETATTR with
 successful OPEN
From: Andy Adamson <androsadamson@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 23, 2014 at 11:26 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> OK. So I read you as saying that there are 2 problems here.
>
> Problem 1: we handle the EAGAIN return value from
> _nfs4_opendata_to_nfs4_state incorrectly by retrying the whole OPEN.
>
> Problem 2: the backup GETATTR call to the server may also fail with
> transient errors such as NFS4ERR_DELAY.
>
> Your patch addresses problem 2, but isn't a fix for problem 1. Correct?

Yes.

The -EAGAIN in _nfs4_opendata_to_nfs4_state is set if only the GETATTR
in the open compound fails and so there is no FATTR info, OR if
nfs_fhget returns an error.

rfc 5661 errors:

GETATTR              | NFS4ERR_ACCESS, NFS4ERR_BADXDR,            |
   |                      | NFS4ERR_DEADSESSION, NFS4ERR_DELAY,        |
   |                      | NFS4ERR_FHEXPIRED, NFS4ERR_GRACE,          |
   |                      | NFS4ERR_INVAL, NFS4ERR_IO, NFS4ERR_MOVED,  |
   |                      | NFS4ERR_NOFILEHANDLE,                      |
   |                      | NFS4ERR_OP_NOT_IN_SESSION,                 |
   |                      | NFS4ERR_REP_TOO_BIG,                       |
   |                      | NFS4ERR_REP_TOO_BIG_TO_CACHE,              |
   |                      | NFS4ERR_REQ_TOO_BIG,                       |
   |                      | NFS4ERR_RETRY_UNCACHED_REP,                |
   |                      | NFS4ERR_SERVERFAULT, NFS4ERR_STALE,        |
   |                      | NFS4ERR_TOO_MANY_OPS, NFS4ERR_WRONG_TYPE   |


The embedded GETATTR in the open compound can only reasonably get this
subset, as the rest would be triggered by previous ops in the
compound, or by bad coding on the client or server :)

NFS4ERR_DELAY
NFS4ERR_IO
NFS4ERR_MOVED
NFS4ERR_SERVERFAULT

So AFAICS of these errors would need to be hit to trigger the -EAGAIN
being returned by _nfs4_opendata_to_nfs4_state for no FATTR info.
NFS4ERR_MOVED is also handled with my patch which leaves NFS4ERR_IO
and NFS4ERR_SERVERFAULT. This means that the server had it together
enough to return a successful OPEN, but failed for some reason to
service the GETATTR. It's difficult to figure out what to do in that
case.

I have not addressed the case where nfs_fhget returns an error which
also triggers an -EAGAIN and so a resend of the OPEN. Note that a lot
of the errors returned by  nfs_fhget have to do with the FATTR being
incomplete or inconsistent.

In summary, for GETATTR errors that are not handled by placing the
_nfs4_do_open getattr call under the handler, and for nfs_fhget calls
that fail in _nfs4_opendata_to_nfs4_state, the code will replay OPEN
compounds where as far as the server is concerned, the file is already
opened.

>
> Another question: why is the replay of the OPEN failing? Is this a
> NFSv4.1 GUARDED exclusive create? AFAICS anything else should replay
> just fine.

Nope. A replay of  EXCLUSIVE4 or EXCLUSIVE4_1 requires a resend with
the same verifier for the server to not return NFS4ERR_EXIST, and when
the current code retries it goes through nfs_opendata_alloc which
creates a new verifier.

So a patch that re-uses the verifier in EXCLUSIVE4 and EXCLUSIVE4_1
opens would leave only GUARDED4 exclusive creates that would fail with
a replay.


-->Andy

>
>
> On Fri, May 23, 2014 at 10:50 AM, Andy Adamson <androsadamson@gmail.com> wrote:
>> On Fri, May 23, 2014 at 9:55 AM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> On Fri, May 23, 2014 at 9:22 AM,  <andros@netapp.com> wrote:
>>>> From: Andy Adamson <andros@netapp.com>
>>>>
>>>> Place the call to resend the failed GETATTR under the error handler so that
>>>> when appropriate, the GETATTR is retried more than once.
>>>>
>>>> The server can fail the GETATTR op in the OPEN compound with a recoverable
>>>> error such as NFS4ERR_DELAY. In the case of an O_EXCL open, the server has
>>>> created the file, so a retrans of the OPEN call will fail with NFS4ERR_EXIST.
>>>>
>>>
>>> Why would the client retransmit the open in this case?
>>
>> It happens an _all_ cases where there is no FATTR, and the open
>> compound GETATTR error is NFS4ERR_DELAY more than two times
>>
>> After the 2nd NFS4ERR_DELAY error on the GETATTR in an OPEN compound:
>> (First one on the original OPEN, the second on the single
>> _nfs4_proc_gettattr call)
>>
>> nfs4_do_open returns with no FATTR info,  so the call to nfs_fhget in
>> _nfs4_opendata_to_nfs4_state
>> fails with -EAGAIN
>>
>>         ret = -EAGAIN;
>>         if (!(data->f_attr.valid & NFS_ATTR_FATTR))
>>                 goto err;
>>
>>
>> which gets propagated through  nfs4_opendata_to_nfs4_state,
>> _nfs4_open_and_get_state,  to  _nfs4_do_open.
>>
>> Then  nfs4_do_open handles the -EAGAIN error by retrying the open compound:
>>
>>
>>                if (status == -EAGAIN) {
>>                         /* We must have found a delegation */ <<<< Get rid of
>>                         exception.retry = 1;
>>                         continue;
>>                 }
>>
>>
>>> We don't use
>>> the return value from the getattr call,
>>
>> Yes, which is why the patch title has 'failed GETTATR' and
>> 'successful OPEN' in it.
>>
>>>  so the callers of
>>> _nfs4_proc_open() will never see the NFS4ERR_DELAY.
>>
>> The NFS4ERR_DELAY is returned on the GETATTR, not the OPEN.
>>
>> My question is why not call nfs4_proc_getattr under the error handler?
>> Even if a GETATTR on a non-create OPEN gets an NFS4ERR_DELAY, the
>> client may not have an inode for this file handle, and can't get one
>> without the FATTR info.
>>
>> AFAICS there is never a reason to resend an OPEN compound that has a
>> successful OPEN and a failed GETATTR.
>>
>> -->Andy
>>
>>>
>>>
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> ---
>>>>  fs/nfs/nfs4proc.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>> index 397be39..be1b305 100644
>>>> --- a/fs/nfs/nfs4proc.c
>>>> +++ b/fs/nfs/nfs4proc.c
>>>> @@ -2027,7 +2027,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
>>>>                         return status;
>>>>         }
>>>>         if (!(o_res->f_attr->valid & NFS_ATTR_FATTR))
>>>> -               _nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr, o_res->f_label);
>>>> +               nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr, o_res->f_label);
>>>>         return 0;
>>>>  }
>>>>
>>>> --
>>>> 1.8.3.1
>>>>
>>>
>>>
>>>
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
