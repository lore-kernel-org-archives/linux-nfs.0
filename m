Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48222 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844Ab3JCNDu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 09:03:50 -0400
Date: Thu, 3 Oct 2013 06:03:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@primarydata.com>
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
Message-ID: <20131003130348.GA9634@infradead.org>
References: <1588761701.18.1380804942396.JavaMail.root@thunderbeast.private.linuxbox.com>
 <592699116.20.1380805088543.JavaMail.root@thunderbeast.private.linuxbox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <592699116.20.1380805088543.JavaMail.root@thunderbeast.private.linuxbox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 03, 2013 at 08:58:08AM -0400, Matt W. Benjamin wrote:
> Hi,
> 
> I think saying exofs is a proof of concept/toy is missing the point.
> Exofs is an implementation baseline that provides insight into the
> scalability/performance values that a pnfs implementation can achieve,
> and potentially how to achieve them.

Speaking like a true diplomat..

What amount of that data are we going to get by merging an exofs based
pnfs server that we haven't been able to gather with it out of tree for
the last 6 years?  How is merging it and complicating the nfs servers
for it going to provide a benefit outside of the small group of about a
dozend people that actively care about the T10 OSD support in Linux?

