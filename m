From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Sat, 08 Jul 2006 08:32:06 -0600
Message-ID: <4DACD752-A520-4420-BB88-E514C91C99FA@sun.com>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; delsp=yes; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, Spencer Shepler <spencer.shepler@Sun.COM>,
	Brian Pawlowski <beepy@netapp.com>, nfsv4@ietf.org,
	Lisa Week <Lisa.Week@Sun.COM>
Return-path: <nfsv4-bounces@ietf.org>
In-reply-to: <B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
To: Sam Falkner <Sam.Falkner@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Jul 7, 2006, at 9:45 PM, Sam Falkner wrote:

> On Jul 7, 2006, at 5:55 AM, Andreas Gruenbacher wrote:
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

More thoughts on this model and getattr.  Giving different versions  
of the ACL depending on how it's requested leads to problems.  To  
recap, if NFSv4.0 client asks for the post-chmod ACL, it'll get the  
inhibited version of the ACL.  Tools for modifying an ACL invariably  
do read/modify/write.  So NFSv4.0 client reads the stripped down ACL,  
modifies it, and writes it back.  At this point, information is lost  
-- the stripped down ACL is now the only ACL we have.  This leads to  
future environments where some classes of clients inadvertently do  
bad things, while others behave more correctly.

The ACL model in draft-ietf-nfsv4-minorversion1-03.txt always shows  
every client the entire, correct ACL, every time.

- Sam

>
>> Alternate permissions in the ACL can be enabled by either setting  
>> an ACL
>> without providing full mask entries, or by setting the appropriate  
>> bit(s) in
>> the corresponding mask entry or entries.
>
> Yes, I think I understand.
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


_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
