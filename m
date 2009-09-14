From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH v2 05/12] nfsd41: Backchannel: callback infrastructure
Date: Mon, 14 Sep 2009 17:16:22 -0400
Message-ID: <1252962982.6866.104.camel@heimdal.trondhjem.org>
References: <4AA8C597.8080809@panasas.com>
	 <1252574759-30176-1-git-send-email-bhalevy@panasas.com>
	 <20090914163535.GE30806@fieldses.org> <20090914164951.GA32757@fieldses.org>
	 <4AAE7C19.7070600@panasas.com> <20090914200423.GE1658@fieldses.org>
	 <1252959452.6866.92.camel@heimdal.trondhjem.org>
	 <20090914203910.GF1658@fieldses.org>
	 <1252961253.6866.98.camel@heimdal.trondhjem.org>
	 <20090914205648.GG1658@fieldses.org>
	 <1252962546.6866.102.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:54917 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756942AbZINVQY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 17:16:24 -0400
In-Reply-To: <1252962546.6866.102.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-09-14 at 17:09 -0400, Trond Myklebust wrote:

> I suppose we could. Alternatively, why not just call it once and for all
> when you start the NFSv4 server? The one cred will work on all
> rpc_clients.

(This is correct...)

> You just have to remember to bump the reference count
> before using it in an RPC call...

Oops! Sorry, this is incorrect. The RPC engine will take care of bumping
the ref count for you if necessary...

Cheers
  Trond

