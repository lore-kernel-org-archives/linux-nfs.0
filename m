From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfs newbie, where to find portmapper?
Date: Sat, 23 Aug 2003 17:31:22 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16199.6218.848334.275159@gargle.gargle.HOWL>
References: <200308210452.06388.gostelow@global.co.za>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19qSsK-0008Bv-00
	for <nfs@lists.sourceforge.net>; Sat, 23 Aug 2003 00:31:52 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <gostelow@global.co.za>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Sat, 23 Aug 2003 17:31:33 +1000
To: gostelow@global.co.za
In-Reply-To: message from Peter Gostelow on Thursday August 21
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

On Thursday August 21, gostelow@global.co.za wrote:
> Slightly off-topic, but I'm a bit stuck.
> 
> After building a custom GNU/Linux system, I am attemping to install a LAN 
> using three computers where one is a bridge/router between two ethernet 
> links. Hopefully, nfs will export the main (/usr/share, /home) directories on 
> one host to all the others.
> 
> My problem is I cannot find a recent portmap source tarball, the debian one 
> (file dates range from 1992 - 1996!) is incompatible with glibc headers. The 
> Slackware has a binary only or a similarly old source. Perhaps I'm missing 
> something, but the Sun Microsystem website doesn't list any rpc stuff, 
> either. The alternative rpcbind (as found by web searches) apparently doesn't 
> support the Intel platform.
> 
> So, what portmapper are the nfs developers using and is there a source tarball 
> available for it?

I use the one that comes with debian.  It works fine.

Debian distribute a patch along with the tar-ball, and the patch
presumable makes it compile with debian's libraries.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
