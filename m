From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: nfsd 2.6.28 merge plans
Date: Tue, 14 Oct 2008 12:07:53 -0700
Message-ID: <20081014120753.7f968845.akpm@linux-foundation.org>
References: <20081008232237.GH14527@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Howells <dhowells@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33481 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750812AbYJNTIS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Oct 2008 15:08:18 -0400
In-Reply-To: <20081008232237.GH14527@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Wed, 8 Oct 2008 19:22:37 -0400 "J. Bruce Fields" <bfields@fieldses.org> wrote:
> Linus's release announcement for -rc9 suggested 2.6.27 could be released
> (and the 2.6.28 merge window opened) any day now.
> 
> What I'm currently planning to merge is the contents of
> 
> 	git://linux-nfs.org/~bfields/linux.git for-2.6.28
> 
> summarized below.
> 
> Chuck's contributed a ton of small patches preparing for ipv6 support
> (which we expect to complete in 2.6.29), Tom Tucker has added support
> for fast memory registration to the server rdma code, and Benny's
> NFSv4.1 work continues to produce miscellaneous NFSv4.1 bugfixes and
> cleanups.
> 
> There's also one pure locking patch, which makes vfs support for posix
> locking configurable.
> 
> And I've got some grace period patches (which I hope will also pave the
> way for nfsd lock migration support in 2.6.29), and some minor tweaks to
> our rpcsec_gss code which (together with recent nfs-utils patches)
> finally makes rpcsec_gss for v2 and v3 work as well as it does for v4.

Thanks.

Is anything happening with David Howells's fscache and cachefiles work over
there?

