Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailservice.tudelft.nl ([130.161.131.5]:51916 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758333Ab1F3HAE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jun 2011 03:00:04 -0400
Received: from localhost (localhost [127.0.0.1])
	by amavis (Postfix) with ESMTP id 02569108C035
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 09:00:03 +0200 (CEST)
Received: from mailservice.tudelft.nl ([130.161.131.74])
	by localhost (tudelft.nl [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id nC3X3ICegBfY for <linux-nfs@vger.kernel.org>;
	Thu, 30 Jun 2011 09:00:01 +0200 (CEST)
Received: from pc-rsmits.dto.tudelft.nl (pc-rsmits.dto.tudelft.nl [131.180.97.81])
	by mx3.tudelft.nl (Postfix) with ESMTP id B3F0D108C061
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 09:00:01 +0200 (CEST)
Message-ID: <4E0C1EF1.10304@tudelft.nl>
Date: Thu, 30 Jun 2011 09:00:01 +0200
From: Richard Smits <R.Smits@tudelft.nl>
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 null request and compatibility with netapp
References: <4E0B3897.40209@jrc.ec.europa.eu> <1309366237.12547.13.camel@lade.trondhjem.org> <C05920BC-8E0A-417B-9F99-FD14C0142099@netapp.com>
In-Reply-To: <C05920BC-8E0A-417B-9F99-FD14C0142099@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello list,

I regularly check this list for information etc, and noticed this 
thread. We also have these messages in our Filer's messages file. We 
always had these messages, also on 7.3.2 version.

I always assumed this was a client issue. We run ontap 7.3.3P4 on a fas 
V3170.

We use Suse enterprise desktop 11 clients with NFS/KRB5 access.

Thu Jun 30 08:51:05 CEST [srv001: nfsd.rpc.request.bad:warning]: Client 
X.X.X.X is sending bad rpc requests with error: RPC version mismatch or 
authentication error(73)

Greetings .. Richard Smits

On 06/29/2011 07:11 PM, Thomas Haynes wrote:
> Franck,
>
> What version of OnTap are you running?
>
> Actually, if you have a case number from NetApp, I can look at that internally.
>
> Thanks,
> Tom
>
>
> On Jun 29, 2011, at 11:50 AM, Trond Myklebust wrote:
>
>> On Wed, 2011-06-29 at 16:37 +0200, Franck Eyraud wrote:
>>> Dear nfs linux list,
>>>
>>> I have an issue with NFSv4 clients running debian with linux kernel
>>> version 2.6.29 and above. The NFS4 server is n a NetApp NAS.
>>>
>>> The problem arised when, after upgrading the kernel of our machines, the
>>> filer started to issue a lot of these messages :
>>>
>>> Client 1XX.1XX.2XX.73 has an authentication error 2
>>> Client 1XX.1XX.2XX.73 is sending bad rpc requests with error: RPC version mismatch or authentication error(73)
>>>
>>> The NetApp team analyzed the tcp trace and sent us with this answer, basically saying that the fault is from client side :
>>>
>>> Can someone on the list confirm that their affirmations are correct ?
>>>
>>> I already opened a bug on debian http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=632074 where they said that maybe the client behavior is not that odd with respect with the RFC standard.
>>
>> Without a trace, it is hard to affirm anything, but please note the
>> following:
>>
>>      1. The client will usually share the same TCP connection for _all_
>>         mounts to any given server, so even if you didn't see the client
>>         establish the rpcsec_gss session after the particular mount that
>>         you used to test on, it may have been established by a previous
>>         mount.
>>      2. Once the client is finished using an rpcsec_gss session, and
>>         that session is kicked out of the cache (usually within 1 minute
>>         of last use, but it may occasionally take longer), then the
>>         client will send out a NULL call with the RPCSEC_GSS_DESTROY
>>         message.
>>      3. The client doesn't know, before sending an RPC call, whether or
>>         not the server has already expired the rpcsec_gss session. If
>>         the server has expired it without the client's knowledge, then
>>         it is unreasonable to declare the RPCSEC_GSS_DESTROY call to be
>>         an error. The server should simply try to obey the call, and
>>         then acknowledge it as a success, whether or not it actually
>>         found an active session.
>>
>> IOW: this all looks to me like a storm in a teacup brought about by a
>> server implementation that is logging errors in a case where it
>> shouldn't.
>>
>> Cheers
>>   Trond
>>
>>> ---------
>>> Tue May 24 10:05:59 MEST [vcid@s-jrciprna004p: nfsd.rpc.request.bad:warning]: Client 1XX.1XX.2XX.73 is sending bad rpc requests with error: RPC version mismatch or
>>> authentication error(73)
>>>
>>> We looked in the code and the (73) has no significance here and is simply the error code number for "RPC version mismatch or authentication error".
>>>
>>> What we see is that the following occurs at the time of these errors:
>>> - The client has an established TCP session on which it does NFSv4.
>>> - The NFSv4 calls uses Kerberos.
>>> - On that TCP session, the client occasionally does a NULL call.
>>> - The filer rejects it with an authentication error (auth state 2, client must begin new session)
>>> - The client does a new NULL call on a separate TCP session without a GSS context.
>>> - The filer responds and a new context is established.
>>> - The client continues on the original TCP session with the new context.
>>>
>>> This explains why no side effect is seen: the client simply establishes a new context and continues as if nothing had happened.
>>> We have checked through the trace for vlan 240 and the pattern is the same throughout and the error always happens for NULL calls only (occasionally two replies may be
>>> sent in the same TCP payload, but the error is always on the NULL reply, then).
>>> We know that some Debian kernels do not exhibit this problem at any time, but others do. This (along with the problem being tied to NULL calls only)
>>> suggest to us that this is due to client side behaviour.
>>>
>>> Anyway, we tried to check for the first occurrence of the error, which warrants some chronology. We'll do references per clock second for ease.
>>> - The first client call is at 10:04:16 in an established NFS mount.
>>> - The initial part of the trace, the client only uses TCP port 1006.
>>> - The client uses the same GSS context, with the exception of a SETCLIENTID and a SETCLIENTID_CONFIRM call.
>>> - At 10:05:00 the client tears down four GSS sessions (used for Kerberos) using RPCSEC_GSS_DESTROY in an NFSv4 NULL call. This is done from TCP port 1006 but for four
>>> different contexts. None of these have been used in the trace at that point.
>>> - The client continues with more cals on port 1006 using the the same GSS context.
>>> - Still at 10:05:00 (frame 1982792), the client uses an NFSv4 call to do a RPCSEC_GSS_INIT to establish a new GSS context.
>>> - The client continues using the new GSS context and does not reuse the old context.
>>> - The sequence described above on the NULL calls start.
>>>
>>> Looking closer at these steps, we notice something important in the NULL calls.
>>> Above, the client destroyed four GSS contexts that were not used during the trace. However, it did not destroy the GSS context it was using for a while there.
>>>
>>> However, we now note the client actually does a RPCSEC_GSS_DESTROY in each of the NFSv4 NULL calls where we respond with an authentication error. As the error
>>> indicates that the client has to begin a new session, this seems like a reasonable response to the call.
>>>
>>> So to summarize:
>>> - The filer logs these errors when the client destroys a GSS context.
>>> - The error message is a logical response.
>>>
>>> The decission to tear down the GSS context is with the client. So this would seem to be a client side issue after all, which just happens to get logged on the filer.
>>> -------------
>>>
>>> Thank you for your help,
>>>
>>> Franck Eyraud
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> Trond Myklebust
>> Linux NFS client maintainer
>>
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
