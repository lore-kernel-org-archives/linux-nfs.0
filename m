From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
 draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 10 Jul 2006 17:26:32 -0500
Message-ID: <A254D982-E33B-4DFA-892C-2ADE1B5AAD52@Sun.COM>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
	<200607091822.44656.agruen@suse.de>
	<B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
	<20060710141541.GA978@fieldses.org>
	<1A2FAFA9-0B94-48FA-8B0B-2A8AC0BE0331@Sun.COM>
	<20060710185742.GD10035@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <spencer.shepler@Sun.COM>, nfs@lists.sourceforge.net,
	nfsv4@ietf.org, Lisa Week <Lisa.Week@Sun.COM>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G04D7-0000FQ-Lx
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 15:26:37 -0700
Received: from brmea-mail-3.sun.com ([192.18.98.34])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G04D7-0004BP-DD
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 15:26:38 -0700
Received: from fe-amer-05.sun.com ([192.18.108.179])
	by brmea-mail-3.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	k6AMQaPx020288
	for <nfs@lists.sourceforge.net>; Mon, 10 Jul 2006 16:26:36 -0600 (MDT)
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
	id <0J2700A01KDS3B00@mail-amer.sun.com>
	(original mail from Sam.Falkner@Sun.COM) for nfs@lists.sourceforge.net;
	Mon, 10 Jul 2006 16:26:36 -0600 (MDT)
In-reply-to: <20060710185742.GD10035@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
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


On Jul 10, 2006, at 1:57 PM, J. Bruce Fields wrote:

> On Mon, Jul 10, 2006 at 09:32:28AM -0600, Sam Falkner wrote:
>> On Jul 10, 2006, at 8:15 AM, J. Bruce Fields wrote:
>>> As Andreas says, this is what the posix draft would have you do.   
>>> It's
>>> also what Linux (and, I assume, Solaris) do in the case of posix  
>>> ACLs.
>>
>> Not on Solaris.  With POSIX-draft ACLs, adding user:friend:rw- to a
>> mode rw-r--r-- file still gives you rw-r--r--.  (And as you point out
>> later, these ACLs ain't POSIX.)
> ...
>>> That is how posix acl's work; again, the group mode bit really
>>> corresponds to the mask, not to the group acl entry:
> ...
>> Again, not so on Solaris.  I wasn't aware that it was on Linux.   
>> Sigh.
>
> Ugh, sorry, OK, I didn't understand that we had that difference.
>
> Personally, after seeing how complicated this can get, I almost think
> I'd rather translate mode bits to NFSv4 ACLs by translating them to  
> the
> obvious ACL with 3 ALLOW ACEs.  And I'd rather translate the mask by
> just masking out the bits in the obvious way, rather than adding DENY
> aces.
>
> At the very least, I'd rather not *forbid* such an implementation.   
> Yes,
> it makes chmod irreversible, and it's wrong in a few rare corner  
> cases,
> but there are advantages to being wrong in a way that's simple and  
> easy
> to document.
>
> If we're committed to getting the mask ace right, though, I would  
> prefer
> to adopt one of Andreas's solutions; they'd allow us to generate much
> simpler ACLs.  I actually prefer the first proposal (letting the  
> server
> use the mode bits to mask out permissions).  But if we're going to add
> explicit mask aces, then please, let's add only one.  I understand the
> theoretical advantage to masking out all three classes, but that's
> adding too much complexity for a few corner cases, and I don't think
> it's going to be easy for users to understand.

How would a scheme that uses one and only one mask ACE work?  Are you  
thinking of catching mode 077 via a

OWNER@:READ_DATA/WRITE_DATA/EXECUTE:DENY

but having no way to catch mode 707 (because GROUP@:READ_DATA/ 
WRITE_DATA/EXECUTE:DENY might catch the owner)?

> We could add a new ACE type (in addition to ALLOW, DENY, AUDIT,  
> ALARM),
> and then a client could query the server's ability to represent the  
> mask
> with the aclsupport attribute and decide whether it wants to add  
> DENY's
> to represent the mask, or just give up on chmod reversibility.

Please explain this further.  What would the fifth ACE type do?  What  
would it give you that DENY wouldn't?

- Sam


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
