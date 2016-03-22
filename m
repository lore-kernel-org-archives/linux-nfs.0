Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35938 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332AbcCVVwe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2016 17:52:34 -0400
Date: Tue, 22 Mar 2016 17:52:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Richard Yao <ryao@gentoo.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: Making an interface for alternative data streams
Message-ID: <20160322215232.GK4083@fieldses.org>
References: <56F03945.40208@gentoo.org>
 <56F05745.50204@gentoo.org>
 <20160321204041.GA807@fieldses.org>
 <34E9F5BC-E8D4-405E-926E-DF2058E31B5F@gentoo.org>
 <20160322212931.GQ11812@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160322212931.GQ11812@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 23, 2016 at 08:29:31AM +1100, Dave Chinner wrote:
> If you want additional seekable data streams, then come up with a
> filesystem namespace method of addressing these alternate data
> streams as *separate files containing data*. That's all an ADS is -
> a namespace hack to address multiple data files through a single
> file name. That's the problem that needs solving and it has nothing
> to do with xattrs.

There was some thread about this years ago.  Looking... "silent semantic
changes with reiser4" or "possible design issues for hybrids" look like
the relevant threads.

One good starting point might be:

	http://mid.gmane.org/20040826212853.GA21964@parcelfarce.linux.theplanet.co.uk

Don't know how out of date that might be now.

--b.
