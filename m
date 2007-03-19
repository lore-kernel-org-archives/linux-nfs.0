From: Karel Zak <kzak@redhat.com>
Subject: [PATCH] Add support for quoted mount options
Date: Mon, 19 Mar 2007 21:02:40 +0100
Message-ID: <20070319200240.GI18681@petra.dvoda.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTO48-0001yh-1Y
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 13:02:48 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTO48-00068P-2S
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 13:02:48 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l2JK2f8X030446
	for <nfs@lists.sourceforge.net>; Mon, 19 Mar 2007 16:02:41 -0400
Received: from devserv.devel.redhat.com (devserv.devel.redhat.com
	[172.16.58.1])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l2JK2fq6003589
	for <nfs@lists.sourceforge.net>; Mon, 19 Mar 2007 16:02:41 -0400
Received: from petra (vpn-4-50.str.redhat.com [10.32.4.50])
	by devserv.devel.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	l2JK2erB021791
	for <nfs@lists.sourceforge.net>; Mon, 19 Mar 2007 15:02:41 -0500
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

The patch avoid the collision between commas in security contexts and the
delimiter between mount options.

Try:
	mount.nfs foo://mnt/bar /mnt/bar -o context=\"aaa,bbb,ccc\",ro

Signed-off-by: Cory Olmo <colmo@TrustedCS.com>
Signed-off-by: Karel Zak <kzak@redhat.com>
---
 utils/mount/mount.c    |   24 ++++++++++++++++++------
 utils/mount/nfsmount.c |   44 +++++++++++++++++++++++++++++++++++---------
 2 files changed, 53 insertions(+), 15 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 55d60aa..592bc7d 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -256,18 +256,30 @@ static void parse_opts (const char *options, int *flags, char **extra_opts)
 {
 	if (options != NULL) {
 		char *opts = xstrdup(options);
-		char *opt;
-		int len = strlen(opts) + 20;
+		char *opt, *p;
+		int len = strlen(opts);
+		int open_quote = 0;
 
 		*extra_opts = xmalloc(len);
 		**extra_opts = '\0';
 
-		for (opt = strtok(opts, ","); opt; opt = strtok(NULL, ","))
-			parse_opt(opt, flags, *extra_opts, len);
-
+		for (p=opts, opt=NULL; p && *p; p++) {
+			if (!opt)
+				opt = p;		/* begin of the option item */
+			if (*p == '"')
+				open_quote ^= 1;	/* reverse the status */
+			if (open_quote)
+				continue;		/* still in a quoted block */
+			if (*p == ',')
+				*p = '\0';		/* terminate the option item */
+			/* end of option item or last item */
+			if (*p == '\0' || *(p+1) == '\0') {
+				parse_opt(opt, flags, *extra_opts, len);
+				opt = NULL;
+			}
+		}
 		free(opts);
 	}
-
 }
 
 static void mount_error(char *node)
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index eac9590..4049e66 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -548,15 +548,31 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 	struct pmap *mnt_pmap = &mnt_server->pmap;
 	struct pmap *nfs_pmap = &nfs_server->pmap;
 	int len;
-	char *opt, *opteq;
+	char *opt, *opteq, *p, *opt_b;
 	char *mounthost = NULL;
 	char cbuf[128];
+	int open_quote = 0;
 
 	data->flags = 0;
 	*bg = 0;
 
 	len = strlen(new_opts);
-	for (opt = strtok(old_opts, ","); opt; opt = strtok(NULL, ",")) {
+	for (p=old_opts, opt_b=NULL; p && *p; p++) {
+		if (!opt_b)
+			opt_b = p;		/* begin of the option item */
+		if (*p == '"')
+			open_quote ^= 1;	/* reverse the status */
+		if (open_quote)
+			continue;		/* still in a quoted block */
+		if (*p == ',')
+			*p = '\0';		/* terminate the option item */
+		if (*p == '\0' || *(p+1) == '\0') {
+			opt = opt_b;		/* opt is useful now */
+			opt_b = NULL;
+		}
+		else
+			continue;		/* still somewhere in the option item */
+
 		if (strlen(opt) >= sizeof(cbuf))
 			goto bad_parameter;
 		if ((opteq = strchr(opt, '=')) && isdigit(opteq[1])) {
@@ -680,14 +696,24 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 			        mounthost=xstrndup(opteq+1,
 						   strcspn(opteq+1," \t\n\r,"));
 			 else if (!strcmp(opt, "context")) {
- 				char *context = opteq + 1;
- 				
- 				if (strlen(context) > NFS_MAX_CONTEXT_LEN) {
- 					printf(_("context parameter exceeds limit of %d\n"),
- 						 NFS_MAX_CONTEXT_LEN);
+				char *context = opteq + 1;
+				int ctxlen = strlen(context);
+
+				if (ctxlen > NFS_MAX_CONTEXT_LEN) {
+					printf(_("context parameter exceeds limit of %d\n"),
+						 NFS_MAX_CONTEXT_LEN);
 					goto bad_parameter;
- 				}
- 				strncpy(data->context, context, NFS_MAX_CONTEXT_LEN);
+				}
+				/* The context string is in the format of
+				 * "system_u:object_r:...".  We only want
+				 * the context str between the quotes.
+				 */
+				if (*context == '"')
+					strncpy(data->context, context+1,
+							ctxlen-2);
+				else
+					strncpy(data->context, context,
+							NFS_MAX_CONTEXT_LEN);
  			} else if (sloppy)
 				continue;
 			else
-- 
1.4.4.2

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
