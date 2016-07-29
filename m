Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:36923 "EHLO
	mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbcG2WYt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2016 18:24:49 -0400
Received: by mail-it0-f50.google.com with SMTP id f6so120391138ith.0
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2016 15:24:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <783DF5CA-AE7E-4F0B-ACCE-1562EC3B7B65@netapp.com>
References: <59704D2B-9FBD-41BB-ADA8-4CF4AEF4BB9D@oracle.com>
 <259CD26A-E1E7-44CA-B1D3-F46AED01B932@netapp.com> <CAN-5tyE_yrspQDpftO1Ls9LxjaZPHGe9hH0V65xaFuNEyrbwig@mail.gmail.com>
 <6BC3C19E-6F44-4C38-BF26-3E9A948D305C@oracle.com> <CAN-5tyHWPvNeq-0kNErTY+nENqkfrbGXwutcMgaOYcvYL3fX7Q@mail.gmail.com>
 <42FD3D54-79F9-485A-A2B4-FBFA65C2FC16@oracle.com> <CAN-5tyGJ8YUesk-KBTK+DFqaRV9wNvjQp-4EkcoU4J58EmM7_A@mail.gmail.com>
 <CAN-5tyEyg4aYXc5Zr-diLHxhkU1VnvYaaKS01qCH-vtxa8qzqg@mail.gmail.com>
 <CC879117-DCA5-4BC1-8A70-FA859546CD01@oracle.com> <CAN-5tyGnK7Zus2pBg5dO__XZ8NrM_h9k4EXzJERneHBBnn6VPg@mail.gmail.com>
 <CAN-5tyGJQXrLm7L98UgJULT=gQjsuVM86KGwEkGPuS8GBTAGrA@mail.gmail.com>
 <9E866C53-DD4B-419E-ABF0-64B04609C066@oracle.com> <6B77F70A-9AD0-4085-A90F-3AE795AA3717@netapp.com>
 <783DF5CA-AE7E-4F0B-ACCE-1562EC3B7B65@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 29 Jul 2016 18:24:48 -0400
Message-ID: <CAN-5tyE1PY7NjEFWToMwQxQVB_n1zq1KEPfAazA91D3_S4X=pg@mail.gmail.com>
Subject: Re: Problem re-establishing GSS contexts after a server reboot
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 29, 2016 at 1:32 PM, Adamson, Andy
<William.Adamson@netapp.com> wrote:
>
>> On Jul 29, 2016, at 1:07 PM, Adamson, Andy <William.Adamson@netapp.com> wrote:
>>
>>>
>>> On Jul 29, 2016, at 12:38 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>>
>>>> On Jul 29, 2016, at 12:27 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>
>>>> On Mon, Jul 25, 2016 at 2:18 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>> On Thu, Jul 21, 2016 at 5:32 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>
>>>>>>
>>>>>>> On Jul 21, 2016, at 10:46 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>>
>>>>>>>> On Thu, Jul 21, 2016 at 3:54 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>>>> On Thu, Jul 21, 2016 at 1:56 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>>>>
>>>>>>>>>> On Jul 21, 2016, at 6:04 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>>>>>
>>>>>>>>>> On Thu, Jul 21, 2016 at 2:55 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>>>>>>
>>>>>>>>>>>> On Jul 20, 2016, at 6:56 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>>>>>>>
>>>>>>>>>>>> On Wed, Jul 20, 2016 at 5:14 AM, Adamson, Andy
>>>>>>>>>>>> <William.Adamson@netapp.com> wrote:
>>>>>>>>>>>>>
>>>>>>>>>>>>>> On Jul 19, 2016, at 10:51 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Hi Andy-
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Thanks for taking the time to discuss this with me. I've
>>>>>>>>>>>>>> copied linux-nfs to make this e-mail also an upstream bug
>>>>>>>>>>>>>> report.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> As we saw in the network capture, recovery of GSS contexts
>>>>>>>>>>>>>> after a server reboot fails in certain cases with NFSv4.0
>>>>>>>>>>>>>> and NFSv4.1 mount points.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> The reproducer is a simple program that generates one NFS
>>>>>>>>>>>>>> WRITE periodically, run while the server repeatedly reboots
>>>>>>>>>>>>>> (or one cluster head fails over to the other and back). The
>>>>>>>>>>>>>> goal of the reproducer is to identify problems with state
>>>>>>>>>>>>>> recovery without a lot of other I/O going on to clutter up
>>>>>>>>>>>>>> the network capture.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> In the failing case, sec=krb5 is specified on the mount
>>>>>>>>>>>>>> point, and the reproducer is run as root. We've found this
>>>>>>>>>>>>>> combination fails with both NFSv4.0 and NFSv4.1.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> At mount time, the client establishes a GSS context for
>>>>>>>>>>>>>> lease management operations, which is bound to the client's
>>>>>>>>>>>>>> NFS service principal and uses GSS service "integrity."
>>>>>>>>>>>>>> Call this GSS context 1.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> When the reproducer starts, a second GSS context is
>>>>>>>>>>>>>> established for NFS operations associated with that user.
>>>>>>>>>>>>>> Since the reproducer is running as root, this context is
>>>>>>>>>>>>>> also bound to the client's NFS service principal, but it
>>>>>>>>>>>>>> uses the GSS service "none" (reflecting the explicit
>>>>>>>>>>>>>> request for "sec=krb5"). Call this GSS context 2.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> After the server reboots, the client re-establishes a TCP
>>>>>>>>>>>>>> connection with the server, and performs a RENEW
>>>>>>>>>>>>>> operation using context 1. Thanks to the server reboot,
>>>>>>>>>>>>>> contexts 1 and 2 are now stale. The server thus rejects
>>>>>>>>>>>>>> the RPC with RPCSEC_GSS_CTXPROBLEM.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> The client performs a GSS_INIT_SEC_CONTEXT via an NFSv4
>>>>>>>>>>>>>> NULL operation. Call this GSS context 3.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Interestingly, the client does not resend the RENEW
>>>>>>>>>>>>>> operation at this point (if it did, we wouldn't see this
>>>>>>>>>>>>>> problem at all).
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> The client then attempts to resume the reproducer workload.
>>>>>>>>>>>>>> It sends an NFSv4 WRITE operation, using the first available
>>>>>>>>>>>>>> GSS context in UID 0's credential cache, which is context 3,
>>>>>>>>>>>>>> already bound to the client's NFS service principal. But GSS
>>>>>>>>>>>>>> service "none" is used for this operation, since it is on
>>>>>>>>>>>>>> behalf of the mount where sec=krb5 was specified.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> The RPC is accepted, but the server reports
>>>>>>>>>>>>>> NFS4ERR_STALE_STATEID, since it has recently rebooted.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> The client responds by attempting state recovery. The
>>>>>>>>>>>>>> first operation it tries is another RENEW. Since this is
>>>>>>>>>>>>>> a lease management operation, the client looks in UID 0's
>>>>>>>>>>>>>> credential cache again and finds the recently established
>>>>>>>>>>>>>> context 3. It tries the RENEW operation using GSS context
>>>>>>>>>>>>>> 3 with GSS service "integrity."
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> The server rejects the RENEW RPC with AUTH_FAILED, and
>>>>>>>>>>>>>> the client reports that "check lease failed" and
>>>>>>>>>>>>>> terminates state recovery.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> The client re-drives the WRITE operation with the stale
>>>>>>>>>>>>>> stateid with predictable results. The client again tries
>>>>>>>>>>>>>> to recover state by sending a RENEW, and still uses the
>>>>>>>>>>>>>> same GSS context 3 with service "integrity" and gets the
>>>>>>>>>>>>>> same result. A (perhaps slow-motion) STALE_STATEID loop
>>>>>>>>>>>>>> ensues, and the client mount point is deadlocked.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Your analysis was that because the reproducer is run as
>>>>>>>>>>>>>> root, both the reproducer's I/O operations, and lease
>>>>>>>>>>>>>> management operations, attempt to use the same GSS context
>>>>>>>>>>>>>> in UID 0's credential cache, but each uses different GSS
>>>>>>>>>>>>>> services.
>>>>>>>>>>>>>
>>>>>>>>>>>>> As RFC2203 states, "In a creation request, the seq_num and service fields are undefined and both must be ignored by the server”
>>>>>>>>>>>>> So a context creation request while kicked off by an operation with a service attached (e.g. WRITE uses rpc_gss_svc_none and RENEW uses rpc_gss_svc_integrity), can be used by either service level.
>>>>>>>>>>>>> AFAICS a single GSS context could in theory be used for all service levels, but in practice, GSS contexts are restricted to a service level (by client? by server? ) once they are used.
>>>>>>>>>>>>>
>>>>>>>>>>>>>
>>>>>>>>>>>>>> The key issue seems to be why, when the mount
>>>>>>>>>>>>>> is first established, the client is correctly able to
>>>>>>>>>>>>>> establish two separate GSS contexts for UID 0; but after
>>>>>>>>>>>>>> a server reboot, the client attempts to use the same GSS
>>>>>>>>>>>>>> context with two different GSS services.
>>>>>>>>>>>>>
>>>>>>>>>>>>> I speculate that it is a race between the WRITE and the RENEW to use the same newly created GSS context that has not been used yet, and so has no assigned service level, and the two requests race to set the service level.
>>>>>>>>>>>>
>>>>>>>>>>>> I agree with Andy. It must be a tight race.
>>>>>>>>>>>
>>>>>>>>>>> In one capture I see something like this after
>>>>>>>>>>> the server restarts:
>>>>>>>>>>>
>>>>>>>>>>> SYN
>>>>>>>>>>> SYN, ACK
>>>>>>>>>>> ACK
>>>>>>>>>>> C WRITE
>>>>>>>>>>> C SEQUENCE
>>>>>>>>>>> R WRITE -> CTX_PROBLEM
>>>>>>>>>>> R SEQUENCE -> CTX_PROBLEM
>>>>>>>>>>> C NULL (KRB5_AP_REQ)
>>>>>>>>>>> R NULL (KRB5_AP_REP)
>>>>>>>>>>> C WRITE
>>>>>>>>>>> C SEQUENCE
>>>>>>>>>>> R WRITE -> NFS4ERR_STALE_STATEID
>>>>>>>>>>> R SEQUENCE -> AUTH_FAILED
>>>>>>>>>>>
>>>>>>>>>>> Andy's theory neatly explains this behavior.
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>>> I have tried to reproduce
>>>>>>>>>>>> your scenario and in my tests of rebooting the server all recover
>>>>>>>>>>>> correctly. In my case, if RENEW was the one hitting the AUTH_ERR then
>>>>>>>>>>>> the new context is established and then RENEW using integrity service
>>>>>>>>>>>> is retried with the new context which gets ERR_STALE_CLIENTID which
>>>>>>>>>>>> then client recovers from. If it's an operation (I have a GETATTR)
>>>>>>>>>>>> that gets AUTH_ERR, then it gets new context and is retried using none
>>>>>>>>>>>> service. Then RENEW gets its own AUTH_ERR as it uses a different
>>>>>>>>>>>> context, a new context is gotten, RENEW is retried over integrity and
>>>>>>>>>>>> gets ERR_STALE_CLIENTID which it recovers from.
>>>>>>>>>>>
>>>>>>>>>>> If one operation is allowed to complete, then
>>>>>>>>>>> the other will always recognize that another
>>>>>>>>>>> fresh GSS context is needed. If two are sent
>>>>>>>>>>> at the same time, they race and one always
>>>>>>>>>>> fails.
>>>>>>>>>>>
>>>>>>>>>>> Helen's test includes a second idle mount point
>>>>>>>>>>> (sec=krb5i) and maybe that is needed to trigger
>>>>>>>>>>> the race?
>>>>>>>>>>
>>>>>>>>>> Chuck, any chance to get "rpcdebug -m rpc auth" output during the
>>>>>>>>>> failure (gssd optionally) (i realize that it might alter the timings
>>>>>>>>>> and not hit the issue but worth a shot)?
>>>>>>>>>
>>>>>>>>> I'm sure that's fine. An internal tester hit this,
>>>>>>>>> not a customer, so I will ask.
>>>>>>>>>
>>>>>>>>> I agree, though, that timing might be a problem:
>>>>>>>>> these systems all have real serial consoles via
>>>>>>>>> iLOM, so /v/l/m traffic does bring everything to
>>>>>>>>> a standstill.
>>>>>>>>>
>>>>>>>>> Meanwhile, what's you're opinion about AUTH_FAILED?
>>>>>>>>> Should the server return RPCSEC_GSS_CTXPROBLEM
>>>>>>>>> in this case instead? If it did, do you think
>>>>>>>>> the Linux client would recover by creating a
>>>>>>>>> replacement GSS context?
>>>>>>>>
>>>>>>>> Ah, yes, I equated AUTH_FAILED And AUTH_ERROR in my mind. If client
>>>>>>>> receives the reason as AUTH_FAILED as oppose to CTXPROBLEM it will
>>>>>>>> fail with EIO error and will not try to create a new GSS context. So
>>>>>>>> yes, I believe it would help if the server returns any of the
>>>>>>>> following errors:
>>>>>>>>             case RPC_AUTH_REJECTEDCRED:
>>>>>>>>             case RPC_AUTH_REJECTEDVERF:
>>>>>>>>             case RPCSEC_GSS_CREDPROBLEM:
>>>>>>>>             case RPCSEC_GSS_CTXPROBLEM:
>>>>>>>>
>>>>>>>> then the client will recreate the context.
>>>>>>>
>>>>>>> Also in my testing, I can see that credential cache is per gss flavor.
>>>>>>> Just to check, what kernel version is this problem encountered on (I
>>>>>>> know you said upstream) but I just want to double check so that I can
>>>>>>> look at the correct source code.
>>>>>>
>>>>>> v4.1.12 (stable) I think.
>>>>>
>>>>> Also, can you share the network trace?
>>>>
>>>> Hi Chuck,
>>>>
>>>> I was finally able to reproduce the condition you were seeing (i.e.,
>>>> the use of the same context for different gss services).
>>>>
>>>> I enabled rpcdebug rpc auth and I can see that the 2nd request ends up
>>>> finding a gss_upcall message because it's just matched by the uid.
>>>> There is even a comment in auth_gss/auth_gss.c in gss_add_msg() saying
>>>> that if there is upcall for an uid then it won't add another upcall.
>>>> So I think the decision is made right there to share the same context
>>>> no matter the gss service.
>>>
>>> If I understand correctly, that's just what Andy predicted.
>>>
>>> That check needs to be changed to allow another upcall to be
>>> queued if the UID matches but the GSS service does not.
>>
>> Yes, we need to ensure that the service is set even though it is ignored by the server.
>
> …service is set in the gss_upcall_msg…
>

I believe a change to accommodate this would have compatibility issues.

Currently, when the gssd creates a context and sends the information
back to the kernel, the first thing in the buffer is the uid. The
kernel parses the uid and then looks up the appropriate gss_upcall
message. Right now no service information is there to do the matching.
If we were to add gssd to sends up the service for which the context
was established, then the old kernel won't work with the new
nfs-utils. And new kernel won't work with old nfs-utils.

>>
>> —>Andy
>>
>>>
>>>
>>> --
>>> Chuck Lever
>
