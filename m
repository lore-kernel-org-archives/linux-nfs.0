From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/6] 2nd IPv6 patchset for 2.6.28 (repost)
Date: Fri, 29 Aug 2008 13:25:06 -0400
Message-ID: <20080829172506.GB7099@fieldses.org>
References: <20080827204852.17837.38361.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35932 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920AbYH2RZL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Aug 2008 13:25:11 -0400
In-Reply-To: <20080827204852.17837.38361.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 27, 2008 at 04:56:58PM -0400, Chuck Lever wrote:
> Based on review comments, I've changed how the NFSv4 callback server
> starts its listener.  If the kernel has IPv6 support, it will start an
> AF_INET6 listener; otherwise it will start an AF_INET listener.
> 
> Subsequent lockd IPv6 patches already work this way, it turns out, so
> I've updated the patch in this subseries that adds a helper to display
> NLM IPv6 addresses.  If an IPv6 address is a mapped IPv4 address, it
> will be displayed as a dotted-quad instead of as an IPv6 address.  This
> should cause the helper to display IPv4-style addresses on systems that
> use only IPv4, even though the listener is AF_INET6.  This effects
> only error and debugging messages.
> 
> I should revisit other areas (already integrated, and in pending
> patches) which display presentation format addresses, to ensure they
> follow suit.

I already applied 2-6, so I've removed those and replaced them by your
new versions.  The resulting change is just the following.

I'm assuming #1 will be up to Trond.

I think I've got nothing else outstanding from you right now?

--b.
