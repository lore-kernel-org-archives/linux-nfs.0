Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44415 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753881Ab3KMQuH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 11:50:07 -0500
Date: Wed, 13 Nov 2013 11:49:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
Message-ID: <20131113164959.GL28033@fieldses.org>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
 <20131112194529.GA26341@fieldses.org>
 <52828767.3030909@netapp.com>
 <20131112195911.GA28033@fieldses.org>
 <5283A24D.4010309@netapp.com>
 <5283A3B7.8080405@netapp.com>
 <20131113161527.GA10046@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131113161527.GA10046@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 13, 2013 at 08:15:27AM -0800, Christoph Hellwig wrote:
> On Wed, Nov 13, 2013 at 11:07:19AM -0500, Anna Schumaker wrote:
> > I'm thinking something like this:
> 
> Given that the whole sparse file support seems more experimental than
> the security labels requiring the former for the latter seems a bit odd.
> 
> I have to admit that I don't really know how to deal with those changes,
> on the one hand I'd love to expose it as soon as possible, on the other
> hand the spec has so many higher level flaws related to their concepts
> of sparse files that I'd feel really bad about locking even parts of it
> in at the moment.

This isn't a candidate for 3.13, and SEEK didn't look like the most
problematic bit, so with a couple more months I'm hoping we'll be more
confident about the protocol?

Actually now that I look, I forget: even if security labels are built
in, 4.2 is still off by default at runtime for now.

We could add another interface to toggle individual features at run time
but I think that's definitely too complicated.

Maybe:

	- keep 4.2 off by default a runtime for now.
	- keep each feature under its individual config option:
	  NFSD_V4_SECURITY_LABEL, NFSD_V4_SEEK, NFSD_V4_SEND_PONIES....
	- when an individual feature matures, ditch its config option
	  and build it unconditionally.  We're always getting little
	  build bugs due to untested build options so I'd rather not
	  keep them around indefinitely.
	- once 4.2 has at least one feature that we think is mature
	  enough, switch the runtime 4.2 default to on and depend on
	  scary warnings on the remaining build options to keep people
	  from exposing them in production.

?

--b.
