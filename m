From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problems with POSIX ACL <=> NFSv4 ACL mapping in mainline
Date: Mon, 26 Jun 2006 12:23:38 -0400
Message-ID: <20060626162338.GC16697@fieldses.org>
References: <200606231745.23344.agruen@suse.de> <20060623160652.GK21357@fieldses.org> <200606261730.09827.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <200606261730.09827.agruen@suse.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, Jun 26, 2006 at 05:30:09PM +0200, Andreas Gruenbacher wrote:
> I much dislike adding a whole lot of complexity to libacl for a specific 
> corner case only because of the NFSv4 to POSIX ACL mapping.

That's certainly understandable, but...

> This mapping should really be hidden from applications wherever possible (and
> only applications that specifically deal with implementing the mapping should
> have to deal with it).

... short of putting the mapping into the kernel, putting it in libacl seems
the closest we can come to hiding it from applications.  Maybe there are other
ways we could connect libacl with the NFSv4 mapping code that would minimize
the impact on libacl?

The current libacl patches need some work in any case.

> > > (2) always trying both formats without knowing the properties of the
> > > underlying filesystem will always be slow,
> >
> > How much slower?  I'd expect the cost of one system call (which just
> > immediately returns -ENOTSUPP) to be insignificant.
> 
> The time overhead probably is low, yes. It's still a mess, and it will fail
> if ever we'll have a file system that understands both forms of ACLs. (How to
> resolve such conflicts is another question of course.)

You've referred several times to the case of a file system that understand both
forms of ACLs.  How are you imagining that would work?  That's a problem that
forces some hard choices, and without knowing how you're thinking of making
those choices, I find it hard to judge whether the current system would help or
hurt that case.

> > > In addition, I could imagine that we'll optionally support local
> > > NFSv4-style ACLs on specific file systems somewhen in the future. (Samba
> > > would benefit greatly from that for example; Solaris already can do
> > > that.) Not being able to tell the one kind of ACLs from the other in a
> > > world where we may have both sounds like a recipe for disaster to me.
> >
> > I'm not following you.  Currently nfsv4 and posix acls are being presented
> > to userspace via different extended attributes, so you can tell one type
> > from the other.
> 
> Except on NFSv4, we see POSIX ACLs represented as "system.nfs4_acl". I'd be 
> much happier to see POSIX ACLs represented as POSIX ACLs, and NFSv4 ACLs and 
> NFSv4 ACLs.

The stuff stored in "system.nfs4_acl" clearly represents an NFSv4 ACL, not a
POSIX ACL, so I'm not sure what you mean here.

> Both at the same time probably is not a good idea, agreed. Perhaps storing an 
> NFSv4 ACL when NFSv4 ACL tools are used and POSIX ACLs when POSIX ACL tools 
> are used might benting version 4 of the NFSACL side-band protocol

(I think there was some email-editing mistake here?)

If what you're proposing is storing *either* NFSv4 ACLs, *or* POSIX ACLs, but
never both, that could work.  It has the problem that if two users using the
two different types of ACLs ever operate on the same file, then they won't be
able to see each others ACLs, and setting one type will completely lose the
other.

If we'd been willing to go for that kind of solution from the start, we could
have tossed mode bits and chosen ACLs that were simpler than both NFSv4 and
POSIX ACLs.  But backwards compatibility seems too strong a requirement....

> Implementing version 4 of the NFSACL side-band protocol and dumping the NFSv4 
> ACL <=> POSIX ACL mapping in nfsd would completely get rid of no-op 
> (hopefully) rounds of mappings. That would mean less complexity in the kernel 
> (we already have version 3 NFSACL, and version 4 is essentially the same).

I'm not as familiar with the NFSACL protocol as I should be.  It can't accept
NFSv4 filehandles, though, can it?

--b.
