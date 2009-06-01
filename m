From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH v2] flow control for WRITE requests
Date: Mon, 01 Jun 2009 17:48:06 -0400
Message-ID: <1243892886.4868.74.camel@heimdal.trondhjem.org>
References: <49C93526.70303@redhat.com>
	 <20090324211917.GJ19389@fieldses.org>  <4A1D9210.8070102@redhat.com>
	 <1243457149.8522.68.camel@heimdal.trondhjem.org>
	 <4A1EB09A.8030809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:48328 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753299AbZFAVsL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jun 2009 17:48:11 -0400
In-Reply-To: <4A1EB09A.8030809@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-05-28 at 11:41 -0400, Peter Staubach wrote:
> -----
> 
> I am trying to do accomplish two things here.  The first thing
> was to smooth the WRITE traffic so that the client would perform
> better.  Caching a few gigabytes of data and then flushing it to
> the server using a firehose doesn't seem to work very well.  In
> a customer situation, I really had a server which could not keep
> up with the client.  Something was needed to better match the
> client and server bandwidths.
> 
> Second, I noticed that the architecture to smooth the WRITE
> traffic and do the flow control could be used very nicely to
> solve the stat() problem too.  The smoothing of the WRITE
> traffic results in fewer dirty cached pages which need to get
> flushed to the server during the stat() processing.  This helps
> to reduce the latency of the stat() call.  Next, the flow control
> aspect can be used to block the application which is writing to
> the file while the application.  It happens without adding any
> more code to the writing path.
> 
> I have spent quite a bit of time trying to measure the performance
> impact.  As far as I can see, it varies from significantly better
> to no affect.  Some things like dd run much better in my test
> network.  Other things like rpmbuild don't appear to be affected.
> Compilations tend to be random access to files and are generally
> more cpu limited than i/o bound.

So, how about doing this by modifying balance_dirty_pages() instead?
Limiting pages on a per-inode basis isn't going to solve the common
problem of 'ls -l' performance, where you have to stat a whole bunch of
files, all of which may be dirty. To deal with that case, you really
need an absolute limit on the number of dirty pages.

Currently, we have only relative limits: a given bdi is allowed a
maximum percentage value of the total write back cache size... We could
add a 'max_pages' field, that specifies an absolute limit at which the
vfs should start writeback.

Cheers
  Trond

