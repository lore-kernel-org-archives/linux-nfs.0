Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34826 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753679Ab2CAT2M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Mar 2012 14:28:12 -0500
Date: Thu, 1 Mar 2012 14:28:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Orion Poplawski <orion@cora.nwra.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs4 mount hanging suddenly
Message-ID: <20120301192808.GA17433@fieldses.org>
References: <4F4EA6D0.30606@cora.nwra.com>
 <20120229231732.GD6506@fieldses.org>
 <4F4EB2FE.9040108@cora.nwra.com>
 <1330609841.6218.6.camel@lade.trondhjem.org>
 <4F4F96EA.9050203@cora.nwra.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F4F96EA.9050203@cora.nwra.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 01, 2012 at 08:34:02AM -0700, Orion Poplawski wrote:
> On 03/01/2012 06:50 AM, Myklebust, Trond wrote:
> >On Wed, 2012-02-29 at 16:21 -0700, Orion Poplawski wrote:
> >>On 02/29/2012 04:17 PM, J. Bruce Fields wrote:
> >>>On Wed, Feb 29, 2012 at 03:29:36PM -0700, Orion Poplawski wrote:
> OMP Reply (Call
> >>>
> >>>That probably means the server is waiting for the client to return a
> >>>delegation.
> >>>
> >>>Either the server's confused about their being a delegation, or the
> >>>client's failing to return one it should?
> >>>
> >
> >As far as I can see from your trace, the client keeps trying to open the
> >file '.history', and the server keeps replying with NFS4ERR_DELAY. There
> >is nothing in the trace itself that can tell us why the server is
> >delaying.
> 
> So, it seems to be on the server side?  I didn't get any relief
> restarting nfs on the server.  Any way to trace what is happening on
> the server side?

Hm.  /proc/locks should be able to tell you whether there's a 
delegation.  (Look for a lock of type LEASE with an inode number 
matching that of the .history (or whatever file's getting the DELAY 
return.))

But honestly it's a fairly old kernel.

--b.
