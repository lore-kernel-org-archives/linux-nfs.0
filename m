From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 2 of 8 - Minor fix to error return when updating server authentication information
Date: Thu, 25 Mar 2004 12:06:52 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1B6JKe-0007DM-00@notabene>
References: <20040325120312.27644.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6JKt-0006bl-It
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:07 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1B6JKt-0007sn-7i
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:07 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 25 Mar 2004 12:06:58 +1100
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


 ----------- Diffstat output ------------
 ./net/sunrpc/auth_gss/svcauth_gss.c |    2 ++
 1 files changed, 2 insertions(+)

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2004-03-25 11:43:12.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2004-03-25 11:43:18.000000000 +1100
@@ -389,11 +389,13 @@ static int rsc_parse(struct cache_detail
 		/* number of additional gid's */
 		if (get_int(&mesg, &N))
 			goto out;
+		status = -ENOMEM;
 		rsci.cred.cr_group_info = groups_alloc(N);
 		if (rsci.cred.cr_group_info == NULL)
 			goto out;
 
 		/* gid's */
+		status = -EINVAL;
 		for (i=0; i<N; i++) {
 			gid_t gid;
 			if (get_int(&mesg, &gid))


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
