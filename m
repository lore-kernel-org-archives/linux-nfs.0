From: miyoshi@hpc.bs1.fc.nec.co.jp
Subject: Re: getcwd() returns wrong pathname
Date: Tue, 03 Dec 2002 19:49:54 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021203194954S.miyoshi@hpc.bs1.fc.nec.co.jp>
References: <15852.9815.372469.298167@notabene.cse.unsw.edu.au>
	<20021203134704L.miyoshi@hpc.bs1.fc.nec.co.jp>
	<15852.17440.790970.70154@notabene.cse.unsw.edu.au>
	<3DEC8468.64E04028@moving-picture.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, tanaka-h@mxm.nes.nec.co.jp,
   hoshi@bsd.tnes.nec.co.jp, yamasita@hpc.necst.nec.co.jp,
   fuku@hpc.bs1.fc.nec.co.jp, lgml@linuxdb.hpc.bs1.fc.nec.co.jp
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tyo202.gate.nec.co.jp ([202.32.8.202])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18JAah-00046w-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Dec 2002 02:47:47 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <15852.17440.790970.70154@notabene.cse.unsw.edu.au>
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


Hi,

> The root cause is that pwd works but walking up a path of ..,
> ../.. etc finding the name of each component by reading through the
> directory for a name which matches the inode number found by statting
> ".." from below (does that make sense?)

Yes, our UNIX guys also explained me like that.

> However, HP-UX (At least) does this comparison wrongly.  In NFSv3,
> filehandles are variable length, up to 64 bytes.  HP-UX however will
> always compare at least 32 bytes (the size of an NFSv2 filehandle).
> If the filehandle returned by the server is less than 32 bytes (which
> is the case with the Linux nfs server) then some of those 32 bytes
> compared will be random garbage, and the comparison will fail.  So pwd
> never finds the mountpoint as it walks up the chain of "..", and gets
> confused.

And our UNIX team agreed with the story above. Thanks for your explanation.

> Apparently HP were going to release a fix for this, but I don't know
> if they have.
> 
> One work-around is to use NFSv2.  It uses fixed sized (zero-padded)
> filehandles and so doesn't suffer this problem.
> 
> It is possible to hack the Linux nfs server to return a minimum
> filehandle of 32 bytes, but I don't want that hack in the standard
> kernel.

I agree with you that it can be done on client side.
But if we need HP-UX compliance :-< we must patch or hack our kernel.

> IRIX clients used to suffer in a similar way - a couple of
> workarounds/patches for the Linux knfsd server are suggested in the NFS
> HOW-TO at:
> 
> http://nfs.sourceforge.net/nfs-howto/interop.html#IRIX

Hmm, I've never thought that the phenomena are already described in
HOW-TO...

Anyhow, thank you two guys. Your comment makes our situations clear.

Regards,
--
MIYOSHI Kazuto <miyoshi@hpc.bs1.fc.nec.co.jp>
 HPC Operating System Group, 1st Computers Software Division,
 Computers Software Operations Unit, NEC Solutions.


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
