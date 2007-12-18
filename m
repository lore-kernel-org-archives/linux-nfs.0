From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/38] svc: Add an svc transport class
Date: Tue, 18 Dec 2007 10:01:43 -0500
Message-ID: <20071218150143.GE14783@fieldses.org>
References: <20071213184506.GA29496@fieldses.org> <C38BA039.233C0%tom@opengridcomputing.com> <20071217174535.GA13515@fieldses.org> <1197937584.13463.44.camel@trinity.ogc.int> <20071218145419.GC14783@fieldses.org> <1197990256.13463.54.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58837 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755662AbXLRPBw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Dec 2007 10:01:52 -0500
In-Reply-To: <1197990256.13463.54.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 18, 2007 at 09:04:16AM -0600, Tom Tucker wrote:
> 
> On Tue, 2007-12-18 at 09:54 -0500, J. Bruce Fields wrote:
> > On Mon, Dec 17, 2007 at 06:26:24PM -0600, Tom Tucker wrote:
> > > I've coded all of the changes that you suggested and built a new
> > > patchset. Besides the tests I outlined in my "test matrix" are there any
> > > other tests you would like to see performed?
> > 
> > krb5p testing might still be interesting.
> > 
> 
> I'll add it to my matrix. It will take some time to set up though since
> I don't have a KDC or anything set up. Are we under any time
> constraints?

For krb5p, I don't think it's terifically urgent.

> > > I could not reproduce the BUG_ON from Bull. I'm wondering if it's a PPC
> > > issue :-\ 
> > 
> > Hm, too bad, I'd like to understand that one.
> > 
> 
> Yeah, and I'm having a hard time believing it's PPC related. I think I'm
> missing something, I'll keep looking.

Thanks!

--b.
