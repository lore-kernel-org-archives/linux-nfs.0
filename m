From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/15] NFS: Add new 'mountaddr=' mount option
Date: Tue, 11 Sep 2007 18:01:04 -0400
Message-ID: <20070911220104.26136.30233.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDnm-0006zI-Cr
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:46 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDnr-0005cm-0V
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:51 -0700
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

I got the 'mounthost=' option wrong - it shouldn't look for an address
value, but rather a hostname value.  However, the in-kernel mount client
and NFS client cannot resolve a hostname by themselves; they rely on
user-land to pass in the resolved address.

Create a new mount option that does take an address so that the mount
program's address can be passed in.  The mount hostname is now ignored
by the kernel.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2cabe09..a24cb0a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -73,6 +73,7 @@ struct nfs_parsed_mount_data {
 
 	struct {
 		struct sockaddr_in	address;
+		char			*hostname;
 		unsigned int		program;
 		unsigned int		version;
 		unsigned short		port;
@@ -116,7 +117,7 @@ enum {
 
 	/* Mount options that take string arguments */
 	Opt_sec, Opt_proto, Opt_mountproto,
-	Opt_addr, Opt_mounthost, Opt_clientaddr,
+	Opt_addr, Opt_mountaddr, Opt_clientaddr,
 
 	/* Mount options that are ignored */
 	Opt_userspace, Opt_deprecated,
@@ -175,7 +176,8 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_mountproto, "mountproto=%s" },
 	{ Opt_addr, "addr=%s" },
 	{ Opt_clientaddr, "clientaddr=%s" },
-	{ Opt_mounthost, "mounthost=%s" },
+	{ Opt_userspace, "mounthost=%s" },
+	{ Opt_mountaddr, "mountaddr=%s" },
 
 	{ Opt_err, NULL }
 };
@@ -961,7 +963,7 @@ static int nfs_parse_mount_options(char *raw,
 				goto out_nomem;
 			mnt->client_address = string;
 			break;
-		case Opt_mounthost:
+		case Opt_mountaddr:
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
