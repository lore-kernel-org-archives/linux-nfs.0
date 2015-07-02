Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:48897 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbbGBEKy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 00:10:54 -0400
Date: Thu, 2 Jul 2015 05:10:46 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Subject: running out of tags in 9P (was Re: [git pull] vfs part 2)
Message-ID: <20150702041046.GG17109@ZenIV.linux.org.uk>
References: <20150621211213.GA18732@ZenIV.linux.org.uk>
 <5587F943.3040006@samsung.com>
 <20150701062752.GC17109@ZenIV.linux.org.uk>
 <55939BE3.6040902@samsung.com>
 <20150701082753.GD17109@ZenIV.linux.org.uk>
 <5593A7A0.6050400@samsung.com>
 <20150701085507.GE17109@ZenIV.linux.org.uk>
 <5593CE37.4070307@samsung.com>
 <20150701184408.GF17109@ZenIV.linux.org.uk>
 <20150702032042.GA32613@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150702032042.GA32613@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[9p and sunrpc folks added to Cc]

On Thu, Jul 02, 2015 at 04:20:42AM +0100, Al Viro wrote:
> On Wed, Jul 01, 2015 at 07:44:08PM +0100, Al Viro wrote:
> > Mismatched reply could also be a possibility, but only if we end up with
> > sending more than one request with the same tag without waiting for response
> > for the first one.
> 
> ... and I think I see what's going on.  Tags are 16bit.  Suppose the
> server stalls for some reason *and* we keep piling the requests up.
> New tags keep being grabbed by this:
> 
>         tag = P9_NOTAG;
>         if (type != P9_TVERSION) {
>                 tag = p9_idpool_get(c->tagpool);
>                 if (tag < 0)
>                         return ERR_PTR(-ENOMEM);
>         }
> tag is int here.  Then we pass tag to
>         req = p9_tag_alloc(c, tag, req_size);
> and that's what sets req->tc->tag.  OK, but... The argument of p9_tag_alloc()
> in u16, so after 2^16 pending requests we'll wrap around.  p9_idpool_get()
> will happily return values greater than 65535 - it's using idr and it's
> used (with different pools) for 16bit tags and 32bit FIDs.
> 
> Now, p9_tag_alloc(c, 65539, max_size) will return the same req we'd got from
> p9_tag_alloc(c, 3, max_size).  And we are fucked - as far as the server is
> concerned, we'd just sent another request with tag 3.  And on the client
> there are two threads waiting for responses on the same p9_req_t.  Both
> happen to be TWRITE.  Response to the first request arrives and we happen
> to let the second thread go at it first.  Voila - the first request had
> been for page-sized write() and got successfully handled.  The _second_ one
> had been short and is very surprised to see confirmation of 4Kb worth of
> data having been written.
> 
> It should be easy to confirm - in p9_client_prepare_req() add
> 		if (WARN_ON_ONCE(tag != (u16)tag)) {
> 			p9_idpool_put(tag, c->tagpool);
> 			return ERR_PTR(-ENOMEM);
> 		}
> right after
>                 tag = p9_idpool_get(c->tagpool);
>                 if (tag < 0)
>                         return ERR_PTR(-ENOMEM);
> 
> and see if it triggers.  I'm not sure if failing with ENOMEM is the
> right response (another variant is to sleep there until the pile
> gets cleaned or until we get killed), and WARN_ON_ONCE() is definitely
> not for the real work, but it will do for confirming that this is what
> we are hitting.

FWIW, we probably would be better off with throttling rather than ENOMEM
in such situations.  I'm not familiar with sunrpc enough to be sure how
to do that right way (note that RPC equivalent of 9P tags is 32bit, so
the throttling there is based on memory shortage rather than running out
of XID space), but the interesting issues should be similar - potential
deadlocks in near-OOM situations.  Suggestions?
