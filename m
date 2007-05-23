From: Greg Banks <gnb@sgi.com>
Subject: [RFC,
	PATCH 0/5] knfsd: simpler call deferral and revisiting for NFS/RDMA
Date: Thu, 24 May 2007 00:32:12 +1000
Message-ID: <20070523143212.GH14076@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hqrsv-0004u9-4J
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:32:20 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/yrjDu3VBjFM+jwyeP75ukQ5Hm2KHN+Ss=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hqrsw-0004FB-U1
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:32:20 -0700
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

G'day,

Proposed tweaks to call deferral and revisit, which allows the generic
code to do almost all the logic, instead of having to duplicate
svc_defer() and svc_revisit() for every transport.

Compiles, untested.  First 2 patches are against 2.6.21 plus
my earlier patches.  Last 2 are against the November nfsrdma
code drop.

[RFC,PATCH 1/5] knfsd: completely centralise deferral handling
[RFC,PATCH 2/5] knfsd: allow preserving of transport header across deferrals
[RFC,PATCH 3/5] knfsd: remove nfsrdma defer and revisit code
[RFC,PATCH 4/5] knfsd: nfsrdma arranges to preserve chunk header across deferrals

Greg
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
