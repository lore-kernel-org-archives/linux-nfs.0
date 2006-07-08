From: "Noveck, Dave" <Dave.Noveck@netapp.com>
Subject: RE: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Sat, 8 Jul 2006 11:04:46 -0400
Message-ID: <C98692FD98048C41885E0B0FACD9DFB8028CEAAC@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <spencer.shepler@Sun.COM>,
	nfs@lists.sourceforge.net, nfsv4@ietf.org, Lisa Week <Lisa.Week@Sun.COM>
Return-path: <nfsv4-bounces@ietf.org>
To: "Sam Falkner" <Sam.Falkner@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

Andreas has asked that we consider his proposal when disucssing=20
where to go with regard to ACL in v4.1, at the Montreal IETF
meeting.

I'm wondering whether we should be discussing specific mechanisms.
It would help me if we could have a discussion of what the goals
should be for ACL's in v4.1.  This isn't resally clear to me but
it could be due to my lack of attention to the matter.

Is there anybody who's going to be at Montreal who could lead such
a discussion (I'm thinking 10 minutes worth)?  Or are the goals
already clear in which case somebody can explain things to me=20
offline and we can avoid wasting other people's time.=20

-----Original Message-----
From: Sam Falkner [mailto:Sam.Falkner@Sun.COM]=20
Sent: Saturday, July 08, 2006 10:32 AM
To: Sam Falkner
Cc: nfs@lists.sourceforge.net; Spencer Shepler; Pawlowski, Brian;
nfsv4@ietf.org; Lisa Week
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction /
mask,draft-ietf-nfsv4-acls-00 not ready

On Jul 7, 2006, at 9:45 PM, Sam Falkner wrote:

> On Jul 7, 2006, at 5:55 AM, Andreas Gruenbacher wrote:
>>
>> Alternative Proposal
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>> Instead of adding DENY entries to the ACL for the purpose of masking,

>> attach three optional attributes to each file: owner_class_mask,=20
>> group_class_mask, and other_class_mask. When those attributes are=20
>> present, they define which permissions in an ACE are effective.
>>
>> Each ACE is is restricted by one of these mask attributes in each=20
>> access
>> check:
>>
>>  - OWNER@ entries and entries for the user@domain that currently owns

>> the file
>>    are restricted by owner_class_mask.
>>
>>  - EVERYONE@ entries are restricted by other_class_mask.
>>
>>  - All other entries are restricted by group_class_mask.
>>
>> The effective permissions are computed as the bitwise and (&) of the=20
>> ACE mask and the associated class_mask attribute.
>
> I take it you mean that "the effective access mask bits for ACEs of=20
> type ALLOW"?
>
>> When doing a chmod(2) or when applying a create mask, the=20
>> owner_class_mask, group_class_mask, and other_class_mask attributes=20
>> are modified according to the owner class, group class, and other=20
>> class permissions of the mode parameter as follows:
>>
>>  - The POSIX read permission implies the ACE4_READ_DATA,=20
>> ACE4_READ_ATTRIBUTES, ACE4_READ_ACL, and ACE4_SYNCHRONIZE bitmask=20
>> flags.
>>
>>  - The POSIX write permission implies the ACE4_WRITE_DATA,=20
>> ACE4_APPEND_DATA, ACE4_WRITE_ATTRIBUTES, ACE4_DELETE_CHILD, and=20
>> ACE4_SYNCHRONIZE bitmask flags.
>
> I'm not sure I agree about ACE4_WRITE_ATTRIBUTES, but that's a minor=20
> detail.
>
>>  - The POSIX execute permission implies the ACE4_EXECUTE mask.
>
>> This saves us from bloating ACLs with DENY entries, is more efficient

>> when doing a chmod, and also saves us from destroying permissions in=20
>> user provided DENY entries.
>
> Yes, but at the cost of adding new file attributes...  Don't get me=20
> wrong, I do see merit in this proposal, but I don't know if it'll be=20
> acceptable.
>
>> When an ACL is set, then set all mask attributes to the values=20
>> provided in the same SETATTR operation, and set the remaining mask=20
>> attributes to the union of all ALLOW ACL entries in the ACL that the=20
>> class applies to.
>
> This doesn't take the ordering of the ACL into account; is this your=20
> intention?  So
>
> GROUP@:read_data/write_data:DENY
> GROUP@:read_data/write_data:ALLOW
>
> would result in a group_class_mask of read_data|write_data, right?  =20
> (I'm not saying it's wrong, I'm just making sure I understand.)
>
>> Without any further changes, NFSv4 clients not aware of the three=20
>> optional attributes would not be aware of the restrictions imposed by

>> those masks when querying for the ACL. This would create an=20
>> interoperability problem, and possible security holes. To solve this=20
>> problem, we can extend the GETATTR operation as follows:
>>
>> When a client requests the ACL attribute, check if it also requests=20
>> one or more of the three optional owner_class_mask, group_class_mask,

>> or other_class_mask attributes. If it does, then send the requested=20
>> attributes as they are. If the client requests only the ACL without=20
>> any of the masks, return an ACL with only effective mask flags set,=20
>> and with all other flags removed.
>
> I assume you mean in the ALLOW ACEs only, right?

More thoughts on this model and getattr.  Giving different versions of
the ACL depending on how it's requested leads to problems.  To recap, if
NFSv4.0 client asks for the post-chmod ACL, it'll get the inhibited
version of the ACL.  Tools for modifying an ACL invariably do
read/modify/write.  So NFSv4.0 client reads the stripped down ACL,
modifies it, and writes it back.  At this point, information is lost
-- the stripped down ACL is now the only ACL we have.  This leads to
future environments where some classes of clients inadvertently do bad
things, while others behave more correctly.

The ACL model in draft-ietf-nfsv4-minorversion1-03.txt always shows
every client the entire, correct ACL, every time.

- Sam

>
>> Alternate permissions in the ACL can be enabled by either setting an=20
>> ACL without providing full mask entries, or by setting the=20
>> appropriate
>> bit(s) in
>> the corresponding mask entry or entries.
>
> Yes, I think I understand.
>
>> When comparing POSIX ACLs and the NFSv4 ACL + mask attributes as=20
>> proposed here, one obvious difference is that POSIX ACLs have only=20
>> one mask entry, while I propose three mask entries here. The reason=20
>> for this is that POSIX ACLs can at most grant read, write, and=20
>> execute permissions, and so with POSIX ACLs, the File Owner Class=20
>> permissions are always identical to the permissions granted to the=20
>> owner, and the File Other Class permissions are always identical to=20
>> the permissions granted to others. With NFSv4 ACLs, OWNER@ and=20
>> EVERYONE@ entries may grant additional permissions that go beyond=20
>> what POSIX read, write, and execute can grant, and we need a=20
>> mechanism so that those alternate permissions can be turned off by=20
>> chmod and during file create without destroying the permissions.
>
> Given that EVERYONE@ is not equivalent to the POSIX "other" class, it=20
> could be trimmed down to two.
>
>> I would appreciate if you could take this alternative proposal into=20
>> consideration when deciding how to proceed with NFSv4 Minor Version 1

>> at next week's IETF 66 meeting.
>
> This proposal certainly has its merits.  I have doubts about the=20
> feasibility of adding two or three new file attributes, and new as-=20
> yet-unimplemented semantics, into the minorversion1 draft.  I have=20
> doubts about how this would be implemented on a Windows-based server.
>
> The current design specified in draft-ietf-nfsv4- minorversion1-03.txt

> has implementation experience -- it's released in Solaris 10 update 3,

> a shipping product.  It meets strict POSIX requirements for those=20
> implementations that choose to conform to POSIX.  I believe it's fully

> implementable on a Windows-based server.
>
> I too hope that this can be discussed at IETF 66.
>
> - Sam
>
>>
>>
>> Thanks and best regards,
>> Andreas
>>
>>> REFERENCES
>>>
>>> [1] Sam Falkner et al.: NFS Version 4 ACLs, draft-ietf-nfsv4-=20
>>> acls-00.txt
>>>
>>> [2] POSIX 1003.1e/2c draft 17 (withdrawn),=20
>>> http://wt.xpilot.org/publications/posix.1e
>>>
>>> [3] Marius Aamodt Eriksen et al.: Mapping Between NFSv4 and Posix=20
>>> Draft ACLs, draft-ietf-nfsv4-acl-mapping-04.txt
>>>
>>> [4] Spencer Shepler (editor): NFSv4 Minor Version 1,=20
>>> draft-ietf-nfsv4-minorversion1-03.txt
>>
>> --
>> Andreas Gruenbacher <agruen@suse.de>
>> Novell / SUSE Labs
>
>
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www1.ietf.org/mailman/listinfo/nfsv4


_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
