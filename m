Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:38425 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756906Ab0KJQ1I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 11:27:08 -0500
Date: Wed, 10 Nov 2010 11:27:06 -0500
From: Jim Rees <rees@umich.edu>
To: Harshula Jayasuriya <harshula@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH] nfs-utils: nfsstat: has_stats() does not function
 correctly for NFSv4 client stats
Message-ID: <20101110162703.GA948@merit.edu>
References: <1289328603.9490.18.camel@serendib>
 <33A5EC88-8770-4E5D-809A-28926ED3C5EC@oracle.com>
 <1289363200.9490.24.camel@serendib>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1289363200.9490.24.camel@serendib>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Harshula Jayasuriya wrote:

  On Tue, 2010-11-09 at 14:29 -0500, Chuck Lever wrote:
  > Hi-
  > 
  > Why not use mountstats?  The /proc/net/rpc/nfs is destined for deprecation, I thought.

  Are you referring to /proc/self/mountstats? I didn't know about it.
  nfsstat's get_stats() would have to be re-written. I can add that to my
  TODO list, but not sure when I'll get to it. In the meantime, this patch
  will fix the previously mentioned bugs and make the existing code a
  little clearer.

We should either fix it or remove it.  Leaving it in and broken seems wrong
even if the interface is depracated, especially since we have a fix.
