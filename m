From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: The rpc.mountd program in 1.0.4:
Date: Mon, 21 Jul 2003 09:34:08 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16155.9968.116304.395927@gargle.gargle.HOWL>
References: <20030717011422.GA16081@lucon.org>
	<16151.15381.883603.343762@gargle.gargle.HOWL>
	<200307181951.55605.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp3.unsw.edu.au ([149.171.96.70])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19eNhX-0001X0-00
	for <nfs@lists.sourceforge.net>; Sun, 20 Jul 2003 16:34:47 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <bernd-schubert@web.de>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Mon, 21 Jul 2003 09:34:41 +1000
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: message from Bernd Schubert on Friday July 18
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

On Friday July 18, bernd-schubert@web.de wrote:
> >
> > There is a 1.0.5 on sourceforge now that fixes this and a few other
> > little things.  It will be on kernel.org shortly.
> 
> Hello !
> 
> The debian-package-building files still think its version 1.0.3, well, not a 
> big deal, but on the other hand its also not a big deal to update the 
> debian/changelog-file and add an entry for 1.0.5 ;-)
> 
> Regards,
> 	Bernd

I like to leave changes to debian/* to Chip as much as possible.
Sometimes I give him the opportunity to update them before I make a
new release, but in that case of 1.0.5 I wanted to do it more quickly.

When I make 1.1.0, I will definately give him the opportunity to get
debian/* fully up-to-date before releasing it.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
