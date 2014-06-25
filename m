Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:56029 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754202AbaFYNgf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 09:36:35 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so1678564qga.9
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jun 2014 06:36:34 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 25 Jun 2014 09:36:32 -0400
To: Jiri Slaby <jslaby@suse.cz>
Cc: stable@vger.kernel.org, linux-nfs@vger.kernel.org, bfields@fieldses.org,
        Tomas Kasparek <kasparek@fit.vutbr.cz>
Subject: Re: [stable PATCH] nfsd: don't try to reuse an expired DRC entry
 off the list
Message-ID: <20140625093632.0d7b58ac@tlielax.poochiereds.net>
In-Reply-To: <53AACF88.5000006@suse.cz>
References: <1403290612-15341-1-git-send-email-jlayton@primarydata.com>
	<53AACF88.5000006@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 25 Jun 2014 15:32:56 +0200
Jiri Slaby <jslaby@suse.cz> wrote:

> On 06/20/2014 08:56 PM, Jeff Layton wrote:
> > From: Jeff Layton <jlayton@redhat.com>
> > 
> > This is commit a0ef5e19684f0447da9ff0654a12019c484f57ca in mainline.
> > 
> > While the commit message below doesn't lay this out, we've subsequently
> > found that there are some cases where an entry that's still in use can
> > be freed prematurely if a particular operation takes a *very* long time
> > (on the order of minutes) and/or the server is very busy and doesn't
> > have a lot of memory dedicated to the DRC. This patch eliminates that
> > possibility, so it's actually more than just a cleanup.
> > 
> > The regression crept in in v3.9, and this patch went into mainline in
> > v3.14. Please apply this to any stable kernel between those two
> > mainline releases.
> 
> Now applied to 3.12. Thanks.
> 
> 

Thank you! It also turns out that we're going to want to pull
1b19453d1c6abcfa7c312ba6c9f11a277568fc94 from mainline into stable
kernels as well. There's one more possibility for an entry to be freed
while still in use that that patch will fix.

I'll resend that to stable@vger later today...

Thanks!
-- 
Jeff Layton <jlayton@primarydata.com>
