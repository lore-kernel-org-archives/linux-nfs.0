Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:49573 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183Ab2KSIjv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2012 03:39:51 -0500
Message-ID: <50A9F03B.1010909@parallels.com>
Date: Mon, 19 Nov 2012 12:39:23 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSd state: nfs4_lock_state() and nfs4_lock_state()
References: <50A622AE.3080809@parallels.com> <20121116165845.GA32183@fieldses.org>
In-Reply-To: <20121116165845.GA32183@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

16.11.2012 20:58, bfields@fieldses.org пишет:
>
> A patch follows: note it's a two-line patch, with 20 lines of changelog
> showing that I looked at what state might be shared by other threads and
> explaining why I think this is safe.
>

Acked-by: Stanislav Kinsburskiy <skinsbursky@parallels.com>

> I think that's what we need to do: little patches that remove it from
> one or another part of the code with careful explanation of why it
> works.
>

Yes, thanks. I'll also try to simplify nfsd_open() by little patches.
In general it looks like client_mutex protect two different things: open owner 
state (which is containerised already, actually) and files access.
So, probably, this client mutex have to be converted into two: per-net one, 
which protects open owner state, and static one, which protects files operations.
What do you think about it?

-- 
Best regards,
Stanislav Kinsbursky
