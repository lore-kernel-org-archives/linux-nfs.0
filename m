From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [NFS] [PATCH] locks: provide a file lease method enabling	cluster-coherent leases
Date: Fri, 1 Jun 2007 11:41:23 -0600
Message-ID: <20070601174123.GS23968@parisc-linux.org>
References: <1180647624483-git-send-email-bfields@fieldses.org> <11806476252240-git-send-email-bfields@fieldses.org> <11806476252913-git-send-email-bfields@fieldses.org> <46601BCD.8050609@redhat.com> <20070601164416.GC10492@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	David Teigland <teigland@redhat.com>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>,
	David Richter <richterd@umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070601164416.GC10492@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Jun 01, 2007 at 12:44:16PM -0400, J. Bruce Fields wrote:
> The only problem I'm aware of is that leases aren't broken on rename,
> link, and unlink.  This is kind of tricky to fix.  David Richter (cc'd)
> and I sketched out a few different approaches, and I think he has some
> patches implementing at least one of them.
> 
> This may require defining some new type of lease, to avoid changing the
> documented behavior of the fcntl lease operations (which only break on
> open).  Although actually I believe Samba needs the same behavior we do,
> and they're probably the most important user of leases....

Samba internally prohibits renaming or deleting an open file, to match
Windows semantics.  So it won't notice the difference.  At least, that's
what I remember from a discussion with Tridge when we were implementing
leases back in 2000.

I think it's an acceptable change in Linux semantics to break leases on
rename/delete/link.  Though I'm not quite sure why you need to -- nobody
else is touching the contents of the file, so it's not like you need to
write the data back to it, or discard your cached copy of it in the case
of a read-only lease.
