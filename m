From: "Ogden, Aaron A." <aogden@unocal.com>
Subject: RE: ~800 mountpoint limitation
Date: Tue, 14 Oct 2003 12:03:40 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6AB920CC10586340BE1674976E0A991D0C6B82@slexch2.sugarland.unocal.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9Sar-0005gx-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 10:04:21 -0700
Received: from unogate.unocal.com ([192.94.3.1])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9Sao-00048A-1N
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 10:04:18 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>, <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Even so, mounting from 800 separate fileservers would provide much more
than we have now.  I wonder if there is any real-world site that could
even approach 800 NFS servers?  (and if so, why???)  With the RPC
limitations of today I can shatter the limit very easily, all I have to
do is mount all of my home directories, there are more than 800.

Re: scalability and performance, I think I'll let Trond and Neil comment
on that, but Trond's patch for 2.5.73 sounds like a big improvement over
the current situation.

I've also noticed that I get RPC errors when I try to mount too many
things at once, for example if I mount 200+ autofs-managed NFS
mountpoints via script by cd'ing into them.  If I insert a short pause
(1/2 second to 1 second) between each mount attempt everything is fine.
Sounds like some kind of race condition to me...

-A

-----Original Message-----
From: Lever, Charles [mailto:Charles.Lever@netapp.com]=20
Sent: Tuesday, October 14, 2003 11:45 AM
To: Ogden, Aaron A.
Cc: nfs@lists.sourceforge.net
Subject: RE: [NFS] ~800 mountpoint limitation


trond has heard my complaints about this before....

sharing an RPC transport socket across mounts is an
interesting solution in some ways, but i'm concerned
about the performance scalability of this solution,
especially since the RPC slot table size is fixed at
a relatively small 16 entries.  imagine sharing 16
RPC slots across all the mounts on a very busy
multi-user system.  if one mount backs up (say
because one of the server's disks gets busy), that
makes all the mounts sharing that slot table unusable.

this solution also won't allow you to mount more than
800 different servers, for similar reasons to today's
800 mounts per client limitation.  you can still only
have about 800 transport sockets.

so there are some issues to be worked out.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
