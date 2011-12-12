Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35828 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab1LLQH1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 11:07:27 -0500
Date: Mon, 12 Dec 2011 11:07:22 -0500
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
Subject: Re: [PATCH 1/4] SUNRPC: use passed network namespace context in
 rpc_parse_scope_id()
Message-ID: <20111212160722.GF18185@fieldses.org>
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6>
 <20111207112016.17273.44510.stgit@localhost6.localdomain6>
 <20111208204749.GC32505@fieldses.org>
 <4EE625E1.7000502@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4EE625E1.7000502@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 12, 2011 at 08:03:45PM +0400, Stanislav Kinsbursky wrote:
> 09.12.2011 00:47, J. Bruce Fields пишет:
> >On Wed, Dec 07, 2011 at 03:20:16PM +0300, Stanislav Kinsbursky wrote:
> >>Use incomming network context in rpc_parse_scope_id() instead of hard-coded
> >
> >Changelogs are a little confusing; I might have said "allow
> >rpc_parse_cope_id() caller to pass in network context instead of using
> >hard-code "init_net"."
> 
> Probably, you variant is better. My English is not good enough to
> write descriptive and, in the same time, clear and short comments to
> patches.

Uh, and mine's got a problm or two as well.  ("hard-code" should be
"hard-coded" in the above.)

My main complaint was just that "incoming network context" sounds like
it refers to the network context associated with an incoming rpc
request.  But actually all you're doing is using the network context
passed in by the caller.

--b.
