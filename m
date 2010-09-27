Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37309 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865Ab0I0OHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 10:07:49 -0400
Date: Mon, 27 Sep 2010 10:07:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/9] sunrpc: Virtualize ip_map_cache
Message-ID: <20100927140744.GA2450@fieldses.org>
References: <4CA06A63.6090507@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CA06A63.6090507@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 27, 2010 at 01:56:51PM +0400, Pavel Emelyanov wrote:
> Hello everyone!
> 
> This is the set I sent previously re-based on the
> git://linux-nfs.org/~bfields/linux.git nfsd-next branch
> and with fixed comment from Bruce.
> 
> Please, consider it for inclusion.

The patches look fine to me, and it sounds like there's a plan for
finishing the work that Trond and Chuck are both OK with....

So I'll queue those up for 2.6.37 soon if nobody spots any further
problem.

--b.
