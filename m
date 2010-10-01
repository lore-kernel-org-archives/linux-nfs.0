Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39366 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380Ab0JARSa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 13:18:30 -0400
Date: Fri, 1 Oct 2010 13:18:10 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <npiggin@kernel.dk>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: Odd NFS related SIGBUS (& possible fix)
Message-ID: <20101001171810.GC30570@fieldses.org>
References: <1285734825.14081.87.camel@pasglop>
 <1285912667.2463.68.camel@pasglop>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1285912667.2463.68.camel@pasglop>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Oct 01, 2010 at 03:57:47PM +1000, Benjamin Herrenschmidt wrote:
> (Reminder: On 2.6.32.16, where we initially experienced the problem, I
> found out that we get a -lot- of invalidations coming due to server
> mtime being more recent than the local mtime, which is very very odd
> considering that the local machine is the only one to ever modify the
> files)

Possibly also related?:

	https://bugzilla.redhat.com/show_bug.cgi?id=636590

We see what seem to be cache invalidations when all we're doing is
something like

	open
	write
	close
	open
	read

from a single thread on a single client.  This happens over a variety of
protocol and server versions.

--b.
