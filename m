From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 02:01:42 +0200
Message-ID: <200607110201.43319.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
	<20060710141541.GA978@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Sam Falkner <Sam.Falkner@sun.com>, Lisa Week <Lisa.Week@sun.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>
Return-path: <nfsv4-bounces@ietf.org>
To: nfsv4@ietf.org
In-Reply-To: <20060710141541.GA978@fieldses.org>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Monday, 10. July 2006 16:15, J. Bruce Fields wrote:
> On Mon, Jul 10, 2006 at 07:29:56AM -0600, Sam Falkner wrote:
> > On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:
> > >According to section 5.1 of draft-ietf-nfsv4-acls [1], the
> > >resulting file mode
> > >permission bits for this acl shall be rw-r--r--.
> >
> > Your proposal would give this mode: rw-rw-r--.  I think we should
> > consider this more carefully.
>
> As Andreas says, this is what the posix draft would have you do.  It's
> also what Linux (and, I assume, Solaris) do in the case of posix ACLs.

We are not talking about the POSIX 1003.1e draft here, we are talking about 
the real POSIX standard.

> If the goals was compatibility with that posix draft, RFC3530 should
> have specified that owner, other, and group bits be kept in sync with
> (respectively) OWNER@, EVERYONE@, and the *maximum* of permissions given
> to any other entity, rather than with OWNER@, EVERYONE@, and GROUP@.

I argued why I think this is a misbelief, please scan for well-formed ACLs and 
non-monotonic permissions.

> > You would call it wrong that a chmod 770 would allow WRITE_DATA to
> > members of the file's owning group?!  The  user did a chmod -- the
> > user changed the permissions on the file!
>
> That is how posix acl's work; again, the group mode bit really
> corresponds to the mask, not to the group acl entry:
>
> 	bfields@pickle:~$ getfacl foo
> 	# file: foo
> 	# owner: bfields
> 	# group: bfields
> 	user::rw-
> 	user:bfields:r--
> 	group::r--
> 	mask::r--
> 	other::---
>
> 	bfields@pickle:~$ chmod 770 foo
> 	bfields@pickle:~$ getfacl foo
> 	# file: foo
> 	# owner: bfields
> 	# group: bfields
> 	user::rwx
> 	user:bfields:r--
> 	group::r--
> 	mask::rwx
> 	other::---
>
>
> Of course, "posix" acls aren't really posix, and we could do something
> else if seems simpler.  Neither behavior seems intuitive to me in all
> situations.

The issue is that you sometimes want to give the owning group fewer perissions 
than say, user:bfields in the above example. You can only do that by 
separating the owning group and mask permissions.

For this aspect of the problem (actually for all aspects except for those that 
the DENY entries cause because they are sometimes difficult or impossible to 
uniquely tell from other "ordinary" entries) it is totally irrelevant whether 
the mask is represented as a mask:: acl entry as in POSIX ACLs, as a series 
of DENY ACL entries, or as NFSv4 attributes.

(POSIX ACLs only need one mask entry because they can never grant more than 
rwx permissions anyway, and so the owner and other permissions are always 
identical to the owner and other file mode permission bits. That's no longer 
true with POSIX ACLs, and so there we also need mask entries for the owner 
and for others.)

Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
