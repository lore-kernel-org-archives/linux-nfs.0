Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:62817 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751383AbcCVV3e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2016 17:29:34 -0400
Date: Wed, 23 Mar 2016 08:29:31 +1100
From: Dave Chinner <david@fromorbit.com>
To: Richard Yao <ryao@gentoo.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: Making an interface for alternative data streams
Message-ID: <20160322212931.GQ11812@dastard>
References: <56F03945.40208@gentoo.org>
 <56F05745.50204@gentoo.org>
 <20160321204041.GA807@fieldses.org>
 <34E9F5BC-E8D4-405E-926E-DF2058E31B5F@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <34E9F5BC-E8D4-405E-926E-DF2058E31B5F@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 21, 2016 at 10:01:35PM -0400, Richard Yao wrote:
> 
> > On Mar 21, 2016, at 4:40 PM, J. Bruce Fields
> > <bfields@fieldses.org> wrote:
> > 
> >> On Mon, Mar 21, 2016 at 04:19:17PM -0400, Richard Yao wrote:
> >> Maybe I should clarify that the idea is to allow
> >> read/write/list of extended attributes via read/write/readdir
> >> so that those that want extended attributes that are
> >> alternative data streams can have them. I do not want to see
> >> extended attributes and alternative data streams be different
> >> things.
> > 
> > I think there are differences between the two that make this
> > awkward.  Does anyone actually use alternative data stream for
> > anything that makes the effort worthwhile?
> 
> For particularly large extended attributes, avoiding having to
> read the entire value into userspace, modify it and write it back
> is nice. I believe that XFS goes up to 64KB.

Sorry, but XFS xattrs are cannot be partially overwritten due to the
write atomicity requirement of xattrs (i.e. either the entire change
or none of the change is present after a crash). not to mention that
we'd have to completely re-implement extended attributes in XFS to
support them being used as ADS. That's simply not going to happen.

Extended attributes are *not data streams*. Stop trying to make them
data streams - the APIs and the implementations in the fileystems
are simply not designed to be used as seekable data streams.

If you want additional seekable data streams, then come up with a
filesystem namespace method of addressing these alternate data
streams as *separate files containing data*. That's all an ADS is -
a namespace hack to address multiple data files through a single
file name. That's the problem that needs solving and it has nothing
to do with xattrs.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
