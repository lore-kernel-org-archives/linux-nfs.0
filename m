Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f46.google.com ([74.125.82.46]:52793 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbaHZSTo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 14:19:44 -0400
Received: by mail-wg0-f46.google.com with SMTP id m15so14888329wgh.29
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 11:19:43 -0700 (PDT)
Message-ID: <53FCCFBD.3080305@plexistor.com>
Date: Tue, 26 Aug 2014 21:19:41 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "Matt W. Benjamin" <matt@linuxbox.com>, Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Adam C. Emerson" <aemerson@linuxbox.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
References: <53FCA183.8000605@plexistor.com>	<1435166875.78.1409066662291.JavaMail.root@thunderbeast.private.linuxbox.com>	<CAHQdGtT-B7NTP8T7ETgTJD1+84k_KW_5aOfrYjLpA04hoR3YsA@mail.gmail.com>	<53FCBC5A.4060304@plexistor.com>	<CAHQdGtSghgbrPr=X8O2YLq=vXbKY1y5OuOMisf6vRoj8WeF0YA@mail.gmail.com>	<53FCBE9C.40906@plexistor.com> <CAHQdGtTgcGiWbcZyAsaOzdB=RpdUx17vHcw1yxg7vS56BfwY+A@mail.gmail.com>
In-Reply-To: <CAHQdGtTgcGiWbcZyAsaOzdB=RpdUx17vHcw1yxg7vS56BfwY+A@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/26/2014 08:54 PM, Trond Myklebust wrote:
> On Tue, Aug 26, 2014 at 1:06 PM, Boaz Harrosh <boaz@plexistor.com> wrote:

> 
> The deadlock occurs _if_ the above layout commit  is unable to get a
> slot. You can't guarantee that it will, because the slot table is a
> finite resource and it can be exhausted 

Yes all I ever seen is 1 slot in any of the clients/servers I've
seen so I assume 1 slot ever

> if you allow fore channel
> calls to trigger synchronous recalls on the back channel 

Beep! but this is exactly what I'm trying to say. The STD specifically
forbids that. The server is not allowed to wait here, it must return
imitatively, with an error that frees the slot and then later issue the
RECALL.

This is what I said exactly three times in my mail, and what I have
depicted in my flow:
	Server async operation (mandated by the STD)
	Client back-channel can be sync with for channel (Not mentioned by the STD)

> that again trigger synchronous calls on the fore channel. 


> You're basically saying
> that the client needs to guarantee that it can allocate 2 slots before
> it is allowed to send a layoutget just in case the server needs to
> recall a layout.
> 

No I am not saying that, please count. Since the Server is not allowed
sync operation then one slot is enough and the client can do sync lo_commit
while in recall.

> If, OTOH, the layoutcommit is asynchronous, then there is no
> serialisation and the back channel thread can happily reply to the
> layout recall even if there are no free slots in the fore channel.
> 

Sure that will work as well, but not optimally, and for no good reason.

Please go back to my flow with the 3 cases. See how the server never waits
for anything and will always imitatively reply to the layout_get.
Since the server is not allowed a sync operation and is mandated by the
RFC text to not wait, then the client is allowed and can do sync operations
because it is enough that only one do async.

BTW: If what you are saying is true than there is a bug in the slot code
because this patch does work, and everything flows past this situation.
I have a reproducer test that fails 100% of the time without this patch
and only fails much later at some other place, but not at this deadlock,
with this patch applied.

Cheers
Boaz

