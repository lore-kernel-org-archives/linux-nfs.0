Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56361 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757781Ab3KHUOv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 15:14:51 -0500
Date: Fri, 8 Nov 2013 15:14:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Message-ID: <20131108201446.GG3533@fieldses.org>
References: <A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com>
 <527C07B4.800@RedHat.com>
 <44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com>
 <527CDBFC.3070903@RedHat.com>
 <20131108082202.4032f1a2@tlielax.poochiereds.net>
 <527CFC72.2030907@RedHat.com>
 <20131108101232.10d49851@tlielax.poochiereds.net>
 <527D0CE6.2020401@RedHat.com>
 <20131108161707.GD3533@fieldses.org>
 <38DC086C-0EB7-42C3-9DCA-858A3225AAD0@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <38DC086C-0EB7-42C3-9DCA-858A3225AAD0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 08, 2013 at 10:09:18AM -0800, Chuck Lever wrote:
> I let this pass earlier, but...
> 
> The krb5i setting is _ONLY_ for lease management, not for data access.  Traversing the pseudo-fs counts as data access.  Our client is supposed to use the security flavor specified on the mount command line for the pseudo-fs.  (That's why the pseudo-fs security policy is the union of all the real exports on the server, right?)
> 
> If no flavor is specified by the client administrator, we have SECINFO_NONAME for negotiating the pseudo-fs security flavor in NFSv4.1, and some roughly equivalent heuristics for this in NFSv4.0, which doesn't have the SECINFO_NONAME operation.  Since 3.11, I believe, our client should be using these mechanisms instead of just plowing ahead with AUTH_SYS.

That makes sense.

(By the way: if a mount is done with krb5*, are we guaranteed the entire
export path is looked up with security at least as strong, or is it
possible we trust cached lookups possibly originally obtained with
weaker security?)

--b.
