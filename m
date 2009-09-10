Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46673 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231AbZIJIoK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2009 04:44:10 -0400
From: "NeilBrown" <neilb@suse.de>
To: "Chuck Lever" <chuck.lever@oracle.com>
Date: Thu, 10 Sep 2009 18:44:00 +1000 (EST)
Message-ID: <9eae93545189a6be6eebe0460b860fc7.squirrel@neil.brown.name>
In-Reply-To: <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net>
    <20090805144540.12866.22084.stgit@matisse.1015granger.net>
    <20090805174811.GB9944@fieldses.org>
    <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com>
    <20090805181545.GF9944@fieldses.org>
    <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com>
    <1249507356.5428.11.camel@heimdal.trondhjem.org>
    <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com>
    <1249515004.5428.34.camel@heimdal.trondhjem.org>
    <20090909142945.755da393@tlielax.poochiereds.net>
    <1252521599.8722.53.camel@heimdal.trondhjem.org>
    <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com>
    <1252525327.8722.81.camel@heimdal.trondhjem.org>
    <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com>
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
     part)
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
        "Jeff Layton" <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, September 10, 2009 8:18 am, Chuck Lever wrote:

> The idea that "the Linux way" is the best and only way is ridiculous
> on its face, anyway.  I mean, what do you expect when we have no
> requirements and specification process, no formal testing, C coding
> style conventions based on 20-year old coding practices, a hit-or-miss
> review process that relies more on reviewers' personal preferences
> than any kind of standards, no static code analysis tools, no defect
> metrics or bug meta-analysis tools, kernel debuggers are verboten, a
> combative mailing list environment, and parts of our knowledge base
> and team history are lost every time a developer leaves (in this case,
> Olaf and Neil)?  It's no wonder we never change anything unless
> absolutely necessary!

And yet is largely works!
I could summarise a lot of your points by observing that the community
values people over process.  I really think that is the right place to
put value, because people are richer and more flexible than process.

I agree that combative mailing lists are a problem, but even there, I
believe most of the aggression is more perceived than real, and that
a graceful, humble, polite attitude can have a positive-feedback effect
too.

Yes, there are lots of practices that might improve things that we don't
have standardised.  But one practice we do have that has proven very
effective is incremental refinement.  It can be hard to understand what
order to make changes until after you have made them, but once you
understand what you want to do, going back and doing it in logical
order really is very effective.  It makes it easier for others to
review, it makes it easy for you to review yourself.  It means
less controversial bits can be included quickly leaving room for the
more controversial bits to be discussed in isolation.

I think that the switch from portmap to rpcbind was a bad idea,
and I think that a wholesale replacement of statd is probably a
bad idea too.  It might seem like the easiest way to get something
useful working, but you'll probably be paying the price for years as
little regression turn up because you didn't completely understand
the original statd (and face it, who does?)

As for the use of sql-lite ... I must admit that I wouldn't choose
it.  Maybe it is a good idea.  If it is, you probably need to merge
that change early with a clear argument and tools to make it manageable
(e.g. a developer will want to tool to be able to look inside the
database easily and make changes, without having to know sql).
It is much easier to discuss one thing at a time on these
combative mailing lists ;-)

NeilBrown

P.S.
And we do have static code analysis tools.  Both 'gcc' and 'sparse'
fit that description.


