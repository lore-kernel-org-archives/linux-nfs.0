From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: The rpc.mountd program in 1.0.4:
Date: Fri, 18 Jul 2003 10:15:17 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16151.15381.883603.343762@gargle.gargle.HOWL>
References: <20030717011422.GA16081@lucon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp3.unsw.edu.au ([149.171.96.70])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19dIuF-00044m-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Jul 2003 17:15:27 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <hjl@lucon.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 18 Jul 2003 10:15:18 +1000
To: "H. J. Lu" <hjl@lucon.org>
In-Reply-To: message from H. J. Lu on Wednesday July 16
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

On Wednesday July 16, hjl@lucon.org wrote:
> ----- Forwarded message from Chris Rankin <cj.rankin@ntlworld.com> -----
> 
> Delivered-To: hjl@localhost.lucon.org
> From: Chris Rankin <cj.rankin@ntlworld.com>
> 
> Jul 15 22:05:50 wellhouse rpc.mountd: authenticated mount request from (null):759 for /home (/home) 
> 
> Notice that (null) where it should give the name of the remote client?
> And the server crashed when I issued a umount request, too.
> 
> My setup is: gcc-3.2.3, glibc-2.3.2, libwrap.a, Linux 2.4.21.
> 
> CFLAGS='-O2 -fomit-frame-pointer'
> ./configure --prefix=/usr
>             --enable-secure-statd
>             --enable-nfsv3
>             --enable-rquotad
>             --with-statduser=nobody

Yeh... makes 1.0.4 a bit of a brown-paper-bag release doesn't it :-(

There is a 1.0.5 on sourceforge now that fixes this and a few other
little things.  It will be on kernel.org shortly.

NeilBrown

> 
> Cheers,
> Chris
> 
> ----- End forwarded message -----
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: VM Ware
> With VMware you can run multiple operating systems on a single machine.
> WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
> same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
