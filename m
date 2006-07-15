From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
 draft-ietf-nfsv4-acls-00 not ready
Date: Sat, 15 Jul 2006 07:56:23 -0600
Message-ID: <CB8011E1-395C-46D7-9F3A-4E75DDB080D4@Sun.COM>
References: <200607032310.15252.agruen@suse.de>
	<200607110215.53496.agruen@suse.de>
	<3E4B637E-57AC-4E2B-A2C8-EDCFF35A5D84@Sun.COM>
	<200607111005.22200.agruen@suse.de>
	<67359DB9-6E3E-49E7-A8F6-3FB34DCC3440@Sun.COM>
	<20060711134635.GA11586@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	nfs@lists.sourceforge.net, Spencer Shepler <spencer.shepler@Sun.COM>,
	Brian Pawlowski <beepy@netapp.com>,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1kdD-000584-A4
	for nfs@lists.sourceforge.net; Sat, 15 Jul 2006 06:56:31 -0700
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G1kdC-0007TG-02
	for nfs@lists.sourceforge.net; Sat, 15 Jul 2006 06:56:31 -0700
Received: from fe-amer-03.sun.com ([192.18.108.177])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	k6FDuPMQ004665
	for <nfs@lists.sourceforge.net>; Sat, 15 Jul 2006 07:56:28 -0600 (MDT)
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
	id <0J2G002012YCIH00@mail-amer.sun.com>
	(original mail from Sam.Falkner@Sun.COM) for nfs@lists.sourceforge.net;
	Sat, 15 Jul 2006 07:56:25 -0600 (MDT)
In-reply-to: <20060711134635.GA11586@fieldses.org>
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
> chmod's
> that leaves the mode bits the same also leaves the ACL the same.  I
> agree that that's a nice property.

Perhaps, but I think having chmod unable to set the mode to be a much  
more undesirable property, to put it mildly.

> What I'm not convinced of yet is that this is really worth caring  
> about
> much.  Is this common application behavior?  Have there been  
> complaints
> about this from people using Solaris's ACLs?

I did some more research, and found that the Solaris chmod() system  
call does pretty much what Linux does -- the group permissions of  
chmod() affect the mask, not the group permission bits.  Originally,  
the chmod command did the chmod() system call, and not much else.

There were many complaints about this.  So many that the chmod  
command line was changed to do the chmod() system call, and then, in  
the presence of an ACL, fix the permission bits.  In other words, the  
bug was fixed.

I have found no complaints about the current Solaris behavior, where  
chmod affects group permissions.

- Sam


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
