From: Andreas Metzler <ametzler@logic.univie.ac.at>
Subject: Re: Cannot umount NFS mounted cdrom
Date: Fri, 18 Oct 2002 15:18:06 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021018131806.GD2364@balrog.logic.univie.ac.at>
References: <200210181441.14640.Nicolas.Turro@sophia.inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from server.logic.univie.ac.at ([131.130.190.41])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 182X1D-0002Y0-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Oct 2002 06:18:23 -0700
Received: from balrog.logic.univie.ac.at ([131.130.190.58] ident=mail)
	by server.logic.univie.ac.at with esmtp (Exim 3.36 #3 )
	id 182X0x-0000uo-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Oct 2002 15:18:07 +0200
Received: from ametzler by balrog.logic.univie.ac.at with local (Exim 3.35 #1 (Debian))
	id 182X0w-0006G5-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Oct 2002 15:18:06 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <200210181441.14640.Nicolas.Turro@sophia.inria.fr>
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

On Fri, Oct 18, 2002 at 02:41:14PM +0200, Nicolas Turro wrote:
> We use linux 2.4.17 and knfsd-0.2.1-1 and we have a problem :
> 1- we mount an ISO cdrom on host A on /mnt/cdrom
> 2- we do a NFS mount of A:/mnt/cdrom /tmp/remotecdrom on host B
> 3- we umount /tmp/remotecdrom on host B
> 4- when we try to umount /mnt/cdrom on host A, he get fs busy and it fails.
> lsof doesn't give any process using /mnt/cdrom
> 
> Is-this a known problem ? Any workaround ?

You have to unexport /mnt/cdrom on A before you can unmount it - use
exportfs -correct -options.
                  cu andreas


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
