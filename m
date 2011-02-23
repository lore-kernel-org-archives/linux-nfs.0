Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58765 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639Ab1BWTwx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Feb 2011 14:52:53 -0500
Date: Wed, 23 Feb 2011 14:52:51 -0500
To: Ferenc Wagner <wferi@niif.hu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: server does not abort grace period
Message-ID: <20110223195250.GB13399@fieldses.org>
References: <87wrl6ix2i.fsf@tac.ki.iif.hu>
 <87mxlpw4cv.fsf@tac.ki.iif.hu>
 <20110222011144.GA18424@fieldses.org>
 <878vx8huet.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <878vx8huet.fsf@tac.ki.iif.hu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 22, 2011 at 06:05:14PM +0100, Ferenc Wagner wrote:
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> > The NFSv4.0 protocol doesn't provide any way for clients to tell the
> > server that they have finished recovering; as long as *any* clients
> > held state on the previous server instance, the new server is stuck
> > waiting out the whole grace period.  Some things we could do:
> >
> > 	- We could at least recognize the case where *no* clients held
> > 	  state before, and end the grace period early in that case.
> 
> Would this mean that /var/lib/nfs/v4recovery is empty on the server?

Right.

> Actually, it contains a hex-named empty directory, sometimes two (we're
> running with two clients at the moment).
> 
> > 	- In the NFSv4.1 case there is a "reclaim complete" rpc that
> > 	  clients are required to send.  Currently we don't take
> > 	  advantage of that to end the grace period early, but we
> > 	  should.  That's no help for 4.0 clients.
> 
> /proc/fs/nfsd/versions shows +4.1 on the server, does this mean that
> nfs4 type Linux client mounts should issue "reclaim complete"?

It means that a 4.1 is supported, so a client *could* use 4.1 if it
asked to.  And if it did use 4.1, yes, it would be required to issue
reclaim complete.  Current linux clients do not use 4.1 unless you
explicitly ask for it on the mont commandline.

(Aside: the server really shouldn't have +4.1 by default, as the 4.1
server is not done.  We should fix that; which distro are you using?)

> I see
> that it won't help anyway at the moment, lacking server support, just
> out of interest...
> 
> > 	- We could record a count of all locks/opens held in stable
> > 	  storage and use that to decide when a client is done
> > 	  recovering.  That would be complicated and risk slowing down
> > 	  normal opens and locks a lot.
> 
> And the "reclaim complete" client RPC seems must better anyway, as the
> server and the client may get out of sync in case of an unclean client
> shutdown.
> 
> > I don't think decreasing the lease time would be so terrible.  Perhaps
> > the default should even be a little less.
> 
> Fine, then.  Does the Linux nfs server implementation use the lease time
> of the previous server instance as grace period on startup, or does it
> simply take whatever it finds in /proc/fs/nfsd/nfsv4leasetime?

The latest server has separately tunable "nfsv4gracetime" and
"nfsv4leasetime", and if you want to be careful, you should:

	- stop the server
	- set nfsv4gracetime to the *previous* lease time
	- set nfsv4leasetime to the *new* lease time
	- start the server

That gives you the new (lower) lease time while still giving a
sufficiently long grace period for clients who only knew about the old
time to recover.  After doing that once, on future restarts you can use
the shorter time for both.

Probably we should write utilites which do this right for you....

--b.
