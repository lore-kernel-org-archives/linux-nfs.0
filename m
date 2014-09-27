Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:50740 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbaI0TZN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2014 15:25:13 -0400
Received: by mail-ie0-f170.google.com with SMTP id x19so14933831ier.15
        for <linux-nfs@vger.kernel.org>; Sat, 27 Sep 2014 12:25:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140927144056.2d303755@synchrony.poochiereds.net>
References: <CAABAsM4zDuzjapXfLUrminwM1FV7iwN+oEzxgzaQ60m93gBBug@mail.gmail.com>
	<20140927144056.2d303755@synchrony.poochiereds.net>
Date: Sat, 27 Sep 2014 15:25:12 -0400
Message-ID: <CAHQdGtQBNpBO+xv_uk+bkue6zoSKMhU72xjKaeOb2gEHY012Ew@mail.gmail.com>
Subject: Re: [nfsv4] Could somebody please enlighten me as to what is supposed
 to happen in this situation?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: "nfsv4@ietf.org" <nfsv4@ietf.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 27, 2014 at 2:40 PM, Jeff Layton
<jeff.layton@primarydata.com> wrote:
> On Sat, 27 Sep 2014 11:22:29 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>
> My take (quite possibly wrong, but...)
>
>> The scenario is this:
>>                                        Server
>>                                        ======
>>                                        boot (B1)
>> Client
>> ======
>> EXCHANGE_ID
>> CREATE_SESSION
>> OPEN(reclaim)
>> LOCK(reclaim)
>> RECLAIM_COMPLETE
>>                                        (lift GRACE period)
>
> At this point, we'd deny reclaim from any client that has not issued a
> RECLAIM_COMPLETE. In the case of the Linux server with nfsdcltrack, we
> clean out any client records that have not issued a RECLAIM_COMPLETE.
>
>>                                        reboot (B2)
>> EXCHANGE_ID
>> CREATE_SESSION
>> OPEN(reclaim)
>>                                         reboot (while GRACE period
>> still being enforced) (B3)
>> EXCHANGE_ID
>> CREATE_SESSION
>> OPEN(reclaim)
>>
>> What should be the server response to the above OPEN(reclaim) from the
>> client after reboot (B3)?
>>
>
> My expectation is that it would be granted. There was a
> RECLAIM_COMPLETE issued during the boot where the grace period was last
> lifted, and that should be enough to allow the client to issue reclaims
> on any subsequent reboot, until the grace period is lifted again.
>
> Doing anything else would be a pretty unfriendly way for the server to
> behave. In the face of rapid reboots (a not-uncommon occurrence when
> patching, etc), you'd lose state unless the client just happened to get
> in there quickly enough to issue a RECLAIM_COMPLETE between each reboot.
>
> That was the situation with the legacy client tracker in knfsd. When
> testing, it was trivial to reboot the machine quickly twice and on the
> second reboot nothing could be reclaimed.

So now, what if the following scenario:

                                       Server
                                       ======
                                       boot (B1')
Client
======
EXCHANGE_ID
CREATE_SESSION
OPEN(reclaim)
LOCK(reclaim)
RECLAIM_COMPLETE
                                       (lift GRACE period)
                                       reboot (B2')
EXCHANGE_ID
CREATE_SESSION
OPEN(reclaim)
                                       (lift GRACE period)
                                       reboot (B3')
EXCHANGE_ID
CREATE_SESSION
OPEN(reclaim)

What should happen to the OPEN(reclaim) in (B3')?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
