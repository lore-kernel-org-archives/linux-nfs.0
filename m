From: Andreas Gruenbacher <agruen@suse.de>
Subject: NFSv4 ACL and POSIX interaction / mask
Date: Mon, 3 Jul 2006 23:10:14 +0200
Message-ID: <200607032310.15252.agruen@suse.de>
Reply-To: nfsv4@ietf.org
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@ietf.org>
To: nfsv4@ietf.org
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

Hello,

I have been thinking about the problems of interaction between NFSv4 ACLs and 
POSIX, and particularly about the issue of masking permissions through chmod 
and after creating files or directories.

On a UNIX system that supports NFSv4 ACLs natively, I think we should try to 
accept as wide a range of NFSv4 ACLs as possible, but we must make sure that 
we can preserve POSIX semantics. In particular, this means that ACLs may 
contain ACEs for users other than OWNER@, GROUP@, and EVERYONE@, and that 
chmod(2) must continue to provide the same kinds of guarantees as without 
NFSv4 ACLs.

I am assuming here that NFSv4 ACLs shall be an additional rather than an 
alternate file access control mechanism in the POSIX sense: Alternate file 
access control mechanisms must ``be enabled only by explicit user action, on 
a per-file basis by the file owner or a user with the appropriate 
privilege'', and must ``be disabled for a file after the file permission bits 
are changed for that file with chmod( )'' according to POSIX. In other words, 
newly created files or directories would have alternate file access control 
mechanisms disabled. This would render NFSv4 ACLs essentially useless for 
UNIX processes, because they would almost always be disabled, and would only 
work for remote processes until a POSIX process chmods a file or creates a 
directory, which wouldn't get us very far.

Let's look at chmod(2): the mode specified in chmod(2) defines the permissions 
of three classes of users: owner, group, and other. Each class is assigned a 
set of the READ, WRITE, and EXECUTE permissions. This defines the maximum set 
of permissions that this class has at any moment.

In an NFSv4 ACL, each entry must be in exactly one of the three classes of 
users: OWNER@ is in the owner class, GROUP@ and additional users and groups 
listed in the ACL are in the group class, and EVERYONE@ is in the other 
class.

No ACL entry shall granted permissions that exceed the permissions of its 
class. (Additional permissions in a class could be enabled explicitly, which 
would amount to an alternate file access mechanism, though.)

Note that we must not allow an ACE to be in no class, either: if we did, a 
chmod call with mode 0 would not disable all access, which would conflict 
with POSIX.

Note that this definition is in line with POSIX 1003.1e draft 17 [2], while it 
conflicts with the IETF NFS Version 4 ACLs draft [1], which associates only 
GROUP@ entries with the group file mode permission bits in section 5.1. The 
relevant text of IETF NFS Version 4 ACLs draft [1] is also found in NFSv4 
Minor Version 1 [4].

We want chmod(2) to be non-destructive, so that a chmod to a more restrictive 
mode and back to the original mode will leave the file with the same 
permissions as before the changes.

According to NFS Version 4 ACLs [1], it has been tried to replace the entire 
ACL with an ACL that only grants the permissions specified by the new mode. 
This approach has two drawbacks: first, it is destructive, and additional 
permissions granted are lost in the first chmod. Second, additional 
restrictions (DENY entries) may be lost as well. This is not acceptable, and 
unsurprisingly, users did not favor this approach.

POSIX ACLs have solved the non-destructiveness problem by introducing a mask 
ACL entry: the mask entry applies to all group class entries, and defines an 
upper bound to the permissions those entries may grant. POSIX ACLs only have 
ACL entries that allow permissions, and only specify READ, WRITE, and EXECUTE 
permissions. Therefore, the owner class and other class permissions are the 
permissions granted to the owner and to others, respectively. (Note the 
difference between these others and NFSv4's EVERYONE@ special identifier).

The mask concept is not part of NFSv4 ACLs. Marius A. Eriksen and others have 
proposed to emulate the POSIX ACL mask entry by prepending (with exception of 
OWNER@ and EVERYONE@ ACEs) each ALLOW ACE with a DENY ACE for the same user, 
group, or special identifier as in the ALLOW ACE. The permissions in the DENY 
ACE are set so that the entry denies the permissions not granted by the mask.

Unless we accept a very specific form of NFSv4 ACLs only (which would 
contradict the goal stated at the top of this message, and which would mean 
that interoperability with anything but POSIX ACLs would become difficult), 
there is no easy way to tell DENY entries introduced to emulate the mask from 
DENY entries added by hand. This has two potential consequences:

 - First, if we fail to identify such a mask-emulation DENY entry, we may end 
up inserting another such entry. We might end up doing so repeatedly.

 - Second, we may take a user-provided DENY entry for a mask-emulation DENY 
entry, and clear mask bits from that entry. This would contradict the user's 
intention. So the approach of inserting mask-emulation DENY entries is not 
good enough in general. (Mapping between NFSv4 and POSIX ACLs does not have 
this problem, because POSIX ACLs don't have DENY ACEs.)

In my opinion, there are two possible solutions for this problem: we can (1) 
devise a special kind of NFSv4 ACL entry that we will recognize as mask 
entry, or (2) give the owner/group/other class permission bits higher 
priority than the ACL entries, and only allow permissions that are allowed by 
both the ACEs and their associated classes.

In case (1), we could either keep prepending (almost) each ALLOW entry with an 
associated DENY entry and set a special flag in the DENY entry, or we could 
introduce something like a MASK@ special identifier, add MASK@ entries to the 
ACL in the appropriate places, and add the mask logic to the permission check 
algorithm.

We would need at most three MASK@ entries per ACL, one for each class of 
users: it should be obvious that we need a mask for the group class, which 
contains the GROUP@ entries and all entries for explicitly named users and 
groups. We want to avoid destroying permissions set explicitly for USER@ and 
EVERYONE@ entries after a chmod as well though. We could then use the mask 
mechanism to selectively turn on additional permissions not covered by READ, 
WRITE, and EXECUTE, as a kind of alternate file access control mechanism.

We could keep such extensions local to the server and not expose them over the 
protocol, with the obvious interoperability problems when copying files 
around, or we could make whichever extensions we need part of the NFSv4 
protocol.

Case (2) would be pretty simple to implement, but all permissions that are not 
covered by READ, WRITE, EXECUTE would always be masked (for correctness, even 
for remote clients), and there would be no controlled way to un-mask them.

Thoughts anyone?

Thanks,
Andreas

REFERENCES

[1] Sam Falkner et al.: NFS Version 4 ACLs, draft-ietf-nfsv4-acls-00.txt

[2] POSIX 1003.1e/2c draft 17 (withdrawn), 
http://wt.xpilot.org/publications/posix.1e

[3] Marius Aamodt Eriksen et al.: Mapping Between NFSv4 and Posix Draft ACLs, 
draft-ietf-nfsv4-acl-mapping-04.txt

[4] Spencer Shepler (editor): NFSv4 Minor Version 1, 
draft-ietf-nfsv4-minorversion1-03.txt

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
