From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/6] SLAB-ify nlm_host cache
Date: Mon, 24 Nov 2008 13:38:36 -0500
Message-ID: <20081124183836.GM17862@fieldses.org>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net> <1225922196.16857.60.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46508 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750837AbYKXSil (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Nov 2008 13:38:41 -0500
In-Reply-To: <1225922196.16857.60.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 05, 2008 at 04:56:36PM -0500, Trond Myklebust wrote:
> On Wed, 2008-11-05 at 16:51 -0500, Chuck Lever wrote:
> > Here's a set of patches to change the NLM host cache to use a slab.
> 
> OK, I'll bite. Why would we care about slabifying the NLM host cache?

There's some argument on the 5th patch:

	"Now that we have a couple of large text buffers in the nlm_host
	struct, the nlm_host cache should use a slab to reduce memory
	utilization and fragmentation on systems that manage a large
	number of NLM peers.

	"We keep these hardware cache-aligned to speed up the linked
	list search in nlm_lookup_host().

	"The overhead of creating a fresh nlm_host entry is also reduced
	using SLAB's init_once callback instead of using kzalloc()."

Chuck, is there any hope of quantifying those improvements?

--b.
