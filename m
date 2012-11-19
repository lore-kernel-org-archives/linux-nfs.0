Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49648 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772Ab2KSMqV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Nov 2012 07:46:21 -0500
Date: Mon, 19 Nov 2012 07:46:18 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSd state: nfs4_lock_state() and nfs4_lock_state()
Message-ID: <20121119124618.GA30084@fieldses.org>
References: <50A622AE.3080809@parallels.com>
 <20121116165845.GA32183@fieldses.org>
 <50A9F03B.1010909@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <50A9F03B.1010909@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 19, 2012 at 12:39:23PM +0400, Stanislav Kinsbursky wrote:
> 16.11.2012 20:58, bfields@fieldses.org пишет:
> >
> >A patch follows: note it's a two-line patch, with 20 lines of changelog
> >showing that I looked at what state might be shared by other threads and
> >explaining why I think this is safe.
> >
> 
> Acked-by: Stanislav Kinsburskiy <skinsbursky@parallels.com>
> 
> >I think that's what we need to do: little patches that remove it from
> >one or another part of the code with careful explanation of why it
> >works.
> >
> 
> Yes, thanks. I'll also try to simplify nfsd_open() by little patches.
> In general it looks like client_mutex protect two different things:
> open owner state (which is containerised already, actually) and
> files access.
> So, probably, this client mutex have to be converted into two:
> per-net one, which protects open owner state, and static one, which
> protects files operations.
> What do you think about it?

That sounds right.

--b.
