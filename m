Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51853 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755656Ab2DJTB3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 15:01:29 -0400
Date: Tue, 10 Apr 2012 15:01:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Sachin Prabhu <sprabhu@redhat.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>, steved <steved@redhat.com>
Subject: Re: ESTALE errors: What can be done to handle this problem.
Message-ID: <20120410190127.GA32661@pad.fieldses.org>
References: <1334073825.2149.29.camel@localhost>
 <1334077062.19865.21.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1334077062.19865.21.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 10, 2012 at 04:57:42PM +0000, Myklebust, Trond wrote:
> Handling ESTALE still doesn't guarantee that you can make progress.
> Remove the 'sleep 3' above, and you can theoretically find yourself
> replaying lookups until the cows come home while that 'stat()' call
> continues to return ESTALE.
> The bottom line is that NFS is not safe in situations such as the above,

By the way, what precisely are the "situations such as the above"?  Or
put in another way, what are the rules users need to know?

("Operations on paths affected by a directory-modifying operation should
not be attempted until after sufficient time has passed for the lookup
cache to time out"?  No, it should be a weaker rule than that.)

> since we don't have the kind of locking required to guarantee that
> LOOKUP + GETATTR can be done atomically.

Though all we actually need is a way to hold a temporary reference on
the looked up filehandle.  In theory that wouldn't be hard to add?:

	- Clarify that current and saved filehandles shouldn't go stale
	  during the lifetime of a compound.
	- If we also need to hold filehandle references across
	  compounds, introduce new operations for that (and make the
	  references part of the client's leased state)

--b.

> 
> > Is this approach feasible? If not, what else can be done to avoid this
> > problem.
> 
> If you have workloads such as the above, then I suggest "mount
> -olookupcache=none". It still won't prevent ESTALE, but at least you
> ensure that the dentry revalidation always does a full lookup.
> 
> Otherwise, you can do as Jeff suggested: handle the ESTALE at the VFS
> level, but ensure that you break out of the loop after a limited number
> of attempts has been made.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
