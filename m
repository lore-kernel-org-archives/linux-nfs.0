From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
 draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 08:44:42 -0400
Message-ID: <7C3E0D57-F0ED-4702-B24B-CF3E366FAF5D@Sun.COM>
References: <200607032310.15252.agruen@suse.de>
	<200607110050.57449.agruen@suse.de>
	<BCB7A126-5749-406A-A730-48B64C41402B@Sun.COM>
	<200607111045.43779.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <Spencer.Shepler@Sun.COM>, nfs@lists.sourceforge.net,
	nfsv4@ietf.org, Lisa Week <Lisa.Week@Sun.COM>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0Hbc-0001Rs-3A
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 05:44:48 -0700
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0Hbb-0004SN-Rz
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 05:44:48 -0700
Received: from fe-amer-05.sun.com ([192.18.108.179])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	k6BCijtv000580
	for <nfs@lists.sourceforge.net>; Tue, 11 Jul 2006 06:44:45 -0600 (MDT)
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
	id <0J2800I01OQ7XB00@mail-amer.sun.com>
	(original mail from Sam.Falkner@Sun.COM) for nfs@lists.sourceforge.net;
	Tue, 11 Jul 2006 06:44:45 -0600 (MDT)
In-reply-to: <200607111045.43779.agruen@suse.de>
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

On Jul 11, 2006, at 4:45 AM, Andreas Gruenbacher wrote:

> On Tuesday, 11. July 2006 08:17, Sam Falkner wrote:
>> On Jul 10, 2006, at 5:50 PM, Andreas Gruenbacher wrote:
>>> On Monday, 10. July 2006 15:29, Sam Falkner wrote:
>>>> On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:
>>>>> On Saturday, 8. July 2006 05:45, Sam Falkner wrote:
>>>>>> On Jul 7, 2006, at 5:55 AM, Andreas Gruenbacher wrote:
>>>>>>> On Monday, 3. July 2006 23:10, Andreas Gruenbacher wrote:
>>>>>
>>>>> Here are some facts to back my points: Let's assume that a file  
>>>>> inherits
>>>>> the following ACL when being created (I am using ^(...) here  
>>>>> with the
>>>>> meaning of "all bitflags except ..."):
>>>>>
>>>>> 	OWNER@:READ_DATA/WRITE_DATA::ALLOW
>>>>> 	OWNER@:^(READ_DATA/WRITE_DATA)::DENY
>>>>> 	GROUP@:READ_DATA::ALLOW
>>>>> 	user@domain:READ_DATA/WRITE_DATA::ALLOW
>>>>> 	GROUP@:^READ_DATA::DENY
>>>>> 	user@domain:^(READ_DATA/WRITE_DATA)::DENY
>>>>> 	EVERYONE@:READ_DATA::ALLOW
>>>>>
>>>>> This acl is "well structured" in the POSIX sense: OWNER@ will  
>>>>> only get
>>>>> the owner permissions and none of the other permissions,  
>>>>> user@domain
>>>>> and GROUP@ will only get the permissions intended for them, and  
>>>>> only
>>>>> others (neither OWNER@ nor user@domain nor GROUP@) will get  
>>>>> EVERYONE@
>>>>> permissions; in other words, the acl is even correct for non- 
>>>>> monotonic
>>>>> permissions.
>>>>>
>>>>> According to section 5.1 of draft-ietf-nfsv4-acls [1], the  
>>>>> resulting
>>>>> file mode permission bits for this acl shall be rw-r--r--.
>>>>
>>>> Your proposal would give this mode: rw-rw-r--.  I think we should
>>>> consider this more carefully.
>>>>
>>>>> After a chmod or a file create, alternate file access control  
>>>>> mechanisms
>>>>> must be disabled and only additional file access control  
>>>>> mechanisms may
>>>>> remain active. According to POSIX, additional file access control
>>>>> mechanisms require that no user may be granted more permissions  
>>>>> than the
>>>>> respective file classes permit. In this case, user@domain  
>>>>> clearly is not
>>>>> in the File Owner Class. (According to POSIX, user@domain must  
>>>>> be in the
>>>>> File Group Class.) The user@domain user is granted WRITE_DATA  
>>>>> though,
>>>>> which is *incorrect* from a POSIX point of view.
>>>>
>>>> No, it is not granted WRITE_DATA after a chmod().  After a chmod  
>>>> 644,
>>>> there will be a "user@domain:WRITE_DATA::DENY" prepended.  This is
>>>> well defined in the current minorversion1.  So it is not "incorrect
>>>> from a POSIX point of view."
>>>
>>> Now that I look at the example again, I realize that I didn't
>>> define the create mode. With create mode 640 or less permissive,
>>> everything is fine. Let's assume create mode 664 though: then the  
>>> file
>>> mode permission bits will still come out as rw-r--r--, but the  
>>> ACL will
>>> grant WRITE_DATA to user@domain. That's the case I meant, and  
>>> this case is
>>> not POSIX compliant.
>>
>> Wrong.  The file mode permission bits will be rw-rw-r--.  There is no
>> problem with POSIX compliance.
>
> Ah. And why should that be according to draft-ietf-nfsv4-acls-00?  
> Because the
> group file mode permission bits write through to GROUP@ entries,  
> and so the
> rw- group permissions in the create mask elevate the permissions  
> given to the
> owning group in the ACL?
>
> I hope that my reply from Tue, 11 Jul 2006 10:05:21 +0200 made it  
> clear that
> writing through to the GROUP@ entries causes POSIX applications to
> accidentally remove restrictions from an ACL, and so we really must  
> not do
> that. The same argument applies to writing through to OWNER@ and  
> EVERYONE@
> entries, by the way. The "The final six ACEs are adjusted according  
> to the
> incoming mode" section of the algorithm described in 5.3 is a  
> really bad
> idea.
>
>>>>> Next, let's assume than an ACL contains the following pair of  
>>>>> user-
>>>>> provided entries:
>>>>>
>>>>> 	GROUP@:WRITE_DATA::DENY
>>>>> 	GROUP@:READ_DATA::ALLOW
>>>>>
>>>>> Clearly the user's intention is to deny WRITE_DATA access to  
>>>>> GROUP@.
>>>>
>>>> Yes, that *was* the user's intention, at the time the user set the
>>>> ACL.
>>>
>>> Hm... not the best example because GROUP@ is the owning group, which
>>> corresponds to the group file mode permission bits in traditional
>>> POSIX. The problem is more difficult to see in this case, but I  
>>> argue
>>> that the owhning group permissions and the group file mode  
>>> permission
>>> bits are not the same with ACLs: the file group mode permission bits
>>> restrict GROUP@ entries, and all user@domain and group@domain  
>>> entries
>>> in the acl. For the sake of this example, substitute GROUP@ with
>>> user@domain though, and you'll see the problem more clearly: a user
>>> adds an explicit user@domain:WRITE_DATA::DENY entry to an acl which
>>> is followed by a user@domain:READ_DATA::ALLOW entry. After a  
>>> chmod to
>>> 664 for example, this user suddenly has write access. The
>>> user clearly did not intend this to happen.
>>
>> No -- after the chmod, the DENY still stands, unaltered.
>
> Great Sam, you have trapped me with another special case that is  
> there only
> because of those pesky mask DENY entries: "the mask bits are a  
> subset of the
> mask bits of the current ACE" [1].

I trapped you, but not out of malice.  The fact that you fell into  
the trap proves a point.  You tried to give an example as a  
reasonable pair of ACEs that a user would set, and fell into the trap  
of having the design deal with your ACEs correctly.  The design is to  
only manipulate DENY entries if the follow a very specific pattern, a  
pattern that an end-user is unlikely to set.  In other words, the  
design avoids manipulating DENYs unless the DENYs are redundant.

> My point still holds, just that the following ALLOW ACE must have  
> the denied
> WRITE_DATA permission set as well:
>
> 	user@domain:WRITE_DATA::DENY
> 	user@domain:READ_DATA/WRITE_DATA::ALLOW

Yes, there, the chmod would change the DENY ACE.  So if an end-user  
really did say WRITE_DATA:DENY, WRITE_DATA:ALLOW, albeit with other  
bits, then yes, the ACL can change as a result of the chmod.

> Do you *still* disagree?

I don't disagree that the DENY would be changed by a chmod(), but I  
do disagree that it's a major flaw.

I would rather live with the flaw of having redundant user-supplied  
ACEs manipulated upon chmod than to add new file attributes that  
NFSv4.0 clients and servers won't know about.

- Sam


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
