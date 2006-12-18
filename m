From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/3] add -r flag to make mountd do reverse resolve of
 ipaddress on the fly
Date: Mon, 18 Dec 2006 15:44:11 -0500
Message-ID: <4586FD9B.5020106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GwPLN-0006G4-7N
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 12:44:17 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GwPLO-0002Mh-FM
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 12:44:18 -0800
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

For those that want "traditional" showmount -a behavior from their mountd
(hostname:/path instead of ipaddr:/path). This patch adds a '-r' flag that
does a reverse-resolve for each IP address listed in the rmtab when
a dump operation is called.

Probably not a good idea for those concerned about performance, but since it's
not the default option, I don't see it being an issue.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

--- nfs-utils-1.0.10/utils/mountd/mountd.c.revres
+++ nfs-utils-1.0.10/utils/mountd/mountd.c
@@ -37,6 +37,7 @@ static void		usage(const char *, int exi
  static exports		get_exportlist(void);
  static struct nfs_fh_len *get_rootfh(struct svc_req *, dirpath *, mountstat3 *, int v3);

+int reverse_resolve = 0;
  int new_cache = 0;

  /* PRC: a high-availability callout program can be specified with -H
@@ -557,7 +558,7 @@ main(int argc, char **argv)

  	/* Parse the command line options and arguments. */
  	opterr = 0;
-	while ((c = getopt_long(argc, argv, "o:n:Fd:f:p:P:hH:N:V:vs:t:", longopts, NULL)) != EOF)
+	while ((c = getopt_long(argc, argv, "o:n:Fd:f:p:P:hH:N:V:vrs:t:", longopts, NULL)) != EOF)
  		switch (c) {
  		case 'o':
  			descriptors = atoi(optarg);
@@ -597,6 +598,9 @@ main(int argc, char **argv)
  		case 'n':
  			_rpcfdtype = SOCK_DGRAM;
  			break;
+		case 'r':
+			reverse_resolve = 1;
+			break;
  		case 's':
  			if ((state_dir = xstrdup(optarg)) == NULL) {
  				fprintf(stderr, "%s: xstrdup(%s) failed!\n",
--- nfs-utils-1.0.10/utils/mountd/rmtab.c.revres
+++ nfs-utils-1.0.10/utils/mountd/rmtab.c
@@ -25,6 +25,8 @@

  #include <limits.h> /* PATH_MAX */

+extern int reverse_resolve;
+
  /* If new path is a link do not destroy it but place the
   * file where the link points.
   */
@@ -185,6 +187,8 @@ mountlist_list(void)
  	struct rmtabent		*rep;
  	struct stat		stb;
  	int			lockid;
+	struct in_addr		addr;
+	struct hostent		*he;

  	if ((lockid = xflock(_PATH_RMTAB, "r")) < 0)
  		return NULL;
@@ -204,7 +208,14 @@ mountlist_list(void)
  		setrmtabent("r");
  		while ((rep = getrmtabent(1, NULL)) != NULL) {
  			m = (mountlist) xmalloc(sizeof(*m));
-			m->ml_hostname = xstrdup(rep->r_client);
+
+			if (reverse_resolve &&
+			   inet_aton((const char *) rep->r_client, &addr) &&
+			   (he = gethostbyaddr(&addr, sizeof(addr), AF_INET)))
+				m->ml_hostname = xstrdup(he->h_name);
+			else
+				m->ml_hostname = xstrdup(rep->r_client);
+
  			m->ml_directory = xstrdup(rep->r_path);
  			m->ml_next = mlist;
  			mlist = m;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
