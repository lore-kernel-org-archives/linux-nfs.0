From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Thu, 3 Aug 2006 15:46:12 +0200
Message-ID: <200608031546.13269.agruen@suse.de>
References: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
	<200607252215.16735.agruen@suse.de>
	<4654D18B-57AD-4779-80A6-BFD2FCEC4A69@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@sun.com>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	"Noveck, Dave" <Dave.Noveck@netapp.com>,
	Spencer Shepler <spencer.shepler@sun.com>,
	"Pawlowski,  Brian" <beepy@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8dTM-0004TE-5v
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 06:42:48 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8dTL-0000aK-2m
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 06:42:48 -0700
To: Sam Falkner <Sam.Falkner@sun.com>
In-Reply-To: <4654D18B-57AD-4779-80A6-BFD2FCEC4A69@Sun.COM>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wednesday, 26 July 2006 06:59, Sam Falkner wrote:
> On Jul 25, 2006, at 2:15 PM, Andreas Gruenbacher wrote:
> >> But let's pretend that all NFSv4 clients do support the ACL
> >> attribute.  Having the chmod command unable to set the mode was a
> >> source of many customer complaints when that was the behavior in
> >> Solaris (http://xrl.us/pd7c and http://xrl.us/pd7b are just two
> >> examples of bugs).  The Solaris chmod command was fixed to alter the
> >> POSIX-draft ACL (in file systems that support POSIX-draft ACLs), so
> >> that chmod was actually able to change the mode.  Since making this
> >> change to chmod, complaints have stopped.
> >
> > Maybe nobody explained to users how to properly use ACLs to prevent
> > this from happening? The behavior of Solaris chmod(1) is a potential
> > security hole, although a small one only.
>
> I remind you that in NFSv4, ACL is not a required attribute.

I think this point has already become clear, but just so that it doesn't 
appear as if I'm selectively ignoring your arguments, let me reiterate:

I did not miss the fact that NFSv4 implementations may choose not to implement 
the ACL attribute. In the mapping I am proposing, the mode attribute always 
reflects the file mode permission bits. On a POSIX server that doesn't 
support the ACL attribute, the mode attribute represents the file mode 
permission bits which determine access.

On the other hand, a server which does support the ACL attribute, the ACL may 
induce further restrictions on the permissions granted by the mode attribute. 
In case any alternate ACE mode bits are set which are not disabled, the ACL 
may also grant permissions that go beyond the file mode permission bits.

[For servers that don't support the ACL attribute, it obviously also makes no 
sense to support file masks.]

> >> So, if we were to do as your proposed design says, and have
> >> MODE4_RGRP, etc., not reflect the mode, then once again, we would
> >> have to modify the chmod command to do more than the chmod() system
> >> call.  This is madness.
> >
> > This is not what I am proposing at all.
> >
> >> Or, we could simply have MODE4_RGRP, etc., reflect the mode of the
> >> file.
> >
> > This *is* what I am proposing. A mode SETATTR also affects which
> > permissions are effective in the ACL and which must be disabled, though.
> > Both proposals disable permissions, but they do so using different
> > mechanisms: your proposal introduces DENY ACEs spread throughout the
> > ACL. My proposal sets masks, which are only applied in the access check
> > algorithm. I argue that simply updating the masks is a much nicer way of
> > achieving the same effect, and that it avoids the problems inherent to
> > those DENY ACEs.
> >
> >>> Algorithm 5.6.3. is at least problematic because it enforces
> >>> implementing masking of permissions using DENY ACEs, while an
> >>> alternative design exists that achieves the same effects without the
> >>> disadvantages of those DENY ACEs.
> >>
> >> That alternative introduces a new file attribute, which causes
> >> problems for NFSv4.0, and for Windows servers.
> >
> > That's not true. There are several ways how we can deal with clients
> > that do not understand masks:
>
> You just ignored my comment about Windows servers.

Not on purpose. I'll assume that your comment is that Windows servers do not 
(and probably will not) support the proposed file_masks attribute, which is 
pretty much the same situation as with NFSv4 (RFC3530) servers that also 
don't support this attribute.

On such a server, nothing prevents users from setting arbitrary ACLs. POSIX 
applications running on the client may chmod files, which maps to mode 
SETATTR calls. Because RFC3530 does not define the interaction between a mode 
SETATTR and the ACL attribute, those servers obviously are not guaranteed to 
implement strict POSIX semantics.

We could map a chmod to an ACL GETATTR, inject DENY ACEs on the client side as 
required, and then set both the new mode and the modified ACL. This would 
give us pretty good POSIX semantics, but implementing this hack on the client 
side sounds pretty ugly to me.

Is this what you were envisioning?

I believe that a more sane approach would be to accept that non-POSIX NFSv4 
servers will not have strict POSIX semantics, and live with the fact.

Andreas

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
