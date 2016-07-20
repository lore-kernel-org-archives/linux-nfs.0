Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36044 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189AbcGTQ4z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jul 2016 12:56:55 -0400
Received: by mail-io0-f177.google.com with SMTP id b62so52910169iod.3
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jul 2016 09:56:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <259CD26A-E1E7-44CA-B1D3-F46AED01B932@netapp.com>
References: <59704D2B-9FBD-41BB-ADA8-4CF4AEF4BB9D@oracle.com> <259CD26A-E1E7-44CA-B1D3-F46AED01B932@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 20 Jul 2016 12:56:53 -0400
Message-ID: <CAN-5tyE_yrspQDpftO1Ls9LxjaZPHGe9hH0V65xaFuNEyrbwig@mail.gmail.com>
Subject: Re: Problem re-establishing GSS contexts after a server reboot
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 20, 2016 at 5:14 AM, Adamson, Andy
<William.Adamson@netapp.com> wrote:
>
>> On Jul 19, 2016, at 10:51 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>> Hi Andy-
>>
>> Thanks for taking the time to discuss this with me. I've
>> copied linux-nfs to make this e-mail also an upstream bug
>> report.
>>
>> As we saw in the network capture, recovery of GSS contexts
>> after a server reboot fails in certain cases with NFSv4.0
>> and NFSv4.1 mount points.
>>
>> The reproducer is a simple program that generates one NFS
>> WRITE periodically, run while the server repeatedly reboots
>> (or one cluster head fails over to the other and back). The
>> goal of the reproducer is to identify problems with state
>> recovery without a lot of other I/O going on to clutter up
>> the network capture.
>>
>> In the failing case, sec=krb5 is specified on the mount
>> point, and the reproducer is run as root. We've found this
>> combination fails with both NFSv4.0 and NFSv4.1.
>>
>> At mount time, the client establishes a GSS context for
>> lease management operations, which is bound to the client's
>> NFS service principal and uses GSS service "integrity."
>> Call this GSS context 1.
>>
>> When the reproducer starts, a second GSS context is
>> established for NFS operations associated with that user.
>> Since the reproducer is running as root, this context is
>> also bound to the client's NFS service principal, but it
>> uses the GSS service "none" (reflecting the explicit
>> request for "sec=krb5"). Call this GSS context 2.
>>
>> After the server reboots, the client re-establishes a TCP
>> connection with the server, and performs a RENEW
>> operation using context 1. Thanks to the server reboot,
>> contexts 1 and 2 are now stale. The server thus rejects
>> the RPC with RPCSEC_GSS_CTXPROBLEM.
>>
>> The client performs a GSS_INIT_SEC_CONTEXT via an NFSv4
>> NULL operation. Call this GSS context 3.
>>
>> Interestingly, the client does not resend the RENEW
>> operation at this point (if it did, we wouldn't see this
>> problem at all).
>>
>> The client then attempts to resume the reproducer workload.
>> It sends an NFSv4 WRITE operation, using the first available
>> GSS context in UID 0's credential cache, which is context 3,
>> already bound to the client's NFS service principal. But GSS
>> service "none" is used for this operation, since it is on
>> behalf of the mount where sec=krb5 was specified.
>>
>> The RPC is accepted, but the server reports
>> NFS4ERR_STALE_STATEID, since it has recently rebooted.
>>
>> The client responds by attempting state recovery. The
>> first operation it tries is another RENEW. Since this is
>> a lease management operation, the client looks in UID 0's
>> credential cache again and finds the recently established
>> context 3. It tries the RENEW operation using GSS context
>> 3 with GSS service "integrity."
>>
>> The server rejects the RENEW RPC with AUTH_FAILED, and
>> the client reports that "check lease failed" and
>> terminates state recovery.
>>
>> The client re-drives the WRITE operation with the stale
>> stateid with predictable results. The client again tries
>> to recover state by sending a RENEW, and still uses the
>> same GSS context 3 with service "integrity" and gets the
>> same result. A (perhaps slow-motion) STALE_STATEID loop
>> ensues, and the client mount point is deadlocked.
>>
>> Your analysis was that because the reproducer is run as
>> root, both the reproducer's I/O operations, and lease
>> management operations, attempt to use the same GSS context
>> in UID 0's credential cache, but each uses different GSS
>> services.
>
> As RFC2203 states, "In a creation request, the seq_num and service fields are undefined and both must be ignored by the server”
> So a context creation request while kicked off by an operation with a service attached (e.g. WRITE uses rpc_gss_svc_none and RENEW uses rpc_gss_svc_integrity), can be used by either service level.
> AFAICS a single GSS context could in theory be used for all service levels, but in practice, GSS contexts are restricted to a service level (by client? by server? ) once they are used.
>
>
>> The key issue seems to be why, when the mount
>> is first established, the client is correctly able to
>> establish two separate GSS contexts for UID 0; but after
>> a server reboot, the client attempts to use the same GSS
>> context with two different GSS services.
>
> I speculate that it is a race between the WRITE and the RENEW to use the same newly created GSS context that has not been used yet, and so has no assigned service level, and the two requests race to set the service level.

I agree with Andy. It must be a tight race. I have tried to reproduce
your scenario and in my tests of rebooting the server all recover
correctly. In my case, if RENEW was the one hitting the AUTH_ERR then
the new context is established and then RENEW using integrity service
is retried with the new context which gets ERR_STALE_CLIENTID which
then client recovers from. If it's an operation (I have a GETATTR)
that gets AUTH_ERR, then it gets new context and is retried using none
service. Then RENEW gets its own AUTH_ERR as it uses a different
context, a new context is gotten, RENEW is retried over integrity and
gets ERR_STALE_CLIENTID which it recovers from.


>
> —>Andy
>>
>> One solution is to introduce a quick check before a
>> context is used to see if the GSS service bound to it
>> matches the GSS service that the caller intends to use.
>> I'm not sure how that can be done without exposing a window
>> where another caller requests the use of a GSS context and
>> grabs the fresh one, before it can be used by our first
>> caller and bound to its desired GSS service.
>>
>> Other solutions might be to somehow isolate the credential
>> cache used for lease management operations, or to split
>> credential caches by GSS service.
>>
>>
>> --
>> Chuck Lever
>>
>>
>>
>
