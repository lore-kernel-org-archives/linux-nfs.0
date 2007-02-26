From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 11/11] nfs-utils: mount: Fixed collision between
 commas in options
Date: Mon, 26 Feb 2007 06:20:41 -0500
Message-ID: <45E2C289.30506@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070501010300070104070300"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdrr-0000eF-Uo
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:18:08 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdrs-0007PU-HC
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:18:09 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBI72e002022
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:18:07 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBI7d4006041
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:18:07 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBI57I025673
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:18:06 -0500
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

This is a multi-part message in MIME format.
--------------070501010300070104070300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------070501010300070104070300
Content-Type: text/x-patch;
 name="patch-11.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-11.dif"

commit 96a3ceb3d35bf5edcb9446aded8375d3b98b4f5b
Author: Cory Olmo <colmo@TrustedCS.com>
Date:   Sat Feb 24 16:20:40 2007 -0500

    This patch avoid the collision between commas in security contexts and the
    delimiter betweeen mount options.
    
    Signed-off-by: Karel Zak <kzak@redhat.com>
    Signed-off-by: Cory Olmo <colmo@TrustedCS.com>

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index b3d3696..f22747b 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -285,18 +285,30 @@ static void parse_opts (const char *options, int *flags, char **extra_opts)
 {
 	if (options != NULL) {
 		char *opts = xstrdup(options);
-		char *opt;
-		int len = strlen(opts) + 20;
-
+		char *opt, *p;
+		int len = strlen(opts) + 256;
+		int open_quote = 0;
+ 
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
+				continue;		/* still in quoted block */
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
 
 /*
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 3ca9b80..08a8ac1 100644
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
+			continue;		/* still in quoted block */
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
@@ -671,13 +687,23 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 						   strcspn(opteq+1," \t\n\r,"));
 			 else if (!strcmp(opt, "context")) {
  				char *context = opteq + 1;
+				int ctxlen = strlen(context);
  				
- 				if (strlen(context) > NFS_MAX_CONTEXT_LEN) {
+ 				if (ctxlen > NFS_MAX_CONTEXT_LEN) {
  					printf(_("context parameter exceeds limit of %d\n"),
  						 NFS_MAX_CONTEXT_LEN);
 					goto bad_parameter;
  				}
- 				strncpy(data->context, context, NFS_MAX_CONTEXT_LEN);
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
  			} else if (!sloppy)
 				goto bad_parameter;
 			sprintf(cbuf, "%s=%s,", opt, opteq+1);

--------------070501010300070104070300
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------070501010300070104070300
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070501010300070104070300--
