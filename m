Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48587 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626Ab3JCOV2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 10:21:28 -0400
Date: Thu, 3 Oct 2013 07:21:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Ric Wheeler <rwheeler@redhat.com>, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Steven Whitehouse <swhiteho@redhat.com>,
        Bob Peterson <rpeterso@redhat.com>, Abhijith Das <adas@redhat.com>,
        Andrew Price <anprice@redhat.com>, Paul Evans <pevans@redhat.com>
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
Message-ID: <20131003142127.GA16716@infradead.org>
References: <20131001203047.GH16245@pad.fieldses.org>
 <524C0556.9070705@primarydata.com>
 <20131002160759.GB27988@infradead.org>
 <524D0873.40602@primarydata.com>
 <20131003095511.GA30147@infradead.org>
 <524D6312.7020709@primarydata.com>
 <524D6D38.1040506@redhat.com>
 <20131003131750.GA23408@infradead.org>
 <524D6EB9.3040309@redhat.com>
 <524D7CF3.6020306@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <524D7CF3.6020306@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 03, 2013 at 05:19:31PM +0300, Benny Halevy wrote:
> The question is what is the minimum value for submitting upstream...
> 
> The thing pnfs over dlm/gfs2 is missing mostly is supporting read/write layout.
> One could use them load balancing, e.g. by either redirecting to a node
> holding an exclusive lock on the file, if there is one, or dlm_ino_hash in its absence.

One could do a lot of things, especially given infinite time.  But what
does the current code buy us?  We need data on that to justify merging
such a large chunk of code.

