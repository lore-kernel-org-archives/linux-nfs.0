From: James Pearson <james-p@moving-picture.com>
Subject: Re: [PATCH] kNFSd - 1 of 9 - TCP nfsd connection hangs when
 partial record header is received
Date: Fri, 23 May 2003 10:33:48 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3ECDEAFC.A7AEBB7E@moving-picture.com>
References: <E19IK1R-00061X-00@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hirokazu Takahashi <taka@valinux.co.jp>,
 	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19J8wo-0001b4-00
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 02:34:46 -0700
To: NeilBrown <neilb@cse.unsw.edu.au>
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

Are any of these NFS over TCP patches out of this patch set also
applicable to the 2.4.2X kernels?

All but one of the 5 NFS over TCP patches out of the set apply OK to the
2.4.20 source, but I have no idea if using these bug fixes with 2.4.20
makes sense or not ...

Thanks

James Pearson

NeilBrown wrote:
> 
> Of these 9 patches against 2.5, some are bug fixes related to NFS over
> TCP, and other are resend so stuff that was dropped a week or more ago.
> 
> Thanks,
> NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
