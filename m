Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34605 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756697Ab1CXRvK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2011 13:51:10 -0400
Date: Thu, 24 Mar 2011 13:51:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Adam Lackorzynski <adam@os.inf.tu-dresden.de>, linux-nfs@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: 2.6.38: Quota over NFS4
Message-ID: <20110324175106.GB1886@fieldses.org>
References: <20110320213111.GO11929@os.inf.tu-dresden.de>
 <20110320214316.GB26036@fieldses.org>
 <20110321184043.GC4992@os.inf.tu-dresden.de>
 <20110321222301.GB472@fieldses.org>
 <20110322221305.GA5857@os.inf.tu-dresden.de>
 <20110323150328.GD23418@fieldses.org>
 <20110323174052.GE5005@os.inf.tu-dresden.de>
 <20110323190632.GA26306@fieldses.org>
 <20110323223017.GA5177@os.inf.tu-dresden.de>
 <20110324171704.GA1784@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110324171704.GA1784@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 24, 2011 at 01:17:05PM -0400, Christoph Hellwig wrote:
> On Wed, Mar 23, 2011 at 11:30:17PM +0100, Adam Lackorzynski wrote:
> > I probably mistyped something and thus bisected again:
> 
> maybe this is just a symptom.  When was the nfs4 code converted
> to just use a single open struct file, and what are the lifetime
> rules for it?  It would easily be that a long alive file might
> make XFS keep persistent preallocations longer or similar issues.

Definitely, the commit he's bisect to there seems much more likely to be
a culprit.  I'll take a closer look....

> Adam, can you create a loop filesystem with ext3 or something else
> on it and see if the problem is XFS-specific?

Originally it sounded like he was able to reproduce this only on one
specific filesystem so I wondered whether there was something particular
to that filesystem.

--b.
