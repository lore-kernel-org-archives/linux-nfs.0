Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56258 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754373AbaADQK2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Jan 2014 11:10:28 -0500
Date: Sat, 4 Jan 2014 11:10:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org, neilb@suse.de
Subject: Re: [RFC PATCH 1/5] sunrpc: don't wait for write before allowing
 reads from use-gss-proxy file
Message-ID: <20140104161022.GG5164@fieldses.org>
References: <1388579314-15255-2-git-send-email-jlayton@redhat.com>
 <20140102212149.GC28219@fieldses.org>
 <20140102172651.559eaa48@tlielax.poochiereds.net>
 <20140102224009.GF28219@fieldses.org>
 <20140102182746.547964c0@tlielax.poochiereds.net>
 <1388736843.26102.33.camel@willson.li.ssimo.org>
 <20140103162319.GK28219@fieldses.org>
 <1388786760.26102.65.camel@willson.li.ssimo.org>
 <20140103223451.GE5164@fieldses.org>
 <1388849302.26102.66.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1388849302.26102.66.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 04, 2014 at 10:28:22AM -0500, Simo Sorce wrote:
> On Fri, 2014-01-03 at 17:34 -0500, J. Bruce Fields wrote:
> > On Fri, Jan 03, 2014 at 05:06:00PM -0500, Simo Sorce wrote:
> > > I'd like to use sd_notify, but preferred a more conservative approach
> > > for wider distribution portability.
> > > 
> > > Patch here waiting for review upstream:
> > > http://fedorapeople.org/cgit/simo/public_git/gss-proxy.git/commit/?h=usermode&id=ddc5eb950bbd2050dc76b4783f3d3383cd89bccf
> > 
> > Thanks.  If it's not too much verbage, it might be helpful to document
> > the reason for the ordering; something like:
> > 
> > 	/*
> > 	 * We need to tell nfsd gss-proxy is available before it starts,
> > 	 * as nfsd may need to know this the moment it receives the
> > 	 * first init_sec_context call.
> > 	 *
> > 	 * So now it is safe to tell the init system that we're done
> > 	 * starting up and that it can continue with nfsd startup.
> > 	 */
> > 
> > ?
> 
> Good idea, I changed the comments loosely after your example:
> http://fedorapeople.org/cgit/simo/public_git/gss-proxy.git/commit/?h=usermode&id=393570b45816b690cb16fd1286d0705142ef2d62

I like how you've done it.  Thanks!

--b.
