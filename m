Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48702 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755948Ab2ASPrf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 10:47:35 -0500
Date: Thu, 19 Jan 2012 10:47:31 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Dr James Bruce Fields <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 0/5] SUNRPC: make caches network namespace aware
Message-ID: <20120119154731.GB527@fieldses.org>
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6>
 <1326986392.6114.1.camel@lade.trondhjem.org>
 <4F18376C.9090504@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4F18376C.9090504@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 19, 2012 at 07:31:56PM +0400, Stanislav Kinsbursky wrote:
> 19.01.2012 19:19, Trond Myklebust пишет:
> >On Thu, 2012-01-19 at 18:48 +0400, Stanislav Kinsbursky wrote:
> >>One more step towards to "NFS in container".
> >>With this patch set caches are allocated per network namespace.
> >>
> >>The following series consists of:
> >>
> >>---
> >>
> >>Stanislav Kinsbursky (5):
> >>       SUNRPC: cache creation and destruction routines introduced
> >>       SUNRPC: create unix gid cache per network namespace
> >>       SUNRPC: create GSS auth cache per network namespace
> >>       SUNRPC: ip map cache per network namespace cleanup
> >>       SUNRPC: generic cache register routines removed
> >
> >The patches look good, and I've applied them for now in my 'devel'
> >branch so we can test them, but I'd like to get an Ack/Nack from Bruce
> >before committing to merging them.
> >
> 
> Cool, thanks.
> BTW, these patches depends on patch "NFSd: use
> network-namespace-aware cache registering routines", which Bruce
> took already (and it's even in linux-next already), but not in your
> devel tree for some reason.

And Linus has pulled those, so if Trond bases his tree on -rc1, he'll
have "NFSd: use network-namespace-aware cache registering routines".

You know best what you're planning to submit over the next cycle, and
what the dependencies are, and which side (client or server) it's likely
to touch more.  So, your choice, I think.  If necessary Trond and I can
probably do a merge between us at some point.

Either way, I'll go take a look at them now....--b.

--b.
