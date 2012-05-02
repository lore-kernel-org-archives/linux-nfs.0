Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48803 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079Ab2EBWI3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 May 2012 18:08:29 -0400
Date: Wed, 2 May 2012 18:08:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kevin Coffman <kwc@umich.edu>
Cc: NFS list <linux-nfs@vger.kernel.org>, Steve Dickson <SteveD@redhat.com>,
        aglo@citi.umich.edu
Subject: Re: RFC: Handling GSS rotated data
Message-ID: <20120502220828.GC12089@fieldses.org>
References: <CAKnQG+dVhQ3JSXJnQihzs0FnS_aeyUKftDX7j7X6iJTjRGMzPQ@mail.gmail.com>
 <20120410215633.GL18465@fieldses.org>
 <20120410230202.GM18465@fieldses.org>
 <CAKnQG+fBw8--kfGmEvh4Fq0tzfAKq0gwi6kQHsKMQ38YmJNQ_A@mail.gmail.com>
 <20120412001224.GB2523@fieldses.org>
 <20120412001922.GC2523@fieldses.org>
 <20120501235210.GA2083@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120501235210.GA2083@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 01, 2012 at 07:52:10PM -0400, J. Bruce Fields wrote:
> On Wed, Apr 11, 2012 at 08:19:22PM -0400, J. Bruce Fields wrote:
> > On Wed, Apr 11, 2012 at 08:12:24PM -0400, J. Bruce Fields wrote:
> > > On Tue, Apr 10, 2012 at 08:56:56PM -0400, Kevin Coffman wrote:
> > > > The rotation values we've seen from Microsoft clients/servers for AES
> > > > have been 28.  Your code definitely looks simpler!
> > > 
> > > So, here's something that actually compiles.  I'll need someone else to
> > > test, though, and I won't be at all surprised if it needs some
> > > fixing....
> 
> By the way, handing it off to Olga for testing this afternoon I gave it
> some more review and found some bugs; this is the version she's testing.

Looks like this is passing tests, so I'm commiting for 3.5.  Thanks to
Olga for testing and to Kevin for the first implementation.

--b.
