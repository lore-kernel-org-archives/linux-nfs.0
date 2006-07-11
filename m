From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
 draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 01:17:43 -0500
Message-ID: <BCB7A126-5749-406A-A730-48B64C41402B@Sun.COM>
References: <200607032310.15252.agruen@suse.de>
	<200607091822.44656.agruen@suse.de>
	<B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
	<200607110050.57449.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@Sun.COM>,
	Brian Pawlowski <beepy@netapp.com>, nfsv4@ietf.org,
	Lisa Week <Lisa.Week@Sun.COM>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0BZ8-0000mt-4O
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 23:17:50 -0700
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0BZ8-0000K4-3e
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 23:17:50 -0700
Received: from fe-amer-01.sun.com ([192.18.108.175])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	k6B6Hken027811
	for <nfs@lists.sourceforge.net>; Tue, 11 Jul 2006 00:17:49 -0600 (MDT)
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
	id <0J2800D014AAYE00@mail-amer.sun.com>
	(original mail from Sam.Falkner@Sun.COM) for nfs@lists.sourceforge.net;
	Tue, 11 Jul 2006 00:17:46 -0600 (MDT)
In-reply-to: <200607110050.57449.agruen@suse.de>
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


On Jul 10, 2006, at 5:50 PM, Andreas Gruenbacher wrote:

> On Monday, 10. July 2006 15:29, Sam Falkner wrote:
>> On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:
>>> On Saturday, 8. July 2006 05:45, Sam Falkner wrote:
>>>> On Jul 7, 2006, at 5:55 AM, Andreas Gruenbacher wrote:
>>>>> On Monday, 3. July 2006 23:10, Andreas Gruenbacher wrote:

>>> Here are some facts to back my points: Let's assume that a file
>>> inherits the
>>> following ACL when being created (I am using ^(...) here with the
>>> meaning of
>>> "all bitflags except ..."):
>>>
>>> 	OWNER@:READ_DATA/WRITE_DATA::ALLOW
>>> 	OWNER@:^(READ_DATA/WRITE_DATA)::DENY
>>> 	GROUP@:READ_DATA::ALLOW
>>> 	user@domain:READ_DATA/WRITE_DATA::ALLOW
>>> 	GROUP@:^READ_DATA::DENY
>>> 	user@domain:^(READ_DATA/WRITE_DATA)::DENY
>>> 	EVERYONE@:READ_DATA::ALLOW
>>>
>>> This acl is "well structured" in the POSIX sense: OWNER@ will only
>>> get the
>>> owner permissions and none of the other permissions, user@domain
>>> and GROUP@
>>> will only get the permissions intended for them, and only others
>>> (neither
>>> OWNER@ nor user@domain nor GROUP@) will get EVERYONE@ permissions;
>>> in other
>>> words, the acl is even correct for non-monotonic permissions.
>>>
>>> According to section 5.1 of draft-ietf-nfsv4-acls [1], the
>>> resulting file mode
>>> permission bits for this acl shall be rw-r--r--.
>>
>> Your proposal would give this mode: rw-rw-r--.  I think we should
>> consider this more carefully.
>>
>>> After a chmod or a file
>>> create, alternate file access control mechanisms must be disabled
>>> and only
>>> additional file access control mechanisms may remain active.
>>> According to
>>> POSIX, additional file access control mechanisms require that no
>>> user may be
>>> granted more permissions than the respective file classes permit.
>>> In this
>>> case, user@domain clearly is not in the File Owner Class.
>>> (According to
>>> POSIX, user@domain must be in the File Group Class.) The
>>> user@domain user is
>>> granted WRITE_DATA though, which is *incorrect* from a POSIX point
>>> of view.
>>
>> No, it is not granted WRITE_DATA after a chmod().  After a chmod 644,
>> there will be a "user@domain:WRITE_DATA::DENY" prepended.  This is
>> well defined in the current minorversion1.  So it is not "incorrect
>> from a POSIX point of view."
>
> Now that I look at the example again, I realize that I didn't  
> define the
> create mode. With create mode 640 or less permissive, everything is  
> fine.
> Let's assume create mode 664 though: then the file mode permission  
> bits will
> still come out as rw-r--r--, but the ACL will grant WRITE_DATA to
> user@domain. That's the case I meant, and this case is not POSIX  
> compliant.

Wrong.  The file mode permission bits will be rw-rw-r--.  There is no  
problem with POSIX compliance.

>> If your problem is with the computation of the mode, then we can
>> discuss this some more.  But following create or chmod, user@domain
>> is not granted WRITE_DATA.
>
> My problems are these:
>
> * the algorithm in 5.3 is based on an ACE classification closer to  
> the one
>   I proposed, while the algorithm in 5.1 is based on a different
>   classsification. We need to straighten this out, and I have argued
>   repeatedly now why the classification I proposed leads to consistent
>   and correct results. Most of the little inconsistencies in
>   draft-ietf-nfsv4-acls-00 will stick out quite clearly once we  
> agree on
>   the right classification, and they will be easy to fix.
>
> * the DENY entries introduced to mask permissions bloat the ACL,  
> and make
>   the ACL look strange to non-POSIX systems. The algorithm in  
> section 5.3
>   may remove permissions from user-provided DENY entries in some  
> cases,
>   and it may introduce duplicate DENY entries in some situations  
> such as
>   when another system reorders ACEs.Some versions of Windows do that.
>
> The alternative approach I am proposing has a clear classification  
> of ACEs,
> separates the orthogonal aspects of classification vs. well-formed  
> acls, and
> has none of the weaknesses that the mask DENY ACEs cause.
>
>>> Next, let's assume than an ACL contains the following pair of user-
>>> provided entries:
>>>
>>> 	GROUP@:WRITE_DATA::DENY
>>> 	GROUP@:READ_DATA::ALLOW
>>>
>>> Clearly the user's intention is to deny WRITE_DATA access to GROUP@.
>>
>> Yes, that *was* the user's intention, at the time the user set the  
>> ACL.
>
> Hm... not the best example because GROUP@ is the owning group, which
> corresponds to the group file mode permission bits in traditional  
> POSIX. The
> problem is more difficult to see in this case, but I argue that the  
> owhning
> group permissions and the group file mode permission bits are not  
> the same
> with ACLs: the file group mode permission bits restrict GROUP@  
> entries, and
> all user@domain and group@domain entries in the acl. For the sake  
> of this
> example, substitute GROUP@ with user@domain though, and you'll see the
> problem more clearly: a user adds an explicit  
> user@domain:WRITE_DATA::DENY
> entry to an acl which is followed by a user@domain:READ_DATA::ALLOW  
> entry.
> After a chmod to 664 for example, this user suddenly has write  
> access. The
> user clearly did not intend this to happen.

No -- after the chmod, the DENY still stands, unaltered.

- Sam


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
