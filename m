From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS4 ACL <-> Posix ACL
Date: Tue, 24 Mar 2009 18:21:00 -0400
Message-ID: <20090324222100.GP19389@fieldses.org>
References: <7f62dcb30903181042n42bae0bbk99f5c91fce6e9e82@mail.gmail.com> <20090319193514.GE3072@fieldses.org> <7f62dcb30903230646u183c79e0i4366edebe32654d5@mail.gmail.com> <20090323213304.GG1067@fieldses.org> <7f62dcb30903231856h7a17cea5ud7a22796ddfb6383@mail.gmail.com> <20090324201002.GF19389@fieldses.org> <1237931047.7516.15.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Bremer <albremer@googlemail.com>, linux-nfs@vger.kernel.org,
	Andreas Gruenbacher <agruen@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:33328 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754944AbZCXWVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2009 18:21:04 -0400
In-Reply-To: <1237931047.7516.15.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 24, 2009 at 05:44:07PM -0400, Trond Myklebust wrote:
> On Tue, 2009-03-24 at 16:10 -0400, J. Bruce Fields wrote:
> > On Tue, Mar 24, 2009 at 02:56:25AM +0100, Alex Bremer wrote:
> > > 2009/3/23, J. Bruce Fields <bfields@fieldses.org>:
> > > >> So is there any way to make newly created files group writeable except
> > > >> for setting the umask of each user to 002?
> > > >
> > > > I think that's the only option.
> > > >
> > > > And that looks hard to fix; if we were going to implement the same
> > > > "inheritance overrides umask" exception as we do for posix acls, either:
> > > >
> > > > 	- The server would have to know about the umask; this would
> > > > 	  require a protocol change.  (But it might not be that hard;
> > > > 	  you could have a write-only "set the mode to this, but only in
> > > > 	  the absence of inheritance" attribute.)
> > > > 	- The client would have to do the inheritance itself, as it does
> > > > 	  with posix acls.  This is perhaps not impossible, but it's
> > > > 	  much more complicated with v4 acls.
> > > >
> > > > Hm.  Another odd option: do the open with the create mode + umask, as we
> > > > currently do, then do a subsequent setattr to the create mode if the
> > > > create mode is more generous and if the client detects inheritable acls
> > > > on the parent directory.
> > > 
> > > Why so complicated? Of course these options would be the nicest way to
> > > do it as it allows to set different permission inheritances on each
> > > directory. However for many use cases it would be enough if one could
> > > set the permissions on a share basis. A simple umask mount-option
> > > would already help a lot. This way administrators could enforce a
> > > umask on a share.
> > 
> > I don't know what to think of a umask mount option.  That's a question
> > for Trond.
> 
> Ugh, no. We already have too many mount options, and this suggestion
> doesn't even fix any problems.
> 
> The correct thing to do is to check for acl support on the server, and
> then check directories for inheritance aces before we decide to create a
> file.

OK, so if we find an inheritable ace on the file, then we just skip
sending the umask in the mode that's sent on open.

The only objection I could see also applies to the current posix code:
there's a small race allowing the file create to be done with stale
information from the parent directory.

> The existing 'noacl' mount option could then turn off this type of check
> in cases where the administrator doesn't care to follow inheritance
> rules...

OK.

For now this falls into the category of patches I'd happily shepherd
along if someone else would write them.  Shouldn't be too hard to write
though.

--b.
