Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f173.google.com ([209.85.160.173]:44592 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbaI0Sk6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2014 14:40:58 -0400
Received: by mail-yk0-f173.google.com with SMTP id 131so927940ykp.32
        for <linux-nfs@vger.kernel.org>; Sat, 27 Sep 2014 11:40:58 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sat, 27 Sep 2014 14:40:55 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "nfsv4@ietf.org" <nfsv4@ietf.org>, linux-nfs@vger.kernel.org
Subject: Re: [nfsv4] Could somebody please enlighten me as to what is
 supposed to happen in this situation?
Message-ID: <20140927144056.2d303755@synchrony.poochiereds.net>
In-Reply-To: <CAABAsM4zDuzjapXfLUrminwM1FV7iwN+oEzxgzaQ60m93gBBug@mail.gmail.com>
References: <CAABAsM4zDuzjapXfLUrminwM1FV7iwN+oEzxgzaQ60m93gBBug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 27 Sep 2014 11:22:29 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:


My take (quite possibly wrong, but...)

> The scenario is this:
>                                        Server
>                                        ======
>                                        boot (B1)
> Client
> ======
> EXCHANGE_ID
> CREATE_SESSION
> OPEN(reclaim)
> LOCK(reclaim)
> RECLAIM_COMPLETE
>                                        (lift GRACE period)

At this point, we'd deny reclaim from any client that has not issued a
RECLAIM_COMPLETE. In the case of the Linux server with nfsdcltrack, we
clean out any client records that have not issued a RECLAIM_COMPLETE.

>                                        reboot (B2)
> EXCHANGE_ID
> CREATE_SESSION
> OPEN(reclaim)
>                                         reboot (while GRACE period
> still being enforced) (B3)
> EXCHANGE_ID
> CREATE_SESSION
> OPEN(reclaim)
> 
> What should be the server response to the above OPEN(reclaim) from the
> client after reboot (B3)?
> 

My expectation is that it would be granted. There was a
RECLAIM_COMPLETE issued during the boot where the grace period was last
lifted, and that should be enough to allow the client to issue reclaims
on any subsequent reboot, until the grace period is lifted again.

Doing anything else would be a pretty unfriendly way for the server to
behave. In the face of rapid reboots (a not-uncommon occurrence when
patching, etc), you'd lose state unless the client just happened to get
in there quickly enough to issue a RECLAIM_COMPLETE between each reboot.

That was the situation with the legacy client tracker in knfsd. When
testing, it was trivial to reboot the machine quickly twice and on the
second reboot nothing could be reclaimed.
-- 
Jeff Layton <jlayton@primarydata.com>
