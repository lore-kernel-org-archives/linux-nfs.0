From: Andreas Gruenbacher <a.gruenbacher@computer.org>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 4 Aug 2006 02:30:51 +0200
Message-ID: <200608040230.52043.a.gruenbacher@computer.org>
References: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
	<200607250232.37603.a.gruenbacher@computer.org>
	<04075B08-F57D-4842-A7B2-9467DF9A39A2@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@sun.com>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	"Noveck, Dave" <Dave.Noveck@netapp.com>,
	Spencer Shepler <spencer.shepler@sun.com>,
	"Pawlowski,  Brian" <beepy@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8neK-0003nf-13
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 17:34:48 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8neJ-0008Fw-RU
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 17:34:48 -0700
To: Sam Falkner <Sam.Falkner@sun.com>
In-Reply-To: <04075B08-F57D-4842-A7B2-9467DF9A39A2@Sun.COM>
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

Sorry this reply took a while; I was away for a couple of days.

On Tuesday, 25 July 2006 06:26, Sam Falkner wrote:
> A more detailed analysis is forthcoming; for now, here's an early
> summary of objections.
>
> Your design tries very hard to preserve information in ACLs while
> retaining POSIX compliance at chmod() and create-with-mode time.  It
> does this by introducing a new file attribute.  The file attribute
> will not be understood by an NFSv4.0 client or server.  Thus, when an
> NFSv4.0 client manipulates the ACL via read/modify/write, it has just
> destroyed the information you tried to preserve within the ACL.

This depends on how backwards compatibility is implemented. I could imagine 
two options: (1) present NFSv4.0 clients/servers with ACLs that have all 
disabled mask bits removed, or (2) inject DENY ACEs in that case, similiar to 
draft-ietf-nfsv4-acls-00.

Let's look at NFSv4.0 clients first. With option (1), the client will see an 
ACL which is relatively simple to understand compared to option (2). After an 
ACL read/modify/write cycle, mask bits that were temporarily disabled before 
will be permanently disabled. In other words, the file will at most have the 
permissions defined in the ACL until the ACL is modified again, and future 
mode SETATTRs may further restrict those permissions, but will not elevate 
them relative to the ACL.

I argue that in an ACL read/modify/write cycle, users will set exactly the 
mask bits they intend the file to have, and so mask bits that were 
temporarily disabled before the ACL read/modify/write cycle and which the 
user did not explicitly set are not needed.

Masking is still important when POSIX applications manipulate file 
permissions: for example, a linker may create an object file with create mode 
0600 in a directory that has file inheritable ACEs, produce the whole file, 
and finally change the file mode to 0755. Masking causes sequences of POSIX 
operations like this to have the intended effect.

With option (2), the unsuspecting client will see a more complicated ACL that 
it may or may not be able to edit properly. It is unlikely that the ACL 
editor on the client will understand the masking mechanism, and it is equally 
unlikely that users will edit the ACL correctly so that none of the masked 
information will be lost, even if the ACL editor supports it. In Windows, the 
ACL editor will probably reorder ACL entries and move all DENY ACEs to the 
front, and so masking will break, for example. So I'm not convinced that the 
more complicated approach will actually gain us anything.

Let's look at NFSv4.0 servers now. The interesting operation in this case is a 
chmod on the client. The client could either (a) do a mode SETATTR, or (b) 
retrieve the ACL via GETATTR, modify it according to the new mode, and set 
the new ACL and mode via SETATTR. In option (b), we can again either (1) 
remove disabled permissions permanently, or (2) introduce DENY ACEs to do the 
masking.

I believe that we should implement option (a), and rely on the server to do 
the right thing: trying to implement POSIX behavior on the client side may 
interact badly with the ACLs support the NFSv4.0 server implements. (Servers 
may map NFSv4 ACLs onto a different kind of ACLs that support different 
semantics, for example.)

Implementing option (b) (2) could give us better POSIX semantics on non-POSIX 
servers like Windows. I am not convinced that the drawbacks of setting ACLs 
on Windows files that users will have a very hard time to understand and that 
Windows probably cannot edit are outweighed by the benefit of pretending that 
a Windows server is POSIX compliant. UNIX servers will probably benefit more 
from having their NFSv4 server updated so that a mode SETATTR does the right 
thing than from such hacks.

> Nor will the new file mask attribute be implemented natively on a
> Windows file system.   Thus, Windows servers will have significantly
> different access semantics for NFS clients than for users accessing
> the file system locally.

The same mask bits will be effective in both cases, so the access semantics 
are the same. A client that understands masks will additionally see which 
mask bits are currently disabled, but this does not change access decisions.

> An NFS server giving different answers for "what is the ACL",
> depending on who's asking or how are they asking, will lead to
> confusion and frustration for end users.

I don't see why this should be the case. Clients that understand masks can ask 
a more intelligent question and will get more information. Of course those 
clients must also present the masks to the user together with the ACL, and 
preferably indicate somehow which mask bits are temporarily disabled.

I claim that the mask DENY ACEs that draft-ietf-nfsv4-acls-00 uses are harder 
to understand than the mask attributes. Both approaches implement the same 
mechanism via different means. The masks implement masking explicitly; the 
DENY ACEs implement masking implicitly and it is harder to see which 
permissions are effective: The mask attributes define the maximum permissions 
that the ACL may grant; with DENY ACEs, the entire ACL needs to be carefully 
checked. Also, it is not guaranteed that the DENY ACEs are in fact consistent 
after a user has modified the ACL.

> One thing I'm very curious about is what you would expect an NFS
> client that supports the new access-mask-file-attribute to do with a
> server that does not support this attribute.  I cannot see a
> satisfactory outcome, but I won't call this a flaw yet, since your
> design is still being worked on.

I tried to answer this above. draft-ietf-nfsv4-acls-00 does not discuss this 
aspect, by the way: how did you intend to implement chmod on such a client?

> Finally, your design also specifies that the mode attribute not
> reflect the file mode.  It makes it impossible for a non-ACL-aware
> client to reliably get or set the owner/group/other permissions on a
> file.  Even on an ACL-aware client, it demands that end user
> utilities understand and support NFSv4 ACLs in order to set the mode
> of a file.

This is incorrect, and I believe we have clarified this already. The mode 
attribute does reflect the POSIX file mode in my proposal.

> It also advocates umask behavior that is not legal within POSIX, but
> that is outside the scope of NFS.

It advocates umask behavior that is not legal within POSIX for good reasons. 
The proposed behavior is specified in 1003.1e draft 17 (withdrawn). It has 
been implemented on several UNIX-like OSes for POSIX ACLs, and has been in 
production use on many installations for years.

Please argue against the reasons I have given if you disagree with the 
proposed behavior instead of hitting at me with the "illegal by POSIX" stick.

Thanks,
Andreas

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
