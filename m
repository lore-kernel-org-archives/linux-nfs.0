Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51825 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064Ab2EKNxI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 May 2012 09:53:08 -0400
Date: Fri, 11 May 2012 09:53:07 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC] NFSd laundromat containerization
Message-ID: <20120511135306.GA12795@fieldses.org>
References: <4FAD1934.8070908@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FAD1934.8070908@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 11, 2012 at 05:50:44PM +0400, Stanislav Kinsbursky wrote:
> Hello.
> I'm currently looking on NFSd laundromat work, and it looks like
> have to be performed per networks namespace context.
> It's easy to make corresponding delayed work per network namespace
> and thus gain per-net data pointer in laundromat function.
> But here a problem appears: network namespace is required to skip
> clients from other network namespaces while iterating over global
> lists (client_lru and friends).
> I see two possible solutions:
> 1) Make these list per network namespace context. In this case
> network namespace will not be required - per-net data will be
> enough.
> 2) Put network namespace link on per-net data (this one is easier, but uglier).

I'd rather there be as few shared data structures between network
namespaces as possible--I think that will simplify things.

So, of those two choices, #1.

--b.
