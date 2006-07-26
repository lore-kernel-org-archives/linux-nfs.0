From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 25 Jul 2006 22:59:25 -0600
Message-ID: <4654D18B-57AD-4779-80A6-BFD2FCEC4A69@Sun.COM>
References: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
	<200607250232.37603.a.gruenbacher@computer.org>
	<04075B08-F57D-4842-A7B2-9467DF9A39A2@Sun.COM>
	<200607252215.16735.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; delsp=yes; charset=US-ASCII
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, "Noveck, Dave" <Dave.Noveck@netapp.com>,
	Spencer Shepler <spencer.shepler@Sun.COM>, "Pawlowski,
	Brian" <beepy@netapp.com>
Return-path: <nfsv4-bounces@ietf.org>
In-reply-to: <200607252215.16735.agruen@suse.de>
To: Andreas Gruenbacher <agruen@suse.de>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Jul 25, 2006, at 2:15 PM, Andreas Gruenbacher wrote:

> On Tuesday, 25. July 2006 06:26, Sam Falkner wrote:
>> On Jul 24, 2006, at 6:32 PM, a.gruenbacher@computer.org wrote:
>>> Looking at draft-ietf-nfsv4-minorversion1-04.txt, I disagree with
>>> secion
>>> 5.4.1. "Discussion of EVERYONE@".
>>
>> The fact that you disagree with it is not a flaw.  That section is
>> very simple -- it says that EVERYONE@ means "everyone".
>>
>> If you are arguing that EVERYONE@ ACEs should be affected by the
>> POSIX "other" class upon chmod(), then that's not in disagreement
>> with 5.4.1.
>
> Alright, fine then.
>
>>> Section 5.5. "Mode Attribute" claims that
>>> MODE4_RGRP, MODE4_WGRP, MODE4_XGRP apply to the principals
>>> identified in the
>>> owner_group attribute, while it's really the File Group Class
>>> according to POSIX.
>>
>> Since when does POSIX define NFSv4?  RFC 3530 is the current
>> authority on NFSv4, and it says that the mode attribute is based upon
>> the UNIX mode -- seems sensible to me.
>
> POSIX does not define NFSv4. The mode attribute directly maps to  
> the POSIX
> file mode though, and I assume we have agreement on that.
>
> My argument is that there is a conceptual difference between the  
> MODE4_RGRP,
> MODE4_WGRP, MODE4_XGRP permission bits (which map to the POSIX File  
> Group
> Class) and the owner_group permissions: this has to do with the
> classification of ACEs, and with the file access control mechanisms  
> that
> POSIX allows.
>
> RFC3530 does not go very deeply into the interactions between the mode
> attribute and POSIX. In Section 5.11.5. "Mode Attribute" RFC2530  
> defines that
> the MODE4_RGRP, MODE4_WGRP, MODE4_XGRP bits apply to the principals
> identified in the owner_group attribute. This is a less general  
> definition
> than how POSIX defines File Permission Bits, which are part of the  
> file mode:
>
> [] File Permission Bits
> []
> [] Information about a file that is used, along with other  
> information, to
> [] determine whether a process has read, write, or execute/search  
> permission
> [] to a file. The bits are divided into three parts: owner, group,  
> and other.
> [] Each part is used with the corresponding file class of  
> processes. These
> [] bits are contained in the file mode.
>
> On POSIX systems that only support the POSIX File Permission Bits  
> and no other
> file access control mechanisms, both definitions amount to the  
> same. On
> systems that implement additional file access control mechanisms,  
> the File
> Group Class permission bits are no longer necessarily identical  
> with the
> permissions granted to the owning group: the definition of  
> Additional File
> Access Control Mechanisms allows further restrictions to be  
> imposed. In other
> words, the owning group may only be granted a subset of the File  
> Group Class
> permissions.

You can implement such a design and be POSIX compliant.  You can also  
implement a design where setting only the mode allows full control of  
read/write/execute for owner/owner_group/other, and be POSIX  
compliant.  With both Alternate and Additional File Access Controls  
available, there many ways to implement an NFSv4 ACL model and be  
POSIX compliant.

Even though your design is not yet complete, I believe that it will  
be POSIX compliant.  That's not the problem.  A major problem with  
your design is that NFSv4 clients that do not support the optional  
ACL attribute will be unable to control read/write/execute for owner/ 
owner_group/other.

> You are arguing that users have been confused by this definition,  
> and that
> changing the File Group Class permissions (=changing the MODE4_RGRP,
> MODE4_WGRP, MODE4_XGRP bits in the mode attribute) should  
> automatically also
> change the owner_group permissions, and that this is how chmod  
> behaves with
> POSIX ACLs on Solaris (and which differs from how implementations  
> of POSIX
> 1003.1e draft 17 (withdrawn) are supposed to behave). In Section  
> 4.6. "Mode
> Changes and the OWNER@, GROUP@, and EVERYONE@ ACEs" of
> http://www.suse.de/~agruen/nfs4acl/mapping-nfsv4-acls-to- 
> posix-00.html I am
> pointing out two reasons why the Solaris behavior is a really bad  
> idea. (Note
> that these problems may well be the reason why Solaris appears to  
> behave
> differently at the system call level.)

You do indeed point out two reasons in your Section 4.6.  We have  
solid data from implementation experience and customer support calls  
that Section 4.6 reaches the wrong conclusion.  End users have  
complained about the behavior of the defunct 1003.1e draft 17.  When  
the chmod command was changed to end-run around this behavior, there  
were no more complaints about the chmod command.

Whether this is a security hole is a matter of opinion.  I would be  
interested in how many are of the opinion that an explicit chmod to  
mode 644 always giving read access to owner_group is a security hole;  
and even if it is, that it is necessary to confuse and annoy end  
users to the point that they generate service calls and demand a fix.

> I would be sorry if you persisted in implementing the current  
> Solaris chmod
> behavior in NFSv4, but in case you really do, this hack still does  
> not belong
> into the NFSv4.1 specification, and I would in that case much  
> prefer if you
> could just break Solaris, and not everybody else as well.
>
>>> From that pretty much follows that the algorithm defined in Section
>>> 5.6.1. is not POSIX compliant: the File Group Class permissions
>>> must be a superset of the permissions of the permissions granted  
>>> to all
>>> ACEs for a who other than OWNER@ and EVERYONE@, and the 5.6.1.  
>>> algorithm
>>> does not guarantee this.
>>
>> You are arguing that NFSv4 should define MODE4_RGRP, MODE4_WGRP, and
>> MODE4_XGRP to be something other than the UNIX mode bits.

In the back-and-forth below, substitute "mode" with "ability to  
reliably control read/write/execute for owner/owner_group/other".

> No, this is a misunderstanding. I am arguing that the NFSv4 mode  
> attribute map
> to the POSIX mode bits, in the precise semantics which POSIX  
> assigns to these
> bits.
>
>> The fact that you argue this does not make it a requirement.  As  
>> stated
>> above, RFC 3530 defines these bits as reflecting the mode.
>
> I have above argued within which limits the definition in RFC3530  
> is correct
> with respect to POSIX, and that this definition is not general  
> enough as soon
> as ACLs, in the form of additional file access control mechanisms,  
> are used
> on POSIX compliant systems.
>
>> ACL is not a required attribute in NFSv4.  If we adopted your
>> proposal, a client that supported mode but not ACL would be unable to
>> set the mode of a file.
>
> Not at all. Maybe you can explain what makes you think so. An  
> application can
> set the mode with a mode SETATTR at any time, etc.
>
>> But let's pretend that all NFSv4 clients do support the ACL
>> attribute.  Having the chmod command unable to set the mode was a
>> source of many customer complaints when that was the behavior in
>> Solaris (http://xrl.us/pd7c and http://xrl.us/pd7b are just two
>> examples of bugs).  The Solaris chmod command was fixed to alter the
>> POSIX-draft ACL (in file systems that support POSIX-draft ACLs), so
>> that chmod was actually able to change the mode.  Since making this
>> change to chmod, complaints have stopped.
>
> Maybe nobody explained to users how to properly use ACLs to prevent  
> this from
> happening? The behavior of Solaris chmod(1) is a potential security  
> hole,
> although a small one only.

I remind you that in NFSv4, ACL is not a required attribute.

>> So, if we were to do as your proposed design says, and have
>> MODE4_RGRP, etc., not reflect the mode, then once again, we would
>> have to modify the chmod command to do more than the chmod() system
>> call.  This is madness.
>
> This is not what I am proposing at all.
>
>> Or, we could simply have MODE4_RGRP, etc., reflect the mode of the  
>> file.
>
> This *is* what I am proposing. A mode SETATTR also affects which  
> permissions
> are effective in the ACL and which must be disabled, though. Both  
> proposals
> disable permissions, but they do so using different mechanisms:  
> your proposal
> introduces DENY ACEs spread throughout the ACL. My proposal sets  
> masks, which
> are only applied in the access check algorithm. I argue that simply  
> updating
> the masks is a much nicer way of achieving the same effect, and  
> that it
> avoids the problems inherent to those DENY ACEs.
>
>>> Algorithm 5.6.3. is at least problematic because it enforces  
>>> implementing
>>> masking of permissions using DENY ACEs, while an alternative  
>>> design exists
>>> that achieves the same effects without the disadvantages of those
>>> DENY ACEs.
>>
>> That alternative introduces a new file attribute, which causes
>> problems for NFSv4.0, and for Windows servers.
>
> That's not true. There are several ways how we can deal with clients

You just ignored my comment about Windows servers.

> that do
> not understand masks:
>
>  (1) we can apply the masks before exposing the ACL to such  
> clients, or
>
>  (2) we can introduce DENY ACEs where necessary, as per your proposal.
>
> With (2), we are back to the problems with DENY ACEs: clients which  
> reorder
> ACEs as (at least some versions of) Windows do will cause havoc.  
> *But* we
> will never run into any such effects with clients that *do*  
> understand masks,
> we don't have to bloat ACLs all the time,
>
> On the other hand, with (1), an ACL read-modify-write cycle will  
> potentially
> lose some information, but the huge benefit is that the ACLs that  
> clients
> will see will actually make some sense to them, instead of being  
> littered
> with DENY ACEs that nobody will know how to deal with. Of course  
> clients that
> understand masks will be fine as well.
>
> With both mechanisms, knocking the right mask bits in place in the  
> ACL will
> cause these bits to become effective (provided that other ACEs  
> don't deny
> them earlier in the ACL).
>
>>> The paragraphs below "3. To conform with POSIX" is lossy, even  
>>> with the
>>> six-entry ACL that "2. If there are at least six ACEs" would
>>> create, which is a very unfavorable property.
>>
>> No, it is not lossy with the six-entry ACE in "2. ...".  That's
>> because the six-entry ACE in "2." will be adjusted in the "3."
>> immediately following "2.".
>>
>> In general, the algorithm can be lossy, when modes such as 077 are
>> assigned to files having ACLs that grant read/write/execute to
>> supplemental groups.
>
> Exactly, the algorithm is lossy with supplemental groups. I misread  
> that "3.
> To conform with POSIX" only applies to explicit groups. My point  
> still stands
> though.

> Where does the algorithm deal with explicit users?

Section 5.6.3, step 1.5.2, if I understand your question correctly.

> Masks are not lossy per se, they will only become lossy when  
> talking to
> clients that don't understand masks

In other words, they can be lossy.

> (and in those cases, the effects will
> never be worse than with DENY ACEs).

The effects can be worse than with DENY ACEs.  I can think of an  
improvement to the existing algorithm that would make it be POSIX  
compliant and not be lossy, even in the face of setting mode 077.   
With your design, you cannot avoid being lossy in the face of NFSv4.0  
clients.

It is an issue that the masks can be lossy, but it is a greater issue  
that they are lossy with certain classes of clients, and not lossy  
with others.

>>> It also does not cover the case where the owner
>>> is granted permissions from EVERYONE@ ACEs, or where users or
>>> groups matching
>>> user@domain or group@domain are granted permissions from EVERYONE@
>>> ACEs.
>>
>> EVERYONE@ ACEs are covered.  Re-read the algorithm.
>
> Ah, I see now, "3. To conform with POSIX" only refers to explicit  
> groups.
>
>>> I can't see a compelling reason for requiring the exact six-entry
>>> ACL as specified in "2. If there are at least six ACEs".
>>
>> The goal of that step is to re-use the final six ACEs if possible, so
>> that successive changes to the mode don't cause a growing ACL.
>
> There is no reason for requiring this exact six-entry ACL other  
> that that the
> algorithm you have chosen relies on this exact form. Other  
> algorithms may be
> just fine with something completely different. I don't think that  
> NFSv4.1
> should limit implementations in ways like this.
>
>>> Finally, I have argued why it is wrong to have a mode SETATTR write
>>> through to USER@, GROUP@, and EVERYONE@ ACEs.
>>
>> To not do so leaves you in the situation where a client that supports
>> the mode attribute and not the ACL attribute cannot set the mode.
>
> Not true. What makes you think so?

Again, substitute "set the mode" with "control read/write/execute for  
owner/owner_group/other".

* * *

This thread has gone on long enough.

I will concede the following points: (1) Andreas' design will most  
likely be POSIX compliant; (2) the algorithms in draft-ietf-nfsv4- 
minorversion1-04.txt can produce ACLs that have ALLOW ACEs appearing  
in front of DENY ACEs, potentially confusing the Windows ACL GUI,  
even in cases where it's possible to have a semantically equivalent  
ACL without the ALLOW/DENY ordering.

I will assert the following points: (1) The current algorithms are  
POSIX compliant, and any attempts to show otherwise have failed; (2)  
Andreas' design requires a new file attribute, thus causing problems  
for Windows servers and inconsistent behavior between NFSv4.0 clients  
and clients that support the new mode; (3) Andreas' design makes it  
impossible to control read/write/execute permissions for owner/ 
owner_group/other without manipulating the ACL attribute.

I have proposed that the ACL text in the minorversion1 draft be  
revised such that the current algorithms are not required, and that  
the goals and requirements of the design are explicitly stated.  Can  
we end this thread until the revised ACL section has reached an  
initial draft?

- Sam

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
