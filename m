From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 00:50:57 +0200
Message-ID: <200607110050.57449.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<200607091822.44656.agruen@suse.de>
	<B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Sam Falkner <Sam.Falkner@sun.com>, Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <spencer.shepler@sun.com>,
	nfs@lists.sourceforge.net, Lisa Week <Lisa.Week@sun.com>
Return-path: <nfsv4-bounces@ietf.org>
To: nfsv4@ietf.org
In-Reply-To: <B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Monday, 10. July 2006 15:29, Sam Falkner wrote:
> On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:
> > On Saturday, 8. July 2006 05:45, Sam Falkner wrote:
> >> On Jul 7, 2006, at 5:55 AM, Andreas Gruenbacher wrote:
> >>> On Monday, 3. July 2006 23:10, Andreas Gruenbacher wrote:
> >>>> Hello,
> >>>>
> >>>> I have been thinking about the problems of interaction between
> >>>> NFSv4 ACLs and POSIX, and particularly about the issue of masking
> >>>> permissions through chmod and after creating files or directories.
> >>>
> >>> Here is a follow-up after some personal feedback from Sam. I
> >>> believe that draft-ietf-nfsv4-acls-00 is not ready to become part
> >>> of the
> >>> NFSv4 Minor Version 1 RFC: some assumptions are not correct from
> >>> a POSIX
> >>> point of view, and the way how chmod and file create modes are
> >>> applied to
> >>> NFSv4 ACLs is weak and not guaranteed to be correct.
> >>
> >> I disagree -- see below.
> >
> > Here are some facts to back my points: Let's assume that a file
> > inherits the
> > following ACL when being created (I am using ^(...) here with the
> > meaning of
> > "all bitflags except ..."):
> >
> > 	OWNER@:READ_DATA/WRITE_DATA::ALLOW
> > 	OWNER@:^(READ_DATA/WRITE_DATA)::DENY
> > 	GROUP@:READ_DATA::ALLOW
> > 	user@domain:READ_DATA/WRITE_DATA::ALLOW
> > 	GROUP@:^READ_DATA::DENY
> > 	user@domain:^(READ_DATA/WRITE_DATA)::DENY
> > 	EVERYONE@:READ_DATA::ALLOW
> >
> > This acl is "well structured" in the POSIX sense: OWNER@ will only
> > get the
> > owner permissions and none of the other permissions, user@domain
> > and GROUP@
> > will only get the permissions intended for them, and only others
> > (neither
> > OWNER@ nor user@domain nor GROUP@) will get EVERYONE@ permissions;
> > in other
> > words, the acl is even correct for non-monotonic permissions.
> >
> > According to section 5.1 of draft-ietf-nfsv4-acls [1], the
> > resulting file mode
> > permission bits for this acl shall be rw-r--r--.
>
> Your proposal would give this mode: rw-rw-r--.  I think we should
> consider this more carefully.
>
> > After a chmod or a file
> > create, alternate file access control mechanisms must be disabled
> > and only
> > additional file access control mechanisms may remain active.
> > According to
> > POSIX, additional file access control mechanisms require that no
> > user may be
> > granted more permissions than the respective file classes permit.
> > In this
> > case, user@domain clearly is not in the File Owner Class.
> > (According to
> > POSIX, user@domain must be in the File Group Class.) The
> > user@domain user is
> > granted WRITE_DATA though, which is *incorrect* from a POSIX point
> > of view.
>
> No, it is not granted WRITE_DATA after a chmod().  After a chmod 644,
> there will be a "user@domain:WRITE_DATA::DENY" prepended.  This is
> well defined in the current minorversion1.  So it is not "incorrect
> from a POSIX point of view."

Now that I look at the example again, I realize that I didn't define the 
create mode. With create mode 640 or less permissive, everything is fine. 
Let's assume create mode 664 though: then the file mode permission bits will 
still come out as rw-r--r--, but the ACL will grant WRITE_DATA to 
user@domain. That's the case I meant, and this case is not POSIX compliant.

> If your problem is with the computation of the mode, then we can
> discuss this some more.  But following create or chmod, user@domain
> is not granted WRITE_DATA.

My problems are these:

* the algorithm in 5.3 is based on an ACE classification closer to the one
  I proposed, while the algorithm in 5.1 is based on a different
  classsification. We need to straighten this out, and I have argued
  repeatedly now why the classification I proposed leads to consistent
  and correct results. Most of the little inconsistencies in
  draft-ietf-nfsv4-acls-00 will stick out quite clearly once we agree on
  the right classification, and they will be easy to fix.

* the DENY entries introduced to mask permissions bloat the ACL, and make
  the ACL look strange to non-POSIX systems. The algorithm in section 5.3
  may remove permissions from user-provided DENY entries in some cases,
  and it may introduce duplicate DENY entries in some situations such as
  when another system reorders ACEs.Some versions of Windows do that.

The alternative approach I am proposing has a clear classification of ACEs, 
separates the orthogonal aspects of classification vs. well-formed acls, and 
has none of the weaknesses that the mask DENY ACEs cause.

> > Next, let's assume than an ACL contains the following pair of user-
> > provided entries:
> >
> > 	GROUP@:WRITE_DATA::DENY
> > 	GROUP@:READ_DATA::ALLOW
> >
> > Clearly the user's intention is to deny WRITE_DATA access to GROUP@.
>
> Yes, that *was* the user's intention, at the time the user set the ACL.

Hm... not the best example because GROUP@ is the owning group, which 
corresponds to the group file mode permission bits in traditional POSIX. The 
problem is more difficult to see in this case, but I argue that the owhning 
group permissions and the group file mode permission bits are not the same
with ACLs: the file group mode permission bits restrict GROUP@ entries, and 
all user@domain and group@domain entries in the acl. For the sake of this 
example, substitute GROUP@ with user@domain though, and you'll see the 
problem more clearly: a user adds an explicit user@domain:WRITE_DATA::DENY 
entry to an acl which is followed by a user@domain:READ_DATA::ALLOW entry. 
After a chmod to 664 for example, this user suddenly has write access. The 
user clearly did not intend this to happen.

> > The algorithm to apply a mode to an existing ACL will remove the
> > WRITE_DATA bit
> > from the GROUP@:WRITE_DATA::DENY entry when a chmod(..., 0770) is done
> > though. This is counter to the user's intention, so I would call
> > that *wrong*
> > as well.
>
> You would call it wrong that a chmod 770 would allow WRITE_DATA to
> members of the file's owning group?!  The  user did a chmod -- the
> user changed the permissions on the file!

Yes. The user set the group file mode permission bits to rwx, in other words, 
ACEs in the File Group Class are limited to rwx after that. This does not 
imply that GROUP@ ACEs automatically have the equivalent of rwx though: the 
File Group Class contains several ACL entries, and you want to control the 
group file mode permission bits independently from the permissions of the 
owning group: otherwise, it wouldn't be possible to give the owning group 
fewer permissions than any user@domain or group@domain entry.

Let's look at this ACL:

	OWNER@:READ_DATA/WRITE_DATA::ALLOW
	GROUP@:READ_DATA::ALLOW
	user@domain:READ_DATA/WRITE_DATA::ALLOW
	EVERYONE@:READ_DATE::ALLOW

The GROUP@ and user@domain entries are in the File Group Class. After a chmod 
to 664, the ACL changes to this in Sam's proposal (some unnecessary 
permissions left out):

	OWNER@:EXECUTE::DENY
	OWNER@:READ_DATA/WRITE_DATA::ALLOW
	GROUP@:EXECUTE::DENY
	GROUP@:READ_DATA::ALLOW
	user@domain:EXECUTE::DENY
	user@domain:READ_DATA/WRITE_DATA::ALLOW
	EVERYONE@:WRITE_DATA/EXECUTE::DENY
	EVERYONE@:READ_DATE::ALLOW

In my proposal, the ACL would remain the same as before the chmod, but the 
owner_class_mask would become READ_DATA/WRITE_DATA, the group_class_mask 
would become READ_DATA/WRITE_DATA, and the other_class_mask would become 
READ_DATA. Note that the ACL does *not* grant write access to GROUP@ in 
either case.

> This is not a POSIX flaw, and this is not a design flaw of any kind.
> "chmod 770" grants the owning group permission to write the file,
> period.

No, see above. chmod 770 grants the File Group Class rwx, but ACLs act as an 
additional file access control mechanism here, and further limit the 
permissions granted to the owning group, which is a member of the File Group 
Class.

> > It also violates the principle of least surprise.
>
> Are you kidding?

I did not mean to.

> Consider a directory with this ACE in its ACL: 
> GROUP@:READ_DATA/WRITE_DATA:FILE_INHERIT:DENY
>
> With your proposal, open("foo", O_CREAT | O_RDWR, 0666) in this
> directory creates a file that the owning group is denied read and
> write permission.  Then:
>
> % chmod 664 foo
>
> Oops, owning group *still* cannot read or write the file!  Linux/*NIX
> has a long history of files having a mode attribute, and users using
> chmod to set permissions -- but not much history with NFSv4 ACLs.

To counter that argument, UNIX systems, including and foremost Solaris, but 
also others like Linux, have had POSIX ACLs for quite some time, and there 
the same "chmod doesn't fix my file" case exists, and it hasn't been a 
problem at all.

The GROUP@:READ_DATA/WRITE_DATA:FILE_INHERIT:DENY ace is a clear case of 
"doctor it hurts when I do this". As is an EVERYONE@:*::DENY ACL entry.

> Your proposal more or less requires that Linux/*NIX users immediately
> start using ACLs, or face the "chmod doesn't fix my file" problem.

Chmod by definition *cannot* fix all permission problems in the presence of 
ACLs unless it completely replaces the ACL with something like the six-entry 
acl pattern in draft-ietf-nfsv4-acls-00. We already know that it's not a good 
idea to have chmod destroy acls.

> I've spent quite some time over the last few days looking for flaws
> in your proposal, but I'll admit that I missed this one, and it's a
> big one.

May I ask you to come back to this issue in case you still feel the same way 
after this reply?

> > There really is no safe way to tell user-provided ACL entries from
> > artificially made up ACL entries.
>
> The semantics in draft-ietf-nfsv4-acls are well defined, predictable,
> consistent, and reasonable.

"Well defined": for one thing, draft-ietf-nfsv4-acls-00 is not explicit or 
clear about the ACE classification it is based on.

"Predictable": probably yes.

"Consistent": it uses different classifications in sections 5.1 and 5.3. 

"Reasonable": I don't like the DENY ACEs at all but that's a matter of taste. 
The problems which the DENY ACEs cause are no matter of taste though, and I 
would call the design unreasonable for that reason. Enforcing the DENY ACEs 
on thers when an alternative design exists that avoids the known problems 
that they have does not seem very reasonable to me, either.

The two proposals have two fundamental differences:

* My proposal tries to be clear in semantics, and separates orthogonal
  aspects from each other. draft-ietf-nfsv4-acls-00 has a number of
  weaknesses when it comes to clarity of semantics. I am positive that
  we will manage to clarify all these areas in draft-ietf-nfsv4-acls-00.
  At that point, the *only* essential difference that will remain between
  the two proposals will be that

* draft-ietf-nfsv4-acls-00 uses DENY ACL entries for masking permissions,
  while my proposal uses explicit mask attributes.

> > draft-ietf-nfsv4-acls is missing a clear classification of ACL
> > entries into the File Owner, File Group, and File Other classes. Every
> > ACL entry must be in one of the three classes in order to compute
> > appropriate file mode permission bits when setting an ACL, and after
> > inheriting permissions. This classification also determines which effect
> > chmod will have on an ACL. 
>
> I assume you mean "every ACE", not "every ACL".

	every ACL entry == every ACE

> As I mentioned above, I'm not sure whether or not this is a requirement,
> but it can be discussed further.

How else can a chmod 700 disable all but the owner permissions, a chmod 770 
disable all "others" to have access, and a chmod 000 disable all permissions 
if you don't know which ACEs each class applies to?

> However, if it turns out that draft-ietf-nfsv4-acls is wrong in this regard,
> then the only consequence is a minor change to 5.1.

I hope I can also convince you that the DENY entries to mask permissions are a 
really bad idea.

> > So draft-ietf-nfsv4-acls is *incorrect* and *wrong* from a POSIX
> > point of
> > view, while my alternative proposal is correct, apart from being
> > simpler to
> > implement. I hope that my emails and some background reading (like
> > the file
> > access related parts of the POSIX definitions volume [5], a paper that
> > explains POSIX ACLs and how they are implemented on Linux [6], and
> > perhaps
> > 1003.1e draft 17) will convince you about that.
>
> I am absolutely not convinced.

I would still recommend that you read [6] at least.

Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
