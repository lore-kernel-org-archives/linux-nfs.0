From: Spencer Shepler <Spencer.Shepler@Sun.COM>
Subject: Re: NFSv4 uninitialized mtime
Date: Wed, 27 Jun 2007 22:59:10 -0500
Message-ID: <2DD93BC2-E5C2-45C5-A054-D0580004E3AC@Sun.COM>
References: <20070627233114.GA14508@ligo.caltech.edu>
	<1182987805.5311.77.camel@heimdal.trondhjem.org>
	<20070628004904.GK9806@ligo.caltech.edu>
	<20070628005957.GA16461@ligo.caltech.edu>
	<20070627211559.e9fc68dd.jlayton@redhat.com>
	<20070628025327.GA18337@ligo.caltech.edu>
	<7FEBE408-60C8-41F3-99A3-9ABF1A381D44@sun.com>
	<20070628032356.GB18337@ligo.caltech.edu>
	<CACFA76B-43D8-454C-B06A-AAA4EF38A033@Sun.COM>
	<20070628034455.GD18337@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Stuart Anderson <anderson@ligo.caltech.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3l9M-0001T9-QH
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:58:32 -0700
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3l9P-0001C1-M3
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:58:36 -0700
Received: from fe-amer-03.sun.com ([192.18.108.177])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	l5S3wYXB021093
	for <nfs@lists.sourceforge.net>; Thu, 28 Jun 2007 03:58:34 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
	id <0JKB00J01UVNTM00@mail-amer.sun.com>
	(original mail from Spencer.Shepler@Sun.COM) for
	nfs@lists.sourceforge.net; Wed, 27 Jun 2007 21:58:34 -0600 (MDT)
In-reply-to: <20070628034455.GD18337@ligo.caltech.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Jun 27, 2007, at 10:44 PM, Stuart Anderson wrote:

> On Wed, Jun 27, 2007 at 10:30:22PM -0500, Spencer Shepler wrote:
>>
>> On Jun 27, 2007, at 10:23 PM, Stuart Anderson wrote:
>>
>>> On Wed, Jun 27, 2007 at 10:09:23PM -0500, Spencer Shepler wrote:
>>>>> Somewhat related is the reason that we are tring NFSV4 on Linux
>>>>> clients is
>>>>> that with NFSV3 ACL's do not work between Linux and Solaris if the
>>>>> filesystem
>>>>> on the Solaris server is ZFS, e.g., cp -p will generate  
>>>>> interesting
>>>>> error
>>>>> messages. While I would rather stay with NFSV4 if possible, has
>>>>> anyone
>>>>> gotten this configuration to work with V3?
>>>>
>>>> It will not.  ZFS does not support the "old" ACL definition; only
>>>> NFSv4 support.
>>>>
>>>
>>> Understood, so this is probably not a bug and just a feature, but  
>>> why
>>> does a Linux client try and then generate application level errors?
>>> A Solaris client is willing to NFS mount vers=3 a ZFS filesystem
>>> and then
>>> run GNU cp -rp, for example, without complaint. Perhaps there is a
>>> simple
>>> method determine if ACL's are available/supported on a particular  
>>> NFS
>>> mount?
>>
>> Does it fail on the "get" or "set" of the ACL?
>
> set
>
> Here is an strace snippet from running cp -rp on a Linux NFSV3 client
> of a Solaris 10 ZFS server:
>
> getxattr("test1/oink", "system.posix_acl_access", "\x02\x00\x00\x00 
> \x01\x00\x06\x00\xff\xff\xff\xff\x04\x00\x04\x00\xff\xff\xff\xff\x10 
> \x00\x07\x00\xff\xff\xff\xff \x00\x04\x00\xff\xff\xff\xff", 132) = 36
> setxattr("test2/oink", "system.posix_acl_access", "\x02\x00\x00\x00 
> \x01\x00\x06\x00\xff\xff\xff\xff\x04\x00\x04\x00\xff\xff\xff\xff\x10 
> \x00\x07\x00\xff\xff\xff\xff \x00\x04\x00\xff\xff\xff\xff", 36, 0)  
> = -1 EINVAL (Invalid argument)
>
> We used to have this same problem with Linux NFSV3 mounts from  
> Solaris QFS servers
> as well, but that was fixed in a recent update to QFS, so I am not  
> really sure
> who is "responsible" for bridging ACL's between the old/new schemes.

The Solaris NFSv3 server will, upon "get acl", map the underlying
ZFS ACL format to the NFSv3/ACL format.  However, on setting of
an acl, an error is returned (NOSUP).  The decision was made that
because of the imperfect mapping on acl set in this path that
an error would be returned.

I believe the Solaris client would map the ENOTSUP back to the
application as is and that may help the application adapt
its behavior (avoid erroring out if that isn't desired).

Spencer


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
