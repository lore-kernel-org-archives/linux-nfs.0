Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47224 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390AbbIITDL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2015 15:03:11 -0400
Date: Wed, 9 Sep 2015 15:03:08 -0400
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir and old cookie verifier
Message-ID: <20150909190308.GB25750@fieldses.org>
References: <267164181.6444770.1441717712553.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <267164181.6444770.1441717712553.JavaMail.zimbra@desy.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 08, 2015 at 03:08:32PM +0200, Mkrtchyan, Tigran wrote:
> 
> Dear NFS gurus,
> 
> we run into situation, where client gets BAD_COOKIE on a readdir.
> Before I go and try to adopt our server to handle it, let me describe
> the situation.
> 
> A client node (we have seen it with RHEL6 and Ubuntu 12.04, but probably
> others affected as well) send a bunch of readdirs to the server. After some
> time (this many be hours, days ) client sends an other set of readdirs.

Starting over with cookie zero, or resuming using some cached cookie?

> But
> it reuses cookie verifier from the first readdir sequence. Server sends back
> BAD_COOKIE, but client never starts over with a cookie and verifier being zero.

I don't think it's really required to do that.  7530 suggests that might
indeed result in an error:

	It should be a rare occurrence that a server is unable to
	continue properly reading a directory with the provided
	cookie/cookieverf pair.  The server should make every effort to
	avoid this condition since the application at the client may not
	be able to properly handle this type of failure.

(Also, RFC 7530 16.24.4 says NOT_SAME is the error in this case.  Is
that really correct?  I would have expected BAD_COOKIE too.)

> As a result, inconsistent listing and anhappy user:
> 
> 
> [exflserv04] ~ $ ls /pnfs/desy.de/exfel/disk/LCLS/2015/RAW/XCS/xcsh8215/xtc/
> ls: reading directory /pnfs/desy.de/exfel/disk/LCLS/2015/RAW/XCS/xcsh8215/xtc/: Unknown error 523

That's EBADCOOKIE.

> Is this behavior of the client correct?

I think so.  It's a huge pain for filesystems, but unfortunately readdir
cookies (like filehandles) are forever.

--b.
