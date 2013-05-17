Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44062 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756164Ab3EQN4v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 May 2013 09:56:51 -0400
Date: Fri, 17 May 2013 09:56:47 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: James Vanns <james.vanns@framestore.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Where in the server code is fsinfo rtpref calculated?
Message-ID: <20130517135647.GB6579@fieldses.org>
References: <20130515174245.GN16811@fieldses.org>
 <1246706961.20581741.1368790982374.JavaMail.root@framestore.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1246706961.20581741.1368790982374.JavaMail.root@framestore.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 17, 2013 at 12:43:02PM +0100, James Vanns wrote:
> > Knowing nothing about your situation, I'd assume the clients are
> > doing that because they actually want that 1MB of data.
> 
> Possibly. But we have no control over that (the application read size,
> I mean).
> 
> > Would you prefer they each send 1024 1k READs?  I don't understand
> > why it's the read size you're focused on here.
> 
> No. But 32x 32k reads is reasonable (because it gives other RPCs a
> look-in).

Maybe.  In any case I'd want to see data before changing our defaults.

> I'm focused on reads because it makes up the majority of
> our NFS traffic. I'm concerned because as it stands (out of the box)
> if the majority of our n knfsd threads are waiting for a 1MB read to
> return then no other RPC request will be serviced and will just
> contribute to the backlog. This backlog itself will probably also contain
> a hefty no. of 1MB read requests too. In short, a lot of other RPC calls
> that are not reads will just be blocking and this will appear to an end
> user as poor performance.

Do you have a performance problem that you've actually measured, and if
so could you share the details?

> We deal with a great number of fairly large files - 10s of GBs in
> size. We just don't want others to suffer because of large request
> sizes coming in (writes end up being of the same size too but there
> are less of them). Our use cases are varied but they all have to share
> the same resource (the array of NFS servers).
> 
> We've only really seen this since our upgrade to SL6/kernel 2.6.32. I
> guess previously that 32k was some sort of default or limit?
> 
> Related to this was my query on when/how the (Linux) client may honour
> the preferred or optimal block size given in the FSINFO reply. Any
> ideas? Is it if a read of less than that preferred block size is
> requested then the preferred is used anyway because it comes at the
> same cost?

I'm not terribly familiar with the client logic, but would expect this
to vary depending on kernel version, read-ahead policy, application
behavior and a number of other factors, so I'd recommend testing with
your workload and finding out.

--b.
