From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS4 ACL <-> Posix ACL
Date: Mon, 23 Mar 2009 17:33:04 -0400
Message-ID: <20090323213304.GG1067@fieldses.org>
References: <7f62dcb30903181042n42bae0bbk99f5c91fce6e9e82@mail.gmail.com> <20090319193514.GE3072@fieldses.org> <7f62dcb30903230646u183c79e0i4366edebe32654d5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Alex Bremer <albremer@googlemail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38071 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757655AbZCWVdH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2009 17:33:07 -0400
In-Reply-To: <7f62dcb30903230646u183c79e0i4366edebe32654d5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 23, 2009 at 02:46:46PM +0100, Alex Bremer wrote:
> 2009/3/19, J. Bruce Fields <bfields@fieldses.org>:
> > On Wed, Mar 18, 2009 at 06:42:10PM +0100, Alex Bremer wrote:
> >> However on a client
> >> using NFS4, these Posix-ACLs don't seem to get mapped to NFS4-ACLs.
> >
> > Actually, they do; what's happening (I believe--this is partly just
> > memory based on last time I looked at something like this) is more
> > subtle: the umask is being overridden by inheritance in the v2/v3 case,
> > and not in the v4 case.
> >
> > Posix default acls are supposed to override the umask.  This is tricky
> > for NFS, since the umask isn't sent over the wire on file creation,
> > leaving the client and server no way to distinguish the create mode from
> > the umask.  The v2/v3 client currently works around this by doing the
> > whole inheritance calculation on the client (reading the directory's
> > acl, then explicitly setting the new child's acl based on it).  The v4
> > client doesn't do that.  So:
> 
> So is there any way to make newly created files group writeable except
> for setting the umask of each user to 002?

I think that's the only option.

And that looks hard to fix; if we were going to implement the same
"inheritance overrides umask" exception as we do for posix acls, either:

	- The server would have to know about the umask; this would
	  require a protocol change.  (But it might not be that hard;
	  you could have a write-only "set the mode to this, but only in
	  the absence of inheritance" attribute.)
	- The client would have to do the inheritance itself, as it does
	  with posix acls.  This is perhaps not impossible, but it's
	  much more complicated with v4 acls.

Hm.  Another odd option: do the open with the create mode + umask, as we
currently do, then do a subsequent setattr to the create mode if the
create mode is more generous and if the client detects inheritable acls
on the parent directory.

> Setting the umask to 002 is
> not an option for us, but all files in the public area have to be
> group writeable. Is there maybe a mount option to set the umask or a
> server sided option which enforces the group writeable flag?
> 
> I would expect that my use case is not that uncommon and that many
> companys have the exact same problem. Would the inheritance work if we
> used a fully NFS4-ACL compatible filesystem?

No, and I suspect non-linux servers all have similar behavior in this
respect.

> Is there any for Linux?

Not currently.

> How do other people share public files with NFS4? If there is no other
> way than setting the users's umask to 002, this would practically
> limit the use of NFS4 to private shares like home directories.

I don't understand why--can't you use the user-private-group trick?:

	http://www.redhat.com/docs/manuals/linux/RHL-7.3-Manual/ref-guide/s1-users-groups-private-groups.html

--b.
