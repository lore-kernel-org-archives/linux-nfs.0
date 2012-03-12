Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51370 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756952Ab2CLVER (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 17:04:17 -0400
Date: Mon, 12 Mar 2012 17:04:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Nikolaus Rath <Nikolaus@rath.org>, linux-nfs@vger.kernel.org
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
Message-ID: <20120312210414.GB8991@fieldses.org>
References: <878vj7x6mj.fsf@vostro.rath.org>
 <87pqchn64e.fsf@inspiron.ap.columbia.edu>
 <20120312193115.GA7203@fieldses.org>
 <4F5E5241.7070008@rath.org>
 <20120312201505.GC7203@fieldses.org>
 <4F5E5CF2.50309@rath.org>
 <20120312204238.GA8991@fieldses.org>
 <7C4C12AF-5820-4BF3-8262-3BF5C201DA8C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7C4C12AF-5820-4BF3-8262-3BF5C201DA8C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 12, 2012 at 04:49:29PM -0400, Chuck Lever wrote:
> 
> On Mar 12, 2012, at 4:42 PM, J. Bruce Fields wrote:
> 
> > On Mon, Mar 12, 2012 at 04:30:42PM -0400, Nikolaus Rath wrote:
> >> On 03/12/2012 04:15 PM, J. Bruce Fields wrote:
> >>> Looking at the packet details, under the client id field, the clients
> >>> are all using:
> >>> 
> >>> 	"0.0.0.0/192.168.1.2 tcp UNIX 0"
> >> 
> >> Hmm. 192.168.1.2 is the server's address on the VPN. Is that supposed to
> >> be there?
> > 
> > Yes,and the first ip is usually the ip of the client, which does suggest
> > the client is guessing it's ip wrong; so the "clientaddr=" option will
> > likely help.
> 
> I thought 0.0.0.0 was a legal callback address, and means "don't send me CB requests".

Yes, that part's fine, it's using it in the clientid that gets us into
trouble here....

> But if all the clients are using the same nfs_client_id4 string, then no, the server can't distinguish between them, and they will tromp on each other's state.

Yeah.

> 
> The question is why can't the clients tell what their own IP address is?  mount.nfs is supposed to figure that out automatically.  Could be a bug in mount.nfs.

You know that code better than me....  Looks like it does basically
gethostbyname(gethostname()) ?

An strace -f of the mount from Nikolaus might help explain what happened
here.

> > Hm, perhaps the server should be rejecting these SETCLIENTID's with
> > INUSE.  It used to do that, and the client would likely recover from
> > that more easily.
> 
> INUSE means the client is using multiple authentication flavors when performing RENEW or SETCLIENTID.  I can't think of a reason the server should reject these; it's not supposed to look at the contents of the nfs_client_id4 string.

Well, from the trace the requests do appear (from the server's point of
view) to be coming from different IP addresses.  We used to use that
fact to return INUSE in this sort of case, which I think would trigger
the client to increment its uniqufier and work around the problem.

In the commit where I changed that I said:

	The spec allows clients to change ip address, so we shouldn't be
	requiring that setclientid always come from the same address.
	For example, a client could reboot and get a new dhcpd address,
	but still present the same clientid to the server.  In that case
	the server should revoke the client's previous state and allow
	it to continue, instead of (as it currently does) returning a
	CLID_INUSE error.
 
But maybe I should have applied that reasoning only in the krb5 case--in
the auth_sys case maybe the client ip address is really the only thing
we have to distinguish two clients.

--b.
