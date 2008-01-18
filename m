From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 4/4] NLM: have nlm_shutdown_hosts kill off all NLM RPC
 tasks
Date: Fri, 18 Jan 2008 17:07:27 -0500
Message-ID: <20080118170727.70a77a6b@tleilax.poochiereds.net>
References: <1200319518-22422-1-git-send-email-jlayton@redhat.com>
	<1200319518-22422-2-git-send-email-jlayton@redhat.com>
	<1200319518-22422-3-git-send-email-jlayton@redhat.com>
	<1200319518-22422-4-git-send-email-jlayton@redhat.com>
	<1200319518-22422-5-git-send-email-jlayton@redhat.com>
	<20080118214345.GM15158@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34655 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762059AbYARWHc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2008 17:07:32 -0500
In-Reply-To: <20080118214345.GM15158@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 18 Jan 2008 16:43:45 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jan 14, 2008 at 09:05:18AM -0500, Jeff Layton wrote:
> > If we're shutting down all the nlm_hosts anyway, then it doesn't
> > make sense to allow RPC calls to linger. Allowing them to do so can
> > mean that the RPC calls can outlive the currently running lockd and
> > can lead to a use after free situation.
> 
> I assume that all new rpc calls are created by the lockd thread itself
> (which also calls nlm_shutdown_hosts(), which guarantees that there
> can't be someone about to make an rpc call using the clnt we're
> destroying here?
> 

I believe that's correct.

> By the way, any idea what the nlm_shutdown_hosts() call in exit_nlm()
> is doing?
> 

Before this patchset, it was possible for more than one lockd
to be up at a time, and I suppose there could have been races that
would cause both to exit without ever calling nlm_shutdown_hosts.

With this patchset, we may be able to remove that. I suspect that it's
probably a noop now. That said, even after spending a fair bit of time
in this code, I'm not entirely comfortable with it. I suggest that we
take the incremental approach to lockd changes unless someone here is
sure :-).

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
