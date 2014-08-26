Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f177.google.com ([209.85.160.177]:59490 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbaHZQ7s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 12:59:48 -0400
Received: by mail-yk0-f177.google.com with SMTP id 79so11519447ykr.22
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 09:59:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53FCBC5A.4060304@plexistor.com>
References: <53FCA183.8000605@plexistor.com>
	<1435166875.78.1409066662291.JavaMail.root@thunderbeast.private.linuxbox.com>
	<CAHQdGtT-B7NTP8T7ETgTJD1+84k_KW_5aOfrYjLpA04hoR3YsA@mail.gmail.com>
	<53FCBC5A.4060304@plexistor.com>
Date: Tue, 26 Aug 2014 12:59:47 -0400
Message-ID: <CAHQdGtSghgbrPr=X8O2YLq=vXbKY1y5OuOMisf6vRoj8WeF0YA@mail.gmail.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: "Matt W. Benjamin" <matt@linuxbox.com>, Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Adam C. Emerson" <aemerson@linuxbox.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 26, 2014 at 12:56 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
> On 08/26/2014 06:36 PM, Trond Myklebust wrote:
>> On Tue, Aug 26, 2014 at 11:24 AM, Matt W. Benjamin <matt@linuxbox.com> wrote:
>>> IIUC, the problem is the forechannel slot count, since the call you want to make synchronously is on the forechannel?
>
>
> Matt no top post on a Linux mailing list ;-)
>
>> Yep. layoutcommit will be sent on the fore channel, which is why it
>> can deadlock with the initial layoutget (or whatever operation that
>> triggered the layout recall).
>
> Trond you said below:
>> The above can deadlock if there are no session slots available to send
>> the layoutcommit, in which case the recall won't complete, and the
>> layoutget won't get a reply (which would free up the slot).
>
> Why would the layoutget not-get-a-reply ?
> This is how it goes with Both ganesha server and knfsd last I tested.
>
> [1]
> The LAYOUT_GET cause LAYOUT_RECALL case: (including the lo_commit)
>
> client          Server                                     comments
> ~~~~~~          ~~~~~~                                     ~~~~~~~~
> LAYOUT_GET ==>
>            <==   LAYOUT_GET_REPLAY(ERR_RECALL_CONFLICT)
>                                                 <--------- fore-channel is free
>            <==   RECALL
> LAYOUT_COMMIT ==>
>             <==  LAYOUT_COMMIT_REPLAY
>                                                 <--------- fore-channel is free

Beep! No free slots, so this hangs.

> RECALL_REPLY(NO_MATCHING) =>
>                                                 <--------- back-channel is free
>
> Note that in this case the server is to send the RECALL only after
> the error reply to LAYOUT_GET, specifically it is not aloud to get stuck
> inside LAYOUT_GET and wait for the RECALL. (mandated by STD)
>
> [2]
> The LAYOUT_GET sent all the while a RECALL is on the wire:
> client          Server                                     comments
> ~~~~~~          ~~~~~~                                     ~~~~~~~~
>            <== RECALL
> LAYOUT_GET ==>
>            <== LAYOUT_GET_REPLAY(ERR_RECALL_CONFLICT)
>                                                 <--------- fore-channel is free
> LAYOUT_COMMIT ==>
>                 LAYOUT_COMMIT_REPLAY
>                                                 <--------- fore-channel is free
> RECALL_REPLY(NO_MATCHING) =>
>                                                 <--------- back-channel is free
>
>
> [3]
> Or the worst case that lo_commit needs to wait for the channel Similar
> to [2] above:
>
> client          Server                                     comments
> ~~~~~~          ~~~~~~                                     ~~~~~~~~
>            <== RECALL
> LAYOUT_GET ==>
> initiate_lo_commit   ==>  slot is taken needs to wait
>
>            <== LAYOUT_GET_REPLAY(ERR_RECALL_CONFLICT)
>                                                 <--------- fore-channel is free
> LAYOUT_COMMIT ==>                               slot is now free lo_commit goes through
>            <== LAYOUT_COMMIT_REPLAY
>                                                 <--------- fore-channel is free
> RECALL_REPLY(NO_MATCHING) =>
>                                                 <--------- back-channel is free
>
> So the most important is that the server must not get stuck in lo_get
> and since there is a slot for each channel the lo_commit can be sent
> from within the recall.
>
> What am I missing?
>
> Thanks
> Boaz
>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
