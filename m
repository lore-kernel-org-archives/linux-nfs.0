From: Spencer Shepler <Spencer.Shepler@Sun.COM>
Subject: Re: NFSv4 uninitialized mtime
Date: Wed, 27 Jun 2007 22:30:22 -0500
Message-ID: <CACFA76B-43D8-454C-B06A-AAA4EF38A033@Sun.COM>
References: <20070627233114.GA14508@ligo.caltech.edu>
	<1182987805.5311.77.camel@heimdal.trondhjem.org>
	<20070628004904.GK9806@ligo.caltech.edu>
	<20070628005957.GA16461@ligo.caltech.edu>
	<20070627211559.e9fc68dd.jlayton@redhat.com>
	<20070628025327.GA18337@ligo.caltech.edu>
	<7FEBE408-60C8-41F3-99A3-9ABF1A381D44@sun.com>
	<20070628032356.GB18337@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Stuart Anderson <anderson@ligo.caltech.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3khQ-00076r-0K
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:29:40 -0700
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3khT-0005gj-8k
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:29:43 -0700
Received: from fe-amer-03.sun.com ([192.18.108.177])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	l5S3TgPW015386
	for <nfs@lists.sourceforge.net>; Thu, 28 Jun 2007 03:29:42 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
	id <0JKB00D01TFQ1V00@mail-amer.sun.com>
	(original mail from Spencer.Shepler@Sun.COM) for
	nfs@lists.sourceforge.net; Wed, 27 Jun 2007 21:29:42 -0600 (MDT)
In-reply-to: <20070628032356.GB18337@ligo.caltech.edu>
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


On Jun 27, 2007, at 10:23 PM, Stuart Anderson wrote:

> On Wed, Jun 27, 2007 at 10:09:23PM -0500, Spencer Shepler wrote:
>>> Somewhat related is the reason that we are tring NFSV4 on Linux
>>> clients is
>>> that with NFSV3 ACL's do not work between Linux and Solaris if the
>>> filesystem
>>> on the Solaris server is ZFS, e.g., cp -p will generate interesting
>>> error
>>> messages. While I would rather stay with NFSV4 if possible, has  
>>> anyone
>>> gotten this configuration to work with V3?
>>
>> It will not.  ZFS does not support the "old" ACL definition; only
>> NFSv4 support.
>>
>
> Understood, so this is probably not a bug and just a feature, but why
> does a Linux client try and then generate application level errors?
> A Solaris client is willing to NFS mount vers=3 a ZFS filesystem  
> and then
> run GNU cp -rp, for example, without complaint. Perhaps there is a  
> simple
> method determine if ACL's are available/supported on a particular NFS
> mount?

Does it fail on the "get" or "set" of the ACL?

Spencer


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
