From: "H. J. Lu" <hjl@lucon.org>
Subject: The rpc.mountd program in 1.0.4:
Date: Wed, 16 Jul 2003 18:14:22 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030717011422.GA16081@lucon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc12.comcast.net ([216.148.227.85])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19cxLr-0008Rw-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Jul 2003 18:14:31 -0700
To: nfs@lists.sourceforge.net
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

----- Forwarded message from Chris Rankin <cj.rankin@ntlworld.com> -----

Delivered-To: hjl@localhost.lucon.org
From: Chris Rankin <cj.rankin@ntlworld.com>

Jul 15 22:05:50 wellhouse rpc.mountd: authenticated mount request from (null):759 for /home (/home) 

Notice that (null) where it should give the name of the remote client?
And the server crashed when I issued a umount request, too.

My setup is: gcc-3.2.3, glibc-2.3.2, libwrap.a, Linux 2.4.21.

CFLAGS='-O2 -fomit-frame-pointer'
./configure --prefix=/usr
            --enable-secure-statd
            --enable-nfsv3
            --enable-rquotad
            --with-statduser=nobody

Cheers,
Chris

----- End forwarded message -----


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
