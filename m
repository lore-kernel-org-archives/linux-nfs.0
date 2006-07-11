From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 02:15:53 +0200
Message-ID: <200607110215.53496.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<20060710141541.GA978@fieldses.org>
	<1A2FAFA9-0B94-48FA-8B0B-2A8AC0BE0331@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Lisa Week <Lisa.Week@sun.com>,
	Sam Falkner <Sam.Falkner@sun.com>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>
Return-path: <nfsv4-bounces@ietf.org>
To: nfsv4@ietf.org
In-Reply-To: <1A2FAFA9-0B94-48FA-8B0B-2A8AC0BE0331@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Monday, 10. July 2006 17:32, Sam Falkner wrote:
> On Jul 10, 2006, at 8:15 AM, J. Bruce Fields wrote:
> > On Mon, Jul 10, 2006 at 07:29:56AM -0600, Sam Falkner wrote:
> >> On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:
> >>> According to section 5.1 of draft-ietf-nfsv4-acls [1], the
> >>> resulting file mode
> >>> permission bits for this acl shall be rw-r--r--.
> >>
> >> Your proposal would give this mode: rw-rw-r--.  I think we should
> >> consider this more carefully.
> >
> > As Andreas says, this is what the posix draft would have you do.  It's
> > also what Linux (and, I assume, Solaris) do in the case of posix ACLs.
>
> Not on Solaris.  With POSIX-draft ACLs, adding user:friend:rw- to a
> mode rw-r--r-- file still gives you rw-r--r--.  (And as you point out
> later, these ACLs ain't POSIX.)

Indeed, they are only pretty close. One other difference is that Solaris POSIX 
ACLs are always four-entry on some (all?) file systems, while Draft 17 ACLs 
as implemented on Irix, FreeBSD, Linux, and possibly others support 
three-entry ACLs as well (they are equivalent to the file mode permission 
bits.)

It would be bad to repeat the mistake of breaking POSIX assumptions.

> I think having chmod be functional, i.e. chmod 770 gives write
> permission to the owning group, and an "ls -l" shows "rwxrwx---",
> would be best by far.

It screws you when you want to give the owning group fewer permissions than 
other users in the File Group Class. This can be worked around by creating a 
dummy group with no members, or one group that only contains a single user 
for each user, and changing the owning group of files, but the owning group 
already has other defined uses in POSIX (think of SETGID for files and 
directories), and so it's not desirable and not always possible to change the 
owning group to such a dummy group.

Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
