From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] kNFSd - 6 of 6 - Make sure nfsd replies from the
	address the request was sent to.
Date: Sun, 07 Sep 2003 23:49:51 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1062971391.3946.14.camel@E136.suse.de>
References: <E19unZ5-0004Vg-00@notabene>
	 <1062970326.3947.8.camel@E136.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19w7Nh-0008Px-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Sep 2003 14:47:37 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19w7Nf-0002n1-47
	for nfs@lists.sourceforge.net; Sun, 07 Sep 2003 14:47:35 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <1062970326.3947.8.camel@E136.suse.de>
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

On Sun, 2003-09-07 at 23:32, Andreas Gruenbacher wrote:
> Hello,
> 
> the patch contains an alignment induced bug on 64-bit platforms:
> sizeof(cm) becomes 32 bytes, instead of 16 + 12 = 28. This causes
> ip_cmsg_send to fail. See the attached fix.

In addition, with the patch applied, I am seeing the following failure
on ia64:

Sep  7 23:24:41 my kernel: Installing knfsd (copyright (C) 1996 okir@monad.swb
Sep  7 23:24:45 my rpc.mountd: authenticated mount request from
localhost:891
Sep  7 23:24:45 my kernel: RPC request reserved -105422848 but used 20
Sep  7 23:24:45 my last message repeated 2 times
Sep  7 23:24:45 my kernel: nfs_get_root: getattr error = 13


If only this patch is removed, the problem disappears.


Cheers,
-- 
Andreas Gruenbacher <agruen@suse.de>
SuSE Labs, SuSE Linux AG <http://www.suse.de/>



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
