From: "Shankar Anand" <shanand@novell.com>
Subject: Re: nfs-utils 1.0.9-rc1 - hopefully -final in a week
Date: Tue, 04 Jul 2006 08:50:56 -0600
Message-ID: <44AACDA6.AD69.00CC.0@novell.com>
References: <17576.25386.427824.894874@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=__Part4663A540.1__="
Cc: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxmDe-0003YL-7D
	for nfs@lists.sourceforge.net; Tue, 04 Jul 2006 07:49:42 -0700
Received: from lucius.provo.novell.com ([137.65.81.172])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FxmDa-0006hj-87
	for nfs@lists.sourceforge.net; Tue, 04 Jul 2006 07:49:42 -0700
To: <nfs@lists.sourceforge.net>, "Neil Brown" <neilb@suse.de>
In-Reply-To: <17576.25386.427824.894874@cse.unsw.edu.au>
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

This is a MIME message. If you are reading this text, you may want to 
consider changing to a mail reader or gateway that understands how to 
properly handle MIME multipart messages.

--=__Part4663A540.1__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

>>> On 7/3/2006 at 5:52 AM, Neil Brown <neilb@suse.de> wrote:

> Hi,
>  I'd like to put out nfs-utils-1.0.9 by the end of the week.
> There is (or will soon be) a -pre1 in
>   http://www.kernel.org/pub/linux/utils/nfs/ 
> and
>   git://linux-nfs.org/nfs-utils
> 
> Recent changes can been seen at
>    http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=log 
>   
> If anyone cares to do some testing that would be great.
> 
> If anyone has patches that are ready and that I haven't included,
now
> might be a good time to send them to me.
> 
> If they aren't quite ready, don't rush - I'd like to put out
> releases a little more often than once per year (which is what it
was
> a for a while) so there will be another chance in a month or two or
> three.

The patch attached here reads /proc/net/rpc/nfsd for nfsv4 server
statistics and displays them.

To maintain uniformity with older nfs versions operations 0 1 and 2
are also printed though they are not used by nfsv4.

Shankar


--=__Part4663A540.1__=
Content-Type: text/plain; name="nfs-utils-1.0.8-display-nfs4-server-stats.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="nfs-utils-1.0.8-display-nfs4-server-stats.diff"

This patch adds code to nfsstat to read /proc/net/rpc/nfsd for nfsv4 server statistics and print them.

Submitted by: Shankar Anand <shanand@novell.com>

diff -aurp nfs-utils-1.0.8.old/utils/nfsstat/nfsstat.c nfs-utils-1.0.8/utils/nfsstat/nfsstat.c
--- nfs-utils-1.0.8.old/utils/nfsstat/nfsstat.c	2005-12-20 09:42:47.000000000 +0530
+++ nfs-utils-1.0.8/utils/nfsstat/nfsstat.c	2006-07-04 20:11:51.000000000 +0530
@@ -29,6 +29,7 @@ static unsigned int	svcv3info[24];	/* NF
 static unsigned int	cltv3info[24];	/* NFSv3 call counts ([0] == 22) */
 static unsigned int	svcv4info[4];	/* NFSv4 call counts ([0] == 2) */
 static unsigned int	cltv4info[34];	/* NFSv4 call counts ([0] == 32) */
+static unsigned int	svcv4opinfo[42];/* NFSv4 call counts ([0] == 40) */
 static unsigned int	svcnetinfo[5];	/* 0  # of received packets
 					 * 1  UDP packets
 					 * 2  TCP packets
@@ -99,6 +100,16 @@ static const char *	nfscltv4name[32] = {
 	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn",
 };
 
+static const char *     nfssvrv4opname[40] = {
+        "op0-unused",   "op1-unused", "op2-future",  "access",     "close",       "commit",
+        "create",       "delegpurge", "delegreturn", "getattr",    "getfh",       "link",
+        "lock",         "lockt",      "locku",       "lookup",     "lookup_root", "nverify",
+        "open",         "openattr",   "open_conf",   "open_dgrd",  "putfh",       "putpubfh",
+        "putrootfh",    "read",       "readdir",     "readlink",   "remove",      "rename",
+        "renew",        "restorefh",  "savefh",      "secinfo",    "setattr",     "setcltid",
+        "setcltidconf", "verify",     "write",       "rellockowner"
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
 

--=__Part4663A540.1__=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--=__Part4663A540.1__=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=__Part4663A540.1__=--
