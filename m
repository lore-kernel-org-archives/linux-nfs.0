Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54447 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756660Ab2CVUyY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 16:54:24 -0400
Date: Thu, 22 Mar 2012 16:54:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4: Change the default setting of the
 nfs4_disable_idmapping parameter
Message-ID: <20120322205423.GB23737@fieldses.org>
References: <1326138354-8138-1-git-send-email-Trond.Myklebust@netapp.com>
 <20120322204705.GA23737@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120322204705.GA23737@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 22, 2012 at 04:47:05PM -0400, bfields wrote:
> By the way, I finally got around to looking at the server side.
> 
> We don't have any way to negotiate with the client--we don't get an
> error back if the name we return in a getattr reply isn't one the client
> likes--so I don't think I can default the new behavior to "on" without
> breaking existing setups.

But we should still be able to make this effectively the default on new
server installations:  maybe:

	- Have the new module parameter be set based on a new
	  "ServerNumericMapping" variable in idmapd.conf defaults to
	  off.
	- Set it to "on" in the example idmapd.conf we distribute
	  upstream, and encourage distributions to do the same in the
	  idmapd.conf they install by default.

--b.

> 
> Other than that I think I'll just copy the client, module parameter and
> all.  That allows us to do the numeric case in-kernel and avoid
> polluting our mapping cache with lots of "obvious" 123<->"123" mappings.
