From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 11] knfsd: Introduction
Date: Thu, 24 Aug 2006 16:36:29 +1000
Message-ID: <20060824162917.3600.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GG8pM-0002yV-CV
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:36:32 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GG8pL-0007VW-Mb
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:36:33 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Following are 11 patch for knfsd against
 2.6.18-rc4-mm2 plus  nfsd-lockdep-annotation.patch
 (the first patch being a fix for that patch).

They are all appropriate for 2.6.19, not 2.6.18.

The batch in the middle (6-9) allow nfsd to handle IO requests
of up to 1Megabyte (rather than the current limit of 32K).
This only applies on TCP connections.  This has not 
been heavily tested...
The max size to allow is configurable via the nfsd filesystem,
and defaults to something that I hope is reasonable.

This set also includes a few more scalability patches from Greg Banks.

NeilBrown


 [PATCH 001 of 11] knfsd: nfsd: lockdep annotation fix
 [PATCH 002 of 11] knfsd: Fix a botched comment from the last patchset
 [PATCH 003 of 11] knfsd: call lockd_down when closing a socket via a write to nfsd/portlist
 [PATCH 004 of 11] knfsd: Protect update to sn_nrthreads with lock_kernel
 [PATCH 005 of 11] knfsd: Fixed handling of lockd fail when adding nfsd socket.
 [PATCH 006 of 11] knfsd: Replace two page lists in struct svc_rqst with one.
 [PATCH 007 of 11] knfsd: Avoid excess stack usage in svc_tcp_recvfrom
 [PATCH 008 of 11] knfsd: Prepare knfsd for support of rsize/wsize of up to 1MB, over TCP.
 [PATCH 009 of 11] knfsd: Allow max size of NFSd payload to be configured.
 [PATCH 010 of 11] knfsd: make nfsd readahead params cache SMP-friendly
 [PATCH 011 of 11] knfsd: knfsd: cache ipmap per TCP socket

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
