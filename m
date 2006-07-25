From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
 draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 24 Jul 2006 22:26:06 -0600
Message-ID: <04075B08-F57D-4842-A7B2-9467DF9A39A2@Sun.COM>
References: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
	<20060721181058.GA17169@fieldses.org>
	<85DB3DBD-31B4-4F71-AEFB-5919DC072AD6@Sun.COM>
	<200607250232.37603.a.gruenbacher@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	"Noveck, Dave" <Dave.Noveck@netapp.com>,
	Spencer Shepler <spencer.shepler@Sun.COM>,
	"Pawlowski,  Brian" <beepy@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5EUY-0008Jj-T5
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 21:25:59 -0700
Received: from brmea-mail-1.sun.com ([192.18.98.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5EUX-0002So-Fq
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 21:25:59 -0700
Received: from fe-amer-04.sun.com ([192.18.108.178])
	by brmea-mail-1.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	k6P4PmWi014527
	for <nfs@lists.sourceforge.net>; Mon, 24 Jul 2006 22:25:53 -0600 (MDT)
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
	id <0J2X00A01YYN6900@mail-amer.sun.com>
	(original mail from Sam.Falkner@Sun.COM) for nfs@lists.sourceforge.net;
	Mon, 24 Jul 2006 22:25:46 -0600 (MDT)
In-reply-to: <200607250232.37603.a.gruenbacher@computer.org>
To: a.gruenbacher@computer.org
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

On Jul 24, 2006, at 6:32 PM, a.gruenbacher@computer.org wrote:

> On Sunday, 23. July 2006 17:47, Sam Falkner wrote:
>> On Jul 21, 2006, at 12:10 PM, J. Bruce Fields wrote:
>>> On Fri, Jul 21, 2006 at 11:10:04AM -0400, Noveck, Dave wrote:
>>>>> Rethinking, it would be preferable to have the ACL specification
>>>>> specify requirements, and have the algorithms serve as examples.
>>>>
>>>> I think the requirements that the algorithms are intended to  
>>>> address,
>>>> would be helpful in understanding, whether the algorithms are
>>>> examples or are mandatory.
>>>
>>> Yes.  My point wasn't necessarily that they should not be mandatory
>>> (though I think they probably shouldn't be--I'm not yet convinced
>>> they're actually correct), but that we need clarified whether  
>>> they're
>>> mandatory or not, and what requirements they're meant to meet,
>>> before we can evaluate them properly.
>>
>> If you have any concerns about their correctness, please let me
>> know.  As of now, there has not been a single example showing a flaw
>> in them.
>
> There are several flaws, but the lack of clarity on what the  
> algorithms are
> meant to achieve makes this somewhat difficult to see.
>
>> I realize this is difficult without having the requirements listed
>> explicitly -- this will be remedied very soon.
>
> Looking at draft-ietf-nfsv4-minorversion1-04.txt, I disagree with  
> secion
> 5.4.1. "Discussion of EVERYONE@".

The fact that you disagree with it is not a flaw.  That section is  
very simple -- it says that EVERYONE@ means "everyone".

If you are arguing that EVERYONE@ ACEs should be affected by the  
POSIX "other" class upon chmod(), then that's not in disagreement  
with 5.4.1.

> Section 5.5. "Mode Attribute" claims that
> MODE4_RGRP, MODE4_WGRP, MODE4_XGRP apply to the principals  
> identified in the
> owner_group attribute, while it's really the File Group Class  
> according to
> POSIX.

Since when does POSIX define NFSv4?  RFC 3530 is the current  
authority on NFSv4, and it says that the mode attribute is based upon  
the UNIX mode -- seems sensible to me.

> From that pretty much follows that the algorithm defined in Section
> 5.6.1. is not POSIX compliant: the File Group Class permissions  
> must be a
> superset of the permissions of the permissions granted to all ACEs  
> for a who
> other than OWNER@ and EVERYONE@, and the 5.6.1. algorithm does not  
> guarantee
> this.

You are arguing that NFSv4 should define MODE4_RGRP, MODE4_WGRP, and  
MODE4_XGRP to be something other than the UNIX mode bits.  The fact  
that you argue this does not make it a requirement.  As stated above,  
RFC 3530 defines these bits as reflecting the mode.

ACL is not a required attribute in NFSv4.  If we adopted your  
proposal, a client that supported mode but not ACL would be unable to  
set the mode of a file.

But let's pretend that all NFSv4 clients do support the ACL  
attribute.  Having the chmod command unable to set the mode was a  
source of many customer complaints when that was the behavior in  
Solaris (http://xrl.us/pd7c and http://xrl.us/pd7b are just two  
examples of bugs).  The Solaris chmod command was fixed to alter the  
POSIX-draft ACL (in file systems that support POSIX-draft ACLs), so  
that chmod was actually able to change the mode.  Since making this  
change to chmod, complaints have stopped.

So, if we were to do as your proposed design says, and have  
MODE4_RGRP, etc., not reflect the mode, then once again, we would  
have to modify the chmod command to do more than the chmod() system  
call.  This is madness.

Or, we could simply have MODE4_RGRP, etc., reflect the mode of the file.

> Algorithm 5.6.3. is at least problematic because it enforces  
> implementing
> masking of permissions using DENY ACEs, while an alternative design  
> exists
> that achieves the same effects without the disadvantages of those  
> DENY ACEs.

That alternative introduces a new file attribute, which causes  
problems for NFSv4.0, and for Windows servers.

> The paragraphs below "3. To conform with POSIX" is lossy, even with  
> the
> six-entry ACL that "2. If there are at least six ACEs" would  
> create, which is
> a very unfavorable property.

No, it is not lossy with the six-entry ACE in "2. ...".  That's  
because the six-entry ACE in "2." will be adjusted in the "3."  
immediately following "2.".

In general, the algorithm can be lossy, when modes such as 077 are  
assigned to files having ACLs that grant read/write/execute to  
supplemental groups.

> It also does not cover the case where the owner
> is granted permissions from EVERYONE@ ACEs, or where users or  
> groups matching
> user@domain or group@domain are granted permissions from EVERYONE@  
> ACEs.

EVERYONE@ ACEs are covered.  Re-read the algorithm.

> I can't see a compelling reason for requiring the exact six-entry  
> ACL as
> specified in "2. If there are at least six ACEs".

The goal of that step is to re-use the final six ACEs if possible, so  
that successive changes to the mode don't cause a growing ACL.

> Finally, I have argued why it is wrong to have a mode SETATTR write  
> through to
> USER@, GROUP@, and EVERYONE@ ACEs.

To not do so leaves you in the situation where a client that supports  
the mode attribute and not the ACL attribute cannot set the mode.

* * *

So, once again, no real flaw has been pointed out in the existing  
specification.

> I have described a lot of aspects to the problem both here on this  
> list and in
> a design document, available at
> http://www.suse.de/~agruen/nfs4acl/mapping-nfsv4-acls-to- 
> posix-00.html, and I
> would very much appreciate if you could comment on which parts you  
> disagree
> with and why, in order so that we can come to a conclusion on what  
> we want to
> achieve. I am convinced that once we agree on the basic framework  
> we operate
> within, how to do so will become a lot more obvious.

A more detailed analysis is forthcoming; for now, here's an early  
summary of objections.

Your design tries very hard to preserve information in ACLs while  
retaining POSIX compliance at chmod() and create-with-mode time.  It  
does this by introducing a new file attribute.  The file attribute  
will not be understood by an NFSv4.0 client or server.  Thus, when an  
NFSv4.0 client manipulates the ACL via read/modify/write, it has just  
destroyed the information you tried to preserve within the ACL.

Nor will the new file mask attribute be implemented natively on a  
Windows file system.   Thus, Windows servers will have significantly  
different access semantics for NFS clients than for users accessing  
the file system locally.

An NFS server giving different answers for "what is the ACL",  
depending on who's asking or how are they asking, will lead to  
confusion and frustration for end users.

One thing I'm very curious about is what you would expect an NFS  
client that supports the new access-mask-file-attribute to do with a  
server that does not support this attribute.  I cannot see a  
satisfactory outcome, but I won't call this a flaw yet, since your  
design is still being worked on.

Finally, your design also specifies that the mode attribute not  
reflect the file mode.  It makes it impossible for a non-ACL-aware  
client to reliably get or set the owner/group/other permissions on a  
file.  Even on an ACL-aware client, it demands that end user  
utilities understand and support NFSv4 ACLs in order to set the mode  
of a file.

It also advocates umask behavior that is not legal within POSIX, but  
that is outside the scope of NFS.

- Sam



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
