Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52279 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751530Ab1HVVIi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Aug 2011 17:08:38 -0400
Date: Mon, 22 Aug 2011 17:08:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: Add scope id to svc_addr_u for IPv6 LINKLOCAL
 address
Message-ID: <20110822210833.GD16261@fieldses.org>
References: <4E4F8B5D.6060404@cn.fujitsu.com>
 <20110822192348.GA16261@fieldses.org>
 <20110822153939.14d0a6ac@tlielax.poochiereds.net>
 <73D17319-3FDB-4278-872A-FF488E1C88DD@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <73D17319-3FDB-4278-872A-FF488E1C88DD@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 22, 2011 at 03:44:39PM -0400, Chuck Lever wrote:
> On Aug 22, 2011, at 3:39 PM, Jeff Layton wrote:
> > That said, on a semi-related note...
> > 
> > I have to wonder about statd in conjunction with link-local addresses.
> > I have a hard time understanding how you'd ever get reboot
> > notifications in such a setup.
> 
> The only way that could work is if DNS was able to look at a local hostname, and provide the correct scope ID.  Doubtful.  I wonder if mDNS might provide such ability.

OK.  Mi Jinlong, if you don't have a use case in mind for this, let's
not bother.

--b.
