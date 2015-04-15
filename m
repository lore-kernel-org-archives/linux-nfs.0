Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:34349 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756151AbbDOS1W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2015 14:27:22 -0400
Received: by obfe9 with SMTP id e9so31030903obf.1
        for <linux-nfs@vger.kernel.org>; Wed, 15 Apr 2015 11:27:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSTc-34R_C0TwYmwk8KdQFadxQbhgmoTxzhWKhsYjiFww@mail.gmail.com>
References: <CAN-5tyE60A+2h6My0Ebb=5j4DbVifDBuG6CjymCRsRefNTMd=w@mail.gmail.com>
	<CAHQdGtSTc-34R_C0TwYmwk8KdQFadxQbhgmoTxzhWKhsYjiFww@mail.gmail.com>
Date: Wed, 15 Apr 2015 14:27:21 -0400
Message-ID: <CAN-5tyEx_Pp0q58EiYSLLAZZ1cR4Tn9=gkD7b_pubsZdXymsFg@mail.gmail.com>
Subject: Re: is receiving BAD_STATEID during IO on delegated stateid unrecoverable?
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I'm resurrecting an old client received "BAD_STATEID" using delegation
stateid on some operation thread.... If client used a delegation
stateid on a SETATTR (i.e. for open truncate) and received this error,
does this also lead to unrecoverable state or do you think client
should try recover? I can see the same argument that if state was
revoked another client could have change the file already.

If you think it's recoverable, there is a bug in the client because it
doesn't recover. I can explain why but there is no need if this is an
acceptable behavior.

Thanks.

On Thu, Nov 20, 2014 at 4:14 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Thu, Nov 20, 2014 at 12:57 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> Hi folks,
>>
>> As far as I can tell, receiving a BAD_STATEID on an IO operation on a
>> delegated stateid when there was a local lock acquired for this IO is
>> unrecoverable — leads to EIO. Codewise, stateid recovery sees that it
>> has a local lock and marks it lost and retry of the IO operation
>> returns the EIO.
>>
>> Is the reason for seizing the IO is that if the server for some reason
>> revoked this stateid then there is no guarantee about the locks and
>> thus doing any IO.
>>
>> This also applies to both 4.0 and 4.1 code as far as I can tell.
>>
>> Can somebody confirm or tell me if this is wrong?
>>
>
> Yes. If the server has lost the lock, then the application has lost
> atomicity for the set of operations that were supposed to be protected
> by that lock, and this is why we return the EIO. In older kernels we
> did try to recover the lock, but that can lead to application-visible
> corruption of data, and so we no longer do that unless you explicitly
> set the nfs 'recover_lost_locks' module parameter - see
> Documentation/kernel-parameters.txt.
>
> --
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com
