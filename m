From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: NFSroot using NFSv4?
Date: Sat, 28 Oct 2006 11:31:42 +0200
Message-ID: <20061028093142.GA16741@janus>
References: <1161861313.454098c141626@stud.fbi.h-da.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GdkXa-0002oY-VR
	for nfs@lists.sourceforge.net; Sat, 28 Oct 2006 02:31:47 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GdkXZ-0007sa-OX
	for nfs@lists.sourceforge.net; Sat, 28 Oct 2006 02:31:48 -0700
To: glogow@fbihome.de
In-Reply-To: <1161861313.454098c141626@stud.fbi.h-da.de>
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

On Thu, Oct 26, 2006 at 01:15:13PM +0200, glogow@fbihome.de wrote:
> Hi
> 
> I'm looking for some information on using Linux kernel NFSroot with NFSv4.
> 
> >From reading some documentation it seems that there are some additional daemons
> involved to mount NFSv4 exports on a client (idmapd, gssd (just for krb5?)).
> 
> Is it possible to run NFSv4 as a read-only NFSroot, without an initrd /
> initramfs, which would otherwise start these deamons and use a NFSv4 enabled
> mount and a pivot_root?

The proper way to do that is actually to put an "/init"  script in
initrd. The kernel won't mount a root filesystem (i.e. no root= parameter)
and leaves it up to the early userspace /init script to setup the root
mount, e.g. /newroot. The last step for /init (being pid 1) is a

	exec chroot /newroot /sbin/init <args>

This can handle much more types of root mounts and avoids the need for
an in-kernel nfsroot.

-- 
Frank

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
