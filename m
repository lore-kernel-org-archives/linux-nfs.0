From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: make the cache cleaner workqueue deferrable
Date: Tue, 6 Jul 2010 12:29:02 -0400
Message-ID: <20100706162902.GF7387@fieldses.org>
References: <1277996756-8415-1-git-send-email-dedekind1@gmail.com>
 <1278333090.29620.47.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"David S. Miller" <davem@davemloft.net>
To: Artem Bityutskiy <dedekind1@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38045 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755880Ab0GFQ3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jul 2010 12:29:05 -0400
In-Reply-To: <1278333090.29620.47.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 05, 2010 at 03:31:30PM +0300, Artem Bityutskiy wrote:
> On Thu, 2010-07-01 at 18:05 +0300, Artem Bityutskiy wrote:
> > From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
> > 
> > This patch makes the cache_cleaner workqueue deferrable, to prevent
> > unnecessary system wake-ups, which is very important for embedded
> > battery-powered devices.
> > 
> > do_cache_clean() is called every 30 seconds at the moment, and often
> > makes the system wake up from its power-save sleep state. With this
> > change, when the workqueue uses a deferrable timer, the
> > do_cache_clean() invocation will be delayed and combined with the
> > closest "real" wake-up. This improves the power consumption situation.
> > 
> > Note, I tried to create a DECLARE_DELAYED_WORK_DEFERRABLE() helper
> > macro, similar to DECLARE_DELAYED_WORK(), but failed because of the
> > way the timer wheel core stores the deferrable flag (it is the
> > LSBit in the time->base pointer). My attempt to define a static
> > variable with this bit set ended up with the "initializer element is
> > not constant" error.
> > 
> > Thus, I have to use run-time initialization, so I created a new
> > cache_initialize() function which is called once when sunrpc is
> > being initialized.
> > 
> > Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
> 
> Bruce,
> 
> I did some git-logging, and found out that sunrpc stuff goes from you,
> from Trond, and from David, and MAINTAINERS also mentions Neil. Whom
> should I ping WRT to merging this patch?

I got it.  (I'm just getting back from vacation, and very backlogged.)

--b.
