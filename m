Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33653 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbcEUBmL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 May 2016 21:42:11 -0400
Received: by mail-io0-f178.google.com with SMTP id t40so70495366ioi.0
        for <linux-nfs@vger.kernel.org>; Fri, 20 May 2016 18:42:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <942F69E5-B9EA-48BD-8F7E-6E81B8FBAE6E@primarydata.com>
References: <CAN-5tyE4tqNpUnQHYpNnbC-MANRKXFm0TttF9dVPOBh9MP9gyw@mail.gmail.com>
	<66555AD3-4421-4C3E-AC60-4AEC31CE8177@primarydata.com>
	<942F69E5-B9EA-48BD-8F7E-6E81B8FBAE6E@primarydata.com>
Date: Fri, 20 May 2016 21:42:10 -0400
Message-ID: <CAN-5tyE71FUWABE3v=2rqHnyPJirhz5v_se1GnYsHe-T3-YAOQ@mail.gmail.com>
Subject: Re: questions about open state recovery and open owner seq_id management
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Thomas Haynes <loghyr@primarydata.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 20, 2016 at 5:22 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
>
> On 5/20/16, 17:11, "linux-nfs-owner@vger.kernel.org on behalf of Thomas
> Haynes" <linux-nfs-owner@vger.kernel.org on behalf of
> loghyr@primarydata.com> wrote:
>
>>
>>> On May 20, 2016, at 1:38 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>
>>> Hi folks,
>>>
>>> I’m seeing a client behavior that I can’t explain the reason behind
>>> (i.e. spec) so want to ask for help.
>>>
>>> Question #1: Should a reclaim of open state handle BAD_SEQID the same
>>> way the normal open handles BAD_SEQID (which is: it just retries). I
>>> can see that during recovery we might not want the recovery to be
>>> trying forever and that’s why we fail? I don’t see anything in the
>>> spec that talk about this…
>>>
>>> Question #2: Incrementing seqid of open owner. I see that when LOCK
>>> receives an error BAD_STATEID/ADMIN_REVOKED, sequence isn’t
>>> incremented and (recovery) OPEN is sent with the same seqid. The code
>>> explicitly sets seqid unconfirmed. Again, I don’t know where to look
>>> in the spec for something like this. What happens is that server
>>> replies back with BAD_SEQID.
>>
>>RFC 5661
>>
>>It doesn’t say it explicitly, but you only bump the seqid on success.
>>
>>3.3.12. stateid4
>>
>> The starting value of the "seqid" field is
>> undefined. The server is required to increment the "seqid" field by
>> one at each transition of the stateid.
>>
>>
>>8.2.1. Stateid Types
>>
>> o Stateids may represent sets of byte-range locks.
>>
>> All locks held on a particular file by a particular owner and
>> gotten under the aegis of a particular open file are associated
>> with a single stateid with the seqid being incremented whenever
>> LOCK and LOCKU operations affect that set of locks.

Which seqid is the spec talking about:  the stateid's seqid or the lock_seqid ?

>>
>>8.2.2. Stateid Structure
>>
>> When such a set of locks is first created, the server returns a
>> stateid with seqid value of one. On subsequent operations that
>> modify the set of locks, the server is required to increment the
>> "seqid" field by one whenever it returns a stateid for the same
>> state-owner/file/type combination and there is some change in the set
>> of locks actually designated. In this case, the server will return a
>> stateid with an "other" field the same as previously used for that
>> state-owner/file/type combination, with an incremented "seqid" field.
>> This pattern continues until the seqid is incremented past
>> NFS4_UINT32_MAX, and one (not zero) is the next seqid value.
>>
>>More of the same in
>>
>>9.4. Stateid Seqid Values and Byte-Range Locks
>>
>>12.5.3 has this to say about layout stateids, while acknowledging they
>>are different from normal stateids:
>>
>> The
>> correct "seqid" is defined as the highest "seqid" value from
>> responses of fully processed LAYOUTGET or LAYOUTRETURN operations or
>> arguments of a fully processed CB_LAYOUTRECALL operation.
>>
>>I take “fully processed” to mean successful.
>>
>>
>>>
>>> So normally, when an open fails with BAD_SEQID the client retries but
>>> combine it with a LOCK that failed with BAD_STATEID. Then it leads to
>>> the application failing with “bad file descriptor” because after
>>> receiving an error for the lock and trying to do open recovery, the
>>> code doesn’t increment seqid and open fails with BAD_SEQID and we
>>> don’t retry the open. So now we don’t have a file descriptor and we
>>> fail the lock.
>>
>>
>>Look back at the sections above, they stated that the seqid is
>>only changed if there is a change in the set of locks designated. The
>>error does not change the set of locks.
>>
>>Your server vendor is having the same issues as you are in deciphering
>>the rules on seqid.
>>
>
> Oh, sorry. Did you mean NFSv4.1, Olga? If so, please disregard my earlier
> reply.

I should have specified that it was 4.0.

Ok so I found that for 4.1 the seqid from the operations are ignored.

15.1.16.1.  NFS4ERR_BAD_SEQID (Error Code 10026)

   The sequence number (seqid) in a locking request is neither the next
   expected number or the last number processed.  These seqids are
   ignored in NFSv4.1.



>
> Trond
>
>
> Disclaimer
>
> The information contained in this communication from the sender is
> confidential. It is intended solely for use by the recipient and others
> authorized to receive it. If you are not the recipient, you are hereby
> notified that any disclosure, copying, distribution or taking action in
> relation of the contents of this information is strictly prohibited and may
> be unlawful.
