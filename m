From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 8] knfsd: Assorted nfsv4 server patches.
Date: Thu, 21 Jun 2007 14:30:17 +1000
Message-ID: <20070621142604.727.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Alexander Soule <soule@umich.edu>, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Marc Eshel <eshel@almaden.ibm.com>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, Benny Halevy <bhalevy@panasas.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1EJb-0005li-Um
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:30:42 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I1EJf-00027h-1X
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:30:43 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Following 8 patches fix minor bug and provide minor enhancements for
nfsv4 service.  They all have "no obvious style problems" and are
"ready for submission".

They are appropriate for inclusion in 2.6.23-rc1.
They are against 2.6.22-rc4-mm2.

Thanks,
NeilBrown


 [PATCH 001 of 8] knfsd: lockd: nfsd4: use same grace period for lockd and nfsd4
 [PATCH 002 of 8] knfsd: nfsd4: fix NFSv4 filehandle size units confusion
 [PATCH 003 of 8] knfsd: nfsd4: silence a compiler warning in ACL code
 [PATCH 004 of 8] knfsd: nfsd4: fix enc_stateid_sz for nfsd callbacks
 [PATCH 005 of 8] knfsd: nfsd4: fix handling of acl errrors
 [PATCH 006 of 8] knfsd: nfsd: remove unused header interface.h
 [PATCH 007 of 8] knfsd: nfsd4: vary maximum delegation limit based on RAM size
 [PATCH 008 of 8] knfsd: nfsd4: don't delegate files that have had conflicts

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
