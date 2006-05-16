From: "Shankar Anand" <shanand@novell.com>
Subject: PATCH[2/2] Display nfsv4 server operations statistics
Date: Tue, 16 May 2006 01:10:28 -0600
Message-ID: <4469C83D.AD69.00CC.0@novell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=__PartCBEEEBF4.0__="
Return-path: <nfsv4-bounces@linux-nfs.org>
To: <nfsv4@linux-nfs.org>,<nfs@lists.sourceforge.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

This is a MIME message. If you are reading this text, you may want to 
consider changing to a mail reader or gateway that understands how to 
properly handle MIME multipart messages.

--=__PartCBEEEBF4.0__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch adds code to nfsstat to read /proc/net/rpc/nfsd for nfsv4
server statistics and print them.

Submitted by: Shankar Anand <shanand@novell.com>

diff -aurp nfs-utils-1.0.8.old/utils/nfsstat/nfsstat.c
nfs-utils-1.0.8/utils/nfsstat/nfsstat.c
--- nfs-utils-1.0.8.old/utils/nfsstat/nfsstat.c	2005-12-20
09:42:47.000000000 +0530
+++ nfs-utils-1.0.8/utils/nfsstat/nfsstat.c	2006-05-16
16:56:18.000000000 +0530
@@ -29,6 +29,7 @@ static unsigned int	svcv3info[24];	/* NF
 static unsigned int	cltv3info[24];	/* NFSv3 call counts ([0] == 22)
*/
 static unsigned int	svcv4info[4];	/* NFSv4 call counts ([0] == 2)
*/
 static unsigned int	cltv4info[34];	/* NFSv4 call counts ([0] == 32)
*/
+static unsigned int	svcv4opinfo[39];/* NFSv4 call counts ([0] == 37)
*/
 static unsigned int	svcnetinfo[5];	/* 0  # of received packets
 					 * 1  UDP packets
 					 * 2  TCP packets
@@ -99,6 +100,16 @@ static const char *	nfscltv4name[32] = {
 	"statfs",    "readlink",  "readdir", "server_caps",
"delegreturn",
 };
 
+static const char *     nfssvrv4opname[37] = {
+        "access",    "close",       "commit",   "create",      
"delegpurge", "delegreturn",
+        "getattr",   "getfh",       "link",     "lock",        
"lockt",      "locku",
+        "lookup",    "lookup_root", "nverify",  "open",        
"openattr",   "open_conf",
+        "open_dgrd", "putfh",       "putpubfh", "putrootfh",   
"read",       "readdir",
+        "readlink",  "remove",      "rename",   "renew",       
"restorefh",  "savefh",
+        "secinfo",   "setattr",     "setcltid", "setcltidconf",
"verify",     "write",
+        "rellockowner"
+};
+
 typedef struct statinfo {
 	char		*tag;
 	int		nrvals;
@@ -115,6 +126,7 @@ static statinfo		svcinfo[] = {
 	{ "proc2",      STRUCTSIZE(svcv2info),  svcv2info  },
 	{ "proc3",      STRUCTSIZE(svcv3info),  svcv3info  },
 	{ "proc4",      STRUCTSIZE(svcv4info),  svcv4info  },
+	{ "proc4ops",   STRUCTSIZE(svcv4opinfo),svcv4opinfo},
 	{ NULL,         0,                      NULL       }
 };
 
@@ -381,11 +393,16 @@ main(int argc, char **argv)
 				"Server nfs v3:\n",
 				nfsv3name, svcv3info + 1,
sizeof(nfsv3name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V4) || ((opt_prt &
PRNT_AUTO) && svcv4info[0] && svcv4info[svcv4info[0]+1] !=
svcv4info[0]))
+			if ((opt_prt & PRNT_V4) || ((opt_prt &
PRNT_AUTO) && svcv4info[0] && svcv4info[svcv4info[0]+1] !=
svcv4info[0])) {
 				print_callstats(
 				"Server nfs v4:\n",
 				nfssvrv4name, svcv4info + 1,
sizeof(nfssvrv4name)/sizeof(char *)
 				);
+				print_callstats(
+				"Server nfs v4 operations:\n",
+				nfssvrv4opname, svcv4opinfo + 1,
sizeof(nfssvrv4opname)/sizeof(char *)
+				);
+			}
 		}
 	}
 


--=__PartCBEEEBF4.0__=
Content-Type: text/plain; name="nfs-utils-1.0.8-display-nfs4-server-stats.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="nfs-utils-1.0.8-display-nfs4-server-stats.diff"

This patch adds code to nfsstat to read /proc/net/rpc/nfsd for nfsv4 server statistics and print them.

Submitted by: Shankar Anand <shanand@novell.com>

diff -aurp nfs-utils-1.0.8.old/utils/nfsstat/nfsstat.c nfs-utils-1.0.8/utils/nfsstat/nfsstat.c
--- nfs-utils-1.0.8.old/utils/nfsstat/nfsstat.c	2005-12-20 09:42:47.000000000 +0530
+++ nfs-utils-1.0.8/utils/nfsstat/nfsstat.c	2006-05-16 16:56:18.000000000 +0530
@@ -29,6 +29,7 @@ static unsigned int	svcv3info[24];	/* NF
 static unsigned int	cltv3info[24];	/* NFSv3 call counts ([0] == 22) */
 static unsigned int	svcv4info[4];	/* NFSv4 call counts ([0] == 2) */
 static unsigned int	cltv4info[34];	/* NFSv4 call counts ([0] == 32) */
+static unsigned int	svcv4opinfo[39];/* NFSv4 call counts ([0] == 37) */
 static unsigned int	svcnetinfo[5];	/* 0  # of received packets
 					 * 1  UDP packets
 					 * 2  TCP packets
@@ -99,6 +100,16 @@ static const char *	nfscltv4name[32] = {
 	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn",
 };
 
+static const char *     nfssvrv4opname[37] = {
+        "access",    "close",       "commit",   "create",       "delegpurge", "delegreturn",
+        "getattr",   "getfh",       "link",     "lock",         "lockt",      "locku",
+        "lookup",    "lookup_root", "nverify",  "open",         "openattr",   "open_conf",
+        "open_dgrd", "putfh",       "putpubfh", "putrootfh",    "read",       "readdir",
+        "readlink",  "remove",      "rename",   "renew",        "restorefh",  "savefh",
+        "secinfo",   "setattr",     "setcltid", "setcltidconf", "verify",     "write",
+        "rellockowner"
+};
+
 typedef struct statinfo {
 	char		*tag;
 	int		nrvals;
@@ -115,6 +126,7 @@ static statinfo		svcinfo[] = {
 	{ "proc2",      STRUCTSIZE(svcv2info),  svcv2info  },
 	{ "proc3",      STRUCTSIZE(svcv3info),  svcv3info  },
 	{ "proc4",      STRUCTSIZE(svcv4info),  svcv4info  },
+	{ "proc4ops",   STRUCTSIZE(svcv4opinfo),svcv4opinfo},
 	{ NULL,         0,                      NULL       }
 };
 
@@ -381,11 +393,16 @@ main(int argc, char **argv)
 				"Server nfs v3:\n",
 				nfsv3name, svcv3info + 1, sizeof(nfsv3name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && svcv4info[0] && svcv4info[svcv4info[0]+1] != svcv4info[0]))
+			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && svcv4info[0] && svcv4info[svcv4info[0]+1] != svcv4info[0])) {
 				print_callstats(
 				"Server nfs v4:\n",
 				nfssvrv4name, svcv4info + 1, sizeof(nfssvrv4name)/sizeof(char *)
 				);
+				print_callstats(
+				"Server nfs v4 operations:\n",
+				nfssvrv4opname, svcv4opinfo + 1, sizeof(nfssvrv4opname)/sizeof(char *)
+				);
+			}
 		}
 	}
 

--=__PartCBEEEBF4.0__=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--=__PartCBEEEBF4.0__=--
