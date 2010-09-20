Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45687 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751786Ab0ITQOx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 12:14:53 -0400
Date: Mon, 20 Sep 2010 12:13:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Neil Brown <neilb@suse.de>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
Message-ID: <20100920161326.GL4580@fieldses.org>
References: <4C90BADB.10700@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C90BADB.10700@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 15, 2010 at 04:23:55PM +0400, Pavel Emelyanov wrote:
> Hello everyone!
> 
> I would like to prepare the sunrpc layer for working in a containerized
> environments. The ultimate goal is to make both nfs client and server
> work in containers. Hopefully you won't object :)

Neat, thanks.

> Not to look like an idle talker I've prepared this set which makes the
> /proc/net/rpc appear in net namespaces and made the ip_map_cache be per-net.
> 
> I do not have any plans about when this patches appear at Linus tree and
> thus do not know which git tree to hack on. That said I prepared the patches
> against the net-next tree (I have some custom netns debugging code in it
> and don't want to port it around in vain).
> 
> Looking forward to your feedback.

What are you thinking of as a use-case for this?

I think it would be useful to able to run what appear to be multiple NFS
servers on a single host; and for that, we would want to vary more than
just the ip_map_cache.  The export-related caches (nfsd.fh and
nfsd.export), at least.

--b.
