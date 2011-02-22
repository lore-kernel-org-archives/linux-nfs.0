Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42667 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978Ab1BVBLp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Feb 2011 20:11:45 -0500
Date: Mon, 21 Feb 2011 20:11:44 -0500
To: Ferenc Wagner <wferi@niif.hu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: server does not abort grace period
Message-ID: <20110222011144.GA18424@fieldses.org>
References: <87wrl6ix2i.fsf@tac.ki.iif.hu>
 <87mxlpw4cv.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87mxlpw4cv.fsf@tac.ki.iif.hu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 21, 2011 at 08:54:24PM +0100, Ferenc Wagner wrote:
> Ferenc Wagner <wferi@niif.hu> writes:
> 
> > We're running 2.6.32 (Debian squeeze) NFS4 server and clients.  The
> > server boots and runs purely from SAN, so we can start it on different
> > computers.  In case of such "hardware failovers" I'd expect the clients
> > to quickly reclaim their locks (if any) and thus the server to abort
> > it's 90-second grace period early.  However, this does not happen,
> > ruining our HA like, totally.
> >
> > So, the questions: is the functionality of aborting the grace period
> > early missing from version 2.6.32 of the Linux kernel?  If yes, is it
> > present in any kernel version?  If it should work, could someone offer
> > some advice on debugging it?  If it isn't supported, what's the
> > best practice of providing highly available NFSv4 today?
> 
> Hi,
> 
> Could somebody please share any related wisdom?  Pretty please?
> In short, how to fight grace period in a HA NFS4 setup?
> Decreasing it (of course after cutting the lock lease time) seems a
> rather big hammer, I'd like to avoid using it if reasonably possible.

The NFSv4.0 protocol doesn't provide any way for clients to tell the
server that they have finished recovering; as long as *any* clients held
state on the previous server instance, the new server is stuck waiting
out the whole grace period.  Some things we could do:

	- We could at least recognize the case where *no* clients held
	  state before, and end the grace period early in that case.
	- In the NFSv4.1 case there is a "reclaim complete" rpc that
	  clients are required to send.  Currently we don't take
	  advantage of that to end the grace period early, but we
	  should.  That's no help for 4.0 clients.
	- We could record a count of all locks/opens held in stable
	  storage and use that to decide when a client is done
	  recovering.  That would be complicated and risk slowing down
	  normal opens and locks a lot.

In short, it's hard.

I don't think decreasing the lease time would be so terrible.  Perhaps
the default should even be a little less.

--b.
