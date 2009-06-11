From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/3] nfsd: optimise the starting of zero threads when
 none are running.
Date: Thu, 11 Jun 2009 13:26:38 -0400
Message-ID: <20090611132638.137b782b@barsoom.rdu.redhat.com>
References: <20090528062730.15937.70579.stgit@notabene.brown>
	<20090528063303.15937.57966.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42380 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695AbZFKR0l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Jun 2009 13:26:41 -0400
In-Reply-To: <20090528063303.15937.57966.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 28 May 2009 16:33:03 +1000
NeilBrown <neilb@suse.de> wrote:

> Currently, if we ask to set then number of nfsd threads to zero when
> there are none running, we set up all the sockets and register the
> service, and then tear it all down again.
> This is pointless.
> 
> So detect that case and exit promptly.
> (also remove an assignment to 'error' which was never used.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>

Acked-by: Jeff Layton <jlayton@redhat.com>

FWIW, the patchset I did to add IPv6 support makes some similar
optimizations to the userspace rpc.nfsd program too.
