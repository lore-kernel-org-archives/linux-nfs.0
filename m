From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Q: directory renames and cache coherency in NFS?
Date: Sun, 27 Jan 2008 13:42:06 -0500
Message-ID: <1201459326.7346.29.camel@heimdal.trondhjem.org>
References: <200801271829.m0RITQkQ002462@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net,
	Al Viro <viro@zeniv.linux.org.uk>
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.netapp.com ([216.240.18.38]:18849 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658AbYA0SmO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Jan 2008 13:42:14 -0500
In-Reply-To: <200801271829.m0RITQkQ002462-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sun, 2008-01-27 at 13:29 -0500, Erez Zadok wrote:
> In message <1201457297.7346.27.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>, Trond Myklebust writes:
> > 
> > On Sun, 2008-01-27 at 10:55 -0500, Erez Zadok wrote:
> > > NFS shares some traits with stackable file systems.  Both have some notion
> > > of "layers": in nfs, it's client -> server -> local f/s; in a stackable f/s
> > > it's upper -> lower.
> > > 
> > > I'm trying to understand what are the semantics of NFS when directories are
> > > renamed on the server while a client is trying to use those directories (I
> > > follow a similar behavior in unionfs or other stackable f/s).  Consider this
> > > sequence of steps:
> > > 
> > > 1. client looks up (or revalidates) directory D1
> > > 2. server renames D1 to D2 (D2 could be anywhere in the tree)
> > > 3. client tries to create file F in (the cached) directory D1
> > > 
> > > What happens in the last step?  Does the client get an ESTALE or some other
> > > error?  Or does it succeed and F gets created in the renamed directory
> > > (D2/F)?  Does the behavior differ b/t nfsv2/3/4?  Is it described the RFCs
> > > or specs?
> > 
> > The general rule is that an NFSv2/v3/v4 client would expect 3 to succeed
> > (provided that the user has the required permissions).
> [...]
> 
> And by "succeed", you mean that the new file F will be created in D2, right?

Yes. That is what a posix application would expect.

Trond
