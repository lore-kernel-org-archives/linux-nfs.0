Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:32867 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752974AbZE2WQm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 May 2009 18:16:42 -0400
Subject: Re: New file doesn't show up if cached as missing
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20090529220412.GJ1719@hostway.ca>
References: <20090529175243.GA30961@hostway.ca>
	 <1243622206.7155.103.camel@heimdal.trondhjem.org>
	 <20090529220412.GJ1719@hostway.ca>
Content-Type: text/plain
Date: Fri, 29 May 2009 18:16:40 -0400
Message-Id: <1243635400.7155.168.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-05-29 at 15:04 -0700, Simon Kirby wrote:
> On Fri, May 29, 2009 at 02:36:46PM -0400, Trond Myklebust wrote:
> 
> > That is most likely to be a consequence of poor mtime resolution on the
> > server (i.e. the directory mtime failing to change because the file
> > creation occurred within < 1 second of the 'rm'), combined with negative
> > lookup caching.
> 
> As in "ls --full-time" shows 0 for the fractional second part?
> 
> Hrm, I thought newer ext3 had nanosecond mtime, but it seems not...

No. You'll have to migrate to ext4 (or xfs) if you want finer grained
timestamps.

> > Try using the '-olookupcache=positive' or '-olookupcache=none' mount
> > options (requires a relatively recent version of nfs-utils).
> 
> After backporting nfs-utils, either of those options seem to this
> particular case work as desired.  Excellent!
> 
> I guess all of the attribute-caching-related options are unrelated to
> this case.  Is this consistent with older operation and that of other
> OSes?  It might be a little surprising for some (me) when "noac" still
> ends up doing some caching.

noac is all about attribute caching, whereas this is lookup/dentry
caching. You can compare it to data caching: 'noac' doesn't force the
cache to be flushed on every read() request, but it does force the mtime
to be checked, and so cache consistency is relatively stronger (provided
the mtime is accurate enough).

Cheers
  Trond

