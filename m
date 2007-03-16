From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] [nfs-utils: mountd] exports too verbose.
Date: Fri, 16 Mar 2007 11:36:04 +1100
Message-ID: <17913.58996.50116.344398@notabene.brown>
References: <45F6CB05.6010604@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HS0Qa-0003Uj-6T
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 17:36:16 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HS0Qa-00058T-Mo
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 17:36:18 -0700
In-Reply-To: message from Steve Dickson on Tuesday March 13
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

On Tuesday March 13, SteveD@redhat.com wrote:
> This patch is relative to the git tree at:
> git://git.infradead.org/~steved/nfs-utils.git
> which has been updated to the nfs-utils-1.0.12
> release.
> 
> Please consider...

How about this instead...
nfs-utils imposes an ordering to some extent.  hostnames first, then 
subnets, the wildcards, then netgroups.
If the two names are in different places in that ordering, then there
really is no need to report anything, as in you case.

OK?

NeilBrown

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 6cf24ce..ed7fe35 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -490,6 +490,7 @@ void nfsd_export(FILE *f)
 	int i;
 	char *dom, *path;
 	nfs_export *exp, *found = NULL;
+	int found_type = 0;
 
 
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
@@ -516,9 +517,10 @@ void nfsd_export(FILE *f)
 				continue;
 			if (strcmp(path, exp->m_export.e_path))
 				continue;
-			if (!found)
+			if (!found) {
 				found = exp;
-			else {
+				found_type = i;
+			} else if (found_type == i) {
 				xlog(L_WARNING, "%s exported to both %s and %s in %s",
 				     path, exp->m_client->m_hostname, found->m_client->m_hostname,
 				     dom);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
