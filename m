Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55104 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752012AbdEWMXf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 08:23:35 -0400
Date: Tue, 23 May 2017 08:23:34 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: hch <hch@lst.de>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: remove function pointer casts and constify function tables
Message-ID: <20170523122334.GA4298@fieldses.org>
References: <20170512161701.22468-1-hch@lst.de>
 <1494620040.19467.1.camel@primarydata.com>
 <20170513072557.GA14602@lst.de>
 <1494691819.31377.1.camel@primarydata.com>
 <20170515152134.GC24547@fieldses.org>
 <20170515154450.GA18630@lst.de>
 <20170523081159.GA19216@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170523081159.GA19216@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 23, 2017 at 10:11:59AM +0200, hch wrote:
> On Mon, May 15, 2017 at 05:44:50PM +0200, hch wrote:
> > On Mon, May 15, 2017 at 11:21:34AM -0400, bfields@fieldses.org wrote:
> > > On Sat, May 13, 2017 at 04:10:21PM +0000, Trond Myklebust wrote:
> > > > Right, so the alternative is that either Bruce or Anna merges the full
> > > > set, and then both pull that common base into their linux-next branches
> > > > on linux-nfs.org, and we then ask everyone to develop their 4.13
> > > > patches against those branches. That would work too...
> > > 
> > > I like that.  Christoph, could you just give us a 12-rc1-based branch to
> > > base our 4.13 work on?
> > 
> >     git://git.infradead.org/users/hch/vfs.git nfs-ops
> > 
> > Gitweb:
> > 
> >     http://git.infradead.org/users/hch/vfs.git/shortlog/refs/heads/nfs-ops
> 
> Any progress on picking this up somewhere?

Unfortunately I can't get anything through testing.  It's not your
patches, it's something in -rc1.  My server VM stops responding to
any network traffic randomly in the middle of a run.  If I log in from a
serial console, I see the interface is up and everything looks OK.  I
haven't had the chance to do much more, and I'm not sure where to
start....  I started a git-bisect attempt, but there are several
unrelated problems, and I'm not sure this one is 100% reproduceable.

--b.
