From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 7 Jul 2006 13:55:30 +0200
Message-ID: <200607071355.30624.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
Reply-To: nfsv4@ietf.org
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Sam Falkner <Sam.Falkner@sun.com>, Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <spencer.shepler@sun.com>, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@ietf.org>
To: nfsv4@ietf.org
In-Reply-To: <200607032310.15252.agruen@suse.de>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Monday, 3. July 2006 23:10, Andreas Gruenbacher wrote:
> Hello,
>
> I have been thinking about the problems of interaction between NFSv4 ACLs
> and POSIX, and particularly about the issue of masking permissions through
> chmod and after creating files or directories.

Here is a follow-up after some personal feedback from Sam. I believe that 
draft-ietf-nfsv4-acls-00 is not ready to become part of the NFSv4 Minor 
Version 1 RFC: some assumptions are not correct from a POSIX point of view, 
and the way how chmod and file create modes are applied to NFSv4 ACLs is weak
and not guaranteed to be correct.

I will first try to clarify some of the points I tried to make in the previous 
posting and point out deficiencies in draft-ietf-nfsv4-acls-00. Then I will 
propose an alternative design which is more correct than introducing DENY 
entries to mask permissions. (As a bonus, it is easier to implement. too.)

> On a UNIX system that supports NFSv4 ACLs natively, I think we should try
> to accept as wide a range of NFSv4 ACLs as possible, but we must make sure
> that we can preserve POSIX semantics. In particular, this means that ACLs
> may contain ACEs for users other than OWNER@, GROUP@, and EVERYONE@, and
> that chmod(2) must continue to provide the same kinds of guarantees as
> without NFSv4 ACLs.
>
> I am assuming here that NFSv4 ACLs shall be an additional rather than an
> alternate file access control mechanism in the POSIX sense: Alternate file
> access control mechanisms must ``be enabled only by explicit user action,
> on a per-file basis by the file owner or a user with the appropriate
> privilege'', and must ``be disabled for a file after the file permission
> bits are changed for that file with chmod( )'' according to POSIX. In other
> words, newly created files or directories would have alternate file access
> control mechanisms disabled. This would render NFSv4 ACLs essentially
> useless for UNIX processes, because they would almost always be disabled,
> and would only work for remote processes until a POSIX process chmods a
> file or creates a directory, which wouldn't get us very far.

As Sam pointed out, a subset of NFSv4 ACLs maps to an additional file access 
control mechanism, while the rest goes beyond that, and therefore is an 
alternate file access control mechanism.

It is important to understand how POSIX defines additional file access control 
mechanisms:

[] 3.4 Additional File Access Control Mechanism
[] An implementation-defined mechanism that is layered upon the access control
[]  mechanisms defined here, but which do not grant permissions beyond those
[]  defined herein, although they may further restrict them.

In other words, when a file has just been created and after chmod, the file 
mode permission bits define an upper bound to the permissions granted to 
anyone on the system, and nobody has additional permissions. Additional 
permissions (as an alternate file access control mechanism) may be 
enabled explicitly, but the next chmod must disable them again.

We can classify the permissions that NFSv4 ACLs grant into additional and 
alternate mechanisms as follows: everything covered by the POSIX 
read/write/execute permissions (such as ACE4_READ_DATA, but also 
ACE4_APPEND_DATA) is additional, while everything beyond that (such as 
ACE4_WRITE_OWNER) is alternate. Under this definition, all NFSv4 ACLs that 
grant no more than ACE4_READ_DATA, ACE4_LIST_DIRECTORY, ACE4_WRITE_DATA, 
ACE4_ADD_FILE, ACE4_APPEND_DATA, ACE4_ADD_SUBDIRECTORY, 
ACE4_READ_NAMED_ATTRS, ACE4_WRITE_NAMED_ATTRS, ACE4_EXECUTE, 
ACE4_READ_ATTRIBUTES, ACE4_WRITE_ATTRIBUTES, ACE4_READ_ACL, and 
ACE4_SYNCHRONIZE would count as additional access control mechanisms. All 
others with ACE4_WRITE_ACL, ACE4_WRITE_OWNER, ACE4_DELETE_CHILD, and 
ACE4_DELETE are alternate.

As said already, the POSIX file mode permission bits define the permissions of 
three classes: owner, group, and other. An additional file access control 
mechanism may only further restrict the permissions granted to those classes.

To map NFSv4 ACLs to an additional file access control mechanism,

 - we must map each NFSv4 ACL entry to exactly one of the three classes.

 - we must ensure that the ACL does not grant any permissions that go beyond
   the class permissions after a chmod or create.

 - in particular, we must ensure that the ACL grants no "alternate"
   permissions after a chmod or create.

We are free to provide mechanisms by which more permissions may be enabled by 
explicit user action, on a per-file basis by the file owner or a user with 
the appropriate privilege, according to POSIX.

The POSIX definitions of the three file permission classes are:

[] 3.173 File Owner Class
[] The property of a file indicating access permissions for a process related
[] to the user identification of a process. A process is in the file owner
[] class of a file if the effective user ID of the process matches the user ID
[] of the file.

[] 3.166 File Group Class
[] The property of a file indicating access permissions for a process
[] related to the group identification of a process. A process is in
[] the file group class of a file if the process is not in the file owner
[] class and if the effective group ID or one of the supplementary group
[] IDs of the process matches the group ID associated with the file. Other
[] members of the class may be implementation-defined.

[] 3.172 File Other Class
[] The property of a file indicating access permissions for a process related
[] to the user and group identification of a process. A process is in the file
[] other class of a file if the process is not in the file owner class or file
[] group class.

The key fact in these definitions is that an implementation may define 
additional members of the File Group Class, while the other classes are not 
extensible.

Under this definition, we end up with the following mapping:

 - OWNER@ entries are in the File Owner Class,
 - EVERYONE@ entries are in the File Other Class,
 - every other entry is in the File Group Class(*).

 (*) User entries for the user who is the current file owner are a special
     case: due to how the NFSv4 ACL permission check algorithm is specified,
     I believe that they should be put in the OWNER@ class.

> Note that this definition is in line with POSIX 1003.1e draft 17 [2], while
> it conflicts with the IETF NFS Version 4 ACLs draft [1], which associates
> only GROUP@ entries with the group file mode permission bits in section
> 5.1. The relevant text of IETF NFS Version 4 ACLs draft [1] is also found
> in NFSv4 Minor Version 1 [4].

Section 5.1 of [1] needs to be fixed: we must set the permission bits so that 
they are a superset of the permissions of all the entries in the respective 
class. (We cannot represent permissions that are not supersets of 
POSIX read, write, execute in the class, but that is not a problem, as we will 
see later.)

Non-monotonic permissions
=========================

Note that with arbitrary NFSV4 ACLs, the permissions granted to a process from 
multiple ACL entries will accumulate. This means that permissions across 
multiple classes may accumulate as well. This can be prevented with DENY 
entries in the ACL, e.g.,

	OWNER@:mask1::ALLOW
	OWNER@:^mask1::DENY
	user@domain:mask2::ALLOW
	group@domain:mask3:ACE4_IDENTIFIER_GROUP:ALLOW
	user@domain:^mask2::DENY
	group@domain:^mask3:ACE4_IDENTIFIER_GROUP:DENY
	EVERYONE:mask4::ALLOW

This means that we will not have to deal with this special case when computing 
the file mode permission bits, and we can achieve consistency by forcing ACLs 
to be "well structured".

We could also leave this as an implementation consideration: ACLs which are 
not "well structured" in the above sense will grant permissions that go 
beyond what an additional access control mechanism may grant *only* for 
non-monotonic file mode permission bits. With non-monotonic I mean file mode 
permission bits which grant more permissions to the group class than to the 
owner class, or more permissions to the other class than to the group class. 

> We want chmod(2) to be non-destructive, so that a chmod to a more
> restrictive mode and back to the original mode will leave the file with the
> same permissions as before the changes.
>
>[...]
>
> POSIX ACLs have solved the non-destructiveness problem by introducing a
> mask ACL entry: the mask entry applies to all group class entries, and
> defines an upper bound to the permissions those entries may grant. POSIX
> ACLs only have ACL entries that allow permissions, and only specify READ,
> WRITE, and EXECUTE permissions. Therefore, the owner class and other class
> permissions are the permissions granted to the owner and to others,
> respectively. (Note the difference between these others and NFSv4's
> EVERYONE@ special identifier).
>
> The mask concept is not part of NFSv4 ACLs. Marius A. Eriksen and others
> have proposed to emulate the POSIX ACL mask entry by prepending (with
> exception of OWNER@ and EVERYONE@ ACEs) each ALLOW ACE with a DENY ACE for
> the same user, group, or special identifier as in the ALLOW ACE. The
> permissions in the DENY ACE are set so that the entry denies the
> permissions not granted by the mask.

Internet draft-ietf-nfsv4-acls-00.txt [1] uses the same mechanism to implement 
masking.

> Unless we accept a very specific form of NFSv4 ACLs only (which would
> contradict the goal stated at the top of this message, and which would mean
> that interoperability with anything but POSIX ACLs would become difficult),
> there is no easy way to tell DENY entries introduced to emulate the mask
> from DENY entries added by hand. This has two potential consequences:
>
>  - First, if we fail to identify such a mask-emulation DENY entry, we may
> end up inserting another such entry. We might end up doing so repeatedly.
>
>  - Second, we may take a user-provided DENY entry for a mask-emulation DENY
> entry, and clear mask bits from that entry. This would contradict the
> user's intention. So the approach of inserting mask-emulation DENY entries
> is not good enough in general. (Mapping between NFSv4 and POSIX ACLs does
> not have this problem, because POSIX ACLs don't have DENY ACEs.)

Therefore, the mechanism described in section 5.3 is not suitable for our 
purposes, and we need to replace it with something better.

> In my opinion, there are two possible solutions for this problem: we can
> (1) devise a special kind of NFSv4 ACL entry that we will recognize as mask
> entry, or (2) give the owner/group/other class permission bits higher
> priority than the ACL entries, and only allow permissions that are allowed
> by both the ACEs and their associated classes.

A third option exists as well which fits in very well with POSIX and can be 
implemented in NFSv4 in a backward compatible way.

Alternative Proposal
====================

Instead of adding DENY entries to the ACL for the purpose of masking, attach 
three optional attributes to each file: owner_class_mask, group_class_mask, 
and other_class_mask. When those attributes are present, they define which 
permissions in an ACE are effective.

Each ACE is is restricted by one of these mask attributes in each access 
check:

 - OWNER@ entries and entries for the user@domain that currently owns the file
   are restricted by owner_class_mask.

 - EVERYONE@ entries are restricted by other_class_mask.

 - All other entries are restricted by group_class_mask.

The effective permissions are computed as the bitwise and (&) of the ACE mask 
and the associated class_mask attribute.

When doing a chmod(2) or when applying a create mask, the owner_class_mask, 
group_class_mask, and other_class_mask attributes are modified according to 
the owner class, group class, and other class permissions of the mode 
parameter as follows:

 - The POSIX read permission implies the ACE4_READ_DATA, ACE4_READ_ATTRIBUTES, 
ACE4_READ_ACL, and ACE4_SYNCHRONIZE bitmask flags.

 - The POSIX write permission implies the ACE4_WRITE_DATA, ACE4_APPEND_DATA, 
ACE4_WRITE_ATTRIBUTES, ACE4_DELETE_CHILD, and ACE4_SYNCHRONIZE bitmask flags.

 - The POSIX execute permission implies the ACE4_EXECUTE mask.

This saves us from bloating ACLs with DENY entries, is more efficient when 
doing a chmod, and also saves us from destroying permissions in user provided 
DENY entries.

When an ACL is set, then set all mask attributes to the values provided in the 
same SETATTR operation, and set the remaining mask attributes to the union of 
all ALLOW ACL entries in the ACL that the class applies to.

Without any further changes, NFSv4 clients not aware of the three optional 
attributes would not be aware of the restrictions imposed by those masks when 
querying for the ACL. This would create an interoperability problem, and 
possible security holes. To solve this problem, we can extend the GETATTR 
operation as follows:

When a client requests the ACL attribute, check if it also requests one or 
more of the three optional owner_class_mask, group_class_mask, or 
other_class_mask attributes. If it does, then send the requested attributes 
as they are. If the client requests only the ACL without any of the masks, 
return an ACL with only effective mask flags set, and with all other flags 
removed.

Alternate permissions in the ACL can be enabled by either setting an ACL 
without providing full mask entries, or by setting the appropriate bit(s) in 
the corresponding mask entry or entries.

When comparing POSIX ACLs and the NFSv4 ACL + mask attributes as proposed 
here, one obvious difference is that POSIX ACLs have only one mask entry, 
while I propose three mask entries here. The reason for this is that POSIX 
ACLs can at most grant read, write, and execute permissions, and so with 
POSIX ACLs, the File Owner Class permissions are always identical to the 
permissions granted to the owner, and the File Other Class permissions are 
always identical to the permissions granted to others. With NFSv4 ACLs, 
OWNER@ and EVERYONE@ entries may grant additional permissions that go beyond 
what POSIX read, write, and execute can grant, and we need a mechanism so 
that those alternate permissions can be turned off by chmod and during file 
create without destroying the permissions.



I would appreciate if you could take this alternative proposal into 
consideration when deciding how to proceed with NFSv4 Minor 
Version 1 at next week's IETF 66 meeting.


Thanks and best regards,
Andreas

> REFERENCES
>
> [1] Sam Falkner et al.: NFS Version 4 ACLs, draft-ietf-nfsv4-acls-00.txt
>
> [2] POSIX 1003.1e/2c draft 17 (withdrawn),
> http://wt.xpilot.org/publications/posix.1e
>
> [3] Marius Aamodt Eriksen et al.: Mapping Between NFSv4 and Posix Draft
> ACLs, draft-ietf-nfsv4-acl-mapping-04.txt
>
> [4] Spencer Shepler (editor): NFSv4 Minor Version 1,
> draft-ietf-nfsv4-minorversion1-03.txt

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
