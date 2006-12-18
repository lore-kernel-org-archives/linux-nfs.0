From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/3] don't rely on old info in my_client
Date: Mon, 18 Dec 2006 15:43:16 -0500
Message-ID: <4586FD64.5030205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GwPKb-0006A8-47
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 12:43:29 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GwPKY-00022s-Tm
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 12:43:27 -0800
To: nfs@lists.sourceforge.net
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

Here's a new set of patches to fix up "showmount -a", based on the approach
suggested by Neil. This first patch is fairly simple. It just stops
the current caching of my_client.

For an explanation, consider this situation with the current code:

1) Client mounts an NFS export from server that is restricted to a particular
hostname or netgroup.

2) DNS or netgroup changes so that the client would be denied.

3) Client attempts mount again. Mount succeeds, even though it shouldn't due
to the fact that mountd relies on cached info in my_client.

This situation can occur as long as no other client attempts a mount between
1 and 3 above. The patch below removes this caching, and causes a new
invocation of client_compose for each pass through auth_authenticate:

Signed-off-by: Jeff Layton <jlayton@redhat.com>

--- nfs-utils-1.0.10/utils/mountd/auth.c.nocache
+++ nfs-utils-1.0.10/utils/mountd/auth.c
@@ -76,21 +76,16 @@ auth_authenticate_internal(char *what, s
  	if (new_cache) {
  		int i;
  		/* return static nfs_export with details filled in */
-		if (my_client.m_naddr != 1 ||
-		    my_client.m_addrlist[0].s_addr != caller->sin_addr.s_addr) {
-			/* different client to last time, so do a lookup */
-			char *n;
-			my_client.m_naddr = 0;
-			my_client.m_addrlist[0] = caller->sin_addr;
-			n = client_compose(caller->sin_addr);
-			*error = unknown_host;
-			if (!n)
-				return NULL;
-			strcpy(my_client.m_hostname, *n?n:"DEFAULT");
-			free(n);
-			my_client.m_naddr = 1;
-		}
-
+		char *n;
+		my_client.m_naddr = 0;
+		my_client.m_addrlist[0] = caller->sin_addr;
+		n = client_compose(caller->sin_addr);
+		*error = unknown_host;
+		if (!n)
+			return NULL;
+		strcpy(my_client.m_hostname, *n?n:"DEFAULT");
+		free(n);
+		my_client.m_naddr = 1;
  		my_exp.m_client = &my_client;

  		exp = NULL;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
