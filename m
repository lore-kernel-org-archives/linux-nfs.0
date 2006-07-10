From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 10 Jul 2006 18:39:39 -0400
Message-ID: <20060710223939.GL10035@fieldses.org>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
	<200607091822.44656.agruen@suse.de>
	<B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
	<20060710141541.GA978@fieldses.org>
	<1A2FAFA9-0B94-48FA-8B0B-2A8AC0BE0331@Sun.COM>
	<20060710185742.GD10035@fieldses.org>
	<A254D982-E33B-4DFA-892C-2ADE1B5AAD52@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <spencer.shepler@Sun.COM>, nfs@lists.sourceforge.net,
	nfsv4@ietf.org, Lisa Week <Lisa.Week@Sun.COM>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G04Po-0001SM-Di
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 15:39:44 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G04Pm-0005Bs-9m
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 15:39:44 -0700
To: Sam Falkner <Sam.Falkner@Sun.COM>
In-Reply-To: <A254D982-E33B-4DFA-892C-2ADE1B5AAD52@Sun.COM>
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

On Mon, Jul 10, 2006 at 05:26:32PM -0500, Sam Falkner wrote:
> 
> On Jul 10, 2006, at 1:57 PM, J. Bruce Fields wrote:
> >If we're committed to getting the mask ace right, though, I would
> >prefer to adopt one of Andreas's solutions; they'd allow us to
> >generate much simpler ACLs.  I actually prefer the first proposal
> >(letting the  server use the mode bits to mask out permissions).  But
> >if we're going to add explicit mask aces, then please, let's add only
> >one.  I understand the theoretical advantage to masking out all three
> >classes, but that's adding too much complexity for a few corner
> >cases, and I don't think it's going to be easy for users to
> >understand.
> 
> How would a scheme that uses one and only one mask ACE work?  Are you
> thinking of catching mode 077 via a
> 
> OWNER@:READ_DATA/WRITE_DATA/EXECUTE:DENY
> 
> but having no way to catch mode 707 (because GROUP@:READ_DATA/
> WRITE_DATA/EXECUTE:DENY might catch the owner)?

Andreas's proposal was actually to add something new to the protocol
(either a new attribute, or a new special entity (like "MASK@")) to
transfer the mask.  One of the advantages of doing that is that you'd no
longer have to use a bunch of DENY ACEs scattered through the ACL, all
carrying the same information.  E.g. you'd the client to include an ACE
like

	MASK@:READ_DATA:DENY

and modify the NFSv4 acl-permission-checking algorithm to mask out any
bitmasks anywhere other than OWNER@ or DENY@.

But Andreas was proposing that we actually add 3 different types of
masks, one for the OWNER@, one for EVERYONE@, and one for the others,
and I think that's overkill.  So that's what I'm arguing against.

> >We could add a new ACE type (in addition to ALLOW, DENY, AUDIT,
> >ALARM), and then a client could query the server's ability to
> >represent the  mask with the aclsupport attribute and decide whether
> >it wants to add  DENY's to represent the mask, or just give up on
> >chmod reversibility.
> 
> Please explain this further.  What would the fifth ACE type do?  What
> would it give you that DENY wouldn't?

It's just a way to pass the mask inside the ACL, but using a new ACE
type instead of a new special entity.

The advantage is that a client can actually probe to see if the server
supports it, so we wouldn't have to make it mandatory for a server to
support it.  But a separate attribute would also have that property.

--b.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
