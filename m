From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] locks: provide a file lease method enabling	cluster-coherent leases
Date: Fri, 1 Jun 2007 14:08:42 -0400
Message-ID: <20070601180842.GG10492@fieldses.org>
References: <1180647624483-git-send-email-bfields@fieldses.org> <11806476252240-git-send-email-bfields@fieldses.org> <11806476252913-git-send-email-bfields@fieldses.org> <46601BCD.8050609@redhat.com> <20070601164416.GC10492@fieldses.org> <20070601174123.GS23968@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	David Teigland <teigland@redhat.com>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>,
	David Richter <richterd@umich.edu>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070601174123.GS23968@parisc-linux.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Jun 01, 2007 at 11:41:23AM -0600, Matthew Wilcox wrote:
> Samba internally prohibits renaming or deleting an open file, to match
> Windows semantics.  So it won't notice the difference.  At least, that's
> what I remember from a discussion with Tridge when we were implementing
> leases back in 2000.

NFSv4 should be doing the same thing (err, for some reason I thought it
already did--I remember writing patches to do it--but I must not have
finished them).  But there's still the problem of renames done by local
users, other file servers in the multiprotocol case, etc.

> I think it's an acceptable change in Linux semantics to break leases on
> rename/delete/link.  Though I'm not quite sure why you need to -- nobody
> else is touching the contents of the file, so it's not like you need to
> write the data back to it, or discard your cached copy of it in the case
> of a read-only lease.

NFSv4 delegations are defined to cover the file's metadata (including
the name it was opened under) as well as its data.  Otherwise you
wouldn't be able to perform opens locally, because you wouldn't know
whether the open path still works, or whether the file permissions still
allow the same access.

And other parts of the protocol make use of this assumption (e.g. OPEN
with CLAIM_DELEGATE_CUR or CLAIM_DELEGATE_PREV, which expect to be able
to re-open a file under its original name).

--b.
