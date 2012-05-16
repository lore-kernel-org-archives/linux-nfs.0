Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56663 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759114Ab2EPUzB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 16:55:01 -0400
Date: Wed, 16 May 2012 16:54:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH RFC 00/13] Lockd: grace period containerization
Message-ID: <20120516205458.GC20487@fieldses.org>
References: <20120505170722.11559.74503.stgit@localhost.localdomain>
 <20120516200630.GB20487@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120516200630.GB20487@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 16, 2012 at 04:06:30PM -0400, J. Bruce Fields wrote:
> On Sat, May 05, 2012 at 09:21:30PM +0400, Stanislav Kinsbursky wrote:
> > This patch set is marked with RFC, because I'm still not quite sure, that this
> > implementation will satisfy other interested people.
> > So, would be appreciated for any comments.
> > 
> > This patch set makes grace period and hosts reclaiming network namespace
> > aware.
> > 
> > Main ideas:
> > 1)  moving of 
> > 
> > 	unsigned long next_gc;
> > 	unsigned long nrhosts;
> > 
> > 	struct delayed_work grace_period_end;
> > 	struct lock_manager lockd_manager;
> > 	struct list_head grace_list;
> > 
> > to per-net Lockd data.
> > 
> > 2) moving of 
> > 
> > 	struct lock_manager nfsd4_manager;
> > 
> > to per-net NFSd data.
> > 
> > 3) shutdown + gc of NLM hosts done now network namespace aware.
> 
> That all sounds reasonable to me.
> 
> > 4) restart_grace() now works only for init_net.
> 
> Eventually we might just remove that.  I doubt it's used anywhere.

And on a quick skim I don't see anything wrong with the patches
themselves; let me know when you consider them ready.

The per-net grace period management probably isn't what we'll want
eventually, but as I said on the other thread I think it's a reasonable
starting point.

--b.
