From: bpm@sgi.com
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
	part)
Date: Thu, 10 Sep 2009 10:05:18 -0500
Message-ID: <20090910150518.GA7042@sgi.com>
References: <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com> <1249507356.5428.11.camel@heimdal.trondhjem.org> <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com> <1249515004.5428.34.camel@heimdal.trondhjem.org> <20090909142945.755da393@tlielax.poochiereds.net> <1252521599.8722.53.camel@heimdal.trondhjem.org> <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com> <1252525327.8722.81.camel@heimdal.trondhjem.org> <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com> <9eae93545189a6be6eebe0460b860fc7.squirrel@neil.brown.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Jeff Layton <jlayton@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:42080 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751612AbZIJPFQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2009 11:05:16 -0400
In-Reply-To: <9eae93545189a6be6eebe0460b860fc7.squirrel-eq65iwfR9nKIECXXMXunQA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 10, 2009 at 06:44:00PM +1000, NeilBrown wrote:
> I could summarise a lot of your points by observing that the community
> values people over process.  I really think that is the right place to
> put value, because people are richer and more flexible than process.

What a refreshing point of view.  I hope it catches on.

> As for the use of sql-lite ... I must admit that I wouldn't choose
> it. 

A number of other projects support multiple backends.  Maybe that makes
sense here.

-Ben
