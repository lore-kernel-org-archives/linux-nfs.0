From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] sunrpc: make warning in svc_check_conn_limits() more  
    generic
Date: Fri, 17 Oct 2008 11:14:29 +1100
Message-ID: <18679.55525.146056.752860@notabene.brown>
References: <1221225127-6042-1-git-send-email-jlayton@redhat.com>
	<20080924215742.GG10841@fieldses.org>
	<20080925162315.6f29d092@tleilax.poochiereds.net>
	<20081015081457.56ef3778@tleilax.poochiereds.net>
	<20081015202102.GC5038@fieldses.org>
	<20081015205118.14de4611@tleilax.poochiereds.net>
	<fdcfe437d88ecb7d49ea4b2729407dc5.squirrel@neil.brown.name>
	<20081016094843.52786ef8@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:33934 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753042AbYJQAOR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Oct 2008 20:14:17 -0400
In-Reply-To: message from Jeff Layton on Thursday October 16
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday October 16, jlayton@redhat.com wrote:
> 
> Thanks for the info Neil, that helps clarify this...
> 
> Using RLIMIT_NOFILE is an interesting idea. From a cursory look at the
> code, the default for RLIMIT_NOFILE looks like it's generally 1024.
> We'll have to figure that this limit will effectively act as a limit on
> the number of concurrent lockd clients. It's not too hard to imagine a
> server with more clients than this (think of a large compute cluster).

If all those clients used UDP, this would not be a problem.  While I
see the value of TCP for NFS, it doesn't seem as convincing for NLM.

But I don't expect we have the luxury of insisting that clients use
UDP for locking :-(

> 
> The problem as you mention, is that that limit won't be easily tunable.
> I think we need some mechanism for an admin to tune this limit. It
> doesn't have to be tunable on the fly, but shouldn't require a kernel
> rebuild. We could eliminate this check for single-threaded services
> entirely, but I suppose that leaves the door open for DoS attacks
> against those services.
> 
> Maybe the best thing is to go with Bruce's idea and add a sv_maxconn
> field to the svc_serv struct. We could make that default to the max of
> RLIMIT_NOFILE rlim_cur value or the currently calculated value.
> Eventually we could add a mechanism to allow  someone to tune that
> value. A module parameter would probably be fine for lockd. We might
> even want to set the limit lower for things like the nfsv4 callback
> thread.
> 
> Thoughts?

A per-service setting that defaults to something reasonable like your
suggestions and can be over-ridden by a module parameter sounds like a
good idea.
If you change the module parameter via
 /sys/modules/lockd/parameters/max_connections
then it wouldn't take effect until the service were stopped and restarted,
but I expect that is acceptable (and could probably be 'fixed' if really
needed).

NeilBrown
