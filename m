From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: make warning in svc_check_conn_limits() more
	generic
Date: Fri, 17 Oct 2008 14:29:37 -0400
Message-ID: <20081017182937.GJ11884@fieldses.org>
References: <20080924215742.GG10841@fieldses.org> <20080925162315.6f29d092@tleilax.poochiereds.net> <20081015081457.56ef3778@tleilax.poochiereds.net> <20081015202102.GC5038@fieldses.org> <20081015205118.14de4611@tleilax.poochiereds.net> <fdcfe437d88ecb7d49ea4b2729407dc5.squirrel@neil.brown.name> <20081016094843.52786ef8@barsoom.rdu.redhat.com> <18679.55525.146056.752860@notabene.brown> <20081017182051.GH11884@fieldses.org> <20081017142753.6485571f@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54120 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754705AbYJQS3s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 14:29:48 -0400
In-Reply-To: <20081017142753.6485571f-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 17, 2008 at 02:27:53PM -0400, Jeff Layton wrote:
> On Fri, 17 Oct 2008 14:20:51 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > > A per-service setting that defaults to something reasonable like your
> > > suggestions and can be over-ridden by a module parameter sounds like a
> > > good idea.
> > > If you change the module parameter via
> > >  /sys/modules/lockd/parameters/max_connections
> > > then it wouldn't take effect until the service were stopped and restarted,
> > > but I expect that is acceptable (and could probably be 'fixed' if really
> > > needed).
> > 
> > Sounds fine to me.
> > 
> > And I'd probably fix the defaults now and then hold off adding
> > max_connections till it'd been seen to be needed.
> > 
> > --b.
> 
> I just posted a small patchset that implements this. I ended up adding
> a module parameter for it since it was easy to do. I've only done basic
> smoke testing with it, however. If it looks OK, I'll see if I can get
> the guy who originally reported this to test it out.

Thanks!  I'll take a look.

--b.
