From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 2] knfsd: Close oopsable race in nfsd
Date: Tue, 17 Apr 2007 12:01:35 +1000
Message-ID: <20070417115242.28047.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: stable@kernel.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Greg Banks <gnb@melbourne.sgi.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hdd10-0006n7-NY
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 19:01:54 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hdd11-00026J-UU
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 19:01:57 -0700
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

Following two patches fix a bug introduced in 
   7b2b1fee30df7e2165525cd03f7d1d01a3a56794
and hence is in 2.6.19 and later.
The first patch is a minimal fix which is suitable for all kernels 
since 2.6.19-pre1.  The second adds some consequent cleaning up
and is probably best left for 2.6.22-rc (and so it not being cc:ed 
to stable@kernel.org).

Thanks,
NeilBrown


 [PATCH 001 of 2] knfsd: Use a spinlock to protect sk_info_authunix
 [PATCH 002 of 2] knfsd: Rename sk_defer_lock to sk_lock

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
