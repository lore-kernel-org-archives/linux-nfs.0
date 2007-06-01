From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] locks: provide a file lease method enabling	cluster-coherent leases
Date: Fri, 1 Jun 2007 12:44:16 -0400
Message-ID: <20070601164416.GC10492@fieldses.org>
References: <1180647624483-git-send-email-bfields@fieldses.org> <11806476252240-git-send-email-bfields@fieldses.org> <11806476252913-git-send-email-bfields@fieldses.org> <46601BCD.8050609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org,
	David Teigland <teigland@redhat.com>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>,
	David Richter <richterd@umich.edu>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <46601BCD.8050609@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Jun 01, 2007 at 09:14:53AM -0400, Peter Staubach wrote:
> J. Bruce Fields wrote:
> >From: J. Bruce Fields <bfields@fieldses.org>
> >
> >Currently leases are only kept locally, so there's no way for a distributed
> >filesystem to enforce them against multiple clients.  We're particularly
> >interested in the case of nfsd exporting a cluster filesystem, in which
> >case nfsd needs cluster-coherent leases in order to implement delegations
> >correctly.
> 
> A couple of naive questions --
> 
> Do the semantics of these leases really match the requirements from NFSv4?

The only problem I'm aware of is that leases aren't broken on rename,
link, and unlink.  This is kind of tricky to fix.  David Richter (cc'd)
and I sketched out a few different approaches, and I think he has some
patches implementing at least one of them.

This may require defining some new type of lease, to avoid changing the
documented behavior of the fcntl lease operations (which only break on
open).  Although actually I believe Samba needs the same behavior we do,
and they're probably the most important user of leases....

> Does the internal NFSv4 server state also need to be shared?

Not that I can see.  The setup we're trying to deal with here is one
where we have a cluster filesystem mounted by several nodes, at least
two of which are running nfs servers exporting that filesystem.  The
servers don't share clients--so no clientid's or stateid's are
shared--but they need leases, locks, etc., to be coherent across all the
servers.

--b.
