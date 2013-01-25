Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay3.sgi.com ([192.48.152.1]:33157 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752811Ab3AYVNR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2013 16:13:17 -0500
Date: Fri, 25 Jan 2013 15:13:16 -0600
From: Ben Myers <bpm@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org,
        Jim Rees <rees@umich.edu>
Subject: Re: sunrpc: socket buffer size tuneable
Message-ID: <20130125211316.GX30652@sgi.com>
References: <20130125192935.GA32470@sgi.com>
 <20130125202107.GD29596@fieldses.org>
 <20130125203521.GE29596@fieldses.org>
 <20130125205145.GF29596@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130125205145.GF29596@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Bruce,

On Fri, Jan 25, 2013 at 03:51:45PM -0500, J. Bruce Fields wrote:
> On Fri, Jan 25, 2013 at 03:35:21PM -0500, J. Bruce Fields wrote:
> > On Fri, Jan 25, 2013 at 03:21:07PM -0500, J. Bruce Fields wrote:
> > > > The minimal overflow fix did not resolve the timeouts.
> > > 
> > > OK, thanks, that's expected.
> > > 
> > > > I will test with this to see if it resolves the timeouts:
> > > 
> > > And I'd expect that to do the job--but at the expense of some tcp
> > > bandwidth.  So you end up needing your other module parameters to get
> > > the performance back.
> > 
> > Also, what do you see happening on the server in the problem case--are
> > threads blocking in svc_send, or are they dropping replies?

I'm working on getting a dump to determine this.  Maybe there is an easier way?

> And what exactly is your test?

Boot of a 144 node nfs root cluster.  The timeouts happen when loading a ~14mb
kernel module.

Thanks,
Ben
