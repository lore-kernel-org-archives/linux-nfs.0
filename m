From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 4/4] NLM: don't requeue block if it was invalidated
	while GRANT_MSG was in flight
Date: Fri, 14 Mar 2008 17:59:10 -0400
Message-ID: <1205531950.3347.14.camel@heimdal.trondhjem.org>
References: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-2-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-3-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-4-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-5-git-send-email-jlayton@redhat.com>
	 <170fa0d20803141255k41e8e2a3t6a53f4f812a15d7b@mail.gmail.com>
	 <1205529061.27906.86.camel@heimdal.trondhjem.org>
	 <170fa0d20803141421s5c784d16ie1db8e1d57e4b428@mail.gmail.com>
	 <1205530164.27906.100.camel@heimdal.trondhjem.org>
	 <20080314173938.48c4f7cb@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mike Snitzer <snitzer@gmail.com>, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:49695 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884AbYCNV7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Mar 2008 17:59:24 -0400
In-Reply-To: <20080314173938.48c4f7cb-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-03-14 at 17:39 -0400, Jeff Layton wrote:
> The race I had in mind was:
> 
> rpciod: nlmsvc_grant_callback checks to see if the block is on the list
> lockd:  lockd() removes the block from the list after getting a SIGKILL
> rpciod: nlmsvc_grant_callback requeues the block with a new timeout
> 
> ...though now that I've looked, it seems like the BKL should prevent
> that particular race.

In any case, this can be fixed very simply: add a new flag B_INVALIDATED
to nlm_block->b_flags which tells nlmsvc_grant_callback() that the block
has been invalidated, and must not be requeued. Then remove the test for
block->b_list...

In fact, it is quite arguable that we should probably have some form of
locking scheme to prevent GRANTED and CANCEL requests from colliding. We
might therefore also want to add a B_LOCKED flag, in order to tell
incoming CANCEL requests that they should be deferred until the GRANTED
call has completed. That would be a separate issue/patch, though.

> > This should, AFAIK, only occur while holding the file->f_mutex.
> > Similarly, the GRANTED code should be holding the same lock when looking
> > up the block.
> > 
> 
> It's not though, is it? I don't think nlmsvc_grant_callback is run
> under the file->f_mutex (unless I'm missing something).

Correct, but nlmsvc_grant_callback isn't actually trying to look up the
block, so my argument is invalid.

Trond

