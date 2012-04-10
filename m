Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347Ab2DJQK4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 12:10:56 -0400
Date: Tue, 10 Apr 2012 12:11:40 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Sachin Prabhu <sprabhu@redhat.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>, bfields@redhat.com,
        steved <steved@redhat.com>, linux-fsdevel@vger.kernel.org
Subject: Re: ESTALE errors: What can be done to handle this problem.
Message-ID: <20120410121140.636a489f@corrin.poochiereds.net>
In-Reply-To: <1334073825.2149.29.camel@localhost>
References: <1334073825.2149.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 10 Apr 2012 17:03:45 +0100
Sachin Prabhu <sprabhu@redhat.com> wrote:

> The change introduced by upstream patch
> 4f48af45842c6e78ab958c90344d3c940db4da15
> means that the lookup call for a file will return a inode as being valid
> as long as 
> 1) The directory containing the file was revalidated ie. the cached
> attributes are valid and it was found that there was no change in the
> directory since the attributes of the file were cached.
> 2) We aren't doing a OPEN call or the LOOKUP_REVAL flag is not set.
> 
> We no longer check to see if the file attributes themselves are valid.
> This patch was introduced in 2.6.23.
> 
> This increases the chances of ESTALE errors on GETATTR calls if
> 1) The attributes of the directory containing the file is refreshed on
> the client and the values stored in the attribute cache are still valid
> when the subsequent steps are run.
> 2) The file is deleted on the server.
> 3) The cached attributes of the file on the client have expired.
> 4) We stat the file.
> 
> For a GETATTR call
> 1) The lookup will return the inode as valid.
> 2) The subsequent getattr call will notice that the attributes are no
> longer valid and will attempt a on the wire call which fails with an
> ESTALE. 
> We cannot recover at this point and return an ESTALE error to userland.
> 
> We can easily reproduce this with the following reproducer.
> 
> On the server
> # while true; do date >b ; rm -f a ; mv b a;sleep 3; done
> 
> On the client
> #while true; do stat a 2>&1 | grep Stale ; done
> 
> We do not see this problem in kernels not containing this patch since we
> revalidate the file inode before we return the inode as valid in the
> lookup call. Here  we notice that the attribute cache is no longer valid
> and do an over the wire GETATTR call to fetch the latest file
> attributes. An ESTALE error in the lookup phase is handled by redoing
> the lookup call. This still has a potential of failing with an ESTALE if
> the attribute cache expires between the lookup and the getattr calls.
> But chances of this happening are relatively low.
> 
> A workaround is to disable attribute caching which is accompanied by a
> huge performance hit. A proper fix would be to just redo the lookup call
> in case we ever encounter an ESTALE error with a limit to the number of
> retries which can be made. However this approach will involve a bit of
> work in the VFS layer. We have a user provided patch which does just
> this but is incomplete.
> 
> Is this approach feasible? If not, what else can be done to avoid this
> problem.
> 
> Sachin Prabhu
> 

(cc'ing linux-fsdevel too)

While it sounds distinctly not-fun to code up, I think the only real
fix is to add code to all of the path-based syscalls to redo the
lookup with LOOKUP_REVAL set and retry the operation when you get back
an ESTALE.

We should retry more than once too since it's possible that you could
race more than once. That should be bounded at some finite
number of retries though so we don't end up in an infinite loop.

I don't think it would be a terribly difficult patchset, but it would
have to be done in the VFS layer and would touch a lot of code there.

-- 
Jeff Layton <jlayton@redhat.com>
