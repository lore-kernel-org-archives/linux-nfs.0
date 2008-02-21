From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Wrap buffers used for rpc debug printks into
	RPC_IFDEBUG
Date: Thu, 21 Feb 2008 16:58:24 -0500
Message-ID: <20080221215824.GH13358@fieldses.org>
References: <47BD2EF9.4010309@openvz.org> <1203630322.8258.35.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36602 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933220AbYBUV61 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 16:58:27 -0500
In-Reply-To: <1203630322.8258.35.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 21, 2008 at 04:45:22PM -0500, Trond Myklebust wrote:
> 
> On Thu, 2008-02-21 at 10:57 +0300, Pavel Emelyanov wrote:
> > Sorry for the noise, but here's the v3 of this compilation fix :)
> > 
> > There are some places, which declare the char buf[...] on the stack
> > to push it later into dprintk(). Since the dprintk sometimes (if the 
> > CONFIG_SYSCTL=n) becomes an empty do { } while (0) stub, these buffers
> > cause gcc to produce appropriate warnings.
> > 
> > Wrap these buffers with RPC_IFDEBUG macro, as Trond proposed, to 
> > compile them out when not needed.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Thanks Pavel!

Yes, thanks Pavel for persisting--it looks very straightforward to me
this way.

> 
> Bruce, do you want to shepherd this in, or should I? I'm planning on
> pushing a couple of bugfixes to Linus this evening anyway...

That would be great; feel free to add an

	Acked-by: J. Bruce Fields <bfields@citi.umich.edu>

if you want.

--b.
