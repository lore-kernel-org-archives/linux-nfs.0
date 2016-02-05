Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33720 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcBEVi4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 16:38:56 -0500
Received: by mail-ig0-f179.google.com with SMTP id rs20so50359310igc.0
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 13:38:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSRrT2L=S7XSpXzmY9gc27rS9P3N7j=veFPVp3JzywmXQ@mail.gmail.com>
References: <CAN-5tyFJNCsSM=pccUnQmtq6ZMDdHNAmxOBZGYV2_0iNzfLsMQ@mail.gmail.com>
	<CAHQdGtSETwRy7ry_ZkMo5M1uTwG6hvWMUmYRkJjgDob+g-RwUA@mail.gmail.com>
	<CAN-5tyH37QCVM_bCufV1caoYFF2Zi_ZJr-RyaQrWdwFsR5Y4SQ@mail.gmail.com>
	<CAHQdGtSBbgZ-32RwoMuUcAV1EaUx1QLjbrQEyJtNOeC=iRSVDw@mail.gmail.com>
	<CAN-5tyF2i5a_=zC8NtYa-bpAnMc9zH3UhA7TT1C56RRE-4M+rA@mail.gmail.com>
	<CAHQdGtSRrT2L=S7XSpXzmY9gc27rS9P3N7j=veFPVp3JzywmXQ@mail.gmail.com>
Date: Fri, 5 Feb 2016 16:38:56 -0500
Message-ID: <CAN-5tyHRo75yyEZQGTrzZP2FghykmkA7Nce6apf4MGJQFM91mw@mail.gmail.com>
Subject: Re: Question about XID use in sunrpc
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 5, 2016 at 4:08 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Fri, Feb 5, 2016 at 2:03 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> On Fri, Feb 5, 2016 at 1:31 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> On Fri, Feb 5, 2016 at 12:01 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>> On Fri, Feb 5, 2016 at 11:44 AM, Trond Myklebust
>>>> <trond.myklebust@primarydata.com> wrote:
>>>>> On Fri, Feb 5, 2016 at 10:37 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>> I have a question regarding the implementation of sunrpc use of XID
>>>>>> when the client receives an AUTH_ERROR. The code (clnt.c line 1933)
>>>>>> explicitly comments that a new XID should be acquired and releases the
>>>>>> currently rpc task (and gets a new one). Why is that? Since the
>>>>>> operation is "replayed" but with the new credentials, why shouldn't
>>>>>> the same XID be used?
>>>>>>
>>>>>> The RPC RFC says that XID is used by the server to detect
>>>>>> retransmissions. It's not clear if in the specs means "retransmission"
>>>>>> == tcp retransmissions. If so then it explains why the client uses the
>>>>>> same XID.
>>>>>>
>>>>>
>>>>> The questions you are asking come under the header "RPC lore" rather
>>>>> than "RPC law". The use of XIDs as a basis for replay caching is not
>>>>> speced out in any RFC. The closest thing we have in the form of
>>>>> documentation is Ric Werme's presentation at the 1996 Connectathon:
>>>>> http://nfsv4bat.org/Documents/ConnectAThon/1996/werme1.pdf
>>>>>
>>>>> Basically, those comments are there in the Linux code to denote issues
>>>>> found when interoperability testing with server implementations that
>>>>> are probably now long dead, but might still be in use somewhere.
>>>>
>>>> Would you consider changing this to use the same XID in case of
>>>> redoing the operation due to the AUTH_ERROR?
>>>>
>>>> The issue it causes (one of the) server's implementation is of the
>>>> following nature:
>>>> 1. client sends an operation to the server. the server process the
>>>> operation but before replying back to the server has an issue and
>>>> resets the connection.
>>>> 2. client re-establishes the connection and replays the RPC. the
>>>> server now fails with the AUTH_ERROR.
>>>> 3. client establishes a new connection and replays the same NFS
>>>> operation over the new XID. The server cached the operation but since
>>>> the last operation arrives with the new XID it won't find the entry in
>>>> the cache. It's problematic when the operation is like REMOVE.
>>>>
>>>> I realize this is why nfs4.1 session were introduce to solve these
>>>> non-idenpotency issues but using the same XID seems like the right
>>>> idea since it is the same operation.
>>>>
>>>> If you don't have objections to the change, I can ask on the IETF list
>>>> to see if any servers will object to such change.
>>>
>>> What you describe is a clear and obvious server bug. It is not a
>>> client bug, and is not something that I'd find acceptable as
>>> justification for changing the client code.
>>>
>>> The server should not be replying AUTH_ERROR and then processing the
>>> RPC anyway. That's not behaviour that is sanctioned by the RPC spec.
>>
>> Perhaps I wasn't clear let me try again. In the first step, the server
>> processes request and does not reply with an AUTH_ERROR but instead
>> resets a connection but it has already populated it's replay cache.
>> Client reestablishes connection resends exactly the same bytes but
>> gets back an AUTH_ERROR (server does not process the operation). It's
>> the recovery from this error that's in question.
>>
>
> Hi Olga,
>
> I understood what you said, but you cannot have multiple replies to
> the same RPC call. It doesn't matter if it was a replay, if the server
> replies AUTH_ERROR, then it is saying "I'm not executing this".

But "this" could have already been executed.

>
> Cheers
>   Trond
