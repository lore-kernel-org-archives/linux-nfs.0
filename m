From: Chip Salzenberg <chip@pobox.com>
Subject: [aj@andaco.de: Bug#297729: nfs-utils: FTBFS (amd64/gcc-4.0): invalid lvalue in assignment]
Date: Wed, 2 Mar 2005 11:49:32 -0500
Message-ID: <20050302164932.GB7858@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6X2X-0002oC-Fd
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 08:49:37 -0800
Received: from perlsupport.com ([66.180.163.120] helo=mail.perlsupport.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D6X2X-00015T-0Y
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 08:49:37 -0800
Received: from [67.132.206.254] (helo=tytlal)
	by mail.perlsupport.com (Exim 4) with esmtpsa (TLS-1.0:RSA_AES_256_CBC_SHA:32)
	id 1D6X2V-0000k3-4u
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 11:49:35 -0500
Received: from chip by tytlal with local (Exim 4.50)
	id 1D6X2S-0003d1-RK
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 11:49:32 -0500
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

A Debian user has contributed the below patch, which fixes a compile
error in the Debian amd64 environment.  ("FTBFS" = Fails To Build From
Source)  Any comments on it?

----- Forwarded message from Andreas Jochens <aj@andaco.de> -----

Subject: Bug#297729: nfs-utils: FTBFS (amd64/gcc-4.0): invalid lvalue in
 assignment
From: Andreas Jochens <aj@andaco.de>
To: Debian Bug Tracking System <submit@bugs.debian.org>
Date: Wed, 02 Mar 2005 17:20:52 +0100

Package: nfs-utils
Severity: normal
Tags: patch

When building 'nfs-utils' on amd64 with gcc-4.0,
I get the following error:

gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -I/usr/include -Wall  -pipe  -DVERSION="\"nfs-utils 1.0.7\"" -DNFS3_SUPPORTED -I../../support/rpc/include -DDEBUG   -c -o svc_auth_gss.o svc_auth_gss.c
svc_auth_gss.c: In function 'svcauth_gss_import_name':
svc_auth_gss.c:124: warning: passing argument 3 of 'gss_import_name' discards qualifiers from pointer target type
svc_auth_gss.c: In function '_svcauth_gss':
svc_auth_gss.c:385: error: invalid lvalue in assignment
make[3]: *** [svc_auth_gss.o] Error 1

With the attached patch 'nfs-utils' can be compiled
on amd64 using gcc-4.0.

Regards
Andreas Jochens

diff -urN ../tmp-orig/nfs-utils-1.0.7/support/rpc/svc_auth_gss.c ./support/rpc/svc_auth_gss.c
--- ../tmp-orig/nfs-utils-1.0.7/support/rpc/svc_auth_gss.c	2004-10-19 02:23:05.000000000 +0200
+++ ./support/rpc/svc_auth_gss.c	2005-03-02 17:08:51.007556121 +0100
@@ -382,7 +382,7 @@
 			return (AUTH_FAILED);
 		}
 		auth->svc_ah_ops = &svc_auth_gss_ops;
-		SVCAUTH_PRIVATE(auth) = gd;
+		auth->svc_ah_private = gd;
 		rqst->rq_xprt->xp_auth = auth;
 	}
 	else gd = SVCAUTH_PRIVATE(rqst->rq_xprt->xp_auth);



----- End forwarded message -----

-- 
Chip Salzenberg            - a.k.a. -            <chip@pobox.com>
 "What I cannot create, I do not understand." - Richard Feynman


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
