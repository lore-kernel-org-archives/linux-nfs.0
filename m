Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58691 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754857AbZICSPh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2009 14:15:37 -0400
Date: Thu, 3 Sep 2009 14:15:35 -0400
To: Peter Staubach <staubach@redhat.com>
Cc: Jason Legate <linux-nfs@proxime.net>, linux-nfs@vger.kernel.org
Subject: Re: NFS for millions of files
Message-ID: <20090903181535.GA10670@fieldses.org>
References: <20090902180841.GF946@proxime.net> <4A9EBB6B.4040009@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4A9EBB6B.4040009@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 02, 2009 at 02:37:31PM -0400, Peter Staubach wrote:
> Please keep in mind that the NFS stable storage requirements are
> probably causing a significant slowdown in activities such as this.

My first thought too, but:

> Jason Legate wrote:
> > When I run our creation benchmark locally  I can get around 3000
> > files/ second in the configuration we're using now, but only around
> > 300/second over NFS.  It's mounted as this:
...
> > When I mount the same FS over localhost instead of across the lan,
> > it performs about full speed (the 3000/sec).

The localhost NFS mount would be incurring the same sync latency, so all
his latency must be due to network.  (And with those numbers I guess
he's either got lots of disk spindles, or an ssd, or (uh-oh) has the
async option set?)

--b.
