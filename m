From: Voluspa <lista2@comhem.se>
Subject: 2.6.0-test3-bk10-final regression getting out of hand
Date: Fri, 31 Oct 2003 21:48:51 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031031214851.0d6e604b.lista2@comhem.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AFgAQ-0007fL-00
	for <nfs@lists.sourceforge.net>; Fri, 31 Oct 2003 12:46:46 -0800
Received: from h234n2fls24o1061.bredband.comhem.se ([217.208.132.234] helo=oden.fish.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AFgAP-0002v5-BG
	for nfs@lists.sourceforge.net; Fri, 31 Oct 2003 12:46:45 -0800
Received: from loke.fish.net (IDENT:1000@loke.fish.net [192.168.111.2])
	by oden.fish.net (8.10.2/8.10.2) with SMTP id h9VL8Wp05395
	for <nfs@lists.sourceforge.net>; Fri, 31 Oct 2003 21:08:33 GMT
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

As reported in:
http://marc.theaimsgroup.com/?l=linux-kernel&m=106195494828814&w=2
I'm experiencing a serious NFS regression since 2.6.0-test3-bk10-final
(bk-set determined now). Since that, along the road to 2.6.0-test9,
something has gotten completely out of hand.

cp -a /mnt/oden/etc .

_2.6.0-test3-bk10_
2 minutes

_2.6.0-test3-bk10-final_
3 minutes 47 seconds

_2.6.0-test9_
29 minutes 54 seconds

Nothing has changed in hardware or setup, and the cp tests were done
today. Not being a programmer I tried to delete individual patches in
the bk-set, but couldn't find the exact breakage point.

Erasing changes to:
linux-2.6.0-test3-bk10/fs/nfs/dir.c
No change.

Erasing changes to:
linux-2.6.0-test3-bk10/fs/nfs/nfsroot.c
No change.

Erasing changes to:
linux-2.6.0-test3-bk10/include/linux/sunrpc/timer.h
linux-2.6.0-test3-bk10/net/sunrpc/timer.c
No change.

Erasing changes to:
linux-2.6.0-test3-bk10/net/sunrpc/clnt.c
Doesn't compile.

Erasing changes to:
linux-2.6.0-test3-bk10/include/linux/sunrpc/xprt.h
linux-2.6.0-test3-bk10/net/sunrpc/xprt.c
Doesn't compile.

Using TCP or DIRECTIO in -test9 makes no difference. Here's the
relevant .config-section:

#
# Network File Systems
#
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V4 is not set
# CONFIG_NFS_DIRECTIO is not set
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V4 is not set
# CONFIG_NFSD_TCP is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=y
CONFIG_SUNRPC=y
# CONFIG_SUNRPC_GSS is not set
# CONFIG_SMB_FS is not set
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_INTERMEZZO_FS is not set
# CONFIG_AFS_FS is not set

Mvh
Mats Johannesson


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
