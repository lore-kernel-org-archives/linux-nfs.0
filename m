From: Lisa Week <Lisa.Week@Sun.COM>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
 draft-ietf-nfsv4-acls-00 not ready
Date: Sat, 08 Jul 2006 00:51:42 -0600
Message-ID: <6C45838C-9240-4422-AFCC-A65173D763DB@Sun.COM>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1776738080=="
Cc: nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@Sun.COM>,
	Brian Pawlowski <beepy@netapp.com>, nfsv4@ietf.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fz6du-0003M3-9j
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 23:50:18 -0700
Received: from brmea-mail-3.sun.com ([192.18.98.34])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fz6du-0003tl-By
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 23:50:18 -0700
Received: from fe-amer-05.sun.com ([192.18.108.179])
	by brmea-mail-3.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	k686oGYn014778
	for <nfs@lists.sourceforge.net>; Sat, 8 Jul 2006 00:50:16 -0600 (MDT)
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
	id <0J2200E01O81NX00@mail-amer.sun.com> (original mail from
	Lisa.Week@Sun.COM)
	for nfs@lists.sourceforge.net; Sat, 08 Jul 2006 00:50:16 -0600 (MDT)
In-reply-to: <B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
To: Andreas Gruenbacher <agruen@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============1776738080==
Content-type: multipart/alternative;
	boundary="Boundary_(ID_yZ6sA2R8WuFZGnATmnS8Tg)"


--Boundary_(ID_yZ6sA2R8WuFZGnATmnS8Tg)
Content-type: text/plain; format=flowed; delsp=yes; charset=US-ASCII
Content-transfer-encoding: 7BIT

Hi Andreas,

I have a couple additional questions and comments.  See those inline...

Thanks,
Lisa

On Jul 7, 2006, at 9:45 PM, Sam Falkner wrote:

> On Jul 7, 2006, at 5:55 AM, Andreas Gruenbacher wrote:
>
>> On Monday, 3. July 2006 23:10, Andreas Gruenbacher wrote:
>>> Hello,
>>>
>>> I have been thinking about the problems of interaction between  
>>> NFSv4 ACLs
>>> and POSIX, and particularly about the issue of masking  
>>> permissions through
>>> chmod and after creating files or directories.
>>
>> Here is a follow-up after some personal feedback from Sam. I  
>> believe that
>> draft-ietf-nfsv4-acls-00 is not ready to become part of the NFSv4  
>> Minor
>> Version 1 RFC: some assumptions are not correct from a POSIX point  
>> of view,
>> and the way how chmod and file create modes are applied to NFSv4  
>> ACLs is weak
>> and not guaranteed to be correct.
>
> I disagree -- see below.
>
>> I will first try to clarify some of the points I tried to make in  
>> the previous
>> posting and point out deficiencies in draft-ietf-nfsv4-acls-00.  
>> Then I will
>> propose an alternative design which is more correct than  
>> introducing DENY
>> entries to mask permissions. (As a bonus, it is easier to  
>> implement. too.)
>>
>>> On a UNIX system that supports NFSv4 ACLs natively, I think we  
>>> should try
>>> to accept as wide a range of NFSv4 ACLs as possible, but we must  
>>> make sure
>>> that we can preserve POSIX semantics. In particular, this means  
>>> that ACLs
>>> may contain ACEs for users other than OWNER@, GROUP@, and  
>>> EVERYONE@, and
>>> that chmod(2) must continue to provide the same kinds of  
>>> guarantees as
>>> without NFSv4 ACLs.
>>>
>>> I am assuming here that NFSv4 ACLs shall be an additional rather  
>>> than an
>>> alternate file access control mechanism in the POSIX sense:  
>>> Alternate file
>>> access control mechanisms must ``be enabled only by explicit user  
>>> action,
>>> on a per-file basis by the file owner or a user with the appropriate
>>> privilege'', and must ``be disabled for a file after the file  
>>> permission
>>> bits are changed for that file with chmod( )'' according to  
>>> POSIX. In other
>>> words, newly created files or directories would have alternate  
>>> file access
>>> control mechanisms disabled. This would render NFSv4 ACLs  
>>> essentially
>>> useless for UNIX processes, because they would almost always be  
>>> disabled,
>>> and would only work for remote processes until a POSIX process  
>>> chmods a
>>> file or creates a directory, which wouldn't get us very far.
>>
>> As Sam pointed out, a subset of NFSv4 ACLs maps to an additional  
>> file access
>> control mechanism, while the rest goes beyond that, and therefore  
>> is an
>> alternate file access control mechanism.
>
> Yes -- ALLOW ACEs are alternate file access control, and DENY ACEs  
> are additional file access control.
>
>> It is important to understand how POSIX defines additional file  
>> access control
>> mechanisms:
>>
>> [] 3.4 Additional File Access Control Mechanism
>> [] An implementation-defined mechanism that is layered upon the  
>> access control
>> []  mechanisms defined here, but which do not grant permissions  
>> beyond those
>> []  defined herein, although they may further restrict them.
>>
>> In other words, when a file has just been created and after chmod,  
>> the file
>> mode permission bits define an upper bound to the permissions  
>> granted to
>> anyone on the system, and nobody has additional permissions.  
>> Additional
>> permissions (as an alternate file access control mechanism) may be
>> enabled explicitly, but the next chmod must disable them again.
>
> The use of the word "Additional" is confusing in the above  
> sentence.  :-)  I think you mean "more", or similar, but  
> "Additional" has a very specific meaning which (I think) isn't what  
> you mean.
>
>> We can classify the permissions that NFSv4 ACLs grant into  
>> additional and
>> alternate mechanisms as follows: everything covered by the POSIX
>> read/write/execute permissions (such as ACE4_READ_DATA, but also
>> ACE4_APPEND_DATA) is additional, while everything beyond that  
>> (such as
>> ACE4_WRITE_OWNER) is alternate.
>
> Note well: this is quite different from draft-ietf-nfsv4- 
> minorversion1-03.txt, i.e. this is an alternate proposal.
>
>> Under this definition, all NFSv4 ACLs that
>> grant no more than ACE4_READ_DATA, ACE4_LIST_DIRECTORY,  
>> ACE4_WRITE_DATA,
>> ACE4_ADD_FILE, ACE4_APPEND_DATA, ACE4_ADD_SUBDIRECTORY,
>> ACE4_READ_NAMED_ATTRS, ACE4_WRITE_NAMED_ATTRS, ACE4_EXECUTE,
>> ACE4_READ_ATTRIBUTES, ACE4_WRITE_ATTRIBUTES, ACE4_READ_ACL, and
>> ACE4_SYNCHRONIZE would count as additional access control  
>> mechanisms. All
>> others with ACE4_WRITE_ACL, ACE4_WRITE_OWNER, ACE4_DELETE_CHILD, and
>> ACE4_DELETE are alternate.
>
> I don't understand what is gained by this designation of additional  
> access control mechanisms.  If you really say that this ACL:
>
> OWNER@:read_data:allow
> friend@your.com:read_data:allow
>
> is additional file access control, then what is the mode on such a  
> file?  Unless the mode says "group can read", then friend@your.com  
> wouldn't be able to read, if the ACL is additional file access  
> control.  What if you want friend@your.com to be able to read, but  
> you don't want the file's owning group to read?

1.) If ACEs with ACE4_WRITE_ACL, ACE4_WRITE_OWNER, ACE4_DELETE_CHILD  
and ACE4_DELETE are alternate access control mechanisms, what will  
happen to ACEs with these access mask bits set upon chmod of the file?

For example, if we have the following ACL:
     lisa@sun.com:ACE4_WRITE_ACL:deny

		or even

     lisa@sun.com:ACE4_WRITE_OWNER:allow

Upon chmod we would have to disable them (however an implementation  
chooses to) and effectively remove it.

The thing that I have a problem with here is the fact that the  
changing of the file permission bits will affect what access has been  
defined in the ACL for things such as ACE4_WRITE_OWNER,  
ACE4_WRITE_ACL, etc.  A user setting the file permission bits is not  
saying anything about what they want to be done with any ACEs that  
include the ACE4_WRITE_OWNER mask bit.  Why would we want to mess  
with them?

2.) So, what if an ACE contained a mixture of the access mask bits  
that are alternate and additional?

Would we allow having ACE4_READ_DATA and ACE4_WRITE_ACL in the same  
ACE?  What would happen to an ACE such as this upon chmod?

>
>> As said already, the POSIX file mode permission bits define the  
>> permissions of
>> three classes: owner, group, and other. An additional file access  
>> control
>> mechanism may only further restrict the permissions granted to  
>> those classes.
>
>> To map NFSv4 ACLs to an additional file access control mechanism,
>
>>  - we must map each NFSv4 ACL entry to exactly one of the three  
>> classes.
>>
>>  - we must ensure that the ACL does not grant any permissions that  
>> go beyond
>>    the class permissions after a chmod or create.
>
> Additional File Access Control must not grant beyond the class  
> permissions *ever*, not just after create or chmod.
>
>>  - in particular, we must ensure that the ACL grants no "alternate"
>>    permissions after a chmod or create.
>
> I don't understand this; you began this section with "To map NFSv4  
> ACLs to an additional...", but here, you seem to be describing ACLs  
> as an alternate file access control mechanism.
>
>> We are free to provide mechanisms by which more permissions may be  
>> enabled by
>> explicit user action, on a per-file basis by the file owner or a  
>> user with
>> the appropriate privilege, according to POSIX.
>
>>
>> The POSIX definitions of the three file permission classes are:
>>
>> [] 3.173 File Owner Class
>> [] The property of a file indicating access permissions for a  
>> process related
>> [] to the user identification of a process. A process is in the  
>> file owner
>> [] class of a file if the effective user ID of the process matches  
>> the user ID
>> [] of the file.
>>
>> [] 3.166 File Group Class
>> [] The property of a file indicating access permissions for a process
>> [] related to the group identification of a process. A process is in
>> [] the file group class of a file if the process is not in the  
>> file owner
>> [] class and if the effective group ID or one of the supplementary  
>> group
>> [] IDs of the process matches the group ID associated with the  
>> file. Other
>> [] members of the class may be implementation-defined.
>>
>> [] 3.172 File Other Class
>> [] The property of a file indicating access permissions for a  
>> process related
>> [] to the user and group identification of a process. A process is  
>> in the file
>> [] other class of a file if the process is not in the file owner  
>> class or file
>> [] group class.
>>
>> The key fact in these definitions is that an implementation may  
>> define
>> additional members of the File Group Class, while the other  
>> classes are not
>> extensible.
>>
>> Under this definition, we end up with the following mapping:
>>
>>  - OWNER@ entries are in the File Owner Class,
>>  - EVERYONE@ entries are in the File Other Class,
>
> No, I don't think EVERYONE@ is in the File Other Class.  Given this  
> ACL:
>
> EVERYONE@:read_data:deny
> OWNER@:read_data:allow
>
> the owner would NOT be able to read.  In other words, file owner  
> class and file group class are also affected by EVERYONE@ ACEs.

I'll restate it because it is important: EVERYONE@ is not equivalent  
to the File Other Class.  I believe the original intention was to  
have it be equivalent to one the Windows "well known sid":   http:// 
msdn.microsoft.com/library/default.asp?url=/library/en-us/secauthz/ 
security/well_known_sid_type.asp


Really with NFSv4 ACLs, the only way we have the equivalent of a File  
Other Class is if the EVERYONE@ entries come at the end of the ACL.   
Such as this:

      owner@:execute:deny
      owner@:read_data/write_data/append_data/write_xattr/ 
write_attributes
          /write_acl/write_owner:allow
      group@:write_data/append_data/execute:deny
      group@:read_data:allow
      everyone@:write_data/append_data/write_xattr/execute/ 
write_attributes
          /write_acl/write_owner:deny
      everyone@:read_data/read_xattr/read_attributes/read_acl/ 
synchronize
          :allow


>
>>  - every other entry is in the File Group Class(*).
>
> including EVERYONE@.  ;-)
>
>>  (*) User entries for the user who is the current file owner are a  
>> special
>>      case: due to how the NFSv4 ACL permission check algorithm is  
>> specified,
>>      I believe that they should be put in the OWNER@ class.
>
> The current minorversion1 draft has a similar design constraint.
>
>>> Note that this definition is in line with POSIX 1003.1e draft 17  
>>> [2], while
>>> it conflicts with the IETF NFS Version 4 ACLs draft [1], which  
>>> associates
>>> only GROUP@ entries with the group file mode permission bits in  
>>> section
>>> 5.1. The relevant text of IETF NFS Version 4 ACLs draft [1] is  
>>> also found
>>> in NFSv4 Minor Version 1 [4].
>>
>> Section 5.1 of [1] needs to be fixed: we must set the permission  
>> bits so that
>> they are a superset of the permissions of all the entries in the  
>> respective
>> class. (We cannot represent permissions that are not supersets of
>> POSIX read, write, execute in the class, but that is not a  
>> problem, as we will
>> see later.)
>
> We must do so carefully.  I'm not convinced that a superset is the  
> best way to go, but we should talk about this later.
>
>> Non-monotonic permissions
>> =========================
>>
>> Note that with arbitrary NFSV4 ACLs, the permissions granted to a  
>> process from
>> multiple ACL entries will accumulate. This means that permissions  
>> across
>> multiple classes may accumulate as well. This can be prevented  
>> with DENY
>> entries in the ACL, e.g.,
>>
>> 	OWNER@:mask1::ALLOW
>> 	OWNER@:^mask1::DENY
>> 	user@domain:mask2::ALLOW
>> 	group@domain:mask3:ACE4_IDENTIFIER_GROUP:ALLOW
>> 	user@domain:^mask2::DENY
>> 	group@domain:^mask3:ACE4_IDENTIFIER_GROUP:DENY
>> 	EVERYONE:mask4::ALLOW
>>
>> This means that we will not have to deal with this special case  
>> when computing
>> the file mode permission bits, and we can achieve consistency by  
>> forcing ACLs
>> to be "well structured".
>
> Yuck!  I'm glad you're not proposing this as a general NFSv4 ACL  
> model.  :-)
>
>> We could also leave this as an implementation consideration: ACLs  
>> which are
>> not "well structured" in the above sense will grant permissions  
>> that go
>> beyond what an additional access control mechanism may grant  
>> *only* for
>> non-monotonic file mode permission bits. With non-monotonic I mean  
>> file mode
>> permission bits which grant more permissions to the group class  
>> than to the
>> owner class, or more permissions to the other class than to the  
>> group class.
>
> I'm sorry, I just don't follow that paragraph.
>
>>> We want chmod(2) to be non-destructive, so that a chmod to a more
>>> restrictive mode and back to the original mode will leave the  
>>> file with the
>>> same permissions as before the changes.
>>>
>>> [...]
>>>
>>> POSIX ACLs have solved the non-destructiveness problem by  
>>> introducing a
>>> mask ACL entry: the mask entry applies to all group class  
>>> entries, and
>>> defines an upper bound to the permissions those entries may  
>>> grant. POSIX
>>> ACLs only have ACL entries that allow permissions, and only  
>>> specify READ,
>>> WRITE, and EXECUTE permissions. Therefore, the owner class and  
>>> other class
>>> permissions are the permissions granted to the owner and to others,
>>> respectively. (Note the difference between these others and NFSv4's
>>> EVERYONE@ special identifier).
>>>
>>> The mask concept is not part of NFSv4 ACLs. Marius A. Eriksen and  
>>> others
>>> have proposed to emulate the POSIX ACL mask entry by prepending  
>>> (with
>>> exception of OWNER@ and EVERYONE@ ACEs) each ALLOW ACE with a  
>>> DENY ACE for
>>> the same user, group, or special identifier as in the ALLOW ACE. The
>>> permissions in the DENY ACE are set so that the entry denies the
>>> permissions not granted by the mask.
>>
>> Internet draft-ietf-nfsv4-acls-00.txt [1] uses the same mechanism  
>> to implement
>> masking.
>>
>>> Unless we accept a very specific form of NFSv4 ACLs only (which  
>>> would
>>> contradict the goal stated at the top of this message, and which  
>>> would mean
>>> that interoperability with anything but POSIX ACLs would become  
>>> difficult),
>>> there is no easy way to tell DENY entries introduced to emulate  
>>> the mask
>>> from DENY entries added by hand.
>
> I would refute this; see below.
>
>>> This has two potential consequences:
>>>
>>>  - First, if we fail to identify such a mask-emulation DENY  
>>> entry, we may
>>> end up inserting another such entry. We might end up doing so  
>>> repeatedly.
>
> But we will not ever fail to identify such a mask-emulation DENY  
> entry, when it is one that was created by a previous chmod.  Only  
> in a degenerate case of modify-acl-carefully, chmod, modify-acl- 
> carefully, chmod, etc., would you get a growing ACL problem.
>
>>>  - Second, we may take a user-provided DENY entry for a mask- 
>>> emulation DENY
>>> entry, and clear mask bits from that entry. This would contradict  
>>> the
>>> user's intention. So the approach of inserting mask-emulation  
>>> DENY entries
>>> is not good enough in general.
>
> A user-provided DENY entry would have to fit into a very specific  
> and somewhat nonsensical form in order to be misidentified.  Here's  
> an example:
>
> samf@sun.com:read_data:deny
> samf@sun.com:read_data:allow
>
> If a "chmod 444" were done, the deny ACE above would be modified.   
> Any other cases of chmod modifying a user-provided ACE would have  
> to be essentially the same as the above example.  I think that  
> that's an acceptable situation.
>
>>> (Mapping between NFSv4 and POSIX ACLs does
>>> not have this problem, because POSIX ACLs don't have DENY ACEs.)
>
>> Therefore, the mechanism described in section 5.3 is not suitable  
>> for our
>> purposes, and we need to replace it with something better.
>
> I don't agree that 5.3 is not suitable, but I would love to see  
> something better.
>
>>> In my opinion, there are two possible solutions for this problem:  
>>> we can
>>> (1) devise a special kind of NFSv4 ACL entry that we will  
>>> recognize as mask
>>> entry, or (2) give the owner/group/other class permission bits  
>>> higher
>>> priority than the ACL entries, and only allow permissions that  
>>> are allowed
>>> by both the ACEs and their associated classes.
>
> Yikes -- I don't like either of the above solutions; let's look at  
> the third...
>
>> A third option exists as well which fits in very well with POSIX  
>> and can be
>> implemented in NFSv4 in a backward compatible way.
>>
>> Alternative Proposal
>> ====================
>>
>> Instead of adding DENY entries to the ACL for the purpose of  
>> masking, attach
>> three optional attributes to each file: owner_class_mask,  
>> group_class_mask,
>> and other_class_mask. When those attributes are present, they  
>> define which
>> permissions in an ACE are effective.
>>
>> Each ACE is is restricted by one of these mask attributes in each  
>> access
>> check:
>>
>>  - OWNER@ entries and entries for the user@domain that currently  
>> owns the file
>>    are restricted by owner_class_mask.
>>
>>  - EVERYONE@ entries are restricted by other_class_mask.

Again, EVERYONE@ is not equivalent to the File Other Class.   
Depending on where an ACE pertaining to EVERYONE@ is in the ACL, it  
could even refer to the owner and the owning group.

>>
>>  - All other entries are restricted by group_class_mask.
>>
>> The effective permissions are computed as the bitwise and (&) of  
>> the ACE mask
>> and the associated class_mask attribute.
>
> I take it you mean that "the effective access mask bits for ACEs of  
> type ALLOW"?
>
>> When doing a chmod(2) or when applying a create mask, the  
>> owner_class_mask,
>> group_class_mask, and other_class_mask attributes are modified  
>> according to
>> the owner class, group class, and other class permissions of the mode
>> parameter as follows:
>>
>>  - The POSIX read permission implies the ACE4_READ_DATA,  
>> ACE4_READ_ATTRIBUTES,
>> ACE4_READ_ACL, and ACE4_SYNCHRONIZE bitmask flags.
>>
>>  - The POSIX write permission implies the ACE4_WRITE_DATA,  
>> ACE4_APPEND_DATA,
>> ACE4_WRITE_ATTRIBUTES, ACE4_DELETE_CHILD, and ACE4_SYNCHRONIZE  
>> bitmask flags.
>
> I'm not sure I agree about ACE4_WRITE_ATTRIBUTES, but that's a  
> minor detail.

Yes, as [4] says, ACE4_WRITE_ATTRIBUTES is the "Permission to change  
the times associated with a file or directory to an arbitrary  
value."  Having that included in the POSIX write permission would not  
be correct, but as Sam said, that is minor.

>
>>  - The POSIX execute permission implies the ACE4_EXECUTE mask.
>
>> This saves us from bloating ACLs with DENY entries, is more  
>> efficient when
>> doing a chmod, and also saves us from destroying permissions in  
>> user provided
>> DENY entries.
>
> Yes, but at the cost of adding new file attributes...  Don't get me  
> wrong, I do see merit in this proposal, but I don't know if it'll  
> be acceptable.
>
>> When an ACL is set, then set all mask attributes to the values  
>> provided in the
>> same SETATTR operation, and set the remaining mask attributes to  
>> the union of
>> all ALLOW ACL entries in the ACL that the class applies to.
>
> This doesn't take the ordering of the ACL into account; is this  
> your intention?  So
>
> GROUP@:read_data/write_data:DENY
> GROUP@:read_data/write_data:ALLOW
>
> would result in a group_class_mask of read_data|write_data, right?   
> (I'm not saying it's wrong, I'm just making sure I understand.)
>
>> Without any further changes, NFSv4 clients not aware of the three  
>> optional
>> attributes would not be aware of the restrictions imposed by those  
>> masks when
>> querying for the ACL. This would create an interoperability  
>> problem, and
>> possible security holes. To solve this problem, we can extend the  
>> GETATTR
>> operation as follows:
>>
>> When a client requests the ACL attribute, check if it also  
>> requests one or
>> more of the three optional owner_class_mask, group_class_mask, or
>> other_class_mask attributes. If it does, then send the requested  
>> attributes
>> as they are. If the client requests only the ACL without any of  
>> the masks,
>> return an ACL with only effective mask flags set, and with all  
>> other flags
>> removed.
>
> I assume you mean in the ALLOW ACEs only, right?
>
>> Alternate permissions in the ACL can be enabled by either setting  
>> an ACL
>> without providing full mask entries, or by setting the appropriate  
>> bit(s) in
>> the corresponding mask entry or entries.
>
> Yes, I think I understand.

Sorry, but I don't think I understand.  Andreas, what do you mean by  
"Alternate" permissions in that sentence?  It is unclear to me as to  
what happens to the access mask bits outside of the following:   
(collectively, these are the access mask bits that make up the POSIX  
read, write and execute permissions)
ACE4_READ_DATA, ACE4_READ_ATTRIBUTES, ACE4_READ_ACL, ACE4_SYNCHRONIZE  
ACE4_WRITE_DATA, ACE4_APPEND_DATA, ACE4_WRITE_ATTRIBUTES,  
ACE4_DELETE_CHILD and ACE4_EXECUTE

The remaining ones are:
ACE4_WRITE_ACL, ACE4_WRITE_OWNER, ACE4_DELETE, ACE4_READ_NAMED_ATTRS  
and ACE4_WRITE_NAMED_ATTRS

Are these "remaining ones" also given representation in the masks?   
Right away I assumed not, but now I am not sure.


Actually, I think what is confusing me is that before, when talking  
about Additional and Alternate file access control mechanisms, you  
said that: " All others with ACE4_WRITE_ACL, ACE4_WRITE_OWNER,  
ACE4_DELETE_CHILD, and ACE4_DELETE are alternate."

I just wonder how that statement  relates to the statement that  
"Alternate permissions in the ACL can be enabled by either setting an  
ACL without providing full mask entries, or by setting the  
appropriate bit(s) in the corresponding mask entry or entries."


>
>> When comparing POSIX ACLs and the NFSv4 ACL + mask attributes as  
>> proposed
>> here, one obvious difference is that POSIX ACLs have only one mask  
>> entry,
>> while I propose three mask entries here. The reason for this is  
>> that POSIX
>> ACLs can at most grant read, write, and execute permissions, and  
>> so with
>> POSIX ACLs, the File Owner Class permissions are always identical  
>> to the
>> permissions granted to the owner, and the File Other Class  
>> permissions are
>> always identical to the permissions granted to others. With NFSv4  
>> ACLs,
>> OWNER@ and EVERYONE@ entries may grant additional permissions that  
>> go beyond
>> what POSIX read, write, and execute can grant, and we need a  
>> mechanism so
>> that those alternate permissions can be turned off by chmod and  
>> during file
>> create without destroying the permissions.
>
> Given that EVERYONE@ is not equivalent to the POSIX "other" class,  
> it could be trimmed down to two.
>
>> I would appreciate if you could take this alternative proposal into
>> consideration when deciding how to proceed with NFSv4 Minor
>> Version 1 at next week's IETF 66 meeting.
>
> This proposal certainly has its merits.  I have doubts about the  
> feasibility of adding two or three new file attributes, and new as- 
> yet-unimplemented semantics, into the minorversion1 draft.  I have  
> doubts about how this would be implemented on a Windows-based server.
>
> The current design specified in draft-ietf-nfsv4- 
> minorversion1-03.txt has implementation experience -- it's released  
> in Solaris 10 update 3, a shipping product.  It meets strict POSIX  
> requirements for those implementations that choose to conform to  
> POSIX.  I believe it's fully implementable on a Windows-based server.
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
>>> [1] Sam Falkner et al.: NFS Version 4 ACLs, draft-ietf-nfsv4- 
>>> acls-00.txt
>>>
>>> [2] POSIX 1003.1e/2c draft 17 (withdrawn),
>>> http://wt.xpilot.org/publications/posix.1e
>>>
>>> [3] Marius Aamodt Eriksen et al.: Mapping Between NFSv4 and Posix  
>>> Draft
>>> ACLs, draft-ietf-nfsv4-acl-mapping-04.txt
>>>
>>> [4] Spencer Shepler (editor): NFSv4 Minor Version 1,
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


--Boundary_(ID_yZ6sA2R8WuFZGnATmnS8Tg)
Content-type: text/html; charset=ISO-8859-1
Content-transfer-encoding: QUOTED-PRINTABLE

<HTML><BODY style=3D"word-wrap: break-word; -khtml-nbsp-mode: space; =
-khtml-line-break: after-white-space; ">Hi=A0Andreas,<DIV><BR class=
=3D"khtml-block-placeholder"></DIV><DIV>I have a couple additional qu=
estions and comments.=A0 See those inline...</DIV><DIV><BR class=3D"k=
html-block-placeholder"></DIV><DIV>Thanks,</DIV><DIV>Lisa</DIV><DIV><=
BR class=3D"khtml-block-placeholder"></DIV><DIV><DIV><SPAN class=3D"A=
pple-style-span"><DIV>On Jul 7, 2006, at 9:45 PM, Sam Falkner wrote:<=
/DIV><BR class=3D"Apple-interchange-newline"><BLOCKQUOTE type=3D"cite=
"><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0p=
x; margin-left: 0px; ">On Jul 7, 2006, at 5:55 AM, Andreas Gruenbache=
r wrote:</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margi=
n-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOC=
KQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; ">On Monday, 3. July 2006 23:=
10, Andreas Gruenbacher wrote:</DIV> <BLOCKQUOTE type=3D"cite"><DIV s=
tyle=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margi=
n-left: 0px; ">Hello,</DIV><DIV style=3D"margin-top: 0px; margin-righ=
t: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR=
></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-botto=
m: 0px; margin-left: 0px; ">I have been thinking about the problems o=
f interaction between NFSv4 ACLs</DIV><DIV style=3D"margin-top: 0px; =
margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">and POSIX,=
 and particularly about the issue of masking permissions through</DIV=
><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px=
; margin-left: 0px; ">chmod and after creating files or directories.<=
/DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0px; =
margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><=
DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; =
margin-left: 0px; ">Here is a follow-up after some personal feedback =
=66rom Sam. I believe that</DIV><DIV style=3D"margin-top: 0px; margin=
-right: 0px; margin-bottom: 0px; margin-left: 0px; ">draft-ietf-nfsv4=
-acls-00 is not ready to become part of the NFSv4 Minor</DIV><DIV sty=
le=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-=
left: 0px; ">Version 1 RFC: some assumptions are not correct from a P=
OSIX point of view,</DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; ">and the way how chmod a=
nd file create modes are applied to NFSv4 ACLs is weak</DIV><DIV styl=
e=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-l=
eft: 0px; ">and not guaranteed to be correct.</DIV> </BLOCKQUOTE><DIV=
 style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; mar=
gin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top=
: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">I d=
isagree -- see below.</DIV><DIV style=3D"margin-top: 0px; margin-righ=
t: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR=
></DIV> <BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; marg=
in-right: 0px; margin-bottom: 0px; margin-left: 0px; ">I will first t=
ry to clarify some of the points I tried to make in the previous</DIV=
><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px=
; margin-left: 0px; ">posting and point out deficiencies in draft-iet=
f-nfsv4-acls-00. Then I will</DIV><DIV style=3D"margin-top: 0px; marg=
in-right: 0px; margin-bottom: 0px; margin-left: 0px; ">propose an alt=
ernative design which is more correct than introducing DENY</DIV><DIV=
 style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; mar=
gin-left: 0px; ">entries to mask permissions. (As a bonus, it is easi=
er to implement. too.)</DIV><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><B=
R></DIV> <BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; mar=
gin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">On a UNIX sys=
tem that supports NFSv4 ACLs natively, I think we should try</DIV><DI=
V style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; ma=
rgin-left: 0px; ">to accept as wide a range of NFSv4 ACLs as possible=
, but we must make sure</DIV><DIV style=3D"margin-top: 0px; margin-ri=
ght: 0px; margin-bottom: 0px; margin-left: 0px; ">that we can preserv=
e POSIX semantics. In particular, this means that ACLs</DIV><DIV styl=
e=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-l=
eft: 0px; ">may contain ACEs for users other than OWNER@, GROUP@, and=
 EVERYONE@, and</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; ">that chmod(2) must continue=
 to provide the same kinds of guarantees as</DIV><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "=
>without NFSv4 ACLs.</DIV><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR>=
</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom=
: 0px; margin-left: 0px; ">I am assuming here that NFSv4 ACLs shall b=
e an additional rather than an</DIV><DIV style=3D"margin-top: 0px; ma=
rgin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">alternate fi=
le access control mechanism in the POSIX sense: Alternate file</DIV><=
DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; =
margin-left: 0px; ">access control mechanisms must ``be enabled only =
by explicit user action,</DIV><DIV style=3D"margin-top: 0px; margin-r=
ight: 0px; margin-bottom: 0px; margin-left: 0px; ">on a per-file basi=
s by the file owner or a user with the appropriate</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">privilege'', and must ``be disabled for a file after the f=
ile permission</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; ">bits are changed for that fi=
le with chmod( )'' according to POSIX. In other</DIV><DIV style=3D"ma=
rgin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0p=
x; ">words, newly created files or directories would have alternate f=
ile access</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">control mechanisms disabled. Thi=
s would render NFSv4 ACLs essentially</DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">usele=
ss for UNIX processes, because they would almost always be disabled,<=
/DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom:=
 0px; margin-left: 0px; ">and would only work for remote processes un=
til a POSIX process chmods a</DIV><DIV style=3D"margin-top: 0px; marg=
in-right: 0px; margin-bottom: 0px; margin-left: 0px; ">file or create=
s a directory, which wouldn't get us very far.</DIV> </BLOCKQUOTE><DI=
V style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; ma=
rgin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-to=
p: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">As=
 Sam pointed out, a subset of NFSv4 ACLs maps to an additional file a=
ccess</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-b=
ottom: 0px; margin-left: 0px; ">control mechanism, while the rest goe=
s beyond that, and therefore is an</DIV><DIV style=3D"margin-top: 0px=
; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">alternat=
e file access control mechanism.</DIV> </BLOCKQUOTE><DIV style=3D"mar=
gin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px=
; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin=
-right: 0px; margin-bottom: 0px; margin-left: 0px; ">Yes -- ALLOW ACE=
s are alternate file access control, and DENY ACEs are additional fil=
e access control.</DIV><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></D=
IV> <BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-r=
ight: 0px; margin-bottom: 0px; margin-left: 0px; ">It is important to=
 understand how POSIX defines additional file access control</DIV><DI=
V style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; ma=
rgin-left: 0px; ">mechanisms:</DIV><DIV style=3D"margin-top: 0px; mar=
gin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14p=
x; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; marg=
in-bottom: 0px; margin-left: 0px; ">[] 3.4 Additional File Access Con=
trol Mechanism</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; ">[] An implementation-defined=
 mechanism that is layered upon the access control</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">[]<SPAN class=3D"Apple-converted-space">=A0 </SPAN>mechani=
sms defined here, but which do not grant permissions beyond those</DI=
V><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0p=
x; margin-left: 0px; ">[]<SPAN class=3D"Apple-converted-space">=A0 </=
SPAN>defined herein, although they may further restrict them.</DIV><D=
IV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; m=
argin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-t=
op: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">I=
n other words, when a file has just been created and after chmod, the=
 file</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-b=
ottom: 0px; margin-left: 0px; ">mode permission bits define an upper =
bound to the permissions granted to</DIV><DIV style=3D"margin-top: 0p=
x; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">anyone =
on the system, and nobody has additional permissions. Additional</DIV=
><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px=
; margin-left: 0px; ">permissions (as an alternate file access contro=
l mechanism) may be</DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; ">enabled explicitly, but=
 the next chmod must disable them again.</DIV> </BLOCKQUOTE><DIV styl=
e=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-l=
eft: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px=
; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">The use =
of the word "Additional" is confusing in the above sentence.<SPAN cla=
ss=3D"Apple-converted-space">=A0 </SPAN>:-)<SPAN class=3D"Apple-conve=
rted-space">=A0 </SPAN>I think you mean "more", or similar, but "Addi=
tional" has a very specific meaning which (I think) isn't what you me=
an.</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bot=
tom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOT=
E type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">We can classify the permissions =
that NFSv4 ACLs grant into additional and</DIV><DIV style=3D"margin-t=
op: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">a=
lternate mechanisms as follows: everything covered by the POSIX</DIV>=
<DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px;=
 margin-left: 0px; ">read/write/execute permissions (such as ACE4_REA=
D_DATA, but also</DIV><DIV style=3D"margin-top: 0px; margin-right: 0p=
x; margin-bottom: 0px; margin-left: 0px; ">ACE4_APPEND_DATA) is addit=
ional, while everything beyond that (such as</DIV><DIV style=3D"margi=
n-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; =
">ACE4_WRITE_OWNER) is alternate.</DIV> </BLOCKQUOTE><DIV style=3D"ma=
rgin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0p=
x; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margi=
n-right: 0px; margin-bottom: 0px; margin-left: 0px; ">Note well: this=
 is quite different from draft-ietf-nfsv4-minorversion1-03.txt, i.e. =
this is an alternate proposal.</DIV><DIV style=3D"margin-top: 0px; ma=
rgin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14=
px; "><BR></DIV> <BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">Under=
 this definition, all NFSv4 ACLs that</DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">grant=
 no more than ACE4_READ_DATA, ACE4_LIST_DIRECTORY, ACE4_WRITE_DATA,</=
DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: =
0px; margin-left: 0px; ">ACE4_ADD_FILE, ACE4_APPEND_DATA, ACE4_ADD_SU=
BDIRECTORY,</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; ma=
rgin-bottom: 0px; margin-left: 0px; ">ACE4_READ_NAMED_ATTRS, ACE4_WRI=
TE_NAMED_ATTRS, ACE4_EXECUTE,</DIV><DIV style=3D"margin-top: 0px; mar=
gin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">ACE4_READ_ATT=
RIBUTES, ACE4_WRITE_ATTRIBUTES, ACE4_READ_ACL, and</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">ACE4_SYNCHRONIZE would count as additional access control =
mechanisms. All</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; ">others with ACE4_WRITE_ACL,=
 ACE4_WRITE_OWNER, ACE4_DELETE_CHILD, and</DIV><DIV style=3D"margin-t=
op: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">A=
CE4_DELETE are alternate.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top=
: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-h=
eight: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; ">I don't understand what=
 is gained by this designation of additional access control mechanism=
s.<SPAN class=3D"Apple-converted-space">=A0 </SPAN>If you really say =
that this ACL:</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV>=
<DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px;=
 margin-left: 0px; ">OWNER@:read_data:allow</DIV><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "=
><A href=3D"mailto:friend@your.com">friend@your.com</A>:read_data:all=
ow</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bott=
om: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">is additional file access control, then what is the mode o=
n such a file?<SPAN class=3D"Apple-converted-space">=A0 </SPAN>Unless=
 the mode says "group can read", then <A href=3D"mailto:friend@your.c=
om">friend@your.com</A> wouldn't be able to read, if the ACL is addit=
ional file access control.<SPAN class=3D"Apple-converted-space">=A0 <=
/SPAN>What if you want <A href=3D"mailto:friend@your.com">friend@your=
.com</A> to be able to read, but you don't want the file's owning gro=
up to read?</DIV></BLOCKQUOTE><DIV><BR class=3D"khtml-block-placehold=
er"></DIV><DIV>1.) If ACEs with ACE4_WRITE_ACL, ACE4_WRITE_OWNER, ACE=
4_DELETE_CHILD and ACE4_DELETE are alternate access control mechanism=
s, what will happen to ACEs with these access mask bits set upon chmo=
d of the file?</DIV><DIV><BR class=3D"khtml-block-placeholder"></DIV>=
<DIV>For example, if we have the following ACL:</DIV><DIV>=A0=A0 =
=A0<A href=3D"mailto:lisa@sun.com">lisa@sun.com</A>:ACE4_WRITE_ACL:de=
ny</DIV><DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV><SPAN c=
lass=3D"Apple-tab-span" style=3D"white-space:pre">=09=09</SPAN>or eve=
n</DIV><DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV>=A0=A0 =
=A0<A href=3D"mailto:lisa@sun.com">lisa@sun.com</A>:ACE4_WRITE_OWNER:=
allow</DIV><DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV>Upon=
 chmod we would have to disable them (however an implementation choos=
es to) and effectively remove it.</DIV><DIV><BR class=3D"khtml-block-=
placeholder"></DIV><DIV>The thing that I have a problem with here is =
the fact that the changing of the file permission bits will affect wh=
at access has been defined in the ACL for things such as ACE4_WRITE_O=
WNER, ACE4_WRITE_ACL, etc.=A0 A user setting the file permission bits=
 is not saying anything about what they want to be done with any ACEs=
 that include the ACE4_WRITE_OWNER mask bit.=A0 Why would we want to =
mess with them?</DIV><DIV><BR class=3D"khtml-block-placeholder"></DIV=
><DIV>2.)=A0So, what if an ACE contained a mixture of the access mask=
 bits that are alternate and additional?</DIV><DIV><BR class=3D"khtml=
-block-placeholder"></DIV><DIV>Would we allow having ACE4_READ_DATA a=
nd ACE4_WRITE_ACL in the same ACE?=A0 What would happen to an ACE suc=
h as this upon chmod?</DIV><BR><BLOCKQUOTE type=3D"cite"><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"cite"><DI=
V style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; ma=
rgin-left: 0px; ">As said already, the POSIX file mode permission bit=
s define the permissions of</DIV><DIV style=3D"margin-top: 0px; margi=
n-right: 0px; margin-bottom: 0px; margin-left: 0px; ">three classes: =
owner, group, and other. An additional file access control</DIV><DIV =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; marg=
in-left: 0px; ">mechanism may only further restrict the permissions g=
ranted to those classes.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top:=
 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-he=
ight: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"cite"><DIV style=3D"marg=
in-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px;=
 ">To map NFSv4 ACLs to an additional file access control mechanism,<=
/DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0px; =
margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> =
<BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-c=
onverted-space">=A0</SPAN>- we must map each NFSv4 ACL entry to exact=
ly one of the three classes.</DIV><DIV style=3D"margin-top: 0px; marg=
in-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px=
; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margi=
n-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-converted-spa=
ce">=A0</SPAN>- we must ensure that the ACL does not grant any permis=
sions that go beyond</DIV><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-c=
onverted-space">=A0=A0 </SPAN>the class permissions after a chmod or =
create.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-righ=
t: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR=
></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-botto=
m: 0px; margin-left: 0px; ">Additional File Access Control must not g=
rant beyond the class permissions *ever*, not just after create or ch=
mod.</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUO=
TE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px; ma=
rgin-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-converted-=
space">=A0</SPAN>- in particular, we must ensure that the ACL grants =
no "alternate"</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-convert=
ed-space">=A0=A0 </SPAN>permissions after a chmod or create.</DIV> </=
BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-b=
ottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV styl=
e=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-l=
eft: 0px; ">I don't understand this; you began this section with "To =
map NFSv4 ACLs to an additional...", but here, you seem to be describ=
ing ACLs as an alternate file access control mechanism.</DIV><DIV sty=
le=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-=
left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"cite"><=
DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; =
margin-left: 0px; ">We are free to provide mechanisms by which more p=
ermissions may be enabled by</DIV><DIV style=3D"margin-top: 0px; marg=
in-right: 0px; margin-bottom: 0px; margin-left: 0px; ">explicit user =
action, on a per-file basis by the file owner or a user with</DIV><DI=
V style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; ma=
rgin-left: 0px; ">the appropriate privilege, according to POSIX.</DIV=
> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0px; marg=
in-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLO=
CKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0p=
x; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DI=
V><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0p=
x; margin-left: 0px; ">The POSIX definitions of the three file permis=
sion classes are:</DIV><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></D=
IV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0=
px; margin-left: 0px; ">[] 3.173 File Owner Class</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">[] The property of a file indicating access permissions fo=
r a process related</DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; ">[] to the user identifi=
cation of a process. A process is in the file owner</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">[] class of a file if the effective user ID of the process=
 matches the user ID</DIV><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; ">[] of the file.</DIV><=
DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; =
margin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-=
top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">=
[] 3.166 File Group Class</DIV><DIV style=3D"margin-top: 0px; margin-=
right: 0px; margin-bottom: 0px; margin-left: 0px; ">[] The property o=
f a file indicating access permissions for a process</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">[] related to the group identification of a process. A pro=
cess is in</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">[] the file group class of a fil=
e if the process is not in the file owner</DIV><DIV style=3D"margin-t=
op: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">[=
] class and if the effective group ID or one of the supplementary gro=
up</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bott=
om: 0px; margin-left: 0px; ">[] IDs of the process matches the group =
ID associated with the file. Other</DIV><DIV style=3D"margin-top: 0px=
; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">[] membe=
rs of the class may be implementation-defined.</DIV><DIV style=3D"mar=
gin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px=
; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin=
-right: 0px; margin-bottom: 0px; margin-left: 0px; ">[] 3.172 File Ot=
her Class</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; marg=
in-bottom: 0px; margin-left: 0px; ">[] The property of a file indicat=
ing access permissions for a process related</DIV><DIV style=3D"margi=
n-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; =
">[] to the user and group identification of a process. A process is =
in the file</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; ma=
rgin-bottom: 0px; margin-left: 0px; ">[] other class of a file if the=
 process is not in the file owner class or file</DIV><DIV style=3D"ma=
rgin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0p=
x; ">[] group class.</DIV><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR>=
</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom=
: 0px; margin-left: 0px; ">The key fact in these definitions is that =
an implementation may define</DIV><DIV style=3D"margin-top: 0px; marg=
in-right: 0px; margin-bottom: 0px; margin-left: 0px; ">additional mem=
bers of the File Group Class, while the other classes are not</DIV><D=
IV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; m=
argin-left: 0px; ">extensible.</DIV><DIV style=3D"margin-top: 0px; ma=
rgin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14=
px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">Under this definition, we end up=
 with the following mapping:</DIV><DIV style=3D"margin-top: 0px; marg=
in-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px=
; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margi=
n-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-converted-spa=
ce">=A0</SPAN>- OWNER@ entries are in the File Owner Class,</DIV><DIV=
 style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; mar=
gin-left: 0px; "><SPAN class=3D"Apple-converted-space">=A0</SPAN>- EV=
ERYONE@ entries are in the File Other Class,</DIV> </BLOCKQUOTE><DIV =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; marg=
in-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top:=
 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">No, =
I don't think EVERYONE@ is in the File Other Class.<SPAN class=3D"App=
le-converted-space">=A0 </SPAN>Given this ACL:</DIV><DIV style=3D"mar=
gin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px=
; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin=
-right: 0px; margin-bottom: 0px; margin-left: 0px; ">EVERYONE@:read_d=
ata:deny</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margi=
n-bottom: 0px; margin-left: 0px; ">OWNER@:read_data:allow</DIV><DIV s=
tyle=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margi=
n-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">the o=
wner would NOT be able to read.<SPAN class=3D"Apple-converted-space">=
=A0 </SPAN>In other words, file owner class and file group class are =
also affected by EVERYONE@ ACEs.</DIV></BLOCKQUOTE><DIV><BR class=
=3D"khtml-block-placeholder"></DIV><DIV>I'll restate it because it is=
 important: EVERYONE@ is not equivalent to the File Other Class.=A0 I=
 believe the original intention was to have it be equivalent to one t=
he Windows "well known sid":=A0 =A0<A href=3D"http://msdn.microsoft.c=
om/library/default.asp?url=3D/library/en-us/secauthz/security/well_kn=
own_sid_type.asp">http://msdn.microsoft.com/library/default.asp?url=
=3D/library/en-us/secauthz/security/well_known_sid_type.asp</A></DIV>=
<DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV><BR class=3D"kh=
tml-block-placeholder"></DIV><DIV>Really with NFSv4 ACLs, the only wa=
y we have the equivalent of a File Other Class is if the EVERYONE@ en=
tries come at the end of the ACL.=A0 Such as this:</DIV><DIV><BR clas=
s=3D"khtml-block-placeholder"></DIV><DIV>=A0 =A0 =A0owner@:execute:de=
ny</DIV><DIV>=A0 =A0 =A0owner@:read_data/write_data/append_data/write=
_xattr/write_attributes</DIV><DIV>=A0 =A0 =A0 =A0=A0 /write_acl/write=
_owner:allow</DIV><DIV>=A0 =A0 =A0group@:write_data/append_data/execu=
te:deny</DIV><DIV>=A0 =A0 =A0group@:read_data:allow</DIV><DIV>=A0 =
=A0 =A0everyone@:write_data/append_data/write_xattr/execute/write_att=
ributes</DIV><DIV>=A0 =A0 =A0 =A0=A0 /write_acl/write_owner:deny</DIV=
><DIV>=A0 =A0 =A0everyone@:read_data/read_xattr/read_attributes/read_=
acl/synchronize</DIV><DIV>=A0 =A0 =A0 =A0=A0 :allow</DIV><DIV><BR cla=
ss=3D"khtml-block-placeholder"></DIV><BR><BLOCKQUOTE type=3D"cite"><D=
IV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; m=
argin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"c=
ite"><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom:=
 0px; margin-left: 0px; "><SPAN class=3D"Apple-converted-space">=A0</=
SPAN>- every other entry is in the File Group Class(*).</DIV> </BLOCK=
QUOTE><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom=
: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">including EVERYONE@.<SPAN class=3D"Apple-converted-space">=
=A0 </SPAN>;-)</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV>=
 <BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-righ=
t: 0px; margin-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-=
converted-space">=A0</SPAN>(*) User entries for the user who is the c=
urrent file owner are a special</DIV><DIV style=3D"margin-top: 0px; m=
argin-right: 0px; margin-bottom: 0px; margin-left: 0px; "><SPAN class=
=3D"Apple-converted-space">=A0=A0 =A0 </SPAN>case: due to how the NFS=
v4 ACL permission check algorithm is specified,</DIV><DIV style=3D"ma=
rgin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0p=
x; "><SPAN class=3D"Apple-converted-space">=A0=A0 =A0 </SPAN>I believ=
e that they should be put in the OWNER@ class.</DIV> </BLOCKQUOTE><DI=
V style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; ma=
rgin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-to=
p: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">Th=
e current minorversion1 draft has a similar design constraint.</DIV><=
DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; =
margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=
=3D"cite"><BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; ma=
rgin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">Note that th=
is definition is in line with POSIX 1003.1e draft 17 [2], while</DIV>=
<DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px;=
 margin-left: 0px; ">it conflicts with the IETF NFS Version 4 ACLs dr=
aft [1], which associates</DIV><DIV style=3D"margin-top: 0px; margin-=
right: 0px; margin-bottom: 0px; margin-left: 0px; ">only GROUP@ entri=
es with the group file mode permission bits in section</DIV><DIV styl=
e=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-l=
eft: 0px; ">5.1. The relevant text of IETF NFS Version 4 ACLs draft [=
1] is also found</DIV><DIV style=3D"margin-top: 0px; margin-right: 0p=
x; margin-bottom: 0px; margin-left: 0px; ">in NFSv4 Minor Version 1 [=
4].</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></D=
IV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0=
px; margin-left: 0px; ">Section 5.1 of [1] needs to be fixed: we must=
 set the permission bits so that</DIV><DIV style=3D"margin-top: 0px; =
margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">they are a=
 superset of the permissions of all the entries in the respective</DI=
V><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0p=
x; margin-left: 0px; ">class. (We cannot represent permissions that a=
re not supersets of</DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; ">POSIX read, write, exec=
ute in the class, but that is not a problem, as we will</DIV><DIV sty=
le=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-=
left: 0px; ">see later.)</DIV> </BLOCKQUOTE><DIV style=3D"margin-top:=
 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-he=
ight: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: =
0px; margin-bottom: 0px; margin-left: 0px; ">We must do so carefully.=
<SPAN class=3D"Apple-converted-space">=A0 </SPAN>I'm not convinced th=
at a superset is the best way to go, but we should talk about this la=
ter.</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUO=
TE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px; ma=
rgin-bottom: 0px; margin-left: 0px; ">Non-monotonic permissions</DIV>=
<DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px;=
 margin-left: 0px; ">=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</DIV><DIV style=3D"margin-top: 0px; ma=
rgin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14=
px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">Note that with arbitrary NFSV4 A=
CLs, the permissions granted to a process from</DIV><DIV style=3D"mar=
gin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px=
; ">multiple ACL entries will accumulate. This means that permissions=
 across</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin=
-bottom: 0px; margin-left: 0px; ">multiple classes may accumulate as =
well. This can be prevented with DENY</DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">entri=
es in the ACL, e.g.,</DIV><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR>=
</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom=
: 0px; margin-left: 0px; "><SPAN class=3D"Apple-tab-span" style=3D"wh=
ite-space:pre">=09</SPAN>OWNER@:mask1::ALLOW</DIV><DIV style=3D"margi=
n-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; =
"><SPAN class=3D"Apple-tab-span" style=3D"white-space:pre">=09</SPAN>=
OWNER@:^mask1::DENY</DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-ta=
b-span" style=3D"white-space:pre">=09</SPAN>user@domain:mask2::ALLOW<=
/DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom:=
 0px; margin-left: 0px; "><SPAN class=3D"Apple-tab-span" style=3D"whi=
te-space:pre">=09</SPAN>group@domain:mask3:ACE4_IDENTIFIER_GROUP:ALLO=
W</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-botto=
m: 0px; margin-left: 0px; "><SPAN class=3D"Apple-tab-span" style=3D"w=
hite-space:pre">=09</SPAN>user@domain:^mask2::DENY</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; "><SPAN class=3D"Apple-tab-span" style=3D"white-space:pre">=
=09</SPAN>group@domain:^mask3:ACE4_IDENTIFIER_GROUP:DENY</DIV><DIV st=
yle=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin=
-left: 0px; "><SPAN class=3D"Apple-tab-span" style=3D"white-space:pre=
">=09</SPAN>EVERYONE:mask4::ALLOW</DIV><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height:=
 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; =
margin-bottom: 0px; margin-left: 0px; ">This means that we will not h=
ave to deal with this special case when computing</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">the file mode permission bits, and we can achieve consiste=
ncy by forcing ACLs</DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; ">to be "well structured"=
.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV=
><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px=
; margin-left: 0px; ">Yuck!<SPAN class=3D"Apple-converted-space">=
=A0 </SPAN>I'm glad you're not proposing this as a general NFSv4 ACL =
model.<SPAN class=3D"Apple-converted-space">=A0 </SPAN>:-)</DIV><DIV =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; marg=
in-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"cite=
"><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0p=
x; margin-left: 0px; ">We could also leave this as an implementation =
consideration: ACLs which are</DIV><DIV style=3D"margin-top: 0px; mar=
gin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">not "well str=
uctured" in the above sense will grant permissions that go</DIV><DIV =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; marg=
in-left: 0px; ">beyond what an additional access control mechanism ma=
y grant *only* for</DIV><DIV style=3D"margin-top: 0px; margin-right: =
0px; margin-bottom: 0px; margin-left: 0px; ">non-monotonic file mode =
permission bits. With non-monotonic I mean file mode</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">permission bits which grant more permissions to the group =
class than to the</DIV><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; ">owner class, or more perm=
issions to the other class than to the group class.</DIV> </BLOCKQUOT=
E><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0p=
x; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"marg=
in-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px;=
 ">I'm sorry, I just don't follow that paragraph.</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"cite"><BL=
OCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; ">We want chmod(2) to be no=
n-destructive, so that a chmod to a more</DIV><DIV style=3D"margin-to=
p: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">re=
strictive mode and back to the original mode will leave the file with=
 the</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; ">same permissions as before the changes=
.</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-botto=
m: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">[...]</DIV><DIV style=3D"margin-top: 0px; margin-right: 0p=
x; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DI=
V><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0p=
x; margin-left: 0px; ">POSIX ACLs have solved the non-destructiveness=
 problem by introducing a</DIV><DIV style=3D"margin-top: 0px; margin-=
right: 0px; margin-bottom: 0px; margin-left: 0px; ">mask ACL entry: t=
he mask entry applies to all group class entries, and</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">defines an upper bound to the permissions those entries ma=
y grant. POSIX</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; ">ACLs only have ACL entries t=
hat allow permissions, and only specify READ,</DIV><DIV style=3D"marg=
in-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px;=
 ">WRITE, and EXECUTE permissions. Therefore, the owner class and oth=
er class</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margi=
n-bottom: 0px; margin-left: 0px; ">permissions are the permissions gr=
anted to the owner and to others,</DIV><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">respectiv=
ely. (Note the difference between these others and NFSv4's</DIV><DIV =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; marg=
in-left: 0px; ">EVERYONE@ special identifier).</DIV><DIV style=3D"mar=
gin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px=
; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin=
-right: 0px; margin-bottom: 0px; margin-left: 0px; ">The mask concept=
 is not part of NFSv4 ACLs. Marius A. Eriksen and others</DIV><DIV st=
yle=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin=
-left: 0px; ">have proposed to emulate the POSIX ACL mask entry by pr=
epending (with</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; ">exception of OWNER@ and EVER=
YONE@ ACEs) each ALLOW ACE with a DENY ACE for</DIV><DIV style=3D"mar=
gin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px=
; ">the same user, group, or special identifier as in the ALLOW ACE. =
The</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bot=
tom: 0px; margin-left: 0px; ">permissions in the DENY ACE are set so =
that the entry denies the</DIV><DIV style=3D"margin-top: 0px; margin-=
right: 0px; margin-bottom: 0px; margin-left: 0px; ">permissions not g=
ranted by the mask.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height:=
 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; =
margin-bottom: 0px; margin-left: 0px; ">Internet draft-ietf-nfsv4-acl=
s-00.txt [1] uses the same mechanism to implement</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">masking.</DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR><=
/DIV> <BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin=
-right: 0px; margin-bottom: 0px; margin-left: 0px; ">Unless we accept=
 a very specific form of NFSv4 ACLs only (which would</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">contradict the goal stated at the top of this message, and=
 which would mean</DIV><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; ">that interoperability wit=
h anything but POSIX ACLs would become difficult),</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">there is no easy way to tell DENY entries introduced to em=
ulate the mask</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; ">from DENY entries added by h=
and.</DIV> </BLOCKQUOTE></BLOCKQUOTE><DIV style=3D"margin-top: 0px; m=
argin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 1=
4px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; ma=
rgin-bottom: 0px; margin-left: 0px; ">I would refute this; see below.=
</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom=
: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE t=
ype=3D"cite"><BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">This has =
two potential consequences:</DIV><DIV style=3D"margin-top: 0px; margi=
n-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px;=
 "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin=
-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-converted-spac=
e">=A0</SPAN>- First, if we fail to identify such a mask-emulation DE=
NY entry, we may</DIV><DIV style=3D"margin-top: 0px; margin-right: 0p=
x; margin-bottom: 0px; margin-left: 0px; ">end up inserting another s=
uch entry. We might end up doing so repeatedly.</DIV> </BLOCKQUOTE></=
BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-b=
ottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV styl=
e=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-l=
eft: 0px; ">But we will not ever fail to identify such a mask-emulati=
on DENY entry, when it is one that was created by a previous chmod.<S=
PAN class=3D"Apple-converted-space">=A0 </SPAN>Only in a degenerate c=
ase of modify-acl-carefully, chmod, modify-acl-carefully, chmod, etc.=
, would you get a growing ACL problem.</DIV><DIV style=3D"margin-top:=
 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-he=
ight: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"cite"><BLOCKQUOTE type=
=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-converted-space">=
=A0</SPAN>- Second, we may take a user-provided DENY entry for a mask=
-emulation DENY</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; ">entry, and clear mask bits =
=66rom that entry. This would contradict the</DIV><DIV style=3D"margi=
n-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; =
">user's intention. So the approach of inserting mask-emulation DENY =
entries</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin=
-bottom: 0px; margin-left: 0px; ">is not good enough in general.</DIV=
> </BLOCKQUOTE></BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><B=
R></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bott=
om: 0px; margin-left: 0px; ">A user-provided DENY entry would have to=
 fit into a very specific and somewhat nonsensical form in order to b=
e misidentified.<SPAN class=3D"Apple-converted-space">=A0 </SPAN>Here=
's an example:</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV>=
<DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px;=
 margin-left: 0px; "><A href=3D"mailto:samf@sun.com">samf@sun.com</A>=
:read_data:deny</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; "><A href=3D"mailto:samf@sun.=
com">samf@sun.com</A>:read_data:allow</DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-hei=
ght: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; ">If a "chmod 444" were don=
e, the deny ACE above would be modified.<SPAN class=3D"Apple-converte=
d-space">=A0 </SPAN>Any other cases of chmod modifying a user-provide=
d ACE would have to be essentially the same as the above example.<SPA=
N class=3D"Apple-converted-space">=A0 </SPAN>I think that that's an a=
cceptable situation.</DIV><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR>=
</DIV> <BLOCKQUOTE type=3D"cite"><BLOCKQUOTE type=3D"cite"><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">(Mapping between NFSv4 and POSIX ACLs does</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">not have this problem, because POSIX ACLs don't have DENY =
ACEs.)</DIV> </BLOCKQUOTE></BLOCKQUOTE><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height:=
 14px; "><BR></DIV> <BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-to=
p: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">Th=
erefore, the mechanism described in section 5.3 is not suitable for o=
ur</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bott=
om: 0px; margin-left: 0px; ">purposes, and we need to replace it with=
 something better.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; =
margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: =
14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; m=
argin-bottom: 0px; margin-left: 0px; ">I don't agree that 5.3 is not =
suitable, but I would love to see something better.</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"cite"><BL=
OCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; ">In my opinion, there are =
two possible solutions for this problem: we can</DIV><DIV style=3D"ma=
rgin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0p=
x; ">(1) devise a special kind of NFSv4 ACL entry that we will recogn=
ize as mask</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; ma=
rgin-bottom: 0px; margin-left: 0px; ">entry, or (2) give the owner/gr=
oup/other class permission bits higher</DIV><DIV style=3D"margin-top:=
 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">prio=
rity than the ACL entries, and only allow permissions that are allowe=
d</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-botto=
m: 0px; margin-left: 0px; ">by both the ACEs and their associated cla=
sses.</DIV> </BLOCKQUOTE></BLOCKQUOTE><DIV style=3D"margin-top: 0px; =
margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: =
14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; m=
argin-bottom: 0px; margin-left: 0px; ">Yikes -- I don't like either o=
f the above solutions; let's look at the third...</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"cite"><DI=
V style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; ma=
rgin-left: 0px; ">A third option exists as well which fits in very we=
ll with POSIX and can be</DIV><DIV style=3D"margin-top: 0px; margin-r=
ight: 0px; margin-bottom: 0px; margin-left: 0px; ">implemented in NFS=
v4 in a backward compatible way.</DIV><DIV style=3D"margin-top: 0px; =
margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: =
14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; m=
argin-bottom: 0px; margin-left: 0px; ">Alternative Proposal</DIV><DIV=
 style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; mar=
gin-left: 0px; ">=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; m=
argin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><D=
IV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; m=
argin-left: 0px; ">Instead of adding DENY entries to the ACL for the =
purpose of masking, attach</DIV><DIV style=3D"margin-top: 0px; margin=
-right: 0px; margin-bottom: 0px; margin-left: 0px; ">three optional a=
ttributes to each file: owner_class_mask, group_class_mask,</DIV><DIV=
 style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; mar=
gin-left: 0px; ">and other_class_mask. When those attributes are pres=
ent, they define which</DIV><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; ">permissions in an AC=
E are effective.</DIV><DIV style=3D"margin-top: 0px; margin-right: 0p=
x; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DI=
V><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0p=
x; margin-left: 0px; ">Each ACE is is restricted by one of these mask=
 attributes in each access</DIV><DIV style=3D"margin-top: 0px; margin=
-right: 0px; margin-bottom: 0px; margin-left: 0px; ">check:</DIV><DIV=
 style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; mar=
gin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top=
: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "><SP=
AN class=3D"Apple-converted-space">=A0</SPAN>- OWNER@ entries and ent=
ries for the user@domain that currently owns the file</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; "><SPAN class=3D"Apple-converted-space">=A0=A0 </SPAN>are re=
stricted by owner_class_mask.</DIV><DIV style=3D"margin-top: 0px; mar=
gin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14p=
x; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; marg=
in-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-converted-sp=
ace">=A0</SPAN>- EVERYONE@ entries are restricted by other_class_mask=
.</DIV></BLOCKQUOTE></BLOCKQUOTE><DIV><BR class=3D"khtml-block-placeh=
older"></DIV><DIV>Again, EVERYONE@ is not equivalent to the File Othe=
r Class.=A0 Depending on where an ACE pertaining to EVERYONE@ is in t=
he ACL, it could even refer to the owner and the owning group.</DIV><=
BR><BLOCKQUOTE type=3D"cite"><BLOCKQUOTE type=3D"cite"><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "><SPAN cla=
ss=3D"Apple-converted-space">=A0</SPAN>- All other entries are restri=
cted by group_class_mask.</DIV><DIV style=3D"margin-top: 0px; margin-=
right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "=
><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-b=
ottom: 0px; margin-left: 0px; ">The effective permissions are compute=
d as the bitwise and (&amp;) of the ACE mask</DIV><DIV style=3D"margi=
n-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; =
">and the associated class_mask attribute.</DIV> </BLOCKQUOTE><DIV st=
yle=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin=
-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0=
px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">I take=
 it you mean that "the effective access mask bits for ACEs of type AL=
LOW"?</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-b=
ottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQU=
OTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px; m=
argin-bottom: 0px; margin-left: 0px; ">When doing a chmod(2) or when =
applying a create mask, the owner_class_mask,</DIV><DIV style=3D"marg=
in-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px;=
 ">group_class_mask, and other_class_mask attributes are modified acc=
ording to</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; marg=
in-bottom: 0px; margin-left: 0px; ">the owner class, group class, and=
 other class permissions of the mode</DIV><DIV style=3D"margin-top: 0=
px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">parame=
ter as follows:</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV=
><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px=
; margin-left: 0px; "><SPAN class=3D"Apple-converted-space">=A0</SPAN=
>- The POSIX read permission implies the ACE4_READ_DATA, ACE4_READ_AT=
TRIBUTES,</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; marg=
in-bottom: 0px; margin-left: 0px; ">ACE4_READ_ACL, and ACE4_SYNCHRONI=
ZE bitmask flags.</DIV><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></D=
IV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0=
px; margin-left: 0px; "><SPAN class=3D"Apple-converted-space">=A0</SP=
AN>- The POSIX write permission implies the ACE4_WRITE_DATA, ACE4_APP=
END_DATA,</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; marg=
in-bottom: 0px; margin-left: 0px; ">ACE4_WRITE_ATTRIBUTES, ACE4_DELET=
E_CHILD, and ACE4_SYNCHRONIZE bitmask flags.</DIV> </BLOCKQUOTE><DIV =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; marg=
in-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top:=
 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">I'm =
not sure I agree about ACE4_WRITE_ATTRIBUTES, but that's a minor deta=
il.</DIV></BLOCKQUOTE><DIV><BR class=3D"khtml-block-placeholder"></DI=
V>Yes, as [4] says, ACE4_WRITE_ATTRIBUTES is the "Permission to chang=
e the times associated with a file=A0or directory to an arbitrary val=
ue."=A0 Having that included in the POSIX write permission would not =
be correct, but as Sam said, that is minor.<BR><BR><BLOCKQUOTE type=
=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUO=
TE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px; ma=
rgin-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-converted-=
space">=A0</SPAN>- The POSIX execute permission implies the ACE4_EXEC=
UTE mask.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-ri=
ght: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><=
BR></DIV> <BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; ma=
rgin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">This saves u=
s from bloating ACLs with DENY entries, is more efficient when</DIV><=
DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; =
margin-left: 0px; ">doing a chmod, and also saves us from destroying =
permissions in user provided</DIV><DIV style=3D"margin-top: 0px; marg=
in-right: 0px; margin-bottom: 0px; margin-left: 0px; ">DENY entries.<=
/DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0px; =
margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><=
DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; =
margin-left: 0px; ">Yes, but at the cost of adding new file attribute=
s...<SPAN class=3D"Apple-converted-space">=A0 </SPAN>Don't get me wro=
ng, I do see merit in this proposal, but I don't know if it'll be acc=
eptable.</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margi=
n-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOC=
KQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; ">When an ACL is set, then se=
t all mask attributes to the values provided in the</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">same SETATTR operation, and set the remaining mask attribu=
tes to the union of</DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; ">all ALLOW ACL entries i=
n the ACL that the class applies to.</DIV> </BLOCKQUOTE><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">This does=
n't take the ordering of the ACL into account; is this your intention=
?<SPAN class=3D"Apple-converted-space">=A0 </SPAN>So</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">GROUP@:re=
ad_data/write_data:DENY</DIV><DIV style=3D"margin-top: 0px; margin-ri=
ght: 0px; margin-bottom: 0px; margin-left: 0px; ">GROUP@:read_data/wr=
ite_data:ALLOW</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV>=
<DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px;=
 margin-left: 0px; ">would result in a group_class_mask of read_data|=
write_data, right?<SPAN class=3D"Apple-converted-space">=A0 </SPAN>(I=
'm not saying it's wrong, I'm just making sure I understand.)</DIV><D=
IV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; m=
argin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"c=
ite"><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom:=
 0px; margin-left: 0px; ">Without any further changes, NFSv4 clients =
not aware of the three optional</DIV><DIV style=3D"margin-top: 0px; m=
argin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">attributes =
would not be aware of the restrictions imposed by those masks when</D=
IV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0=
px; margin-left: 0px; ">querying for the ACL. This would create an in=
teroperability problem, and</DIV><DIV style=3D"margin-top: 0px; margi=
n-right: 0px; margin-bottom: 0px; margin-left: 0px; ">possible securi=
ty holes. To solve this problem, we can extend the GETATTR</DIV><DIV =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; marg=
in-left: 0px; ">operation as follows:</DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-hei=
ght: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; ">When a client requests th=
e ACL attribute, check if it also requests one or</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">more of the three optional owner_class_mask, group_class_m=
ask, or</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin=
-bottom: 0px; margin-left: 0px; ">other_class_mask attributes. If it =
does, then send the requested attributes</DIV><DIV style=3D"margin-to=
p: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">as=
 they are. If the client requests only the ACL without any of the mas=
ks,</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bot=
tom: 0px; margin-left: 0px; ">return an ACL with only effective mask =
flags set, and with all other flags</DIV><DIV style=3D"margin-top: 0p=
x; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">removed=
.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV=
><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px=
; margin-left: 0px; ">I assume you mean in the ALLOW ACEs only, right=
?</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-botto=
m: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE =
type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px; margi=
n-bottom: 0px; margin-left: 0px; ">Alternate permissions in the ACL c=
an be enabled by either setting an ACL</DIV><DIV style=3D"margin-top:=
 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">with=
out providing full mask entries, or by setting the appropriate bit(s)=
 in</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bot=
tom: 0px; margin-left: 0px; ">the corresponding mask entry or entries=
.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV=
><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px=
; margin-left: 0px; ">Yes, I think I understand.</DIV></BLOCKQUOTE><D=
IV><BR class=3D"khtml-block-placeholder"></DIV>Sorry, but I don't thi=
nk I understand.=A0 Andreas, what do you mean by "Alternate" permissi=
ons in that sentence?=A0 It is unclear to me as to what happens to th=
e access mask bits outside of the following:=A0 (collectively, these =
are the access mask bits that make up the POSIX read, write and execu=
te permissions)</SPAN></DIV><DIV><FONT class=3D"Apple-style-span" col=
or=3D"#010101">ACE4_READ_DATA, ACE4_READ_ATTRIBUTES,=A0ACE4_READ_ACL,=
 ACE4_SYNCHRONIZE=A0ACE4_WRITE_DATA, ACE4_APPEND_DATA,=A0ACE4_WRITE_A=
TTRIBUTES, ACE4_DELETE_CHILD and=A0</FONT>ACE4_EXECUTE</DIV><DIV><BR =
class=3D"khtml-block-placeholder"></DIV><DIV>The remaining ones are:<=
/DIV><DIV>ACE4_WRITE_ACL, ACE4_WRITE_OWNER, ACE4_DELETE, ACE4_READ_NA=
MED_ATTRS and ACE4_WRITE_NAMED_ATTRS</DIV><DIV><BR class=3D"khtml-blo=
ck-placeholder"></DIV><DIV>Are these "remaining ones" also given repr=
esentation in the masks?=A0 Right away I assumed not, but now I am no=
t sure.</DIV><DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV><B=
R class=3D"khtml-block-placeholder"></DIV><DIV>Actually, I think what=
 is confusing me is that before, when talking about Additional and Al=
ternate file access control mechanisms, you said that: "=A0All=A0othe=
rs with ACE4_WRITE_ACL, ACE4_WRITE_OWNER, ACE4_DELETE_CHILD, and=A0AC=
E4_DELETE are alternate."</DIV><DIV><BR class=3D"khtml-block-placehol=
der"></DIV><DIV>I just wonder how that statement=A0 relates to the st=
atement that "Alternate permissions in the ACL can be enabled by eith=
er setting an ACL=A0without providing full mask entries, or by settin=
g the appropriate bit(s) in=A0the corresponding mask entry or entries=
."</DIV><BLOCKQUOTE type=3D"cite"><BLOCKQUOTE type=3D"cite"></BLOCKQU=
OTE></BLOCKQUOTE><DIV><BR class=3D"khtml-block-placeholder"></DIV><BL=
OCKQUOTE type=3D"cite"><BLOCKQUOTE type=3D"cite"></BLOCKQUOTE></BLOCK=
QUOTE><DIV><BR class=3D"khtml-block-placeholder"></DIV><BLOCKQUOTE ty=
pe=3D"cite"></BLOCKQUOTE><BLOCKQUOTE type=3D"cite"><BLOCKQUOTE type=
=3D"cite"></BLOCKQUOTE></BLOCKQUOTE><DIV><BLOCKQUOTE type=3D"cite"><D=
IV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; m=
argin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"c=
ite"><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom:=
 0px; margin-left: 0px; ">When comparing POSIX ACLs and the NFSv4 ACL=
 + mask attributes as proposed</DIV><DIV style=3D"margin-top: 0px; ma=
rgin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">here, one ob=
vious difference is that POSIX ACLs have only one mask entry,</DIV><D=
IV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; m=
argin-left: 0px; ">while I propose three mask entries here. The reaso=
n for this is that POSIX</DIV><DIV style=3D"margin-top: 0px; margin-r=
ight: 0px; margin-bottom: 0px; margin-left: 0px; ">ACLs can at most g=
rant read, write, and execute permissions, and so with</DIV><DIV styl=
e=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-l=
eft: 0px; ">POSIX ACLs, the File Owner Class permissions are always i=
dentical to the</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; ">permissions granted to the =
owner, and the File Other Class permissions are</DIV><DIV style=3D"ma=
rgin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0p=
x; ">always identical to the permissions granted to others. With NFSv=
4 ACLs,</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin=
-bottom: 0px; margin-left: 0px; ">OWNER@ and EVERYONE@ entries may gr=
ant additional permissions that go beyond</DIV><DIV style=3D"margin-t=
op: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">w=
hat POSIX read, write, and execute can grant, and we need a mechanism=
 so</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bot=
tom: 0px; margin-left: 0px; ">that those alternate permissions can be=
 turned off by chmod and during file</DIV><DIV style=3D"margin-top: 0=
px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">create=
 without destroying the permissions.</DIV> </BLOCKQUOTE><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">Given tha=
t EVERYONE@ is not equivalent to the POSIX "other" class, it could be=
 trimmed down to two.</DIV><DIV style=3D"margin-top: 0px; margin-righ=
t: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR=
></DIV> <BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; marg=
in-right: 0px; margin-bottom: 0px; margin-left: 0px; ">I would apprec=
iate if you could take this alternative proposal into</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">consideration when deciding how to proceed with NFSv4 Mino=
r</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-botto=
m: 0px; margin-left: 0px; ">Version 1 at next week's IETF 66 meeting.=
</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV>=
<DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px;=
 margin-left: 0px; ">This proposal certainly has its merits.<SPAN cla=
ss=3D"Apple-converted-space">=A0 </SPAN>I have doubts about the feasi=
bility of adding two or three new file attributes, and new as-yet-uni=
mplemented semantics, into the minorversion1 draft.<SPAN class=3D"App=
le-converted-space">=A0 </SPAN>I have doubts about how this would be =
implemented on a Windows-based server.</DIV><DIV style=3D"margin-top:=
 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-he=
ight: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: =
0px; margin-bottom: 0px; margin-left: 0px; ">The current design speci=
fied in draft-ietf-nfsv4-minorversion1-03.txt has implementation expe=
rience -- it's released in Solaris 10 update 3, a shipping product.<S=
PAN class=3D"Apple-converted-space">=A0 </SPAN>It meets strict POSIX =
requirements for those implementations that choose to conform to POSI=
X.<SPAN class=3D"Apple-converted-space">=A0 </SPAN>I believe it's ful=
ly implementable on a Windows-based server.</DIV><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-botto
m: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">I too hope that this can be discussed at IETF 66.</DIV><DI=
V style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; ma=
rgin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-to=
p: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">- =
Sam</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bot=
tom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOT=
E type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV=
 style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; mar=
gin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top=
: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">Tha=
nks and best regards,</DIV><DIV style=3D"margin-top: 0px; margin-righ=
t: 0px; margin-bottom: 0px; margin-left: 0px; ">Andreas</DIV><DIV sty=
le=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-=
left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"cite"><=
DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; =
margin-left: 0px; ">REFERENCES</DIV><DIV style=3D"margin-top: 0px; ma=
rgin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14=
px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">[1] Sam Falkner et al.: NFS Vers=
ion 4 ACLs, draft-ietf-nfsv4-acls-00.txt</DIV><DIV style=3D"margin-to=
p: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-=
height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; ">[2] POSIX 1003.1e/2c d=
raft 17 (withdrawn),</DIV><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; "><A href=3D"http://wt.x=
pilot.org/publications/posix.1e">http://wt.xpilot.org/publications/po=
six.1e</A></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV=
 style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; mar=
gin-left: 0px; ">[3] Marius Aamodt Eriksen et al.: Mapping Between NF=
Sv4 and Posix Draft</DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; ">ACLs, draft-ietf-nfsv4-=
acl-mapping-04.txt</DIV><DIV style=3D"margin-top: 0px; margin-right: =
0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></=
DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: =
0px; margin-left: 0px; ">[4] Spencer Shepler (editor): NFSv4 Minor Ve=
rsion 1,</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margi=
n-bottom: 0px; margin-left: 0px; ">draft-ietf-nfsv4-minorversion1-03.=
txt</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></D=
IV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0=
px; margin-left: 0px; ">--<SPAN class=3D"Apple-converted-space">=A0</=
SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-b=
ottom: 0px; margin-left: 0px; ">Andreas Gruenbacher &lt;<A href=3D"ma=
ilto:agruen@suse.de">agruen@suse.de</A>&gt;</DIV><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "=
>Novell / SUSE Labs</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height:=
 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; =
margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><=
DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; =
margin-left: 0px; ">_______________________________________________</=
DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: =
0px; margin-left: 0px; ">nfsv4 mailing list</DIV><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "=
><A href=3D"mailto:nfsv4@ietf.org">nfsv4@ietf.org</A></DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; "><A href=3D"https://www1.ietf.org/mailman/listinfo/nfsv4">h=
ttps://www1.ietf.org/mailman/listinfo/nfsv4</A></DIV> </BLOCKQUOTE></=
DIV><BR></DIV></BODY></HTML>

--Boundary_(ID_yZ6sA2R8WuFZGnATmnS8Tg)--


--===============1776738080==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1776738080==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1776738080==--
