From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 18] knfsd: Introduction - NFSv4 updates and more
Date: Fri, 8 Dec 2006 12:13:18 +1100
Message-ID: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUIX-00036B-8F
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:09 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUIY-000109-BM
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:10 -0800
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

Following are 18 patches against 2.6.19-rc6-mm2 which are suitable for 2.6.20.

First 16 are from the NFSv4 team at umich (thanks Bruce).  Mostly
fixing minor bugs and tidying-up code.

Last 2 from me.  We haven't been testing against old versions of
nfs-utils and bit-rot has set in.  Some of that (hopefully all) has
been fixed.

 [PATCH 001 of 18] knfsd: nfsd4: remove a dprink from nfsd4_lock
 [PATCH 002 of 18] knfsd: svcrpc: fix gss krb5i memory leak
 [PATCH 003 of 18] knfsd: nfsd4: clarify units of COMPOUND_SLACK_SPACE
 [PATCH 004 of 18] knfsd: nfsd: make exp_rootfh handle exp_parent errors
 [PATCH 005 of 18] knfsd: nfsd: simplify exp_pseudoroot
 [PATCH 006 of 18] knfsd: nfsd4: handling more nfsd_cross_mnt errors in nfsd4 readdir
 [PATCH 007 of 18] knfsd: nfsd: don't drop silently on upcall deferral
 [PATCH 008 of 18] knfsd: svcrpc: remove another silent drop from deferral code
 [PATCH 009 of 18] knfsd: nfsd4: pass saved and current fh together into nfsd4 operations.
 [PATCH 010 of 18] knfsd: nfsd4: remove spurious replay_owner check
 [PATCH 011 of 18] knfsd: nfsd4: move replay_owner to cstate
 [PATCH 012 of 18] knfsd: nfsd4: don't inline nfsd4 compound op functions
 [PATCH 013 of 18] knfsd: nfsd4: make verify and nverify wrappers
 [PATCH 014 of 18] knfsd: nfsd4: reorganize compound ops
 [PATCH 015 of 18] knfsd: nfsd4: simplify migration op check
 [PATCH 016 of 18] knfsd: nfsd4: simplify filehandle check
 [PATCH 017 of 18] knfsd: Don't ignore kstrdup failure in rpc caches.
 [PATCH 018 of 18] knfsd: Fix up some bit-rot in exp_export

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
