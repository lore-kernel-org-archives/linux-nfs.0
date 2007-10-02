From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils: rpc.mountd: cache debugging statements
Date: Tue, 02 Oct 2007 10:22:10 -0400
Message-ID: <47025412.5010603@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcidZ-0003UA-DO
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 07:22:13 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Icide-0006ie-7Y
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 07:22:18 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l92EMBLa015294
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Tue, 2 Oct 2007 10:22:11 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l92EMAG8005127
	for <nfs@lists.sourceforge.net>; Tue, 2 Oct 2007 10:22:10 -0400
Received: from [10.12.32.32] (dickson.boston.devel.redhat.com [10.12.32.32])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l92EMAmb025852
	for <nfs@lists.sourceforge.net>; Tue, 2 Oct 2007 10:22:10 -0400
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

The following patch adds some debugging statement to rpc.mound
that show what data is being passed up from the kernel during
mounts. I found these to be very useful but non obtrusive
in my recent travels...

This patch is relative to the Fedora nfs-utils git tree:
git://git.infradead.org/~steved/nfs-utils.fedora

but does apply to Neil's git tree.

steved.


commit 6e7d2cd031bd019c71db2c70851bcc5709105c1d
Author: Steve Dickson <steved@dickson.boston.devel.redhat.com>
Date:   Tue Oct 2 09:03:55 2007 -0400

     Added a couple debugging statements to the caching
     code that shows data be sent up from the kernel.
     These statements were very using in debugging some
     recent issues.

     Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index d068843..3b670ec 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -78,6 +78,8 @@ void auth_unix_ip(FILE *f)
  	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
  		return;

+	xlog(D_CALL, "auth_unix_ip: inbuf '%s'", lbuf);
+
  	cp = lbuf;

  	if (qword_get(&cp, class, 20) <= 0 ||
@@ -102,6 +104,7 @@ void auth_unix_ip(FILE *f)
  	if (client)
  		qword_print(f, *client?client:"DEFAULT");
  	qword_eol(f);
+	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, *client?client: 
"DEFAULT");

  	if (client) free(client);
  	
@@ -273,8 +276,10 @@ void nfsd_fh(FILE *f)
  	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
  		return;

-	cp = lbuf;
+	xlog(D_CALL, "nfsd_fh: inbuf '%s'", lbuf);

+	cp = lbuf;
+	
  	dom = malloc(strlen(cp));
  	if (dom == NULL)
  		return;
@@ -492,6 +497,7 @@ void nfsd_fh(FILE *f)
  	qword_eol(f);
   out:
  	free(dom);
+	xlog(D_CALL, "nfsd_fh: found %p path %s", found, found ? found->e_path 
: NULL);
  	return;		
  }

@@ -563,6 +569,8 @@ void nfsd_export(FILE *f)
  	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
  		return;

+	xlog(D_CALL, "nfsd_export: inbuf '%s'", lbuf);
+
  	cp = lbuf;
  	dom = malloc(strlen(cp));
  	path = malloc(strlen(cp));
@@ -634,6 +642,7 @@ void nfsd_export(FILE *f)
  		dump_to_cache(f, dom, path, NULL);
  	}
   out:
+	xlog(D_CALL, "nfsd_export: found %p path %s", found, path ? path : NULL);
  	if (dom) free(dom);
  	if (path) free(path);
  }

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
