From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problems with POSIX ACL <=> NFSv4 ACL mapping in mainline
Date: Fri, 23 Jun 2006 12:06:52 -0400
Message-ID: <20060623160652.GK21357@fieldses.org>
References: <200606231745.23344.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <200606231745.23344.agruen@suse.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Jun 23, 2006 at 05:45:22PM +0200, Andreas Gruenbacher wrote:
> they don't map onto each other very well. Marius and others are proposing a 
> mapping between the two formats [3], and an implementation of that mapping 
> seems to have found its way into the mainline nfsv4 implementation. (Note 
> that I didn't actually verify the implemented mapping actually reflects draft 
> [3].)

It doesn't; the implementation is based on the previous version.  The newer
version requires the server to perform a (possibly lossy) mapping of virtually
any NFSv4 ACL, whereas the previous (currently implemented) version only
accepted a very small subset of possible NFSv4 ACLs.

> The CITI has patches that try to work around this in libacl by trying both 
> POSIX ACLs and "system.nfs4_acl" attributes, and converting between the two 
> if necessary. This approach has a number of disadvantages: (1) applications 
> that don't use libacl will still fail

Are there particular examples of such applications that you're thinking of?

> (2) always trying both formats without knowing the properties of the
> underlying filesystem will always be slow,

How much slower?  I'd expect the cost of one system call (which just
immediately returns -ENOTSUPP) to be insignificant.

> In addition, I could imagine that we'll optionally support local NFSv4-style
> ACLs on specific file systems somewhen in the future. (Samba would benefit
> greatly from that for example; Solaris already can do that.) Not being able
> to tell the one kind of ACLs from the other in a world where we may have both
> sounds like a recipe for disaster to me.

I'm not following you.  Currently nfsv4 and posix acls are being presented to
userspace via different extended attributes, so you can tell one type from the
other.

> I could imagine the following solutions to this problem:
> 
> * Don't map between POSIX ACLs and NFSv4 ACLs at all, and use a different
> protocol for POSIX ACLs and for NFSv4 ACLs instead (e.g., version 4 of the
> NFSACL protocol extension). The protocol extension is not currently
> implemented in Solaris because current Solaris supports NFSv4 ACLs natively
> instead of POSIX ACLs, and so they don't seem to have as strong a motivation
> to keep POSIX ACLs working well as we currently do. The NFSACL protocol has
> the huge advantage of supporting POSIX ACLs pretty well, and so a lot of the
> overhead and complexity of doing the NFSv4 mapping would go away though.

If you wanted to support *both* POSIX and NFSv4 ACLs, then you'd still have the
same problem.  Unless you expect it to be possible to set both types of ACLs on
the same file independently, and make the kernel enforce the AND of the two, or
something like that.  I don't think that would be helpful.

> * Map back from NFSv4 ACLs to POSIX ACLs on the client side, so that POSIX
> ACLs on the server will appear as POSIX ACLs on the client. This would take
> away all the mess we currently have in user-space

And put it in the kernel instead?  We originally did exactly that, and Trond
argued that we should do this in userspace instead.  I still think that was the
right decision.

I'm not satisfied with the current situation either.  But I don't think Samba
or NFSv4 will ever be completely happy until we provide good support for
NFSv4/Windows-style ACLs.  We can't rip out POSIX ACLs in the process, so we're
going to have to support both.  I don't see how to support both well without
mapping between them.  And if we've got to do this complicated mapping, let's
do it in userspace whenever possible.

--b.
