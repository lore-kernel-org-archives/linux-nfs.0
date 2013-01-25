Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:51735 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756802Ab3AYTQf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2013 14:16:35 -0500
Date: Fri, 25 Jan 2013 14:16:20 -0500
From: Jim Rees <rees@umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Ben Myers <bpm@sgi.com>, Olga Kornievskaia <aglo@citi.umich.edu>,
        linux-nfs@vger.kernel.org
Subject: Re: sunrpc: socket buffer size tuneable
Message-ID: <20130125191620.GA12925@umich.edu>
References: <20130125005930.GC30652@sgi.com>
 <20130125185748.GC29596@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130125185748.GC29596@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:

  On Thu, Jan 24, 2013 at 06:59:30PM -0600, Ben Myers wrote:
  > At 1020 threads the send buffer size wraps and becomes negative causing
  > the nfs server to grind to a halt.  Rather than setting bufsize based
  > upon the number of nfsd threads, make the buffer sizes tuneable via
  > module parameters.
  > 
  > Set the buffer sizes in terms of the number of rpcs you want to fit into
  > the buffer.
  
  From private communication, my understanding is that the original
  problem here was due to memory pressure forcing the tcp send buffer size
  below the size required to hold a single rpc.
  
  In which case the important variable here is lock_bufsize, as that's
  what prevents the buffer size from going too low.
  
  Cc'ing Jim Rees in case he remembers: I seem to recall discussing this
  possibility, wondering whether we needed a special interface to the
  network layer allowing us to set a minimum, and deciding it wasn't
  really necessary at the time as we didn't think the network layer would
  actually do this.  Is that right?  In which case either we were wrong,
  or something changed.

I do remember discussing this. My memory is that we needed it but no one
wanted to implement it and it never happened. But I could be
mis-remembering. Maybe ask Olga, she's the one who put the bufsize
autotuning patch in, commit 96604398.

I'll go back through my old mail and see if I can figure out what happened
with this.
