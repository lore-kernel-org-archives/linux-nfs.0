From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: citi, linux-nfs.org downtime
Date: Wed, 24 Jun 2009 17:35:27 -0400
Message-ID: <20090624213527.GC14503@fieldses.org>
References: <20090622162611.GB16719@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 174-143-236-118.static.slicehost.net ([174.143.236.118]:55885
	"EHLO fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755190AbZFXVfY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2009 17:35:24 -0400
In-Reply-To: <20090622162611.GB16719@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 22, 2009 at 12:26:11PM -0400, J. Bruce Fields wrote:
> CITI's offices and machine room are moving to a new building tomorrow
> (tuesday).  This means that citi.umich.edu and linux-nfs.org will be
> going down late tonight or early tomorrow morning, and staying down at
> least until early afternoon (and probably longer).
> 
> (Alert users may already have noticed one or two outages of several
> hours over the last few weeks as we prepared the machine room for the
> move.)
> 
> Apologies in advance for any inconvenience--getting services back up
> will be our first priority, but it's a complicated operation.

Stuff should be mostly working again now.

So, if I have this right:

	Total data moved: ~ 35 terabytes
	Time to get racks back online: ~ 28 hours
	Estimated total bandwidth of the CITI move: 2.8 gigabits/second

If we count only the time to physically move the racks, and not the time
to get them back online, bandwidth is closer to 20 gigabits per second.

--b.
