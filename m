Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:17072 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759027Ab3D2TJm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Apr 2013 15:09:42 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4: Servers should only check SETATTR stateid
 open mode on size change
Date: Mon, 29 Apr 2013 19:09:41 +0000
Message-ID: <1367262579.19515.33.camel@leira.trondhjem.org>
References: <1367248534-33387-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1367259352.19515.16.camel@leira.trondhjem.org>
	 <20130429182145.GL17268@fieldses.org>
	 <1367260027.19515.25.camel@leira.trondhjem.org>
	 <20130429182939.GN17268@fieldses.org>
	 <1367260382.19515.29.camel@leira.trondhjem.org>
	 <20130429184103.GO17268@fieldses.org>
In-Reply-To: <20130429184103.GO17268@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-04-29 at 14:41 -0400, J. Bruce Fields wrote:
> On Mon, Apr 29, 2013 at 06:33:02PM +0000, Myklebust, Trond wrote:
> > On Mon, 2013-04-29 at 14:29 -0400, J. Bruce Fields wrote:
> > > On Mon, Apr 29, 2013 at 06:27:07PM +0000, Myklebust, Trond wrote:
> > > > On Mon, 2013-04-29 at 14:21 -0400, J. Bruce Fields wrote:
> > > > > On Mon, Apr 29, 2013 at 06:15:52PM +0000, Myklebust, Trond wrote:
> > > > > > On Mon, 2013-04-29 at 11:15 -0400, Trond Myklebust wrote:
> > > > > > > The NFSv4 and NFSv4.1 specs are both clear that the server should only check
> > > > > > > stateid open mode if a SETATTR specifies the size attribute. If the
> > > > > > > open mode is not one that allows writing, then it returns NFS4ERR_OPENMODE.
> > > > > > > 
> > > > > > > In the case where the SETATTR is not changing the size, the client will
> > > > > > > still pass it the delegation stateid to ensure that the server does not
> > > > > > > recall that delegation. In that case, the server should _ignore_ the
> > > > > > > delegation open mode, and simply apply standard permission checks.
> > > > > > 
> > > > > > Bruce, what does the Linux server do when we send it a delegation
> > > > > > stateid as part of a SETATTR that just changes the mode or acl (no size
> > > > > > change)? Will it recall the delegation? How about the delegations held
> > > > > > by other clients?
> > > > > 
> > > > > Yes, it breaks all delegations on any setattr.
> > > > 
> > > > Do you plan to change that?
> > > 
> > > I'd take patches.
> > 
> > Have the NFSv4 delegation patches been merged yet, and do they hand out
> > delegations on file creation?
> 
> The vfs support patches haven't been merged, but nfsd still continues to
> give out read delegations on any confirmed read-open of a file that
> hasn't had a recent delegation conflict.  (They're just not consistent
> w.r.t local metadata operations....)

The problem is that without those there seems to be no VFS level
functionality that allows you to say "break the leases for all processes
except this one".

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
