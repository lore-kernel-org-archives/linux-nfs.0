From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 10 Jul 2006 23:09:31 +0200
Message-ID: <200607102309.31515.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
	<6C45838C-9240-4422-AFCC-A65173D763DB@Sun.COM>
Reply-To: nfsv4@ietf.org
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Cc: Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <spencer.shepler@sun.com>,
	nfs@lists.sourceforge.net, nfsv4@ietf.org
Return-path: <nfsv4-bounces@ietf.org>
To: Lisa Week <Lisa.Week@sun.com>
In-Reply-To: <6C45838C-9240-4422-AFCC-A65173D763DB@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

Lisa,

On Saturday, 08 July 2006 08:51, Lisa Week wrote:
> Hi Andreas,
>
> I have a couple additional questions and comments.  See those inline...
>
> [...]
>
> For example, if we have the following ACL:
>      lisa@sun.com:ACE4_WRITE_ACL:deny
>
> 		or even
>
>      lisa@sun.com:ACE4_WRITE_OWNER:allow
>
> Upon chmod we would have to disable them (however an implementation
> chooses to) and effectively remove it.

In my proposal with the owner_class_mask, group_class_mask, and 
other_class_mask attributes, the chmod does not remove any mask bits from the 
ACEs, it sets the mask attributes to reflect the chmod mode parameter. The 
permission check algorithm only considers the effective permissions. So the 
mask attributes define which permissions are enabled and which are disabled.

> The thing that I have a problem with here is the fact that the
> changing of the file permission bits will affect what access has been
> defined in the ACL for things such as ACE4_WRITE_OWNER,
> ACE4_WRITE_ACL, etc.  A user setting the file permission bits is not
> saying anything about what they want to be done with any ACEs that
> include the ACE4_WRITE_OWNER mask bit.  Why would we want to mess
> with them?

It's quite simple: ACE4_WRITE_OWNER is an alternate access control mechanism 
under POSIX, no matter how we look at it. POSIX says that a chmod must disable 
alternate access control mechanisms, and it says that additional access 
control mechanisms may only introduce further restrictions. So a chmod will 
disable ACE4_WRITE_ACL and ACE4_WRITE_OWNER access, in both proposals.

> 2.) So, what if an ACE contained a mixture of the access mask bits
> that are alternate and additional?
>
> Would we allow having ACE4_READ_DATA and ACE4_WRITE_ACL in the same
> ACE?  What would happen to an ACE such as this upon chmod?

Of course we allow such ACEs. In fact, any NFSv4 ACL is allowed(*). Chmod does 
not touch the ACL, it adjusts the mask attributes so that only bits allowed 
by the respective class (File Owner Class, File Group Class, File Other 
Class) will be set in the mask attributes. Because only bits set both in an 
ACE and in the associated mask attribute are effective, all other permissions 
will automatically be disabled. Your proposal achieves the same effect by 
prepending ALLOW entries with DENY entries that deny masked permissions.

(*) See the well-formed ACLs and non-monotonic permissions discussion in the 
previous mails for why we may want to enforce a specific form of ACLs for 
full POSIX compliance, and in which conditions this matters.

> I'll restate it because it is important: EVERYONE@ is not equivalent
> to the File Other Class.  I believe the original intention was to
> have it be equivalent to one the Windows "well known sid":   http://
> msdn.microsoft.com/library/default.asp?url=/library/en-us/secauthz/
> security/well_known_sid_type.asp

EVERYONE@ in NFSv4 ACLs indeed matches EVERYONE@ in Windows ACLs.

> Really with NFSv4 ACLs, the only way we have the equivalent of a File
> Other Class is if the EVERYONE@ entries come at the end of the ACL.

Again, that's what I discussed as part of well-formed ACLs and non-monotonic 
permissions. Think of it this way:

We classify ACEs as follows:

  - OWNER@ entries and user@domain entries for the user who currently owns
    a file are in the File Owner Class,

  - EVERYONE@ entries are in the File Other Class,

  - all other entries are in the File Group Class.

Well-formed NFSv4 ACLs include DENY entries which make sure that the 
permissions granted to each class (File Owner Class, File Group Class, File 
Other Class) are isolated, and permissions granted to one class will not 
"swap over" to another class. In particular, this means that nobody in the 
File Owner and File Group classes will be granted any permissions from an 
EVERYONE@ ACE.

Arbitrary NFSv4 ACLs are not "well-formed" in this sense. They do not isolate 
the classes, and permissions from several classes may accumulate.

So, for strict POSIX compliance, we much make sure that ACLs are well-formed 
if both is true:

 - they are inherited or chmod'ed

 - and the mask applied to the ACL is non-monotonic

In all other cases (when an ACL is set, or when the permissions are monotonic) 
we will still be within the bounds of POSIX, and so we don't need to care.

So I'll restate that EVERYONE@ entries *are* in the File Other Class. Whether 
or not permissions may "swap over" from one class to another is determined by 
whether or not an ACL is "well-formed". This is an aspect orthogonal to the 
classification, to be dealt with separately. No other classification can fix 
the well-formedness aspect.

> Again, EVERYONE@ is not equivalent to the File Other Class.
> Depending on where an ACE pertaining to EVERYONE@ is in the ACL, it
> could even refer to the owner and the owning group.

Wrong in my opinion: with an ACL that simply consists of a single EVERYONE@ 
ACE, the other permissions will apply to all classes, but that's because the 
ACL is not well-formed, not because EVERYONE@ is classified wrong.

> Sorry, but I don't think I understand.  Andreas, what do you mean by
> "Alternate" permissions in that sentence?

Here is a table of NFSv4 ACL mask bits and their classification. Mask bits are 
classified as Additional if they are either always permitted under POSIX 
(indicated as None in the table), or if they are equivalent to or a subset of 
a POSIX permission (indicated as Read, Write, Execute in the table). Mask 
bits are classified as Alternate if POSIX permissions cannot grant this 
permission (e.g., the equvalent of WRITE_ACL is implicitly granted to the 
owner, but there is no way to grant WRITE_ACL to an arbitrary other user).

READ_DATA               Additional (Read)
LIST_DIRECTORY          Additional (Read)
WRITE_DATA              Additional (Write)
ADD_FILE                Additional (Write)
APPEND_DATA             Additional (Write)
ADD_SUBDIRECTORY        Additional (Write)
READ_NAMED_ATTRS        Additional (Read) (**)
WRITE_NAMED_ATTRS       Additional (Write) (**)
EXECUTE                 Additional (Execute)
DELETE_CHILD            Additional (Write)
READ_ATTRIBUTES         Additional (None)
WRITE_ATTRIBUTES        Alternate
DELETE                  Alternate
READ_ACL                Additional (None)
WRITE_ACL               Alternate
WRITE_OWNER             Alternate
SYNCHRONIZE             Additional (None)

> It is unclear to me as to 
> what happens to the access mask bits outside of the following:
> (collectively, these are the access mask bits that make up the POSIX
> read, write and execute permissions)
> ACE4_READ_DATA, ACE4_READ_ATTRIBUTES, ACE4_READ_ACL, ACE4_SYNCHRONIZE
> ACE4_WRITE_DATA, ACE4_APPEND_DATA, ACE4_WRITE_ATTRIBUTES,
> ACE4_DELETE_CHILD and ACE4_EXECUTE
>
> The remaining ones are:
> ACE4_WRITE_ACL, ACE4_WRITE_OWNER, ACE4_DELETE, ACE4_READ_NAMED_ATTRS
> and ACE4_WRITE_NAMED_ATTRS

(**) I think that Read and Write imply ACE4_READ_NAMED_ATTRS and 
ACE4_WRITE_NAMED_ATTRS on Solaris, respectively, but I'm not sure. In case 
they are not, they would indeed count as Alternate.

> Are these "remaining ones" also given representation in the masks?

Yes. Alternate permissions must be subject to the mask attributes, because we 
must be able to disable them upon chmod and ACL inheritance. We can turn them 
back on later by setting the corresponding bitflags in the mask attributes 
(explicitly, or implicitly by setting a new ACL without also providing mask 
attributes, see further below).

POSIX does not require that alternate file access mechanisms be either on or 
off completely (i.e., an on/off switch); we are free to turn alternate 
permissions on or off individually. (We must turn them all off upon chmod and 
permission inheritance, but that should be clear by now.)

> Actually, I think what is confusing me is that before, when talking
> about Additional and Alternate file access control mechanisms, you
> said that: " All others with ACE4_WRITE_ACL, ACE4_WRITE_OWNER,
> ACE4_DELETE_CHILD, and ACE4_DELETE are alternate."
>
> I just wonder how that statement  relates to the statement that
> "Alternate permissions in the ACL can be enabled by either setting an
> ACL without providing full mask entries, or by setting the
> appropriate bit(s) in the corresponding mask entry or entries."

My proposal was that a SETATTR of ACL that does not also set the mask 
attributes should automatically set all unspecified mask attributes to the 
union of all the ALLOW ACEs in the respective class. In other words, when a 
NFSv4.0 client executes an ACL SETATTR, all the ALLOW permissions in the ACL 
will automatically get set in the respective mask attributes as well, and 
will be effective. POSIX allows this behavior.


Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
