Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32196 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbcHYPdU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Aug 2016 11:33:20 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: READ during state recovery uses zero stateid
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <56448609-05CA-493F-B98A-A2DCAB7909E9@oracle.com>
Date: Thu, 25 Aug 2016 11:31:48 -0400
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A4DDDEDB-6D78-45C7-89AF-87FA28975B9E@oracle.com>
References: <AB29A5B8-1564-4C31-A843-F0C5CC4C91F1@oracle.com> <87A94B50-A9D5-44FF-9F78-F916C98E6767@primarydata.com> <182FCDA3-1BD7-436F-88A3-B29AAD7E6BAE@oracle.com> <832771A7-EF94-475C-871E-EE9499EC75B3@primarydata.com> <56448609-05CA-493F-B98A-A2DCAB7909E9@oracle.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 24, 2016, at 3:37 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Aug 24, 2016, at 3:05 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
>> 
>>> 
>>> On Aug 24, 2016, at 14:47, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> 
>>> 
>>>> On Aug 24, 2016, at 2:23 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
>>>> 
>>>>> 
>>>>> On Aug 24, 2016, at 14:10, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>> 
>>>>> Hi-
>>>>> 
>>>>> I have a wire capture that shows this race while a simple I/O workload is
>>>>> running:
>>>>> 
>>>>> 0. The client reconnects after a network partition
>>>>> 1. The client sends a couple of READ requests
>>>>> 2. The client independently discovers its lease has expired
>>>>> 3. The client establishes a fresh lease
>>>>> 4. The client destroys open, lock, and delegation stateids for the file
>>>>> that was open under the previous lease
>>>>> 5. The client issues a new OPEN to recover state for that file
>>>>> 6. The server replies to the READs in step 1. with NFS4ERR_EXPIRED
>>>>> 7. The client turns the READs around immediately using the current open
>>>>> stateid for that file, which is the zero stateid
>>>>> 8. The server replies NFS4_OK to the OPEN from step 5
>>>>> 
>>>>> If I understand the code correctly, if the server happened to send those
>>>>> READ replies after its OPEN reply (rather than before), the client would
>>>>> have used the recovered open stateid instead of the zero stateid when
>>>>> resending the READ requests.
>>>>> 
>>>>> Would it be better if the client recognized there is state recovery in
>>>>> progress, and then waited for recovery to complete, before retrying the
>>>>> READs?
>>>>> 
>>>> 
>>>> Why isn’t the session draining taking care of ensuring the READs don’t happen until after recovery is done?
>>> 
>>> This is NFSv4.0. (Apologies, I recalled NFS4ERR_EXPIRED had been removed
>>> from NFSv4.1, but I see that I was mistaken).
>>> 
>>> Here's step 1 and 2, exactly. After the partition heals, the client sends:
>>> 
>>> C READ
>>> C GETATTR
>>> C READ
>>> C RENEW
>>> 
>>> The server responds to the RENEW first with GSS_CTXPROBLEM. The client's
>>> gssd connects and establishes a fresh GSS context. The client sends the
>>> RENEW again with the fresh context, and the server responds NFS4ERR_EXPIRED.
>>> This triggers step 3.
>>> 
>>> The replies for those READ calls are in step 6., after state recovery
>>> has started.
>> 
>> This is what I’m confused about: Normally, I’d expect the NFSv4.0 code to drain, due to the checks in nfs40_setup_sequence().
>> 
>> IOW: there should be 2 steps
>> 
>>  2.5) Call nfs4_drain_slot_tbl() and wait for operations to complete
>>  2.6) Process the NFS4ERR_EXPIRED errors returned by the READ requests sent in (1).
>> 
>> before we get to recovering the lease in (3)...
> 
> My kernel is missing commit 5cae02f42793 ("NFSv4: Always drain the slot
> table before re-establishing the lease"). I can give that a try, thank
> you!

This is v4.1.31, btw.


--
Chuck Lever



