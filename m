From: Jason Holmes <jholmes@psu.edu>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Fri, 14 Nov 2003 13:37:24 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB520E4.133AF7DB@psu.edu>
References: <3FB27670.4C878A84@psu.edu>
		<shssmkttk34.fsf@charged.uio.no>
		<3FB29D43.A618973D@psu.edu>
		<16306.41898.291062.36209@charged.uio.no>
		<3FB2A738.3F2C90B8@psu.edu>
		<16306.49310.195265.145519@charged.uio.no>
		<3FB2DC60.FA7D3E08@psu.edu>
		<16306.59249.857512.354675@charged.uio.no>
		<3FB3924B.7450E9F7@psu.edu>
		<3FB3FDE8.47E819FF@psu.edu> <16308.8254.89284.377113@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKip4-0000Ta-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Nov 2003 10:37:34 -0800
Received: from vpn-19-8.aset.psu.edu ([146.186.19.8] helo=funkmachine.cac.psu.edu)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AKip3-0002xm-V9
	for nfs@lists.sourceforge.net; Fri, 14 Nov 2003 10:37:34 -0800
To: trond.myklebust@fys.uio.no
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

Trond Myklebust wrote:
> 
> IOW this all appears to be doing synchronous I/O only (both in the
> case of 2.4.22 and 2.6.0).
> Note: most of these RPC calls do indeed appear to be something other
> than WRITE calls. Are they perhaps GETATTR calls? Have you for
> instance set 'noac', 'actimeo' or something like that?

This was my mistake - I had changed the export to sync for a test right
before the debug runs and forgot to change it back.

> Could you please try using
> 
> echo "9" >/proc/sys/sunrpc/nfs_debug

Files should be up there (http://magicbus.cac.psu.edu/nfs).  I do have
to admit that something odd is going on - 2.4.22 still is faster than
2.6.0-test9-bk17 and test9-bk17 is still showing the large amount of
commits, but both of them are running faster than they did before on the
sync mounts and I'm not sure what I might have changed to cause this.

Thanks,

--
Jason Holmes


-------------------------------------------------------
This SF. Net email is sponsored by: GoToMyPC
GoToMyPC is the fast, easy and secure way to access your computer from
any Web browser or wireless device. Click here to Try it Free!
https://www.gotomypc.com/tr/OSDN/AW/Q4_2003/t/g22lp?Target=mm/g22lp.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
