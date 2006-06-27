From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 14] knfsd: Introduction
Date: Tue, 27 Jun 2006 17:19:34 +1000
Message-ID: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7rP-0006EV-H9
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:19:47 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7rO-00076s-Df
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:19:47 -0700
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


Following are 14 assorted patches for nfsd.
Patches are against 2.6.17-mm2 and are suitable for inclusion in 2.6.18.

Primarily minor bug fixes.

Last three patches are initial support for RPC privacy (i.e. decrypt
the RPC request and encrypt the reply).  This code is sub-optimal in
several ways (memcopys ...) which will probably get tidied up once we
determine the best way to do so.

Thanks,
NeilBrown

 [PATCH 001 of 14] knfsd: Improve the test for cross-device-rename in nfsd
 [PATCH 002 of 14] knfsd: Fixing missing 'expkey' support for fsid type 3
 [PATCH 003 of 14] knfsd: Remove noise about filehandle being uptodate.
 [PATCH 004 of 14] knfsd: Ignore ref_fh when crossing a mountpoint.
 [PATCH 005 of 14] knfsd: nfsd4: fix open_confirm locking
 [PATCH 006 of 14] knfsd: nfsd: call nfsd_setuser() on fh_compose(), fix nfsd4 permissions problem
 [PATCH 007 of 14] knfsd: nfsd4: remove superfluous grace period checks
 [PATCH 008 of 14] knfsd: nfsd: fix misplaced fh_unlock() in nfsd_link()
 [PATCH 009 of 14] knfsd: svcrpc: gss: simplify rsc_parse()
 [PATCH 010 of 14] knfsd: nfsd4: fix some open argument tests
 [PATCH 011 of 14] knfsd: nfsd4: fix open flag passing
 [PATCH 012 of 14] knfsd: svcrpc: Simplify nfsd rpcsec_gss integrity code
 [PATCH 013 of 14] knfsd: nfsd: mark rqstp to prevent use of sendfile in privacy case
 [PATCH 014 of 14] knfsd: svcrpc: gss: server-side implementation of rpcsec_gss privacy.

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
