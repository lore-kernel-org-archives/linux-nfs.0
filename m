Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58286 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757658AbaLIQo2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 11:44:28 -0500
Date: Tue, 9 Dec 2014 11:44:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] sunrpc: reduce pool->sp_lock contention when
 queueing a xprt for servicing
Message-ID: <20141209164427.GF20526@fieldses.org>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 21, 2014 at 02:19:27PM -0500, Jeff Layton wrote:
> Here are the patches that I had mentioned earlier that reduce the
> contention for the pool->sp_lock when the server is heavily loaded.
> 
> The basic problem is that whenever a svc_xprt needs to be queued up for
> servicing, we have to take the pool->sp_lock to try and find an idle
> thread to service it.  On a busy server, that lock becomes highly
> contended and that limits the throughput.
> 
> This patchset fixes this by changing how we search for an idle thread.
> First, we convert svc_rqst and the sp_all_threads list to be
> RCU-managed. Then we change the search for an idle thread to use the
> sp_all_threads list, which now can be done under the rcu_read_lock.
> When there is an available thread, queueing an xprt to it can now be
> done without any spinlocking.
> 
> With this, we see a pretty substantial increase in performance on a
> larger-scale server that is heavily loaded. Chris has some preliminary
> numbers, but they need to be cleaned up a bit before we can present
> them. I'm hoping to have those by early next week.

I have these merged on top of Trond's nfs-for-3.19-1 tag.  The result is
at git://linux-nfs.org/~bfields/linux-topics.git for-3.19-incoming if
you want to check that I haven't screwed anything up.

I'll probably push that to for-3.19 once it's passed a little more
testing, and send a pull request once I've cleared my mailbox backlog
and seen Trond's stuff merged.

--b.
