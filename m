Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:56178 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753733Ab3GOB0a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Jul 2013 21:26:30 -0400
Date: Sun, 14 Jul 2013 21:26:20 -0400
From: Jim Rees <rees@umich.edu>
To: "J.Bruce Fields" <bfields@citi.umich.edu>
Cc: NeilBrown <neilb@suse.de>, Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130715012620.GC7429@umich.edu>
References: <20130710092255.0240a36d@notabene.brown>
 <20130710022735.GI8281@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130710022735.GI8281@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J.Bruce Fields wrote:

  On Wed, Jul 10, 2013 at 09:22:55AM +1000, NeilBrown wrote:
  > 
  > Hi,
  >  I just noticed this commit:
  > 
  > commit 9660439861aa8dbd5e2b8087f33e20760c2c9afc
  > Author: Olga Kornievskaia <aglo@citi.umich.edu>
  > Date:   Tue Oct 21 14:13:47 2008 -0400
  > 
  >     svcrpc: take advantage of tcp autotuning
  > 
  > 
  > which I must confess surprised me.  I wonder if the full implications of
  > removing that functionality were understood.
  > 
  > Previously nfsd would set the transmit buffer space for a connection to
  > ensure there is plenty to hold all replies.  Now it doesn't.
  > 
  > nfsd refuses to accept a request if there isn't enough space in the transmit
  > buffer to send a reply.  This is important to ensure that each reply gets
  > sent atomically without blocking and there is no risk of replies getting
  > interleaved.
  > 
  > The server starts out with a large estimate of the reply space (1M) and for
  > NFSv3 and v2 it quickly adjusts this down to something realistic.  For NFSv4
  > it is much harder to estimate the space needed so it just assumes every
  > reply will require 1M of space.
  > 
  > This means that with NFSv4, as soon as you have enough concurrent requests
  > such that 1M each reserves all of whatever window size was auto-tuned, new
  > requests on that connection will be ignored.
  >
  > This could significantly limit the amount of parallelism that can be achieved
  > for a single TCP connection (and given that the Linux client strongly prefers
  > a single connection now, this could become more of an issue).
  
  Worse, I believe it can deadlock completely if the transmit buffer
  shrinks too far, and people really have run into this:

It's been a few years since I looked at this, but are you sure autotuning
reduces the buffer space available on the sending socket? That doesn't sound
like correct behavior to me. I know we thought about this at the time.

It does seem like a bug that we don't multiply the needed send buffer space
by the number of threads. I think that's because we don't know how many
threads there are going to be in svc_setup_socket()?
