From: "Chris Croswhite" <csc@cadence.com>
Subject: RE: Issues with nfs solaris server
Date: Thu, 19 Jun 2003 16:47:34 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <EE335453C5C57840823404C684F9F617012D684B@exmbx01sj.Cadence.COM>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailgate2.cadence.com ([158.140.2.31])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T97x-0000m6-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 16:47:37 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

By die, I mean any action on that mount point hangs (ls, cd , etc.)?  I =
can "ctl c" out which returns me to the console.  I can not unmount the =
mount point, the error returned is that the mount point is busy.

mount options:
rsize=3D8192,wsize=3D8192,nfsvers=3D2,proto=3Dudp,bg,intr

I have also tried adding hard to the list.

These hung mount points are seemed to affect dual cpu machines.

Any other information?

TIA!


-----Original Message-----
From:	Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
Sent:	Thu 6/19/2003 10:15 AM
To:	Chris Croswhite
Cc:	nfs@lists.sourceforge.net
Subject:	Re: [NFS] Issues with nfs solaris server
>>>>> " " =3D=3D Chris Croswhite <csc@cadence.com> writes:

     > Guys, We are seeing issues with solaris nfs servers.  Every
     > once in a while, mount points die and are not recoverable
     > (except to reboot).  nfsutils 1.0.3 kernel 2.4.19.  I had heard
     > someone mention that it might be a spinlock within the kernel.

Could you elaborte on what you mean by 'die'? Also, what type of mount
options are you using (is it TCP or UDP)?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
