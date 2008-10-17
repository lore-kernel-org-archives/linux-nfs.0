From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: make warning in svc_check_conn_limits() more
 generic
Date: Fri, 17 Oct 2008 14:27:53 -0400
Message-ID: <20081017142753.6485571f@tleilax.poochiereds.net>
References: <1221225127-6042-1-git-send-email-jlayton@redhat.com>
	<20080924215742.GG10841@fieldses.org>
	<20080925162315.6f29d092@tleilax.poochiereds.net>
	<20081015081457.56ef3778@tleilax.poochiereds.net>
	<20081015202102.GC5038@fieldses.org>
	<20081015205118.14de4611@tleilax.poochiereds.net>
	<fdcfe437d88ecb7d49ea4b2729407dc5.squirrel@neil.brown.name>
	<20081016094843.52786ef8@barsoom.rdu.redhat.com>
	<18679.55525.146056.752860@notabene.brown>
	<20081017182051.GH11884@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49943 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754561AbYJQS2x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 14:28:53 -0400
In-Reply-To: <20081017182051.GH11884@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 17 Oct 2008 14:20:51 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> > A per-service setting that defaults to something reasonable like your
> > suggestions and can be over-ridden by a module parameter sounds like a
> > good idea.
> > If you change the module parameter via
> >  /sys/modules/lockd/parameters/max_connections
> > then it wouldn't take effect until the service were stopped and restarted,
> > but I expect that is acceptable (and could probably be 'fixed' if really
> > needed).
> 
> Sounds fine to me.
> 
> And I'd probably fix the defaults now and then hold off adding
> max_connections till it'd been seen to be needed.
> 
> --b.

I just posted a small patchset that implements this. I ended up adding
a module parameter for it since it was easy to do. I've only done basic
smoke testing with it, however. If it looks OK, I'll see if I can get
the guy who originally reported this to test it out.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
