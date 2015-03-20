Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:57379 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbbCTGt3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2015 02:49:29 -0400
Date: Fri, 20 Mar 2015 07:49:25 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>,
        Eric Sandeen <sandeen@sandeen.net>, linux-nfs@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150320064925.GB626@lst.de>
References: <20150304225623.GZ4251@dastard> <20150305040849.GJ1627@fieldses.org> <20150305131731.GA16235@lst.de> <20150305150138.GA15674@fieldses.org> <20150305170217.GC15674@fieldses.org> <20150305204749.GA17934@fieldses.org> <20150305205922.GF18360@dastard> <20150306204715.GA27257@fieldses.org> <20150319172731.GA16329@lst.de> <20150319184714.GB20852@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150319184714.GB20852@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 19, 2015 at 02:47:14PM -0400, J. Bruce Fields wrote:
> Also, there's the problem that when this is turned on a client can end
> up doing unnecessary LAYOUTGET.  Do we have a plan for that?
> 
> Possibilities:
> 
> 	- Just depend on export flags: but some clients may have direct
> 	  access and some not.  If the clients with direct access or all
> 	  easily identifiable by IP subnet, maybe it's not a big deal.
> 	  Still, seems like an administrative hassle.

We defintively want this to avoid getting into problems.

> 
> 	- Do nothing, assume the client can deal with this with some
> 	  kind of heuristics, and/or that the GETLAYOUT calls can be
> 	  made very cheap.  Not sure if that's true.

The calls itself are cheap, the cliet processing of them isn't.  I think we
should just stop issueing GETLAYOUT calls on the client side if we keep
errors again and again.  One option might be to add negative device id
cache entries, similar to how negative dentries work in the dcache.

> 	- Use something like GETDEVLICELIST so the client can figure out
> 	  in one go whether any layouts on a given filesystem will work.
> 	  I forget what the problems with GETDEVICELIST were.

The way the device IDs rules are written in NFS it is inherently racy.

If I could go back 10 years in time I'd rewrite device ids to be stateids
bound to a fsid, and a lot of things could be fixed up neatly that way..
