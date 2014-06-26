Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:32859 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097AbaFZNX4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 09:23:56 -0400
Date: Thu, 26 Jun 2014 14:23:52 +0100
From: Luis Henriques <luis.henriques@canonical.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Jiri Slaby <jslaby@suse.cz>, stable@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org,
        Tomas Kasparek <kasparek@fit.vutbr.cz>
Subject: Re: [stable PATCH] nfsd: don't try to reuse an expired DRC entry off
 the list
Message-ID: <20140626132352.GC15901@hercules>
References: <1403290612-15341-1-git-send-email-jlayton@primarydata.com>
 <53AACF88.5000006@suse.cz>
 <20140625093632.0d7b58ac@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20140625093632.0d7b58ac@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 25, 2014 at 09:36:32AM -0400, Jeff Layton wrote:
> On Wed, 25 Jun 2014 15:32:56 +0200
> Jiri Slaby <jslaby@suse.cz> wrote:
> 
> > On 06/20/2014 08:56 PM, Jeff Layton wrote:
> > > From: Jeff Layton <jlayton@redhat.com>
> > > 
> > > This is commit a0ef5e19684f0447da9ff0654a12019c484f57ca in mainline.
> > > 
> > > While the commit message below doesn't lay this out, we've subsequently
> > > found that there are some cases where an entry that's still in use can
> > > be freed prematurely if a particular operation takes a *very* long time
> > > (on the order of minutes) and/or the server is very busy and doesn't
> > > have a lot of memory dedicated to the DRC. This patch eliminates that
> > > possibility, so it's actually more than just a cleanup.
> > > 
> > > The regression crept in in v3.9, and this patch went into mainline in
> > > v3.14. Please apply this to any stable kernel between those two
> > > mainline releases.
> > 
> > Now applied to 3.12. Thanks.
> > 
> > 
> 
> Thank you! It also turns out that we're going to want to pull
> 1b19453d1c6abcfa7c312ba6c9f11a277568fc94 from mainline into stable
> kernels as well. There's one more possibility for an entry to be freed
> while still in use that that patch will fix.
> 
> I'll resend that to stable@vger later today...
> 
> Thanks!
> -- 
> Jeff Layton <jlayton@primarydata.com>
> --
> To unsubscribe from this list: send the line "unsubscribe stable" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Thanks, I'll queue both patches for the 3.11 kernel.

Cheers,
--
Luís
