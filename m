Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:12671 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752712AbcCVWuV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2016 18:50:21 -0400
Date: Wed, 23 Mar 2016 09:50:18 +1100
From: Dave Chinner <david@fromorbit.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Richard Yao <ryao@gentoo.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: Making an interface for alternative data streams
Message-ID: <20160322225018.GV11812@dastard>
References: <56F03945.40208@gentoo.org>
 <56F05745.50204@gentoo.org>
 <20160321204041.GA807@fieldses.org>
 <34E9F5BC-E8D4-405E-926E-DF2058E31B5F@gentoo.org>
 <20160322212931.GQ11812@dastard>
 <20160322215232.GK4083@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160322215232.GK4083@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 22, 2016 at 05:52:32PM -0400, J. Bruce Fields wrote:
> On Wed, Mar 23, 2016 at 08:29:31AM +1100, Dave Chinner wrote:
> > If you want additional seekable data streams, then come up with a
> > filesystem namespace method of addressing these alternate data
> > streams as *separate files containing data*. That's all an ADS is -
> > a namespace hack to address multiple data files through a single
> > file name. That's the problem that needs solving and it has nothing
> > to do with xattrs.
> 
> There was some thread about this years ago.  Looking... "silent semantic
> changes with reiser4" or "possible design issues for hybrids" look like
> the relevant threads.
>
> One good starting point might be:
> 
> 	http://mid.gmane.org/20040826212853.GA21964@parcelfarce.linux.theplanet.co.uk
> 
> Don't know how out of date that might be now.

Not sure it is the same issue - that looks like auto-bind-mount
stuff. There are some relevant questions though, like "directory
over file" semantics and implications...

But we have covered this ground before, and at LSF/MM summits, too.
historically it has been made pretty clear that xattrs are not
something that can be used for alternate data streams. I think ADS
is primarily a namespace and API problem - that needs to be sorted
out first, and then what filesytems need to implement will be
obvious.

Perhaps overlayfs is a good place to start prototyping such
functionality as there is an abstraction between the presented
namespace and the underlying storage of the data....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
