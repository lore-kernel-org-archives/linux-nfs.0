Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38255 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758507Ab3D2S2C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Apr 2013 14:28:02 -0400
Date: Mon, 29 Apr 2013 14:28:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4: Servers should only check SETATTR stateid
 open mode on size change
Message-ID: <20130429182800.GM17268@fieldses.org>
References: <1367248534-33387-1-git-send-email-Trond.Myklebust@netapp.com>
 <1367259352.19515.16.camel@leira.trondhjem.org>
 <20130429182145.GL17268@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130429182145.GL17268@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 29, 2013 at 02:21:45PM -0400, J. Bruce Fields wrote:
> On Mon, Apr 29, 2013 at 06:15:52PM +0000, Myklebust, Trond wrote:
> > On Mon, 2013-04-29 at 11:15 -0400, Trond Myklebust wrote:
> > > The NFSv4 and NFSv4.1 specs are both clear that the server should only check
> > > stateid open mode if a SETATTR specifies the size attribute. If the
> > > open mode is not one that allows writing, then it returns NFS4ERR_OPENMODE.
> > > 
> > > In the case where the SETATTR is not changing the size, the client will
> > > still pass it the delegation stateid to ensure that the server does not
> > > recall that delegation. In that case, the server should _ignore_ the
> > > delegation open mode, and simply apply standard permission checks.
> > 
> > Bruce, what does the Linux server do when we send it a delegation
> > stateid as part of a SETATTR that just changes the mode or acl (no size
> > change)? Will it recall the delegation? How about the delegations held
> > by other clients?
> 
> Yes, it breaks all delegations on any setattr.

(Well, any setattr that doesn't set size--if it sets size, you'll get
OPENMODE (since we don't support write delegations) before we get around
to breaking any delegations.

In fact, it skips all the stateid processing entirely in the case size
isn't set--so you could send garbage in the stateid field and it'd
work.)

--b.
