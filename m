From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 1 of 8 - Return -EOPNOTSUPP when unknown mechanism name encountered
Date: Thu, 25 Mar 2004 12:06:51 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1B6JKd-0007DF-00@notabene>
References: <20040325120312.27644.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6JKu-0006bt-8a
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:08 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1B6JKt-0007tL-SH
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:08 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 25 Mar 2004 12:06:57 +1100
To: Andrew Morton <akpm@osdl.org>
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


It's better than oopsing.

 ----------- Diffstat output ------------
 ./net/sunrpc/auth_gss/svcauth_gss.c |    4 ++++
 1 files changed, 4 insertions(+)

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2004-03-25 11:43:12.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2004-03-25 11:43:12.000000000 +1100
@@ -406,7 +406,11 @@ static int rsc_parse(struct cache_detail
 		if (len < 0)
 			goto out;
 		gm = gss_mech_get_by_name(buf);
+		status = -EOPNOTSUPP;
+		if (!gm)
+			goto out;
 
+		status = -EINVAL;
 		/* mech-specific data: */
 		len = qword_get(&mesg, buf, mlen);
 		if (len < 0) {


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
