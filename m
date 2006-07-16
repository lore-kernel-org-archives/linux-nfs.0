From: "Noveck, Dave" <Dave.Noveck@netapp.com>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Sun, 16 Jul 2006 09:10:43 -0400
Message-ID: <C98692FD98048C41885E0B0FACD9DFB8029EFB06@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	nfs@lists.sourceforge.net, Spencer Shepler <spencer.shepler@Sun.COM>,
	Brian Pawlowski <beepy@netapp.com>,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G26Os-000382-6j
	for nfs@lists.sourceforge.net; Sun, 16 Jul 2006 06:11:10 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G26Or-00037e-Ao
	for nfs@lists.sourceforge.net; Sun, 16 Jul 2006 06:11:10 -0700
To: "Sam Falkner" <Sam.Falkner@Sun.COM>,
	"J. Bruce Fields" <bfields@fieldses.org>
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

What does Solaris do about chmod +s?  Does it modify the ACL? 

-----Original Message-----
From: Sam Falkner [mailto:Sam.Falkner@Sun.COM] 
Sent: Saturday, July 15, 2006 9:56 AM
To: J. Bruce Fields
Cc: Lisa Week; nfsv4@ietf.org; nfs@lists.sourceforge.net; Spencer
Shepler; Pawlowski, Brian; Andreas Gruenbacher
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction /
mask,draft-ietf-nfsv4-acls-00 not ready

On Jul 11, 2006, at 9:46 AM, J. Bruce Fields wrote:

> On Tue, Jul 11, 2006 at 08:29:21AM -0400, Sam Falkner wrote:
>> That's not how Solaris works either.  Sorry, I should have explained 
>> it better.  In Solaris using POSIX-draft ACLs, chmod() changes both 
>> the group permissions and the mask, simultaneously.  I now understand

>> why you were hesitant to have chmod affect the group permissions, but

>> having it affect both mask and group solves both problems.
>
> I think you're missing the point of his example.  The point is that a 
> chmod-using application may expect the sequence chmod(600) chmod
> (664) on
> a file with mode 664 to be a no-op.
>
> But if chmod() changes both group and mask bits ("owning group" and 
> "group file class" bits) then this sequence isn't a no-op any more in 
> his example.  It gives GROUP@ write permissions.

Okay, understood.

> So Andreas is trying to ensure the property that any sequence of 
> chmod's that leaves the mode bits the same also leaves the ACL the 
> same.  I agree that that's a nice property.

Perhaps, but I think having chmod unable to set the mode to be a much
more undesirable property, to put it mildly.

> What I'm not convinced of yet is that this is really worth caring 
> about much.  Is this common application behavior?  Have there been 
> complaints about this from people using Solaris's ACLs?

I did some more research, and found that the Solaris chmod() system call
does pretty much what Linux does -- the group permissions of
chmod() affect the mask, not the group permission bits.  Originally, the
chmod command did the chmod() system call, and not much else.

There were many complaints about this.  So many that the chmod command
line was changed to do the chmod() system call, and then, in the
presence of an ACL, fix the permission bits.  In other words, the bug
was fixed.

I have found no complaints about the current Solaris behavior, where
chmod affects group permissions.

- Sam

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
