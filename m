From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: make warning in svc_check_conn_limits() more
	generic
Date: Fri, 17 Oct 2008 14:29:13 -0400
Message-ID: <20081017182913.GI11884@fieldses.org>
References: <1221225127-6042-1-git-send-email-jlayton@redhat.com> <20080924215742.GG10841@fieldses.org> <20080925162315.6f29d092@tleilax.poochiereds.net> <20081015081457.56ef3778@tleilax.poochiereds.net> <20081015202102.GC5038@fieldses.org> <20081015205118.14de4611@tleilax.poochiereds.net> <fdcfe437d88ecb7d49ea4b2729407dc5.squirrel@neil.brown.name> <20081016094843.52786ef8@barsoom.rdu.redhat.com> <18679.55525.146056.752860@notabene.brown> <89c397150810170755r578ae723o89ab7b475b894704@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Jeff Layton <jlayton@redhat.com>,
	linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54117 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754603AbYJQS31 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 14:29:27 -0400
In-Reply-To: <89c397150810170755r578ae723o89ab7b475b894704-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 17, 2008 at 10:55:38AM -0400, William A. (Andy) Adamson wrote:
> There is a related resource issue for the NFSv4.1 server DRC where the
> server guarantees a per session DRC cache size. The server needs to
> determine how much memory to assign to each session, and will
> therefore need to limit the number of connections based not only on
> the TCP buffer size, but also on memory. I'm writing the DRC code, and
> I'm looking for suggestions on how to manage the per-session memory
> resource. Any thought welcome..

As a starting point you could look at nfsd_create_serv() to see how it
decides max_blksize.

Caveat: Andrew Morton tells me we should be using nr_free_buffer_pages()
here in place of totalram.

Maybe we should define one function

	nfsd_how_big_should_i_be()

that by default just returns some fraction of nr_free_buffer_pages();
and then use that return value to size various things like this.

I don't know....

--b.

> 
> Thanks
> 
> -->Andy
> 
> On Thu, Oct 16, 2008 at 8:14 PM, Neil Brown <neilb@suse.de> wrote:
> > On Thursday October 16, jlayton@redhat.com wrote:
> >>
> >> Thanks for the info Neil, that helps clarify this...
> >>
> >> Using RLIMIT_NOFILE is an interesting idea. From a cursory look at the
> >> code, the default for RLIMIT_NOFILE looks like it's generally 1024.
> >> We'll have to figure that this limit will effectively act as a limit on
> >> the number of concurrent lockd clients. It's not too hard to imagine a
> >> server with more clients than this (think of a large compute cluster).
> >
> > If all those clients used UDP, this would not be a problem.  While I
> > see the value of TCP for NFS, it doesn't seem as convincing for NLM.
> >
> > But I don't expect we have the luxury of insisting that clients use
> > UDP for locking :-(
> >
> >>
> >> The problem as you mention, is that that limit won't be easily tunable.
> >> I think we need some mechanism for an admin to tune this limit. It
> >> doesn't have to be tunable on the fly, but shouldn't require a kernel
> >> rebuild. We could eliminate this check for single-threaded services
> >> entirely, but I suppose that leaves the door open for DoS attacks
> >> against those services.
> >>
> >> Maybe the best thing is to go with Bruce's idea and add a sv_maxconn
> >> field to the svc_serv struct. We could make that default to the max of
> >> RLIMIT_NOFILE rlim_cur value or the currently calculated value.
> >> Eventually we could add a mechanism to allow  someone to tune that
> >> value. A module parameter would probably be fine for lockd. We might
> >> even want to set the limit lower for things like the nfsv4 callback
> >> thread.
> >>
> >> Thoughts?
> >
> > A per-service setting that defaults to something reasonable like your
> > suggestions and can be over-ridden by a module parameter sounds like a
> > good idea.
> > If you change the module parameter via
> >  /sys/modules/lockd/parameters/max_connections
> > then it wouldn't take effect until the service were stopped and restarted,
> > but I expect that is acceptable (and could probably be 'fixed' if really
> > needed).
> >
> > NeilBrown
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
