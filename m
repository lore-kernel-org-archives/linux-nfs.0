From: "mrg" <mrg@normailer.com>
Subject: Re: NFS Server problem (kernel > 2.6.5 ?)
Date: Wed, 27 Oct 2004 18:43:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001501c4bc44$051867a0$1203a8c0@utvikling>
References: <001801c4bb3d$5d670bd0$1203a8c0@utvikling> <417E8DFA.5090204@psu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "Jason Holmes" <jholmes@psu.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMqt5-0006HM-2z
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 09:43:03 -0700
Received: from 628936148.32-4.adsl.nsn.no ([62.89.36.148] helo=mail.normailer.com)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CMqt3-0006m6-SG
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 09:43:03 -0700
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Thanks, it worked!

I uninstalled the nfs-utils-1.0.6-22 (from FC2), then installed
nfs-utils-1.0.6 from kernel.org. Et voila!

  - Geir R
----- Original Message -----
From: "Jason Holmes" <jholmes@psu.edu>
To: "mrg" <mrg@normailer.com>
Cc: <nfs@lists.sourceforge.net>
Sent: Tuesday, October 26, 2004 7:48 PM
Subject: Re: [NFS] NFS Server problem (kernel > 2.6.5 ?)


> mrg wrote:
> > Hi,
> >
> > I've had a server running FC2 for a while. I recently upgraded the
kernel to
> > 2.6.8.1, and then the NFS server stopped working.
> > I only get a 'Permission denied' on the client side, but the server
writes a
> > 'rpc.mountd: authenticated mount request from ...' in the message log.
> > I've tried al kinds of kernel options without any luck. I've also tried
> > 2.6.8, 2.6.9-rc4 and 2.6.9, but the only kernel that works is the
> > 2.6.5-1.358 which comes with FC2. However, the client can run both FC2
stock
> > kernel and 2.6.9 and still connect to the server (when run with kernel
> > 2.6.5-1.358).
> >
> > Some config info:
> > /etc/exports:
> >     /rootfs 192.168.1.0/24(rw,sync,no_root_squash)
> >
> > /etc/hosts.deny is empty, /etc/hosts.allow: ALL:ALL
> >
> >
> > Does anybody know what the problem is ?
>
> I had a similar problem when replacing the RedHat kernel on Enterprise 3
> Update 3.  The problem was that the RedHat nfs-utils package didn't work
> properly with the vanilla kernels (even though it's version 1.0.6, it's
> a very much patched version of 1.0.6).  After replacing the nfs-utils
> package with a vanilla 1.0.6, things worked fine.
>
> Thanks,
>
> --
> Jason Holmes
>
>



-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
