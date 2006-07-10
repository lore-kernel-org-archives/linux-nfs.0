From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 10 Jul 2006 10:15:41 -0400
Message-ID: <20060710141541.GA978@fieldses.org>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
	<200607091822.44656.agruen@suse.de>
	<B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <spencer.shepler@Sun.COM>, nfs@lists.sourceforge.net,
	nfsv4@ietf.org, Lisa Week <Lisa.Week@Sun.COM>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FzwY5-0004e8-0g
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 07:15:45 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FzwY5-0000aX-24
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 07:15:45 -0700
To: Sam Falkner <Sam.Falkner@Sun.COM>
In-Reply-To: <B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
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

On Mon, Jul 10, 2006 at 07:29:56AM -0600, Sam Falkner wrote:
> On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:
> >According to section 5.1 of draft-ietf-nfsv4-acls [1], the  
> >resulting file mode
> >permission bits for this acl shall be rw-r--r--.
> 
> Your proposal would give this mode: rw-rw-r--.  I think we should  
> consider this more carefully.

As Andreas says, this is what the posix draft would have you do.  It's
also what Linux (and, I assume, Solaris) do in the case of posix ACLs.

If the goals was compatibility with that posix draft, RFC3530 should
have specified that owner, other, and group bits be kept in sync with
(respectively) OWNER@, EVERYONE@, and the *maximum* of permissions given
to any other entity, rather than with OWNER@, EVERYONE@, and GROUP@.

> You would call it wrong that a chmod 770 would allow WRITE_DATA to  
> members of the file's owning group?!  The  user did a chmod -- the  
> user changed the permissions on the file!

That is how posix acl's work; again, the group mode bit really
corresponds to the mask, not to the group acl entry:

	bfields@pickle:~$ getfacl foo
	# file: foo
	# owner: bfields
	# group: bfields
	user::rw-
	user:bfields:r--
	group::r--
	mask::r--
	other::---

	bfields@pickle:~$ chmod 770 foo
	bfields@pickle:~$ getfacl foo
	# file: foo
	# owner: bfields
	# group: bfields
	user::rwx
	user:bfields:r--
	group::r--
	mask::rwx
	other::---


Of course, "posix" acls aren't really posix, and we could do something
else if seems simpler.  Neither behavior seems intuitive to me in all
situations.

--b.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
