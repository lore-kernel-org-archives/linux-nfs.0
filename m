From: Spencer Shepler <Spencer.Shepler@Sun.COM>
Subject: Re: NFSv4 uninitialized mtime
Date: Wed, 27 Jun 2007 22:09:23 -0500
Message-ID: <7FEBE408-60C8-41F3-99A3-9ABF1A381D44@sun.com>
References: <20070627233114.GA14508@ligo.caltech.edu>
	<1182987805.5311.77.camel@heimdal.trondhjem.org>
	<20070628004904.GK9806@ligo.caltech.edu>
	<20070628005957.GA16461@ligo.caltech.edu>
	<20070627211559.e9fc68dd.jlayton@redhat.com>
	<20070628025327.GA18337@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Stuart Anderson <anderson@ligo.caltech.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3kN9-00056o-RO
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:08:43 -0700
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3kNB-0008Ms-4p
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:08:47 -0700
Received: from fe-amer-03.sun.com ([192.18.108.177])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	l5S38hfP011364
	for <nfs@lists.sourceforge.net>; Thu, 28 Jun 2007 03:08:43 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
	id <0JKB00901SDBAW00@mail-amer.sun.com>
	(original mail from Spencer.Shepler@Sun.COM) for
	nfs@lists.sourceforge.net; Wed, 27 Jun 2007 21:08:43 -0600 (MDT)
In-reply-to: <20070628025327.GA18337@ligo.caltech.edu>
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


On Jun 27, 2007, at 9:53 PM, Stuart Anderson wrote:

> On Wed, Jun 27, 2007 at 09:15:59PM -0400, Jeff Layton wrote:
>> On Wed, 27 Jun 2007 17:59:57 -0700
>> Stuart Anderson <anderson@ligo.caltech.edu> wrote:
>>
>>> More precisely, applying this patch to the 2.6.20.14 kernel plus the
>>> revalidate-the-fsid patch did not result in any changes. Does the
>>> O_EXCL patch require some other supporting patches relative to  
>>> 2.6.20.14?
>>>
>>> or perhaps it is necessary to rebase to a newer kernel before  
>>> applying it?
>>> even tough it applies, builds and runs with 2.6.20.14?
>>>
>>> Thanks.
>>>
>>
>> With Linux, both client and server side were broken in this respect.
>> The server didn't set the bitmask in the reply and the client didn't
>> look at it anyway. It's possible that Solaris server is broken in  
>> this
>> regard as well. It would be interesting to see a capture here,
>> particularly one containing the reply from the CREATE.
>
> Possible, but when we switch the client from Linux to Solaris and  
> share
> the same filesytem from the same server there are no O_EXCL problems.
>
> I will see if we can capture the bits. Any recomendations on which  
> tool
> with what options would be most useful to capture the useful traffic?
>
>>
>> Exactly what version of Solaris is the server running?
>
> # cat /etc/release
>                         Solaris 10 11/06 s10x_u3wos_10 X86
>            Copyright 2006 Sun Microsystems, Inc.  All Rights Reserved.
>                         Use is subject to license terms.
>                            Assembled 14 November 2006
> # uname -v
> Generic_118855-36
>
>
> Somewhat related is the reason that we are tring NFSV4 on Linux  
> clients is
> that with NFSV3 ACL's do not work between Linux and Solaris if the  
> filesystem
> on the Solaris server is ZFS, e.g., cp -p will generate interesting  
> error
> messages. While I would rather stay with NFSV4 if possible, has anyone
> gotten this configuration to work with V3?

It will not.  ZFS does not support the "old" ACL definition; only  
NFSv4 support.

Spencer

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
