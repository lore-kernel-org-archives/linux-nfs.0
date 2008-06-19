From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC] new client gssd upcall
Date: Thu, 19 Jun 2008 15:11:17 -0400
Message-ID: <20080619151117.20ddc00e@tleilax.poochiereds.net>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
	<20080616102859.66fa6a34@tleilax.poochiereds.net>
	<20080617213622.GA5849@fieldses.org>
	<1213739969.7288.90.camel@localhost>
	<485A7D2D.4060206@citi.umich.edu>
	<20080619114929.5c211ec9@tleilax.poochiereds.net>
	<1213895182.7120.13.camel@localhost>
	<20080619132720.6bce2bb9@tleilax.poochiereds.net>
	<1213899199.7120.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Olga Kornievskaia <aglo@citi.umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>, kwc@citi.umich.edu,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42827 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbYFSTLh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jun 2008 15:11:37 -0400
In-Reply-To: <1213899199.7120.22.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 19 Jun 2008 14:13:19 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2008-06-19 at 13:27 -0400, Jeff Layton wrote:
> > There's also no reason we couldn't use keys for
> > idmap upcalls as well. I'm considering them for a similar idmap scheme
> > for CIFS.
> 
> Ewww.... NACK, NACK, NACK, NACK....
> 
> There is a perfectly good reason why you wouldn't ever want to use keys
> for idmap upcalls: keys are user/process/thread objects while idmapd
> entries are NFSv4-namespace objects.
> 

My thinking for CIFS is to use keys to do the upcall and copy the
mapping into a cache that we'll manage independently of the key cache.
The CIFS case is a little different though. We're not mapping usernames
to uid's and vice-versa, but Windows RID's to unix uid's. Still, it's a
somewhat similar problem. The amount of data that we're dealing with in
an idmap upcall is pretty small, so copying it and then destroying the
key wouldn't involve a lot of overhead.

That may not be palatable for NFS though.

-- 
Jeff Layton <jlayton@redhat.com>
