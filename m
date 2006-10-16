From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 5] knfsd: Introduction - bugfixes for 2.6.19
Date: Tue, 17 Oct 2006 09:30:04 +1000
Message-ID: <20061017092702.11224.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZbuQ-00016J-S9
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:14 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZbuQ-000146-JJ
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:15 -0700
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

Following 5 patches for nfsd/lockd are bug fixes that are appropriate for 
2.6.19 (matches made against 2.6.18-rc1-mm1).

Thanks,
NeilBrown


 [PATCH 001 of 5] knfsd: nfsd4: fix owner-override on open
 [PATCH 002 of 5] knfsd: nfsd4: fix open permission checking
 [PATCH 003 of 5] knfsd: nfsd4: Fix error handling in nfsd's callback client
 [PATCH 004 of 5] knfsd: Fix bug in recent lockd patches that can cause reclaim to fail.
 [PATCH 005 of 5] knfsd: Allow lockd to drop replys as appropriate.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
