From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH] [nfsd] Add lock annotations to e_start and e_stop
Date: Wed, 26 Jul 2006 09:06:56 +0100
Message-ID: <20060726080656.GA28346@infradead.org>
References: <1153840824.12517.9.camel@josh-work.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932512AbWGZIHB@vger.kernel.org>
To: Josh Triplett <josht@us.ibm.com>
In-Reply-To: <1153840824.12517.9.camel@josh-work.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Jul 25, 2006 at 08:20:24AM -0700, Josh Triplett wrote:
> e_start acquires svc_export_cache.hash_lock, and e_stop releases it.  Add lock
> annotations to these two functions so that sparse can check callers for lock
> pairing, and so that sparse will not complain about these functions since they
> intentionally use locks in this manner.
> 
> Signed-off-by: Josh Triplett <josh@freedesktop.org>

The Signed-off-by: line doesn't match the from line of this mail.  Is that
any problem or fine in general?
