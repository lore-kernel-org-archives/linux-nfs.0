From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Re: Permission denied
Date: Wed, 7 May 2003 17:34:30 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.55.0305071732360.2587@xpc5.ast.cam.ac.uk>
References: <Pine.LNX.4.55.0305071639490.2587@xpc5.ast.cam.ac.uk>
 <shsu1c6zpji.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gold.csi.cam.ac.uk ([131.111.8.12])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DRsl-0000OX-00
	for <nfs@lists.sourceforge.net>; Wed, 07 May 2003 09:35:03 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsu1c6zpji.fsf@charged.uio.no>
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

On Wed, 7 May 2003, Trond Myklebust wrote:

> Can it be duplicated on newer kernels?

I'm not sure. I couldn't reproduce the problem when rebooting machines by
hand, and I don't think I can do much testing with the production
machines as I can't easily upgrade the kernel. I'll invesitgate this.

> Which automounter BTW?

autofs-3.1.7

Thanks, Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
