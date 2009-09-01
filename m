From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Change default behavior when "sec=" is not
 specified by user
Date: Tue, 01 Sep 2009 17:22:40 -0400
Message-ID: <1251840160.8463.20.camel@heimdal.trondhjem.org>
References: <20090901151830.GC22846@fieldses.org>
	 <18678BB3-52C6-4376-BBD1-50B8947BAAC7@oracle.com>
	 <20090901160914.GG22846@fieldses.org>
	 <73E8EAAF-9164-4F78-A9D4-1CC86A6A6255@oracle.com>
	 <20090901163846.GJ22846@fieldses.org>
	 <B9CADBA9-54B0-44AD-A8DC-FE3ED63341BC@oracle.com>
	 <1251829540.18608.31.camel@heimdal.trondhjem.org>
	 <D11105A9-4FAB-4F5C-BF02-BE489520C150@oracle.com>
	 <1251833479.18608.69.camel@heimdal.trondhjem.org>
	 <E7FCF468-0A25-4DA1-8E71-A383BCBA4642@oracle.com>
	 <20090901201544.GF27726@fieldses.org>
	 <411DA127-278F-4799-9E40-EB8409510E2E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:34525 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752014AbZIAVWm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 17:22:42 -0400
In-Reply-To: <411DA127-278F-4799-9E40-EB8409510E2E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-09-01 at 16:31 -0400, Chuck Lever wrote:
> For v4, you have WRONGSEC, but I don't think NFSv2 makes that  
> distinction.  Would the client probe the server with NFS requests each  
> using a different flavor?  Would we expect to see the RPC level "weak  
> authentication" reply in the NFSv2 case?  Before Eisler says it, why  
> would we bother?
> 
> Even so, that's a much different proposition than simply reading the  
> flavor list returned by MNT3PROC, so I'm straining to see how we could  
> reuse the logic I'm adding to the kernel's MNT client to do security  
> negotiation for NFSv2.  If Trond is referring only to merging the  
> kernel's auth flavor lists, then that comment makes more sense.

IMO the goal should be to have _one_ engine that can iterate through a
list of auth flavours (either the list provided by the MNT server, or
the list of all flavours supported by the client) until it gets a
positive response to an RPC call. We shouldn't assume that the flavour
that was negotiated at mount time is final.
It makes sense to code this iteration process at the RPC level instead
of at the NFS level. That enables us to use the same engine for NFSv2,
NFSv4, and the NFSv4.0 server (when doing client callbacks). Possibly
also for NLM and MOUNT (apparently IRIX used to support this)...


