From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
 draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 00:42:05 -0500
Message-ID: <3E4B637E-57AC-4E2B-A2C8-EDCFF35A5D84@Sun.COM>
References: <200607032310.15252.agruen@suse.de>
	<20060710141541.GA978@fieldses.org>
	<1A2FAFA9-0B94-48FA-8B0B-2A8AC0BE0331@Sun.COM>
	<200607110215.53496.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@Sun.COM>,
	Brian Pawlowski <beepy@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0B0j-0006Oj-98
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 22:42:17 -0700
Received: from brmea-mail-1.sun.com ([192.18.98.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0B0h-0000iD-Uc
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 22:42:17 -0700
Received: from fe-amer-02.sun.com ([192.18.108.176])
	by brmea-mail-1.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	k6B5g9CL007695
	for <nfs@lists.sourceforge.net>; Mon, 10 Jul 2006 23:42:13 -0600 (MDT)
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
	id <0J2800D013T59J00@mail-amer.sun.com>
	(original mail from Sam.Falkner@Sun.COM) for nfs@lists.sourceforge.net;
	Mon, 10 Jul 2006 23:42:09 -0600 (MDT)
In-reply-to: <200607110215.53496.agruen@suse.de>
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


On Jul 10, 2006, at 7:15 PM, Andreas Gruenbacher wrote:

> On Monday, 10. July 2006 17:32, Sam Falkner wrote:
>> On Jul 10, 2006, at 8:15 AM, J. Bruce Fields wrote:
>>> On Mon, Jul 10, 2006 at 07:29:56AM -0600, Sam Falkner wrote:
>>>> On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:
>>>>> According to section 5.1 of draft-ietf-nfsv4-acls [1], the
>>>>> resulting file mode
>>>>> permission bits for this acl shall be rw-r--r--.
>>>>
>>>> Your proposal would give this mode: rw-rw-r--.  I think we should
>>>> consider this more carefully.
>>>
>>> As Andreas says, this is what the posix draft would have you do.   
>>> It's
>>> also what Linux (and, I assume, Solaris) do in the case of posix  
>>> ACLs.
>>
>> Not on Solaris.  With POSIX-draft ACLs, adding user:friend:rw- to a
>> mode rw-r--r-- file still gives you rw-r--r--.  (And as you point out
>> later, these ACLs ain't POSIX.)
>
> Indeed, they are only pretty close. One other difference is that  
> Solaris POSIX
> ACLs are always four-entry on some (all?) file systems, while Draft  
> 17 ACLs
> as implemented on Irix, FreeBSD, Linux, and possibly others support
> three-entry ACLs as well (they are equivalent to the file mode  
> permission
> bits.)
>
> It would be bad to repeat the mistake of breaking POSIX assumptions.
>
>> I think having chmod be functional, i.e. chmod 770 gives write
>> permission to the owning group, and an "ls -l" shows "rwxrwx---",
>> would be best by far.
>
> It screws you when you want to give the owning group fewer  
> permissions than
> other users in the File Group Class. This can be worked around by  
> creating a
> dummy group with no members, or one group that only contains a  
> single user
> for each user, and changing the owning group of files, but the  
> owning group
> already has other defined uses in POSIX (think of SETGID for files and
> directories), and so it's not desirable and not always possible to  
> change the
> owning group to such a dummy group.

No -- if you want owning group to have fewer permissions than other  
users, you're using an ACL.  You use tools that manipulate ACLs.

Solaris' POSIX-draft ACLs have the property that chmod works (i.e.  
you can set group permissions), and you use setfacl if you want to  
change other entries.  It's perfectly easy to have owning group have  
fewer permissions than supplimental users.

The bottom line is that chmod must set the mode, rather than "set the  
mode, unless there's some sort of ACL thingy, in which case the group  
bits aren't the group bits but are instead the mask bits".

- Sam


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
