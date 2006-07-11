From: Lisa Week <Lisa.Week@Sun.COM>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
 draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 02:50:20 -0400
Message-ID: <A15E619E-E88C-420C-AEC4-4E7409F187F3@Sun.COM>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
	<200607091822.44656.agruen@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0775454623=="
Cc: Sam Falkner <Sam.Falkner@Sun.COM>,
	Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <spencer.shepler@Sun.COM>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0C3A-0003Qh-UO
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 23:48:53 -0700
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0C3B-0000Pb-4n
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 23:48:53 -0700
Received: from fe-amer-05.sun.com ([192.18.108.179])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	k6B6mppk010316
	for <nfs@lists.sourceforge.net>; Tue, 11 Jul 2006 00:48:51 -0600 (MDT)
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
	id <0J28007015DPHG00@mail-amer.sun.com> (original mail from
	Lisa.Week@Sun.COM)
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 00:48:51 -0600 (MDT)
In-reply-to: <200607091822.44656.agruen@suse.de>
To: nfsv4@ietf.org
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


--===============0775454623==
Content-type: multipart/alternative;
	boundary="Boundary_(ID_cHlkUrxHYveM+jMg7d6JQQ)"


--Boundary_(ID_cHlkUrxHYveM+jMg7d6JQQ)
Content-type: text/plain; format=flowed; delsp=yes; charset=US-ASCII
Content-transfer-encoding: 7BIT


On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:

> On Saturday, 8. July 2006 05:45, Sam Falkner wrote:
>> On Jul 7, 2006, at 5:55 AM, Andreas Gruenbacher wrote:
>>> On Monday, 3. July 2006 23:10, Andreas Gruenbacher wrote:
>>>> Hello,
>>>>
>>>> I have been thinking about the problems of interaction between
>>>> NFSv4 ACLs and POSIX, and particularly about the issue of masking
>>>> permissions through chmod and after creating files or directories.
>>>
>>> Here is a follow-up after some personal feedback from Sam. I
>>> believe that draft-ietf-nfsv4-acls-00 is not ready to become part  
>>> of the
>>> NFSv4 Minor Version 1 RFC: some assumptions are not correct from  
>>> a POSIX
>>> point of view, and the way how chmod and file create modes are  
>>> applied to
>>> NFSv4 ACLs is weak and not guaranteed to be correct.
>>
>> I disagree -- see below.
>
> Here are some facts to back my points: Let's assume that a file  
> inherits the
> following ACL when being created (I am using ^(...) here with the  
> meaning of
> "all bitflags except ..."):
>
> 	OWNER@:READ_DATA/WRITE_DATA::ALLOW
> 	OWNER@:^(READ_DATA/WRITE_DATA)::DENY
> 	GROUP@:READ_DATA::ALLOW
> 	user@domain:READ_DATA/WRITE_DATA::ALLOW
> 	GROUP@:^READ_DATA::DENY
> 	user@domain:^(READ_DATA/WRITE_DATA)::DENY
> 	EVERYONE@:READ_DATA::ALLOW
>
> This acl is "well structured" in the POSIX sense: OWNER@ will only  
> get the
> owner permissions and none of the other permissions, user@domain  
> and GROUP@
> will only get the permissions intended for them, and only others  
> (neither
> OWNER@ nor user@domain nor GROUP@) will get EVERYONE@ permissions;  
> in other
> words, the acl is even correct for non-monotonic permissions.
>
> According to section 5.1 of draft-ietf-nfsv4-acls [1], the  
> resulting file mode
> permission bits for this acl shall be rw-r--r--. After a chmod or a  
> file
> create, alternate file access control mechanisms must be disabled  
> and only
> additional file access control mechanisms may remain active.  
> According to
> POSIX, additional file access control mechanisms require that no  
> user may be
> granted more permissions than the respective file classes permit.  
> In this
> case, user@domain clearly is not in the File Owner Class.  
> (According to
> POSIX, user@domain must be in the File Group Class.) The  
> user@domain user is
> granted WRITE_DATA though, which is *incorrect* from a POSIX point  
> of view.
>
> Next, let's assume than an ACL contains the following pair of user- 
> provided
> entries:
>
> 	GROUP@:WRITE_DATA::DENY
> 	GROUP@:READ_DATA::ALLOW
>
> Clearly the user's intention is to deny WRITE_DATA access to  
> GROUP@. The
> algorithm to apply a mode to an existing ACL will remove the  
> WRITE_DATA bit
> from the GROUP@:WRITE_DATA::DENY entry when a chmod(..., 0770) is done
> though. This is counter to the user's intention, so I would call  
> that *wrong*
> as well. It also violates the principle of least surprise. There  
> really is no
> safe way to tell user-provided ACL entries from artificially made  
> up ACL
> entries.
>
> draft-ietf-nfsv4-acls is missing a clear classification of ACL  
> entries into
> the File Owner, File Group, and File Other classes. Every ACL entry  
> must be
> in one of the three classes in order to compute appropriate file mode
> permission bits when setting an ACL, and after inheriting  
> permissions. This
> classification also determines which effect chmod will have on an ACL.
>
> So draft-ietf-nfsv4-acls is *incorrect* and *wrong* from a POSIX  
> point of
> view, while my alternative proposal is correct, apart from being  
> simpler to
> implement. I hope that my emails and some background reading (like  
> the file
> access related parts of the POSIX definitions volume [5], a paper that
> explains POSIX ACLs and how they are implemented on Linux [6], and  
> perhaps
> 1003.1e draft 17) will convince you about that.
>
> Note that in traditional POSIX, permissions from multiple file  
> classes will
> never accumulate: each user always is either granted the File Owner
> permission bits, the File Group permission bits, or the File Other  
> permission
> bits. (Additional file access control mechanisms may further limit the
> permissions granted, and alternative file access control mechanisms  
> may
> further limit or extend the permissions granted.) Permissions from  
> multiple
> acl entries accumulate in the NFSv4 ACL model though, and so unless  
> an acl is
> "well structured" in the above sense, permissions from multiple  
> classes may
> accumulate.

Yes, permissions may accumulate, but in the design in the minor  
version doc, after a chmod, any permissions that go beyond the mode  
bits being set will be disabled.  This is done via the algorithm in  
section 3.16.6.3 -  "Applying a Mode to an Existing ACL".  This makes  
sure that the permissions (ACE4_READ_DATA/ACE4_LIST_DIRECTORY,
ACE4_WRITE_DATA/ACE4_WRITE_DATA, ACE4_APPEND_DATA/ 
ACE4_ADD_SUBDIRECTORY and ACE4_EXECUTE... which is what the mode  
defines) that accumulate will NOT go beyond the mode bits being set.

>
>>> I will first try to clarify some of the points I tried to make in
>>> the previous posting and point out deficiencies in
>>> draft-ietf-nfsv4-acls-00. Then I will propose an alternative  
>>> design which
>>> is more correct than introducing DENY entries to mask  
>>> permissions. (As a
>>> bonus, it is easier to implement. too.)
>>>
>>>> On a UNIX system that supports NFSv4 ACLs natively, I think we
>>>> should try to accept as wide a range of NFSv4 ACLs as possible,  
>>>> but we
>>>> must make sure that we can preserve POSIX semantics. In  
>>>> particular, this
>>>> means that ACLs may contain ACEs for users other than OWNER@,  
>>>> GROUP@, and
>>>> EVERYONE@, and that chmod(2) must continue to provide the same  
>>>> kinds of
>>>> guarantees as without NFSv4 ACLs.
>>>>
>>>> I am assuming here that NFSv4 ACLs shall be an additional rather  
>>>> than an
>>>> alternate file access control mechanism in the POSIX sense:  
>>>> Alternate
>>>> file access control mechanisms must ``be enabled only by  
>>>> explicit user
>>>> action, on a per-file basis by the file owner or a user with the
>>>> appropriate privilege'', and must ``be disabled for a file after  
>>>> the file
>>>> permission bits are changed for that file with chmod( )''  
>>>> according to
>>>> POSIX. In other words, newly created files or directories would  
>>>> have
>>>> alternate file access control mechanisms disabled. This would  
>>>> render
>>>> NFSv4 ACLs essentially useless for UNIX processes, because they  
>>>> would
>>>> almost always be disabled, and would only work for remote  
>>>> processes until
>>>> a POSIX process chmods a file or creates a directory, which  
>>>> wouldn't get
>>>> us very far.
>>>
>>> As Sam pointed out, a subset of NFSv4 ACLs maps to an additional  
>>> file
>>> access control mechanism, while the rest goes beyond that, and  
>>> therefore
>>> is an alternate file access control mechanism.
>>
>> Yes -- ALLOW ACEs are alternate file access control, and DENY ACEs
>> are additional file access control.
>
> This classification makes no sense, and it also does not match what  
> you
> propose in section 5.3 of draft-ietf-nfsv4-acls, either: there are  
> acls that
> contain ALLOW entries which are still only an additional file  
> access control
> mechanism, so we really need to classify them as an additional file  
> access
> control mechanism in order to avoid having to disable them during  
> chmod or
> when inheriting permissions.

We clearly have a disagreement what "additional" and "alternate" file  
access control mechanisms mean to NFSv4 ACLs.

Without these fundamental things, we will never be able to reach  
consensus.  So lets try to up-level the discussion and see if we can  
get agreement on what the meanings of these two access control  
mechanisms are in the context of NFSv4...

I know this has been iterated over and over again, but bear with  
me...  hopefully this will give you a better idea of where we're  
coming from.

POSIX defines Additional Access Control Mechanism as follows:
"An implementation-defined mechanism that is layered upon the access  
control mechanisms defined here, but which do not grant permissions  
beyond those defined herein, although they may further restrict them."

POSIX defines Alternate Access Control Mechanisms are as follows:
"An implementation-defined mechanism that is independent of the  
access control mechanisms defined herein, and which if enabled on a  
file may either restrict or extend the permissions of a given user.  
IEEE Std 1003.1-2001 defines when such mechanisms can be enabled and  
when they are disabled."

So, the question that comes to my mind when reading that text is:  
What does it mean when they say "access mechanisms defined herein" in  
both of those definitions?  Well, the access mechanisms defined in  
the POSIX spec are the "File Access Permissions", right?  So, can we  
agree that "access mechanisms defined herein" would be the "File  
Access Permissions"?

Okay, the description of "File Access Permissions" says that "The  
standard file access control mechanism uses the file permission bits..."

So, what are the file permission bits?  They are read, write, execute/ 
search for the File Owner Class, File Group Class and File Other Class.

So, to put this together, Additional access control mechanisms are   
the ability to further restrict the read, write, execute/search  
permissions for the File Owner Class, File Group Class and File Other  
Class.  And, Alternate access control mechanisms are the ability to  
either restrict or extend the read, write, execute/search permissions  
for the File Owner, Group and Other Class.

Now, to classify NFSv4 ACLs into Additional and Alternate access  
control mechanisms...
Since we are only controlling the read, write, execute/search  
permissions, the only permissions we should classify in NFSv4 ACLs  
are the access mask bits that intersect with the file permission bits  
as defined by POSIX.  And for NFSv4 that means the following access  
mask bits are of interest:
ACE4_READ_DATA/ACE4_LIST_DIRECTORY
ACE4_WRITE_DATA/ACE4_WRITE_DATA, ACE4_APPEND_DATA/ACE4_ADD_SUBDIRECTORY
ACE4_EXECUTE.

(Actually, this is where the existing draft-ietf-acl-00 proposal is  
confusing.  It doesn't come right out and say this.  In the write up  
we had the assumptions that this was clear, but I know that it needs  
to be further specified.)

So, now in the NFSv4 ACL sense, Alternate access control mechanisms  
are used to further extend and Additional access control mechanisms  
are used to further restrict the following access mask bits:
ACE4_READ_DATA/ACE4_LIST_DIRECTORY
ACE4_WRITE_DATA/ACE4_WRITE_DATA, ACE4_APPEND_DATA/ACE4_ADD_SUBDIRECTORY
ACE4_EXECUTE.

How would one extend those access mask bits (Alternate)?  By putting  
them in an ALLOW ACE.
How would one restrict those access mask bits (Additional)?  By  
putting them in a DENY ACE.

As far as the other access mask bits...they aren't covered by the  
POSIX File Access Permissions so do they need a classification?  No,  
not really.  (More on this below...)

> If ALLOW ACEs were alternate in general, then we
> would have to disable them all after a chmod, and I think we agree  
> that this
> would make ACLs practically useless in combination with POSIX.
>
> The only classification that makes sense is by the permissions that  
> an ACL
> grants.

I would agree with that, but don't go putting further restrictions on  
us than POSIX defined in the first place.  As said before POSIX only  
defines what should happen with regard to the access control  
mechanisms that layer on top of or extend the *file permission  
bits*.  See more below.

> You have given an example of an ACL that clearly is an additional
> file access control mechanism only. With this kind of  
> classification, a
> significant subset of NFSv4 ACLs can be treated as an additional  
> file access
> control mechanism, which makes them actually useful even when POSIX  
> systems
> and Windows (or other systems with NFSv4 ACLs or similar) interact  
> and both
> change ACLs.


The thing that is still out there is that if you classify ACEs with  
ACE4_READ_DATA, for example, as an additional access control  
mechanism, you will never be able to give a arbitrary user or group  
the ACE4_READ_DATA permission without having the File Class that it  
belongs to also have at least those permissions.  That seems broken  
to me.


>
>>> It is important to understand how POSIX defines additional file
>>> access control mechanisms:
>>>
>>> [] 3.4 Additional File Access Control Mechanism
>>> [] An implementation-defined mechanism that is layered upon the
>>> [] access control mechanisms defined here, but which do not grant
>>> [] permissions beyond those defined herein, although they may  
>>> further
>>> [] restrict them.
>>>
>>> In other words, when a file has just been created and after chmod,
>>> the file mode permission bits define an upper bound to the  
>>> permissions
>>> granted to anyone on the system, and nobody has additional  
>>> permissions.
>>> Additional permissions (as an alternate file access control  
>>> mechanism) may
>>> be enabled explicitly, but the next chmod must disable them again.
>>
>> The use of the word "Additional" is confusing in the above
>> sentence.  :-)  I think you mean "more", or similar, but "Additional"
>> has a very specific meaning which (I think) isn't what you mean.
>
> I indeed meant more permissions as in additional mask bits granted,  
> as opposed
> to an additional file access control mechanism in the sense how  
> POSIX defines
> this term.
>
>>> We can classify the permissions that NFSv4 ACLs grant into  
>>> additional and
>>> alternate mechanisms as follows: everything covered by the POSIX
>>> read/write/execute permissions (such as ACE4_READ_DATA, but also
>>> ACE4_APPEND_DATA) is additional, while everything beyond that  
>>> (such as
>>> ACE4_WRITE_OWNER) is alternate.
>>
>> Note well: this is quite different from draft-ietf-nfsv4-
>> minorversion1-03.txt, i.e. this is an alternate proposal.
>
> Yes, this is a different approach of classifying NFSv4 ACLs into  
> additional
> and alternate file access control mechanisms, which complies to  
> POSIX as well
> as to the current NFSv4 RFC. It conflicts with draft-ietf-nfsv4- 
> acls, and by
> implication with draft-ietf-nfsv4-minorversion1-03 [4], which  
> includes the
> same text.
>
> Note that draft-ietf-nfsv4-acls is inconsistent in itself: the  
> algorithm in
> section 5.3 restricts which permissions an ACL grants by masking  
> permissions
> (which implies that you are classifying by permission as opposed to  
> turning
> off all ALLOW entries),

I give you this.  The wording about the classification of ACEs in  
draft-ietf-nfsv4-acls is not quite sufficient.  As I've said before,  
It makes some important assumptions, but isn't clear as to what those  
are.  It doesn't map to what the algorithm specifies.  With that  
said, it was not meant to be misleading in any way.

As documented in the algorithm definition in section 3.16.6.3 -  
"Applying a Mode to an Existing ACL" of the minor version doc, the  
following is a clarification of the classification:

ALLOW ACEs with ACE4_READ_DATA/ACE4_LIST_DIRECTORY, ACE4_WRITE_DATA/ 
ACE4_ADD_FILE, ACE4_APPEND_DATA/ACE4_ADD_SUBDIRECTORY, and  
ACE4_EXECUTE access mask bits are Alternate security mechanisms.   
These access mask bits will be disabled upon chmod.

DENY ACEs with those access mask bits are Additional access control  
mechanisms.  These access mask bits will be left unchanged  after a  
chmod, unless, as described in 3.16.6.3 it is one of the special  
identifiers, OWNER@, GROUP@, EVERYONE@.

All other access mask bits listed below are outside of the access  
control mechanisms specified by POSIX and are therefore unclassified  
and unrestricted:
ACE4_READ_NAMED_ATTRS
ACE4_WRITE_NAMED_ATTRS
ACE4_DELETE_CHILD
ACE4_READ_ATTRIBUTES
ACE4_WRITE_ATTRIBUTES
ACE4_DELETE
ACE4_READ_ACL
ACE4_WRITE_ACL
ACE4_WRITE_OWNER
ACE4_SYNCHRONIZE

This means that if an ACE defines one of those access mask bits, the  
access granted or denied will remain unchanged after a chmod.


> while section 14.4 says that "the ALLOW type of ACE
> is considered to be an alternate file access control mechanism  
> because it can
> further extend the permissions of a user".
>

Thoughts?

Thanks,
Lisa

--Boundary_(ID_cHlkUrxHYveM+jMg7d6JQQ)
Content-type: text/html; charset=ISO-8859-1
Content-transfer-encoding: QUOTED-PRINTABLE

<HTML><BODY style=3D"word-wrap: break-word; -khtml-nbsp-mode: space; =
-khtml-line-break: after-white-space; "><BR><DIV><DIV>On Jul 9, 2006,=
 at 10:22 AM, Andreas Gruenbacher wrote:</DIV><BR class=3D"Apple-inte=
rchange-newline"><BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">On Sa=
turday, 8. July 2006 05:45, Sam Falkner wrote:</DIV> <BLOCKQUOTE type=
=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; ">On Jul 7, 2006, at 5:55 AM, Andreas Gr=
uenbacher wrote:</DIV> <BLOCKQUOTE type=3D"cite"><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "=
>On Monday, 3. July 2006 23:10, Andreas Gruenbacher wrote:</DIV> <BLO=
CKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0p=
x; margin-bottom: 0px; margin-left: 0px; ">Hello,</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">I have be=
en thinking about the problems of interaction between</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">NFSv4 ACLs and POSIX, and particularly about the issue of =
masking</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin=
-bottom: 0px; margin-left: 0px; ">permissions through chmod and after=
 creating files or directories.</DIV> </BLOCKQUOTE><DIV style=3D"marg=
in-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px;=
 min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-=
right: 0px; margin-bottom: 0px; margin-left: 0px; ">Here is a follow-=
up after some personal feedback from Sam. I</DIV><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "=
>believe that draft-ietf-nfsv4-acls-00 is not ready to become part of=
 the</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; ">NFSv4 Minor Version 1 RFC: some assump=
tions are not correct from a POSIX</DIV><DIV style=3D"margin-top: 0px=
; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">point of=
 view, and the way how chmod and file create modes are applied to</DI=
V><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0p=
x; margin-left: 0px; ">NFSv4 ACLs is weak and not guaranteed to be co=
rrect.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR>=
</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom=
: 0px; margin-left: 0px; ">I disagree -- see below.</DIV> </BLOCKQUOT=
E><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0p=
x; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"marg=
in-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px;=
 ">Here are some facts to back my points: Let's assume that a file in=
herits the<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; marg=
in-left: 0px; ">following ACL when being created (I am using ^(...) h=
ere with the meaning of<SPAN class=3D"Apple-converted-space">=A0</SPA=
N></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bott=
om: 0px; margin-left: 0px; ">"all bitflags except ..."):</DIV><DIV st=
yle=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin=
-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0=
px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "><SPAN =
class=3D"Apple-tab-span" style=3D"white-space:pre">=09</SPAN>OWNER@:R=
EAD_DATA/WRITE_DATA::ALLOW</DIV><DIV style=3D"margin-top: 0px; margin=
-right: 0px; margin-bottom: 0px; margin-left: 0px; "><SPAN class=3D"A=
pple-tab-span" style=3D"white-space:pre">=09</SPAN>OWNER@:^(READ_DATA=
/WRITE_DATA)::DENY</DIV><DIV style=3D"margin-top: 0px; margin-right: =
0px; margin-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-tab=
-span" style=3D"white-space:pre">=09</SPAN>GROUP@:READ_DATA::ALLOW</D=
IV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0=
px; margin-left: 0px; "><SPAN class=3D"Apple-tab-span" style=3D"white=
-space:pre">=09</SPAN>user@domain:READ_DATA/WRITE_DATA::ALLOW</DIV><D=
IV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; m=
argin-left: 0px; "><SPAN class=3D"Apple-tab-span" style=3D"white-spac=
e:pre">=09</SPAN>GROUP@:^READ_DATA::DENY</DIV><DIV style=3D"margin-to=
p: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "><S=
PAN class=3D"Apple-tab-span" style=3D"white-space:pre">=09</SPAN>user=
@domain:^(READ_DATA/WRITE_DATA)::DENY</DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "><SPAN=
 class=3D"Apple-tab-span" style=3D"white-space:pre">=09</SPAN>EVERYON=
E@:READ_DATA::ALLOW</DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR><=
/DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom:=
 0px; margin-left: 0px; ">This acl is "well structured" in the POSIX =
sense: OWNER@ will only get the<SPAN class=3D"Apple-converted-space">=
=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">owner permissions and none of th=
e other permissions, user@domain and GROUP@<SPAN class=3D"Apple-conve=
rted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; ">will only get the pe=
rmissions intended for them, and only others (neither<SPAN class=3D"A=
pple-converted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; =
margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">OWNER@ nor=
 user@domain nor GROUP@) will get EVERYONE@ permissions; in other<SPA=
N class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=3D"margi=
n-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; =
">words, the acl is even correct for non-monotonic permissions.</DIV>=
<DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px;=
 margin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "=
>According to section 5.1 of draft-ietf-nfsv4-acls [1], the resulting=
 file mode<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; marg=
in-left: 0px; ">permission bits for this acl shall be rw-r--r--. Afte=
r a chmod or a file<SPAN class=3D"Apple-converted-space">=A0</SPAN></=
DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: =
0px; margin-left: 0px; ">create, alternate file access control mechan=
isms must be disabled and only<SPAN class=3D"Apple-converted-space">=
=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">additional file access control m=
echanisms may remain active. According to<SPAN class=3D"Apple-convert=
ed-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; ">POSIX, additional file=
 access control mechanisms require that no user may be<SPAN class=
=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">grant=
ed more permissions than the respective file classes permit. In this<=
SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=3D"ma=
rgin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0p=
x; ">case, user@domain clearly is not in the File Owner Class. (Accor=
ding to<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV sty=
le=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-=
left: 0px; ">POSIX, user@domain must be in the File Group Class.) The=
 user@domain user is<SPAN class=3D"Apple-converted-space">=A0</SPAN><=
/DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom:=
 0px; margin-left: 0px; ">granted WRITE_DATA though, which is *incorr=
ect* from a POSIX point of view.</DIV><DIV style=3D"margin-top: 0px; =
margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: =
14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; m=
argin-bottom: 0px; margin-left: 0px; ">Next, let's assume than an ACL=
 contains the following pair of user-provided<SPAN class=3D"Apple-con=
verted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-r=
ight: 0px; margin-bottom: 0px; margin-left: 0px; ">entries:</DIV><DIV=
 style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; mar=
gin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top=
: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "><SP=
AN class=3D"Apple-tab-span" style=3D"white-space:pre">=09</SPAN>GROUP=
@:WRITE_DATA::DENY</DIV><DIV style=3D"margin-top: 0px; margin-right: =
0px; margin-bottom: 0px; margin-left: 0px; "><SPAN class=3D"Apple-tab=
-span" style=3D"white-space:pre">=09</SPAN>GROUP@:READ_DATA::ALLOW</D=
IV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0=
px; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"mar=
gin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px=
; ">Clearly the user's intention is to deny WRITE_DATA access to GROU=
P@. The<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV sty=
le=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-=
left: 0px; ">algorithm to apply a mode to an existing ACL will remove=
 the WRITE_DATA bit<SPAN class=3D"Apple-converted-space">=A0</SPAN></=
DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: =
0px; margin-left: 0px; ">from the GROUP@:WRITE_DATA::DENY entry when =
a chmod(..., 0770) is done<SPAN class=3D"Apple-converted-space">=A0</=
SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-b=
ottom: 0px; margin-left: 0px; ">though. This is counter to the user's=
 intention, so I would call that *wrong*<SPAN class=3D"Apple-converte=
d-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; ">as well. It also violat=
es the principle of least surprise. There really is no<SPAN class=
=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">safe =
way to tell user-provided ACL entries from artificially made up ACL<S=
PAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=3D"mar=
gin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px=
; ">entries.</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; m=
argin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><D=
IV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; m=
argin-left: 0px; ">draft-ietf-nfsv4-acls is missing a clear classific=
ation of ACL entries into<SPAN class=3D"Apple-converted-space">=A0</S=
PAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; ">the File Owner, File Group, and File O=
ther classes. Every ACL entry must be<SPAN class=3D"Apple-converted-s=
pace">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0p=
x; margin-bottom: 0px; margin-left: 0px; ">in one of the three classe=
s in order to compute appropriate file mode<SPAN class=3D"Apple-conve=
rted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; ">permission bits when=
 setting an ACL, and after inheriting permissions. This<SPAN class=
=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">class=
ification also determines which effect chmod will have on an ACL.</DI=
V><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0p=
x; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"marg=
in-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px;=
 ">So draft-ietf-nfsv4-acls is *incorrect* and *wrong* from a POSIX p=
oint of<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV sty=
le=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-=
left: 0px; ">view, while my alternative proposal is correct, apart fr=
om being simpler to<SPAN class=3D"Apple-converted-space">=A0</SPAN></=
DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: =
0px; margin-left: 0px; ">implement. I hope that my emails and some ba=
ckground reading (like the file<SPAN class=3D"Apple-converted-space">=
=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">access related parts of the POSI=
X definitions volume [5], a paper that<SPAN class=3D"Apple-converted-=
space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; ">explains POSIX ACLs and h=
ow they are implemented on Linux [6], and perhaps<SPAN class=3D"Apple=
-converted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; marg=
in-right: 0px; margin-bottom: 0px; margin-left: 0px; ">1003.1e draft =
17) will convince you about that.</DIV><DIV style=3D"margin-top: 0px;=
 margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height:=
 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; =
margin-bottom: 0px; margin-left: 0px; ">Note that in traditional POSI=
X, permissions from multiple file classes will<SPAN class=3D"Apple-co=
nverted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-=
right: 0px; margin-bottom: 0px; margin-left: 0px; ">never accumulate:=
 each user always is either granted the File Owner<SPAN class=3D"Appl=
e-converted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; mar=
gin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">permission bi=
ts, the File Group permission bits, or the File Other permission<SPAN=
 class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "=
>bits. (Additional file access control mechanisms may further limit t=
he<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">permissions granted, and alternative file access control m=
echanisms may<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><D=
IV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; m=
argin-left: 0px; ">further limit or extend the permissions granted.) =
Permissions from multiple<SPAN class=3D"Apple-converted-space">=A0</S=
PAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; ">acl entries accumulate in the NFSv4 AC=
L model though, and so unless an acl is<SPAN class=3D"Apple-converted=
-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: =
0px; margin-bottom: 0px; margin-left: 0px; ">"well structured" in the=
 above sense, permissions from multiple classes may<SPAN class=3D"App=
le-converted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; ma=
rgin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">accumulate.<=
/DIV></BLOCKQUOTE><DIV><BR class=3D"khtml-block-placeholder"></DIV><D=
IV>Yes, permissions may accumulate, but in the design in the minor ve=
rsion doc, after a chmod, any permissions that go beyond the mode bit=
s being set will be disabled.=A0 This is done via the algorithm in se=
ction=A03.16.6.3 - =A0"Applying a Mode to an Existing ACL".=A0=A0This=
 makes sure that the permissions (ACE4_READ_DATA/ACE4_LIST_DIRECTORY,=
</DIV><DIV>ACE4_WRITE_DATA/ACE4_WRITE_DATA, ACE4_APPEND_DATA/ACE4_ADD=
_SUBDIRECTORY and=A0ACE4_EXECUTE... which is what the mode defines) t=
hat accumulate will NOT go beyond the mode bits being set.</DIV><BR><=
BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; "><BR><=
/DIV> <BLOCKQUOTE type=3D"cite"><BLOCKQUOTE type=3D"cite"><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">I will first try to clarify some of the points I tried to =
make in</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin=
-bottom: 0px; margin-left: 0px; ">the previous posting and point out =
deficiencies in</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0px; ">draft-ietf-nfsv4-acls-00. T=
hen I will propose an alternative design which</DIV><DIV style=3D"mar=
gin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px=
; ">is more correct than introducing DENY entries to mask permissions=
. (As a</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin=
-bottom: 0px; margin-left: 0px; ">bonus, it is easier to implement. t=
oo.)</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUO=
TE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right: 0px; ma=
rgin-bottom: 0px; margin-left: 0px; ">On a UNIX system that supports =
NFSv4 ACLs natively, I think we</DIV><DIV style=3D"margin-top: 0px; m=
argin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">should try =
to accept as wide a range of NFSv4 ACLs as possible, but we</DIV><DIV=
 style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; mar=
gin-left: 0px; ">must make sure that we can preserve POSIX semantics.=
 In particular, this</DIV><DIV style=3D"margin-top: 0px; margin-right=
: 0px; margin-bottom: 0px; margin-left: 0px; ">means that ACLs may co=
ntain ACEs for users other than OWNER@, GROUP@, and</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">EVERYONE@, and that chmod(2) must continue to provide the =
same kinds of</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; =
margin-bottom: 0px; margin-left: 0px; ">guarantees as without NFSv4 A=
CLs.</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">I am assuming here that NFSv4 ACLs shall be an additional =
rather than an</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; ">alternate file access contro=
l mechanism in the POSIX sense: Alternate</DIV><DIV style=3D"margin-t=
op: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">f=
ile access control mechanisms must ``be enabled only by explicit user=
</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom=
: 0px; margin-left: 0px; ">action, on a per-file basis by the file ow=
ner or a user with the</DIV><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; ">appropriate privileg=
e'', and must ``be disabled for a file after the file</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">permission bits are changed for that file with chmod( )'' =
according to</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; m=
argin-bottom: 0px; margin-left: 0px; ">POSIX. In other words, newly c=
reated files or directories would have</DIV><DIV style=3D"margin-top:=
 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">alte=
rnate file access control mechanisms disabled. This would render</DIV=
><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px=
; margin-left: 0px; ">NFSv4 ACLs essentially useless for UNIX process=
es, because they would</DIV><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; ">almost always be dis=
abled, and would only work for remote processes until</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">a POSIX process chmods a file or creates a directory, whic=
h wouldn't get</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; ">us very far.<SPAN class=3D"A=
pple-converted-space">=A0</SPAN></DIV> </BLOCKQUOTE><DIV style=3D"mar=
gin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px=
; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin=
-right: 0px; margin-bottom: 0px; margin-left: 0px; ">As Sam pointed o=
ut, a subset of NFSv4 ACLs maps to an additional file</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">access control mechanism, while the rest goes beyond that,=
 and therefore</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px;=
 margin-bottom: 0px; margin-left: 0px; ">is an alternate file access =
control mechanism.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: 0px; =
margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-height: =
14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; m=
argin-bottom: 0px; margin-left: 0px; ">Yes -- ALLOW ACEs are alternat=
e file access control, and DENY ACEs</DIV><DIV style=3D"margin-top: 0=
px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">are ad=
ditional file access control.</DIV> </BLOCKQUOTE><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; m=
in-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-ri=
ght: 0px; margin-bottom: 0px; margin-left: 0px; ">This classification=
 makes no sense, and it also does not match what you<SPAN class=3D"Ap=
ple-converted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; m=
argin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">propose in =
section 5.3 of draft-ietf-nfsv4-acls, either: there are acls that<SPA=
N class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=3D"margi=
n-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; =
">contain ALLOW entries which are still only an additional file acces=
s control<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV s=
tyle=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margi=
n-left: 0px; ">mechanism, so we really need to classify them as an ad=
ditional file access<SPAN class=3D"Apple-converted-space">=A0</SPAN><=
/DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom:=
 0px; margin-left: 0px; ">control mechanism in order to avoid having =
to disable them during chmod or<SPAN class=3D"Apple-converted-space">=
=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">when inheriting permissions.<BR>=
</DIV></BLOCKQUOTE><DIV><BR class=3D"khtml-block-placeholder"></DIV><=
DIV>We clearly have a disagreement what "additional" and "alternate" =
file access control mechanisms mean to NFSv4 ACLs.</DIV><DIV><BR clas=
s=3D"khtml-block-placeholder"></DIV><DIV>Without these fundamental th=
ings, we will never be able to reach consensus.=A0 So lets try to up-=
level the discussion and see if we can get agreement on what the mean=
ings of these two access control mechanisms are in the context of NFS=
v4...</DIV><DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV>I kn=
ow this has been iterated over and over again, but bear with me...=
=A0 hopefully this will give you a better idea of where we're coming =
=66rom.</DIV><DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV>PO=
SIX defines Additional Access Control Mechanism as follows:</DIV><DIV=
><FONT class=3D"Apple-style-span" face=3D"Verdana" size=3D"4"><SPAN c=
lass=3D"Apple-style-span" style=3D"font-size: 13.3px;">"An implementa=
tion-defined mechanism that is layered upon the access control mechan=
isms defined here, but which do not grant permissions beyond those de=
fined herein, although they may further restrict them."</SPAN></FONT>=
</DIV><DIV><FONT class=3D"Apple-style-span" face=3D"Verdana" size=
=3D"4"><SPAN class=3D"Apple-style-span" style=3D"font-size: 13.3px;">=
</SPAN></FONT></DIV><DIV><FONT class=3D"Apple-style-span" face=3D"Ver=
dana" size=3D"4"><SPAN class=3D"Apple-style-span" style=3D"font-size:=
 13.3px;"><BR class=3D"khtml-block-placeholder"></SPAN></FONT></DIV><=
DIV>POSIX defines Alternate Access Control Mechanisms are as follows:=
</DIV><DIV><FONT class=3D"Apple-style-span" face=3D"Verdana" size=
=3D"4"><SPAN class=3D"Apple-style-span" style=3D"font-size: 13.3px;">=
"An implementation-defined mechanism that is independent of the acces=
s control mechanisms defined herein, and which if enabled on a file m=
ay either restrict or extend the permissions of a given user. IEEE=
=A0Std=A01003.1-2001 defines when such mechanisms can be enabled and =
when they are disabled."</SPAN></FONT></DIV><DIV><FONT class=3D"Apple=
-style-span" face=3D"Verdana" size=3D"4"><SPAN class=3D"Apple-style-s=
pan" style=3D"font-size: 13.3px;"><BR class=3D"khtml-block-placeholde=
r"></SPAN></FONT></DIV><DIV>So, the question that comes to my mind wh=
en reading that text is: What does it mean when they say "access mech=
anisms defined herein" in both of those definitions?=A0 Well, the acc=
ess mechanisms defined in the POSIX spec are the "File Access Permiss=
ions", right?=A0 So, can we agree that "access mechanisms defined her=
ein" would be the "File Access Permissions"?</DIV><DIV><BR class=3D"k=
html-block-placeholder"></DIV><DIV>Okay, the description of "File Acc=
ess Permissions" says that "The standard file access control mechanis=
m uses the file permission bits..."</DIV><DIV><FONT class=3D"Apple-st=
yle-span" face=3D"Verdana" size=3D"4"><SPAN class=3D"Apple-style-span=
" style=3D"font-size: 13.3px;"><BR class=3D"khtml-block-placeholder">=
</SPAN></FONT></DIV><DIV>So, what are the file permission bits?=A0 Th=
ey are read, write, execute/search for the File Owner Class, File Gro=
up Class and File Other Class.</DIV><DIV><BR class=3D"khtml-block-pla=
ceholder"></DIV><DIV>So, to put this together, Additional access cont=
rol mechanisms are=A0 the ability to further restrict the read, write=
, execute/search permissions for the File Owner Class, File Group Cla=
ss and File Other Class.=A0 And, Alternate access control mechanisms =
are the ability to either restrict or extend the read, write, execute=
/search permissions for the File Owner, Group and Other Class.</DIV><=
DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV>Now, to classify=
 NFSv4 ACLs into Additional and Alternate access control mechanisms..=
.</DIV><DIV>Since we are only controlling the read, write, execute/se=
arch permissions, the only permissions we should classify in NFSv4 AC=
Ls are the access mask bits that intersect with the file permission b=
its as defined by POSIX.=A0 And for NFSv4 that means the following ac=
cess mask bits are of interest:</DIV><DIV>ACE4_READ_DATA/ACE4_LIST_DI=
RECTORY</DIV><DIV>ACE4_WRITE_DATA/ACE4_WRITE_DATA, ACE4_APPEND_DATA/A=
CE4_ADD_SUBDIRECTORY</DIV><DIV>ACE4_EXECUTE.</DIV><DIV><BR class=3D"k=
html-block-placeholder"></DIV><DIV>(Actually, this is where the exist=
ing draft-ietf-acl-00 proposal is confusing.=A0 It doesn't come right=
 out and say this.=A0 In the write up we had the assumptions that thi=
s was clear, but I know that it needs to be further specified.)</DIV>=
<DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV>So, now in the =
NFSv4 ACL sense, Alternate access control mechanisms are used to furt=
her extend and Additional access control mechanisms are used to furth=
er restrict the following access mask bits:</DIV><DIV>ACE4_READ_DATA/=
ACE4_LIST_DIRECTORY</DIV><DIV>ACE4_WRITE_DATA/ACE4_WRITE_DATA, ACE4_A=
PPEND_DATA/ACE4_ADD_SUBDIRECTORY</DIV><DIV>ACE4_EXECUTE.</DIV><DIV><B=
R class=3D"khtml-block-placeholder"></DIV><DIV>How would one extend t=
hose access mask bits (Alternate)?=A0 By putting them in an ALLOW ACE=
.</DIV><DIV>How would one restrict those access mask bits (Additional=
)?=A0 By putting them in a DENY ACE.</DIV><DIV><BR class=3D"khtml-blo=
ck-placeholder"></DIV><DIV>As far as the other access mask bits...the=
y aren't covered by the POSIX File Access Permissions so do they need=
 a classification?=A0 No, not really.=A0 (More on this below...)</DIV=
><BR><BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-=
right: 0px; margin-bottom: 0px; margin-left: 0px; ">If ALLOW ACEs wer=
e alternate in general, then we<SPAN class=3D"Apple-converted-space">=
=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">would have to disable them all a=
fter a chmod, and I think we agree that this<SPAN class=3D"Apple-conv=
erted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-ri=
ght: 0px; margin-bottom: 0px; margin-left: 0px; ">would make ACLs pra=
ctically useless in combination with POSIX.</DIV><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; m=
in-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-ri=
ght: 0px; margin-bottom: 0px; margin-left: 0px; ">The only classifica=
tion that makes sense is by the permissions that an ACL<SPAN class=
=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">grant=
s.<BR></DIV></BLOCKQUOTE><DIV><BR class=3D"khtml-block-placeholder"><=
/DIV><DIV>I would agree with that, but don't go putting further restr=
ictions on us than POSIX defined in the first place.=A0 As said befor=
e POSIX only defines what should happen with regard to the access con=
trol mechanisms that layer on top of or extend the *file permission b=
its*.=A0 See more below.</DIV><BR><BLOCKQUOTE type=3D"cite"><DIV styl=
e=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-l=
eft: 0px; ">You have given an example of an ACL that clearly is an ad=
ditional<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV st=
yle=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin=
-left: 0px; ">file access control mechanism only. With this kind of c=
lassification, a<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV=
><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px=
; margin-left: 0px; ">significant subset of NFSv4 ACLs can be treated=
 as an additional file access<SPAN class=3D"Apple-converted-space">=
=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">control mechanism, which makes t=
hem actually useful even when POSIX systems<SPAN class=3D"Apple-conve=
rted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; ">and Windows (or othe=
r systems with NFSv4 ACLs or similar) interact and both<SPAN class=
=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">chang=
e ACLs.</DIV></BLOCKQUOTE><DIV><BR class=3D"khtml-block-placeholder">=
</DIV><DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV>The thing=
 that is still out there is that if you classify ACEs with ACE4_READ_=
DATA, for example, as an additional access control mechanism, you wil=
l never be able to give a arbitrary user or group the ACE4_READ_DATA =
permission without having the File Class that it belongs to also have=
 at least those permissions.=A0 That seems broken to me.</DIV><DIV><B=
R class=3D"khtml-block-placeholder"></DIV><BR><BLOCKQUOTE type=3D"cit=
e"><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0=
px; margin-left: 0px; min-height: 14px; "><BR></DIV> <BLOCKQUOTE type=
=3D"cite"><BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; ma=
rgin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">It is import=
ant to understand how POSIX defines additional file</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">access control mechanisms:</DIV><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-hei=
ght: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; ">[] 3.4 Additional File Ac=
cess Control Mechanism</DIV><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; ">[] An implementation=
-defined mechanism that is layered upon the</DIV><DIV style=3D"margin=
-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; "=
>[] access control mechanisms defined here, but which do not grant</D=
IV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0=
px; margin-left: 0px; ">[] permissions beyond those defined herein, a=
lthough they may further</DIV><DIV style=3D"margin-top: 0px; margin-r=
ight: 0px; margin-bottom: 0px; margin-left: 0px; ">[] restrict them.<=
SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=3D"ma=
rgin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0p=
x; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margi=
n-right: 0px; margin-bottom: 0px; margin-left: 0px; ">In other words,=
 when a file has just been created and after chmod,</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">the file mode permission bits define an upper bound to the=
 permissions</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; m=
argin-bottom: 0px; margin-left: 0px; ">granted to anyone on the syste=
m, and nobody has additional permissions.</DIV><DIV style=3D"margin-t=
op: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">A=
dditional permissions (as an alternate file access control mechanism)=
 may</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bo=
ttom: 0px; margin-left: 0px; ">be enabled explicitly, but the next ch=
mod must disable them again.</DIV> </BLOCKQUOTE><DIV style=3D"margin-=
top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; mi=
n-height: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; ">The use of the word =
"Additional" is confusing in the above</DIV><DIV style=3D"margin-top:=
 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">sent=
ence.<SPAN class=3D"Apple-converted-space">=A0 </SPAN>:-)<SPAN class=
=3D"Apple-converted-space">=A0 </SPAN>I think you mean "more", or sim=
ilar, but "Additional"</DIV><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; ">has a very specific =
meaning which (I think) isn't what you mean.</DIV> </BLOCKQUOTE><DIV =
style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; marg=
in-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top:=
 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">I in=
deed meant more permissions as in additional mask bits granted, as op=
posed<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">to an additional file access control mechanism in the sens=
e how POSIX defines<SPAN class=3D"Apple-converted-space">=A0</SPAN></=
DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: =
0px; margin-left: 0px; ">this term.</DIV><DIV style=3D"margin-top: 0p=
x; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-heigh=
t: 14px; "><BR></DIV> <BLOCKQUOTE type=3D"cite"><BLOCKQUOTE type=3D"c=
ite"><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom:=
 0px; margin-left: 0px; ">We can classify the permissions that NFSv4 =
ACLs grant into additional and</DIV><DIV style=3D"margin-top: 0px; ma=
rgin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">alternate me=
chanisms as follows: everything covered by the POSIX</DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">read/write/execute permissions (such as ACE4_READ_DATA, bu=
t also</DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-=
bottom: 0px; margin-left: 0px; ">ACE4_APPEND_DATA) is additional, whi=
le everything beyond that (such as</DIV><DIV style=3D"margin-top: 0px=
; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">ACE4_WRI=
TE_OWNER) is alternate.</DIV> </BLOCKQUOTE><DIV style=3D"margin-top: =
0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; min-hei=
ght: 14px; "><BR></DIV><DIV style=3D"margin-top: 0px; margin-right: 0=
px; margin-bottom: 0px; margin-left: 0px; ">Note well: this is quite =
different from draft-ietf-nfsv4-</DIV><DIV style=3D"margin-top: 0px; =
margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">minorversi=
on1-03.txt, i.e. this is an alternate proposal.</DIV> </BLOCKQUOTE><D=
IV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; m=
argin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-t=
op: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">Y=
es, this is a different approach of classifying NFSv4 ACLs into addit=
ional<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">and alternate file access control mechanisms, which compli=
es to POSIX as well<SPAN class=3D"Apple-converted-space">=A0</SPAN></=
DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: =
0px; margin-left: 0px; ">as to the current NFSv4 RFC. It conflicts wi=
th draft-ietf-nfsv4-acls, and by<SPAN class=3D"Apple-converted-space"=
>=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; ma=
rgin-bottom: 0px; margin-left: 0px; ">implication with draft-ietf-nfs=
v4-minorversion1-03 [4], which includes the<SPAN class=3D"Apple-conve=
rted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-rig=
ht: 0px; margin-bottom: 0px; margin-left: 0px; ">same text.</DIV><DIV=
 style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; mar=
gin-left: 0px; min-height: 14px; "><BR></DIV><DIV style=3D"margin-top=
: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; ">Not=
e that draft-ietf-nfsv4-acls is inconsistent in itself: the algorithm=
 in<SPAN class=3D"Apple-converted-space">=A0</SPAN></DIV><DIV style=
=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-le=
ft: 0px; ">section 5.3 restricts which permissions an ACL grants by m=
asking permissions<SPAN class=3D"Apple-converted-space">=A0</SPAN></D=
IV><DIV style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 0=
px; margin-left: 0px; ">(which implies that you are classifying by pe=
rmission as opposed to turning<SPAN class=3D"Apple-converted-space">=
=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">off all ALLOW entries), <BR></DI=
V></BLOCKQUOTE><DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV>=
I give you this.=A0 The wording about the classification of ACEs in d=
raft-ietf-nfsv4-acls is not quite sufficient.=A0 As I've said before,=
 It makes some important assumptions, but isn't clear as to what thos=
e are.=A0 It doesn't map to what the algorithm specifies.=A0 With tha=
t said, it was not meant to be misleading in any way.</DIV><DIV><BR c=
lass=3D"khtml-block-placeholder"></DIV><DIV>As documented in the algo=
rithm definition in section=A03.16.6.3 - "Applying a Mode to an Exist=
ing ACL" of the minor version doc, the following is a clarification o=
f the classification:</DIV><DIV><BR class=3D"khtml-block-placeholder"=
></DIV><DIV>ALLOW ACEs with ACE4_READ_DATA/ACE4_LIST_DIRECTORY, ACE4_=
WRITE_DATA/ACE4_ADD_FILE, ACE4_APPEND_DATA/ACE4_ADD_SUBDIRECTORY, and=
 ACE4_EXECUTE access mask bits are Alternate security mechanisms.=
=A0 These access mask bits will be disabled=A0upon chmod.</DIV><DIV><=
BR class=3D"khtml-block-placeholder"></DIV><DIV>DENY ACEs with those =
access mask bits are Additional access control mechanisms.=A0 These a=
ccess mask bits will be left unchanged=A0 after a chmod, unless, as d=
escribed in 3.16.6.3 it is one of the special identifiers, OWNER@, GR=
OUP@, EVERYONE@.</DIV><DIV><BR class=3D"khtml-block-placeholder"></DI=
V><DIV>All other access mask bits listed below are outside of the acc=
ess control mechanisms specified by POSIX and are therefore unclassif=
ied and unrestricted:</DIV><DIV>ACE4_READ_NAMED_ATTRS</DIV><DIV>ACE4_=
WRITE_NAMED_ATTRS</DIV><DIV>ACE4_DELETE_CHILD</DIV><DIV>ACE4_READ_ATT=
RIBUTES</DIV><DIV>ACE4_WRITE_ATTRIBUTES</DIV><DIV>ACE4_DELETE</DIV><D=
IV>ACE4_READ_ACL</DIV><DIV>ACE4_WRITE_ACL</DIV><DIV>ACE4_WRITE_OWNER<=
/DIV><DIV>ACE4_SYNCHRONIZE</DIV><DIV><BR class=3D"khtml-block-placeho=
lder"></DIV><DIV>This means that if an ACE defines one of those acces=
s mask bits, the access granted or denied will remain unchanged after=
 a chmod.</DIV><DIV><BR class=3D"khtml-block-placeholder"></DIV><BR><=
BLOCKQUOTE type=3D"cite"><DIV style=3D"margin-top: 0px; margin-right:=
 0px; margin-bottom: 0px; margin-left: 0px; ">while section 14.4 says=
 that "the ALLOW type of ACE<SPAN class=3D"Apple-converted-space">=
=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-right: 0px; mar=
gin-bottom: 0px; margin-left: 0px; ">is considered to be an alternate=
 file access control mechanism because it can<SPAN class=3D"Apple-con=
verted-space">=A0</SPAN></DIV><DIV style=3D"margin-top: 0px; margin-r=
ight: 0px; margin-bottom: 0px; margin-left: 0px; ">further extend the=
 permissions of a user".</DIV><DIV style=3D"margin-top: 0px; margin-r=
ight: 0px; margin-bottom: 0px; margin-left: 0px; min-height: 14px; ">=
<BR></DIV> <BLOCKQUOTE type=3D"cite"><BLOCKQUOTE type=3D"cite"></BLOC=
KQUOTE></BLOCKQUOTE></BLOCKQUOTE><BR></DIV><DIV>Thoughts?</DIV><DIV><=
BR class=3D"khtml-block-placeholder"></DIV><DIV>Thanks,</DIV><DIV>Lis=
a</DIV></BODY></HTML>

--Boundary_(ID_cHlkUrxHYveM+jMg7d6JQQ)--


--===============0775454623==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

--===============0775454623==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0775454623==--
