From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
 draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 08:29:21 -0400
Message-ID: <67359DB9-6E3E-49E7-A8F6-3FB34DCC3440@Sun.COM>
References: <200607032310.15252.agruen@suse.de>
	<200607110215.53496.agruen@suse.de>
	<3E4B637E-57AC-4E2B-A2C8-EDCFF35A5D84@Sun.COM>
	<200607111005.22200.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@Sun.COM>,
	Brian Pawlowski <beepy@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0HMk-0008Op-Gn
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 05:29:26 -0700
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0HMj-0000uq-FG
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 05:29:26 -0700
Received: from fe-amer-01.sun.com ([192.18.108.175])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	k6BCTOrp021150
	for <nfs@lists.sourceforge.net>; Tue, 11 Jul 2006 06:29:24 -0600 (MDT)
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
	id <0J2800401NTSRQ00@mail-amer.sun.com>
	(original mail from Sam.Falkner@Sun.COM) for nfs@lists.sourceforge.net;
	Tue, 11 Jul 2006 06:29:24 -0600 (MDT)
In-reply-to: <200607111005.22200.agruen@suse.de>
To: Andreas Gruenbacher <agruen@suse.de>
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


On Jul 11, 2006, at 4:05 AM, Andreas Gruenbacher wrote:

> On Tuesday, 11. July 2006 07:42, Sam Falkner wrote:
>>>> I think having chmod be functional, i.e. chmod 770 gives write
>>>> permission to the owning group, and an "ls -l" shows "rwxrwx---",
>>>> would be best by far.
>>>
>>> It screws you when you want to give the owning group fewer  
>>> permissions
>>> than other users in the File Group Class. This can be worked  
>>> around by
>>> creating a dummy group with no members, or one group that only  
>>> contains
>>> a single user for each user, and changing the owning group of  
>>> files, but
>>> the owning group already has other defined uses in POSIX (think  
>>> of SETGID
>>> for files and directories), and so it's not desirable and not always
>>> possible to change the owning group to such a dummy group.
>>
>> No -- if you want owning group to have fewer permissions than other
>> users, you're using an ACL.  You use tools that manipulate ACLs.
>
> Sorry, but while this may look like a good idea at first, it  
> doesn't work very
> well. Let's look at an example:
>
> 	OWNER@:READ_DATA/WRITE_DATA::ALLOW
> 	GROUP@:READ_DATA/WRITE_DATA::ALLOW
> 	user@domain:READ_DATA/WRITE_DATA::ALLOW
> 	EVERYONE:READ_DATA::ALLOW
>
> The mode is rw-rw-r--. Now we use ACL tools to change the ACL to  
> give the
> owning group fewer permissions than user@domain as you say:
>
> 	OWNER@:READ_DATA/WRITE_DATA::ALLOW
> 	GROUP@:READ_DATA::ALLOW
> 	user@domain:READ_DATA/WRITE_DATA::ALLOW
> 	EVERYONE:READ_DATA::ALLOW

> The mode must still be rw-rw-r-- because otherwise, user@domain  
> wouldn't have
> WRITE_DATA access. Now a nasty, evil POSIX application that doesn't  
> know
> anything about ACLs comes along and does a chmod(file, 0600), chmod 
> (file,
> 0664). What should be the appropriate result? If changing the group  
> file mode
> permission bits writes through to the GROUP@ entry as you say, then  
> we would
> end up with the following *effective* permissions:
>
> 	OWNER@:READ_DATA/WRITE_DATA::ALLOW
> 	GROUP@:READ_DATA/WRITE_DATA::ALLOW
> 	user@domain:READ_DATA/WRITE_DATA::ALLOW
> 	EVERYONE:READ_DATA::ALLOW

That's not how Solaris works either.  Sorry, I should have explained  
it better.  In Solaris using POSIX-draft ACLs, chmod() changes both  
the group permissions and the mask, simultaneously.  I now understand  
why you were hesitant to have chmod affect the group permissions, but  
having it affect both mask and group solves both problems.

I realize that I'm talking about POSIX-draft ACLs, but the same  
design principles work for NFSv4 ACLs.  chmod() affects the GROUP@  
permissions directly, and also affects the mask, no matter how the  
mask is implemented.

- Sam


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
