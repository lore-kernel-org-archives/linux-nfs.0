From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Re: RedHat Rawhide Kernels
Date: Mon, 12 Aug 2002 11:41:36 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020812114136.C6498@ast.cam.ac.uk>
References: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from purple.csi.cam.ac.uk ([131.111.8.4])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eCdn-0008Ow-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 03:41:40 -0700
Received: from cass41.ast.cam.ac.uk ([131.111.69.186])
	by purple.csi.cam.ac.uk with esmtp (Exim 4.10)
	id 17eCdk-00054u-00
	for nfs@lists.sourceforge.net; Mon, 12 Aug 2002 11:41:36 +0100
Received: from xalph6.ast.cam.ac.uk (xalph6 [131.111.68.34])
	by cass41.ast.cam.ac.uk (8.11.6+Sun/8.11.6) with ESMTP id g7CAfa202332
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 11:41:36 +0100 (BST)
Received: from xpc1.ast.cam.ac.uk (IDENT:46/FnTn9Xen4Rtwwywm5hNdlhNgoxU5l@xpc1.ast.cam.ac.uk [131.111.68.219])
	by xalph6.ast.cam.ac.uk (8.10.0/8.10.0) with ESMTP id g7CAfap28375
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 11:41:36 +0100 (BST)
Received: (from jss@localhost)
	by xpc1.ast.cam.ac.uk (8.11.6/8.11.6) id g7CAfaa06564
	for nfs@lists.sourceforge.net; Mon, 12 Aug 2002 11:41:36 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk>; from jss@ast.cam.ac.uk on Thu, Aug 08, 2002 at 08:21:27PM +0100
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Thu, Aug 08, 2002 at 08:21:27PM +0100, Jeremy Sanders wrote:
> Just to let you guys know (as it's close to the current thread), I'm
> getting very bad lock-ups using the current rawhide kernel (2.4.18-7.94).
> When I connet with a machine running 2.4.18-5 (standard 7.3 errata
> kernel), both the client and the server get processes stuck in a "D" state
> - the nfsd processes on the server and the user command on the client.
> This means you can't shut the server down as the nfsd processes can't get
> killed. Strangely 2.4.19 kernels can talk to the server fine!
> 
> See
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=70561

Interestingly this bug seems to be due to ext3 (or a combination of ext3
and nfs). Remounting the partition as ext2 stops the hang.

The processes get stuck (when using ext3) in

nfsd          D F68108E0  5976  1142      1          1141  1143 (L-TLB)
Call Trace: [<c0107f7a>] __down [kernel] 0x6a (0xf6af9de4))
[<c01080d4>] __down_failed [kernel] 0x8 (0xf6af9e08))
[<f8824aa0>] ext3_readdir [ext3] 0x0 (0xf6af9e10))
[<c014fdce>] .text.lock.readdir [kernel] 0x5 (0xf6af9e18))
[<f89997e3>] nfsd_readdir [nfsd] 0xc3 (0xf6af9e38))
[<f89a1070>] nfs3svc_encode_entry_plus [nfsd] 0x0 (0xf6af9e40))
[<f8837ca0>] ext3_dir_operations [ext3] 0x0 (0xf6af9e80))
[<f899ee6e>] nfsd3_proc_readdirplus [nfsd] 0xde (0xf6af9ef0))
[<f89a1070>] nfs3svc_encode_entry_plus [nfsd] 0x0 (0xf6af9f04))
[<f89a61c4>] nfsd_procedures3 [nfsd] 0x264 (0xf6af9f24))
[<f89935c0>] nfsd_dispatch [nfsd] 0xd0 (0xf6af9f30))
[<f89a5898>] nfsd_version3 [nfsd] 0x0 (0xf6af9f44))
[<f89754cc>] svc_process_R6eda96b1 [sunrpc] 0x43c (0xf6af9f50))
[<f89a61c4>] nfsd_procedures3 [nfsd] 0x264 (0xf6af9f78))
[<f89a58b8>] nfsd_program [nfsd] 0x0 (0xf6af9f7c))
[<f89933b0>] nfsd [nfsd] 0x1d0 (0xf6af9f98))
[<c010765e>] kernel_thread [kernel] 0x2e (0xf6af9ff0))
[<f89931e0>] nfsd [nfsd] 0x0 (0xf6af9ff8))

nfsd          D F68108E0  5592  1143      1          1142  1144 (L-TLB)
Call Trace: [<c0107f7a>] __down [kernel] 0x6a (0xf6aefc24))
[<c01080d4>] __down_failed [kernel] 0x8 (0xf6aefc48))
[<f8837e20>] ext3_dir_inode_operations [ext3] 0x0 (0xf6aefc50))
[<f8999fab>] .text.lock.vfs [nfsd] 0xaf (0xf6aefc58))
[<c01af97c>] ide_wait_stat [kernel] 0xcc (0xf6aefc68))
[<f89a1a20>] encode_fattr3 [nfsd] 0x200 (0xf6aefc90))
[<f89a0f6b>] encode_entry [nfsd] 0x1ab (0xf6aefcb4))
[<f8824d02>] ext3_readdir [ext3] 0x262 (0xf6aefd70))
[<c0223760>] udp_getfrag [kernel] 0x0 (0xf6aefdcc))
[<c014f6b2>] vfs_readdir [kernel] 0x92 (0xf6aefe18))
[<f89a1070>] nfs3svc_encode_entry_plus [nfsd] 0x0 (0xf6aefe24))
[<f89997e3>] nfsd_readdir [nfsd] 0xc3 (0xf6aefe38))
[<f89a1070>] nfs3svc_encode_entry_plus [nfsd] 0x0 (0xf6aefe40))
[<f8837ca0>] ext3_dir_operations [ext3] 0x0 (0xf6aefe80))
[<f899ee6e>] nfsd3_proc_readdirplus [nfsd] 0xde (0xf6aefef0))
[<f89a1070>] nfs3svc_encode_entry_plus [nfsd] 0x0 (0xf6aeff04))
[<f89a61c4>] nfsd_procedures3 [nfsd] 0x264 (0xf6aeff24))
[<f89935c0>] nfsd_dispatch [nfsd] 0xd0 (0xf6aeff30))
[<f89a5898>] nfsd_version3 [nfsd] 0x0 (0xf6aeff44))
[<f89754cc>] svc_process_R6eda96b1 [sunrpc] 0x43c (0xf6aeff50))
[<f89a61c4>] nfsd_procedures3 [nfsd] 0x264 (0xf6aeff78))
[<f89a58b8>] nfsd_program [nfsd] 0x0 (0xf6aeff7c))
[<f89933b0>] nfsd [nfsd] 0x1d0 (0xf6aeff98))
[<c010765e>] kernel_thread [kernel] 0x2e (0xf6aefff0))
[<f89931e0>] nfsd [nfsd] 0x0 (0xf6aefff8))


(See the above bug for more details).

Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
