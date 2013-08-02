Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37724 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753828Ab3HBPrG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 11:47:06 -0400
Date: Fri, 2 Aug 2013 11:47:03 -0400
To: Dawid Stawiarski <neeo@xl.wp.pl>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Performance/stability problems with nfs shares
Message-ID: <20130802154703.GL17581@fieldses.org>
References: <51fb4bf3a9bde1.52024761@wp.pl>
 <20130802091242.23b9c904@corrin.poochiereds.net>
 <51FBC445.4000006@xl.wp.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51FBC445.4000006@xl.wp.pl>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 02, 2013 at 04:37:57PM +0200, Dawid Stawiarski wrote:
> W dniu 02.08.2013 15:12, Jeff Layton pisze:
> >Typically, a stack trace like that indicates that the process is
> >waiting for the server to respond. The first thing I would do would be
> >to ascertain whether the server is actually responding to these
> >requests.
> >
> 
> The same share is accessible on other nodes, so the problem involves
> only one of the nodes (completly random) at a time.

It's still conceivable that a server problem could cause it to stop
responding to calls only from a single client--it'd be useful if
possible to check a trace to see if that's what's happening.  If the
traffic is really huge then capturing and analyzing a good trace may be
difficult.

--b.
