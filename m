From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC] new client gssd upcall
Date: Thu, 19 Jun 2008 13:27:20 -0400
Message-ID: <20080619132720.6bce2bb9@tleilax.poochiereds.net>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
	<20080616102859.66fa6a34@tleilax.poochiereds.net>
	<20080617213622.GA5849@fieldses.org>
	<1213739969.7288.90.camel@localhost>
	<485A7D2D.4060206@citi.umich.edu>
	<20080619114929.5c211ec9@tleilax.poochiereds.net>
	<1213895182.7120.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Olga Kornievskaia <aglo@citi.umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>, kwc@citi.umich.edu,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39299 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753946AbYFSR1m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jun 2008 13:27:42 -0400
In-Reply-To: <1213895182.7120.13.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 19 Jun 2008 13:06:22 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2008-06-19 at 11:49 -0400, Jeff Layton wrote:
> > Because it's less code that we have to maintain. rpc_pipefs certainly works
> > (and works fairly well), but we have so many upcall mechanisms in the
> > kernel already. keyctl also has some nice features (automated cache
> > timeouts, granular security, etc), and was designed with this sort of use
> > in mind.
> > 
> > I'm not saying that we absolutely need to scrap rpc_pipefs, but considering
> > alternatives may mean less work for us all in the long run.
> 
> Talk about scrapping rpc_pipefs is premature, to say the least: I have
> yet to see a plan for replacing the idmapd upcall. I have yet to see
> working code that replaces the gss upcall and that works correctly in a
> non-blocking environment.
> 

That was probably too strongly worded. We wouldn't be scrapping
rpc_pipefs for a long time even if we did add new upcall schemes. That
said:

I know that David H. recently added async versions of request_key:

request_key_async()

...and...

request_key_async_with_auxdata()

...assuming they work the way I think they do, they should be OK for
the non-blocking case. There's also no reason we couldn't use keys for
idmap upcalls as well. I'm considering them for a similar idmap scheme
for CIFS.

Of course all of this is handwavy and speculative. I have no working
code. I was just asking whether anyone had considered this API for
this purpose.

-- 
Jeff Layton <jlayton@redhat.com>
