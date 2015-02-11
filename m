Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:42531 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753094AbbBKS12 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Feb 2015 13:27:28 -0500
Date: Wed, 11 Feb 2015 13:27:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: default NFSv4.2 to on
Message-ID: <20150211182727.GJ25696@fieldses.org>
References: <20150202161557.GF22301@fieldses.org>
 <20150211123757.GA10532@infradead.org>
 <20150211141257.GA25696@fieldses.org>
 <20150211141619.GA24299@infradead.org>
 <20150211145413.GC25696@fieldses.org>
 <20150211181231.GA80012@kitty.kitty>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150211181231.GA80012@kitty.kitty>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 10:12:31AM -0800, Tom Haynes wrote:
> On Wed, Feb 11, 2015 at 09:54:13AM -0500, J. Bruce Fields wrote:
> > 
> > I agree there's a documentation and marketing problem: it would simplify
> > communication with users if "this server supports 4.2" reliably meant
> > support for some minimum list of features.
> > 
> 
> The "marketing" message over NFSv4.2 has been pretty consistent - everything
> is optional and a fully compliant server can return not supported for
> every new feature. I.e., a NFSv4.2 server is pretty simple if you have
> an existing NFSv4.1 server.

Yes, and I like that, but it's not without tradeoffs.

--b.
