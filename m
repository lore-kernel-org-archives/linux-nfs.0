Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58945 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203Ab1LLQPp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 11:15:45 -0500
Date: Mon, 12 Dec 2011 11:15:42 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 0/4] SUNRPC: pass network namespace context to sockaddr
 construction routines
Message-ID: <20111212161542.GH18185@fieldses.org>
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6>
 <20111208204648.GB32505@fieldses.org>
 <4EE62824.9090807@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4EE62824.9090807@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 12, 2011 at 08:13:24PM +0400, Stanislav Kinsbursky wrote:
> 09.12.2011 00:46, J. Bruce Fields пишет:
> >On Wed, Dec 07, 2011 at 03:20:07PM +0300, Stanislav Kinsbursky wrote:
> >>This is another precursor patch set aimed to remove hard-coded "init_net"
> >>reference from SUNRPC sockaddr convertion and construction routines.
> >
> >ACK--all look straightforward.  (Only complaint would be that this isn't
> >terribly interesting till we see how these are used.)
> >
> 
> Actually, all is simple. These init_net pointers will be replaced
> later by "transports, clients and others" network namespace
> contexts.
> I have some more patches for NFS layer. But I don't see any sense to
> sent them now since no "virtualization" patches were commited yet.
> So, currently, I'm trying to finalize "SUNRPC per network namespace"
> task, and soon I'll send a patch set making SUNRPC sysctl's
> network-namespace-aware. It is a little bit tricky and ugly from my
> pow, so any ideas are welcome.

No ideas.... What's the ugly part?

--b.
