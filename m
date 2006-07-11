From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 02:44:30 +0200
Message-ID: <200607110244.31010.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<A254D982-E33B-4DFA-892C-2ADE1B5AAD52@Sun.COM>
	<20060710223939.GL10035@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Sam Falkner <Sam.Falkner@sun.com>, Lisa Week <Lisa.Week@sun.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G06PK-0004su-Q7
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 17:47:22 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G06PK-0000oQ-Az
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 17:47:23 -0700
To: nfsv4@ietf.org
In-Reply-To: <20060710223939.GL10035@fieldses.org>
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

On Tuesday, 11. July 2006 00:39, J. Bruce Fields wrote:
> On Mon, Jul 10, 2006 at 05:26:32PM -0500, Sam Falkner wrote:
> > On Jul 10, 2006, at 1:57 PM, J. Bruce Fields wrote:
> > >If we're committed to getting the mask ace right, though, I would
> > >prefer to adopt one of Andreas's solutions; they'd allow us to
> > >generate much simpler ACLs.  I actually prefer the first proposal
> > >(letting the  server use the mode bits to mask out permissions).  But
> > >if we're going to add explicit mask aces, then please, let's add only
> > >one.  I understand the theoretical advantage to masking out all three
> > >classes, but that's adding too much complexity for a few corner
> > >cases, and I don't think it's going to be easy for users to
> > >understand.
> >
> > How would a scheme that uses one and only one mask ACE work?  Are you
> > thinking of catching mode 077 via a
> >
> > OWNER@:READ_DATA/WRITE_DATA/EXECUTE:DENY
> >
> > but having no way to catch mode 707 (because GROUP@:READ_DATA/
> > WRITE_DATA/EXECUTE:DENY might catch the owner)?
>
> Andreas's proposal was actually to add something new to the protocol
> (either a new attribute, or a new special entity (like "MASK@")) to
> transfer the mask.  One of the advantages of doing that is that you'd no
> longer have to use a bunch of DENY ACEs scattered through the ACL, all
> carrying the same information.  E.g. you'd the client to include an ACE
> like
>
> 	MASK@:READ_DATA:DENY
>
> and modify the NFSv4 acl-permission-checking algorithm to mask out any
> bitmasks anywhere other than OWNER@ or DENY@.

Another benefit would be that we can tell what are MASK entries and which 
entries are not. That's not always possible with the DENY entries.

> But Andreas was proposing that we actually add 3 different types of
> masks, one for the OWNER@, one for EVERYONE@, and one for the others,
> and I think that's overkill.  So that's what I'm arguing against.

The reason for adding owner and other masks was this: we want to be able to 
turn off alternate permissions upon chmod and acl inheritance. We can already 
easily do that for the File Group Class by cleaning the alternate mask bits 
there; it's the same mechanism we also use for turning off additional mask 
bits for chmod, for example. We need to be able to turn off alternate and 
additional mode bits for the owner and for others as well in cases like 
chmod. Now we could devise a different mechanism for turning off alternate 
permissions for the owner and for others (like a bit somewhere), but that 
would still leave us with the problem of how to turn off additional mask 
bits. The NFSv4 ACL mask bits are more fine-grained that the POSIX mask bits, 
and we don't want to destroy the granularity of the NFSv4 ACL mask bits when 
masking permissions. Therefore, we need mask entries for the owner and for 
others as well.

Consider this ACL:

	OWNER@:READ_DATA/WRITE_DATA::ALLOW
	GROUP@:APPEND_DATA::DENY
	GROUP@:READ_DATA::ALLOW
	EVERYONE@:APPEND_DATA::ALLOW

The corresponding mode is 0642 (rw-r---w-). POSIX applications will know 
nothing about the fact that others are only allowed to append data to that 
file. Now consider that a user does a chmod(file, 0) followed by a 
chmod(file, 0642). Which permissions should others have after the chmod? Not 
full write access I assume; POSIX applications should not remove restrictions 
they are not even aware of by accident.

Using the same masking mechanism across all three classes and being able to 
selectively turn alternate mask bits on and off for all classes can only be a 
benefit.

> > >We could add a new ACE type (in addition to ALLOW, DENY, AUDIT,
> > >ALARM), and then a client could query the server's ability to
> > >represent the  mask with the aclsupport attribute and decide whether
> > >it wants to add  DENY's to represent the mask, or just give up on
> > >chmod reversibility.
> >
> > Please explain this further.  What would the fifth ACE type do?  What
> > would it give you that DENY wouldn't?
>
> It's just a way to pass the mask inside the ACL, but using a new ACE
> type instead of a new special entity.

Yes, that was one of the possible designs.

> The advantage is that a client can actually probe to see if the server
> supports it, so we wouldn't have to make it mandatory for a server to
> support it.  But a separate attribute would also have that property.

Advantages of attributes are that clients will never be bothered with ACE 
types they don't know. We can directly access attibutes, rather than scanning 
for the right ACEs, inserting ACEs in case they are missing, etc. There will 
be exactly three masks (or so I hope), and I don't see why we should need to 
add more classes later. We can store all three classes as a single attribute 
though; that may be more acceptable that three separate attributes.

Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
