Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38149 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864Ab2JEOet (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Oct 2012 10:34:49 -0400
Date: Fri, 5 Oct 2012 10:34:47 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/3] nfsd: add a usermodehelper upcall for client id
 tracking
Message-ID: <20121005143447.GA15134@fieldses.org>
References: <1349268031-16498-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1349268031-16498-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 03, 2012 at 08:40:28AM -0400, Jeff Layton wrote:
> This is a respin of the set with the same title that I sent on Monday
> (Oct 1st). This one has a few bugfixes, and adds some code to allow the
> upcall program to convert from the legacy database to the new one. I'll
> also be posting a respin of the companion nfs-utils set too.
> 
> The idea here is to allow a one-way conversion from the legacy clientid
> tracking code to the new one, which should allow for seamless kernel and
> nfs-utils upgrades.
> 
> In order to handle that, this set also changes the heuristic that the
> kernel uses to decide what client tracker to use. We now must now try
> the usermodehelper upcall first and only fall back to other schemes if
> its initialization fails.
> 
> Note that I'm not 100% sold on the idea to convert from the legacy db
> format. It's doable but somewhat "fiddly" to handle. There are probably
> corner cases where it will fall down, so it may be best not to even try
> to do that. I won't be offended if you decide not to take the last
> patch.
> 
> Comments? Discuss!

So that's take 3 at reboot recovery.  Take 1 is what people actually use
(despite it being ugly), take 2 nobody's using yet--so it could probably
be ripped out fairly quickly.

I don't see anything objectionable on a quick skim.

I'd rather wait a little longer and consider it for the next merge
window.

--b.
