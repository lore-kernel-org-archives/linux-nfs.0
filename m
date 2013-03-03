Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58835 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207Ab3CCAU4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Mar 2013 19:20:56 -0500
Date: Sat, 2 Mar 2013 19:20:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: status of idr_alloc() conversion in nfsd?
Message-ID: <20130303002054.GA20389@fieldses.org>
References: <20130302212411.GB3678@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130302212411.GB3678@htj.dyndns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 02, 2013 at 01:24:11PM -0800, Tejun Heo wrote:
> Hello, Bruce.
> 
> As we're reaching -rc1, I'm preparing final conversions and
> deprecation of the old idr interface.  It seems like nfsd still hasn't
> been converted.  It it gonna happen soon?

Whoops, sorry, I think I assumed you'd do it.

The prerequisite cleanup is upstream now, so I think it should be
straightforward?

Let me know if you want me to do it, or I'm happy to ACK anything of
yours.

--b.
