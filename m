From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 10:45:43 +0200
Message-ID: <200607111045.43779.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<200607110050.57449.agruen@suse.de>
	<BCB7A126-5749-406A-A730-48B64C41402B@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>, nfsv4@ietf.org,
	Lisa Week <Lisa.Week@sun.com>
Return-path: <nfsv4-bounces@ietf.org>
To: Sam Falkner <Sam.Falkner@sun.com>
In-Reply-To: <BCB7A126-5749-406A-A730-48B64C41402B@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Tuesday, 11. July 2006 08:17, Sam Falkner wrote:
> On Jul 10, 2006, at 5:50 PM, Andreas Gruenbacher wrote:
> > On Monday, 10. July 2006 15:29, Sam Falkner wrote:
> >> On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:
> >>> On Saturday, 8. July 2006 05:45, Sam Falkner wrote:
> >>>> On Jul 7, 2006, at 5:55 AM, Andreas Gruenbacher wrote:
> >>>>> On Monday, 3. July 2006 23:10, Andreas Gruenbacher wrote:
> >>>
> >>> Here are some facts to back my points: Let's assume that a file inherits
> >>> the following ACL when being created (I am using ^(...) here with the
> >>> meaning of "all bitflags except ..."):
> >>>
> >>> 	OWNER@:READ_DATA/WRITE_DATA::ALLOW
> >>> 	OWNER@:^(READ_DATA/WRITE_DATA)::DENY
> >>> 	GROUP@:READ_DATA::ALLOW
> >>> 	user@domain:READ_DATA/WRITE_DATA::ALLOW
> >>> 	GROUP@:^READ_DATA::DENY
> >>> 	user@domain:^(READ_DATA/WRITE_DATA)::DENY
> >>> 	EVERYONE@:READ_DATA::ALLOW
> >>>
> >>> This acl is "well structured" in the POSIX sense: OWNER@ will only get
> >>> the owner permissions and none of the other permissions, user@domain
> >>> and GROUP@ will only get the permissions intended for them, and only
> >>> others (neither OWNER@ nor user@domain nor GROUP@) will get EVERYONE@
> >>> permissions; in other words, the acl is even correct for non-monotonic
> >>> permissions. 
> >>>
> >>> According to section 5.1 of draft-ietf-nfsv4-acls [1], the resulting
> >>> file mode permission bits for this acl shall be rw-r--r--.
> >>
> >> Your proposal would give this mode: rw-rw-r--.  I think we should
> >> consider this more carefully.
> >>
> >>> After a chmod or a file create, alternate file access control mechanisms
> >>> must be disabled and only additional file access control mechanisms may
> >>> remain active. According to POSIX, additional file access control
> >>> mechanisms require that no user may be granted more permissions than the
> >>> respective file classes permit. In this case, user@domain clearly is not
> >>> in the File Owner Class. (According to POSIX, user@domain must be in the
> >>> File Group Class.) The user@domain user is granted WRITE_DATA though,
> >>> which is *incorrect* from a POSIX point of view.
> >>
> >> No, it is not granted WRITE_DATA after a chmod().  After a chmod 644,
> >> there will be a "user@domain:WRITE_DATA::DENY" prepended.  This is
> >> well defined in the current minorversion1.  So it is not "incorrect
> >> from a POSIX point of view."
> >
> > Now that I look at the example again, I realize that I didn't
> > define the create mode. With create mode 640 or less permissive,
> > everything is fine. Let's assume create mode 664 though: then the file
> > mode permission bits will still come out as rw-r--r--, but the ACL will
> > grant WRITE_DATA to user@domain. That's the case I meant, and this case is
> > not POSIX compliant.
>
> Wrong.  The file mode permission bits will be rw-rw-r--.  There is no
> problem with POSIX compliance.

Ah. And why should that be according to draft-ietf-nfsv4-acls-00? Because the 
group file mode permission bits write through to GROUP@ entries, and so the 
rw- group permissions in the create mask elevate the permissions given to the 
owning group in the ACL?

I hope that my reply from Tue, 11 Jul 2006 10:05:21 +0200 made it clear that 
writing through to the GROUP@ entries causes POSIX applications to 
accidentally remove restrictions from an ACL, and so we really must not do 
that. The same argument applies to writing through to OWNER@ and EVERYONE@ 
entries, by the way. The "The final six ACEs are adjusted according to the 
incoming mode" section of the algorithm described in 5.3 is a really bad 
idea.

> >>> Next, let's assume than an ACL contains the following pair of user-
> >>> provided entries:
> >>>
> >>> 	GROUP@:WRITE_DATA::DENY
> >>> 	GROUP@:READ_DATA::ALLOW
> >>>
> >>> Clearly the user's intention is to deny WRITE_DATA access to GROUP@.
> >>
> >> Yes, that *was* the user's intention, at the time the user set the
> >> ACL.
> >
> > Hm... not the best example because GROUP@ is the owning group, which
> > corresponds to the group file mode permission bits in traditional
> > POSIX. The problem is more difficult to see in this case, but I argue
> > that the owhning group permissions and the group file mode permission
> > bits are not the same with ACLs: the file group mode permission bits
> > restrict GROUP@ entries, and all user@domain and group@domain entries
> > in the acl. For the sake of this example, substitute GROUP@ with
> > user@domain though, and you'll see the problem more clearly: a user
> > adds an explicit user@domain:WRITE_DATA::DENY entry to an acl which
> > is followed by a user@domain:READ_DATA::ALLOW entry. After a chmod to
> > 664 for example, this user suddenly has write access. The
> > user clearly did not intend this to happen.
>
> No -- after the chmod, the DENY still stands, unaltered.

Great Sam, you have trapped me with another special case that is there only 
because of those pesky mask DENY entries: "the mask bits are a subset of the 
mask bits of the current ACE" [1].

My point still holds, just that the following ALLOW ACE must have the denied 
WRITE_DATA permission set as well:

	user@domain:WRITE_DATA::DENY
	user@domain:READ_DATA/WRITE_DATA::ALLOW

Do you *still* disagree?

Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
