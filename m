Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36418 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbcETVD4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 May 2016 17:03:56 -0400
Received: by mail-io0-f176.google.com with SMTP id f8so26868228ioe.3
        for <linux-nfs@vger.kernel.org>; Fri, 20 May 2016 14:03:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9C8C4184-5D77-43B2-A97B-173DF237F8E8@primarydata.com>
References: <CAN-5tyE4tqNpUnQHYpNnbC-MANRKXFm0TttF9dVPOBh9MP9gyw@mail.gmail.com>
	<9C8C4184-5D77-43B2-A97B-173DF237F8E8@primarydata.com>
Date: Fri, 20 May 2016 17:03:55 -0400
Message-ID: <CAN-5tyG0SZOarfudExa5Hra=NR2dUYgctwT-_DQH_zFDXDHx5g@mail.gmail.com>
Subject: Re: questions about open state recovery and open owner seq_id management
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 20, 2016 at 4:43 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
>
> On 5/20/16, 16:38, "linux-nfs-owner@vger.kernel.org on behalf of Olga
> Kornievskaia" <linux-nfs-owner@vger.kernel.org on behalf of aglo@umich.edu>
> wrote:
>
>>Hi folks,
>>
>>I’m seeing a client behavior that I can’t explain the reason behind
>>(i.e. spec) so want to ask for help.
>>
>>Question #1: Should a reclaim of open state handle BAD_SEQID the same
>>way the normal open handles BAD_SEQID (which is: it just retries). I
>>can see that during recovery we might not want the recovery to be
>>trying forever and that’s why we fail? I don’t see anything in the
>>spec that talk about this…
>>
>>Question #2: Incrementing seqid of open owner. I see that when LOCK
>>receives an error BAD_STATEID/ADMIN_REVOKED, sequence isn’t
>>incremented and (recovery) OPEN is sent with the same seqid. The code
>>explicitly sets seqid unconfirmed. Again, I don’t know where to look
>>in the spec for something like this. What happens is that server
>>replies back with BAD_SEQID.
>>
>>So normally, when an open fails with BAD_SEQID the client retries but
>>combine it with a LOCK that failed with BAD_STATEID. Then it leads to
>>the application failing with “bad file descriptor” because after
>>receiving an error for the lock and trying to do open recovery, the
>>code doesn’t increment seqid and open fails with BAD_SEQID and we
>>don’t retry the open. So now we don’t have a file descriptor and we
>>fail the lock.
>>
>
> See:
> https://tools.ietf.org/html/rfc7530#section-9.1.7
>
> The client MUST advance the sequence number for the CLOSE, LOCK,
> LOCKU, OPEN, OPEN_CONFIRM, and OPEN_DOWNGRADE operations. This is
> true even in the event that the previous operation that used the
> sequence number received an error. The only exception to this rule
> is if the previous operation received one of the following errors:
> NFS4ERR_STALE_CLIENTID, NFS4ERR_STALE_STATEID, NFS4ERR_BAD_STATEID,
> NFS4ERR_BAD_SEQID, NFS4ERR_BADXDR, NFS4ERR_RESOURCE,
> NFS4ERR_NOFILEHANDLE, or NFS4ERR_MOVED.
>

Thanks Trond.
> Cheers
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
