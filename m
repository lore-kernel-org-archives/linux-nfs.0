Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51279 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761842Ab3JPSWl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 14:22:41 -0400
Date: Wed, 16 Oct 2013 11:22:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@redhat.com,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: state lock elimination
Message-ID: <20131016182238.GA2944@infradead.org>
References: <20131015211445.GA23636@infradead.org>
 <525DB943.3010707@primarydata.com>
 <20131016064243.GA28758@infradead.org>
 <525E4C88.9050701@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <525E4C88.9050701@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 16, 2013 at 11:21:28AM +0300, Benny Halevy wrote:
> I tried reducing the lock scope but the problem is that we hash state
> on objects with different scopes of access, particularly net/client vs. file
> and the hashing needs to be consistent and atomic.

Lists, Hashes or similar lookup data structures are generally not the
hard part, as it's enough to lock the data structure that the hash or
list hangs off.  No need to involve looks in the structure pointed to.

