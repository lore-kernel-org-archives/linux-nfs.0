From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Problems with POSIX ACL <=> NFSv4 ACL mapping in mainline
Date: Mon, 26 Jun 2006 17:30:09 +0200
Message-ID: <200606261730.09827.agruen@suse.de>
References: <200606231745.23344.agruen@suse.de> <20060623160652.GK21357@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060623160652.GK21357@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Friday, 23 June 2006 18:06, J. Bruce Fields wrote:

> > The CITI has patches that try to work around this in libacl by trying
> > both POSIX ACLs and "system.nfs4_acl" attributes, and converting between
> > the two if necessary. This approach has a number of disadvantages: (1)
> > applications that don't use libacl will still fail
>
> Are there particular examples of such applications that you're thinking of?

Anything that simply copies xattrs from a file on NFSv4 to a file on another 
filesystem fails. The specific case I ran into was that I didn't apply the 
CITI libacl patches because I am unconvinced about the general approach, and 
I didn't feel well with adding the whole mess to libacl late in the SLES10 
game, let alone testing the code. The result were errors when copying files 
with cp -p (which preserves xattrs).

I much dislike adding a whole lot of complexity to libacl for a specific 
corner case only because of the NFSv4 to POSIX ACL mapping. This mapping 
should really be hidden from applications wherever possible (and only 
applications that specifically deal with implementing the mapping should have 
to deal with it).

> > (2) always trying both formats without knowing the properties of the
> > underlying filesystem will always be slow,
>
> How much slower?  I'd expect the cost of one system call (which just
> immediately returns -ENOTSUPP) to be insignificant.

The time overhead probably is low, yes. It's still a mess, and it will fail if 
ever we'll have a file system that understands both forms of ACLs. (How to 
resolve such conflicts is another question of course.)

> > In addition, I could imagine that we'll optionally support local
> > NFSv4-style ACLs on specific file systems somewhen in the future. (Samba
> > would benefit greatly from that for example; Solaris already can do
> > that.) Not being able to tell the one kind of ACLs from the other in a
> > world where we may have both sounds like a recipe for disaster to me.
>
> I'm not following you.  Currently nfsv4 and posix acls are being presented
> to userspace via different extended attributes, so you can tell one type
> from the other.

Except on NFSv4, we see POSIX ACLs represented as "system.nfs4_acl". I'd be 
much happier to see POSIX ACLs represented as POSIX ACLs, and NFSv4 ACLs and 
NFSv4 ACLs.

> > I could imagine the following solutions to this problem:
> >
> > * Don't map between POSIX ACLs and NFSv4 ACLs at all, and use a different
> > protocol for POSIX ACLs and for NFSv4 ACLs instead (e.g., version 4 of
> > the NFSACL protocol extension). The protocol extension is not currently
> > implemented in Solaris because current Solaris supports NFSv4 ACLs
> > natively instead of POSIX ACLs, and so they don't seem to have as strong
> > a motivation to keep POSIX ACLs working well as we currently do. The
> > NFSACL protocol has the huge advantage of supporting POSIX ACLs pretty
> > well, and so a lot of the overhead and complexity of doing the NFSv4
> > mapping would go away though.
>
> If you wanted to support *both* POSIX and NFSv4 ACLs, then you'd still have
> the same problem.  Unless you expect it to be possible to set both types of
> ACLs on the same file independently, and make the kernel enforce the AND of
> the two, or something like that.  I don't think that would be helpful.

Both at the same time probably is not a good idea, agreed. Perhaps storing an 
NFSv4 ACL when NFSv4 ACL tools are used and POSIX ACLs when POSIX ACL tools 
are used might benting version 4 of the NFSACL side-band protocol and dumping 
the NFSv4 ACL <=> POSIX ACL mapping in nfsd would completely get rid of no-op 
(hopefully) rounds of mappings. That would mean less complexity in the kernel 
(we already have version 3 NFSACL), and complexity in user spaceecome an 
option, or some such.

> > * Map back from NFSv4 ACLs to POSIX ACLs on the client side, so that
> > POSIX ACLs on the server will appear as POSIX ACLs on the client. This
> > would take away all the mess we currently have in user-space
>
> And put it in the kernel instead?

Yes.

> We originally did exactly that, and Trond argued that we should do this in
> userspace instead.  I still think that was the right decision.

Things would look different with native NFSv4 ACLs as on Solaris, but we are 
not in this situation.

> I'm not satisfied with the current situation either.  But I don't think
> Samba or NFSv4 will ever be completely happy until we provide good support
> for NFSv4/Windows-style ACLs.  We can't rip out POSIX ACLs in the process,
> so we're going to have to support both.  I don't see how to support both
> well without mapping between them.  And if we've got to do this complicated
> mapping, let's do it in userspace whenever possible.

Implementing version 4 of the NFSACL side-band protocol and dumping the NFSv4 
ACL <=> POSIX ACL mapping in nfsd would completely get rid of no-op 
(hopefully) rounds of mappings. That would mean less complexity in the kernel 
(we already have version 3 NFSACL, and version 4 is essentially the same).

Andreas
