Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14550 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932326Ab3GWQPI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jul 2013 12:15:08 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20130723120258.01024e81@tlielax.poochiereds.net>
References: <20130723120258.01024e81@tlielax.poochiereds.net> <20130723154924.24306.42326.stgit@warthog.procyon.org.uk>
To: Jeff Layton <jlayton@redhat.com>
Cc: dhowells@redhat.com, torvalds@linux-foundation.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-cachefs@redhat.com, Milosz Tanski <milosz@adfin.com>,
        Yacine Belkadi <yacine.belkadi.1@gmail.com>
Subject: Re: [PATCH] Fix __wait_on_atomic_t() to call the action func if the counter != 0
Date: Tue, 23 Jul 2013 17:15:02 +0100
Message-ID: <24785.1374596102@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> wrote:

> > @@ -333,7 +333,8 @@ int __wait_on_atomic_t(wait_queue_head_t *wq, struct wait_bit_queue *q,
> >  		prepare_to_wait(wq, &q->wait, mode);
> >  		val = q->key.flags;
> >  		if (atomic_read(val) == 0)
> > -			ret = (*action)(val);
> > +			break;
> > +		ret = (*action)(val);
> >  	} while (!ret && atomic_read(val) != 0);
> 
> nit: can you now eliminate the check for "val" in the while condition?
> It doesn't look like it harms anything, but eliminating it would
> probably simplify the code slightly...

Its presence means that we don't have to call prepare_to_wait() again if val
became 0.

David
