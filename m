Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34642 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209Ab3GaUfu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Jul 2013 16:35:50 -0400
Date: Wed, 31 Jul 2013 16:35:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Larry Keegan <lk@pfw.demon.co.uk>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: nfs client: Now you see it, now you don't (aka spurious ESTALE
 errors)
Message-ID: <20130731203537.GA2668@fieldses.org>
References: <20130725134515.67af44e2@cs3.al.itld>
 <20130725101143.6a22cb81@corrin.poochiereds.net>
 <20130725170526.6e54c7db@cs3.al.itld>
 <20130725141828.1862a1e1@tlielax.poochiereds.net>
 <20130726124101.058df8dc@cs3.al.itld>
 <20130726091225.5f299ff6@corrin.poochiereds.net>
 <20130726150222.GC30651@fieldses.org>
 <20130726222510.793c1627@cs3.al.itld>
 <20130731140328.GA28266@fieldses.org>
 <20130731195017.334bb05c@cs3.al.itld>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130731195017.334bb05c@cs3.al.itld>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 31, 2013 at 07:50:17PM +0000, Larry Keegan wrote:
> On Wed, 31 Jul 2013 10:03:28 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Fri, Jul 26, 2013 at 10:25:10PM +0000, Larry Keegan wrote:
> > > As far as NFS client arrangements are concerned, both of the NFS
> > > server machines also function as NFS clients, so /home/larry works
> > > on them in the same way as it does on any other NFS client on the
> > > network. It is just that the NFS servers also run my postfix MTAs.
> > 
> > It's unrelated to your ESTALE problem, but note that a setup like this
> > may be prone to deadlock.  (The client may need to write to the server
> > to free up memory.  The server may need memory to service the write.
> > If the server and client are on the same machine, this can deadlock.)
> > 
> > --b.
> > 
> 
> Dear Bruce,
> 
> Perhaps you can clear something up for me. If I understand you
> correctly, the following commands might lead to deadlock:
> 
> nfsserver# mount localhost:/filesystem /mnt
> nfsserver# memory-eater &
> [1] 1234
> nfsserver# echo tip it over the edge > /mnt/file
> 
> but that it won't deadlock if there is memory to spare. The reason I
> ask is I'd always assumed that any 'spare' memory in an active Linux
> system would end up being consumed by the disc cache, and that the
> cached pages are discarded or copied to disc when other parts of the

Note if the pages are backed by NFS files then "copying to disk" may
mean writing to the NFS server.

> system want memory (or sooner), assuming there is memory available to do
> that.
> 
> What I'm asking is whether this deadlock scenario is 'prone' to occur
> whenever there are insufficient reclaimable pages free or whether this
> can occur before that point? Can this deadlock occur even if the cache
> is large enough to ensure that most of what it contains has been
> written to disc already? IOW, ignoring the other parts of the O/S, if a
> programme writes 100MB/sec maximum to an NFS mounted directory on the
> same machine, and the NFS server commits its data to disc within 10
> seconds say, would 4GB of RAM provide enough headroom to make this
> deadlock unlikely?

Sorry, I don't know.

--b.
