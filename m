From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: mountd --no-tcp -p bugs?
Date: Wed, 19 Feb 2003 15:27:33 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15955.1973.280641.589925@notabene.cse.unsw.edu.au>
References: <20030211002846.GC7774@retsil.sesgroup.com.au>
	<20030214191723.D26265@sesgroup.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lLtB-00009y-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 20:31:21 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <benno@sesgroup.net>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Wed, 19 Feb 2003 15:28:10 +1100
To: benno@sesgroup.net
In-Reply-To: message from Ben Leslie on Friday February 14
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday February 14, benno@sesgroup.net wrote:
> On Tue, 11 Feb 2003, Benno wrote:
> 
> > Hi all,
> > 
> > I'm running into a couple of problems with mountd.
> 
> Hi again,
> 
> I haven't had any feedback on this email from a few days
> ago. Is this not a bug and I'm missing something, or just 
> no one cares about bugs in client programs, or am I just being
> impatient?

It is a bug.
You aren't missing much.
People do care, but are also busy.
You were reasonably patient, and it does help to ask again (and
again...) if you don't get a response.  It gives an indication of how
important it is, and helps people with short memory and long todo
lists.

I have just committed the following patch to the nfs-utils CVS.  It
should address your issues.

NeilBrown

Index: ChangeLog
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/ChangeLog,v
retrieving revision 1.187
diff -u -r1.187 ChangeLog
--- ChangeLog	13 Feb 2003 02:29:42 -0000	1.187
+++ ChangeLog	19 Feb 2003 04:23:27 -0000
@@ -1,3 +1,16 @@
+2003-02-19 NeilBrown <neilb@cse.unsw.edu.au>	
+	Ben Leslie <benno@sesgroup.net>
+
+	* support/nfs/rpcmisc.c(rpc_init):  change test for ignoring
+	"defport" from (__rpcfdtype == 0) to (__rpcpmstart==0).  The
+	former would incorectly ignore defport if the application 
+	explicitly set __rpcfdtype.  The later is sufficient to avoid the
+	special handling in the case where stdin is an internet socket.
+
+	* utils/mountd/mountd.c(main): Add 'n' to option list in
+	getopt_long as this is a short form of --no-tcp which want being
+	checked.
+	
 2003-02-12  Chip Salzenberg  <chip@pobox.com>
 
 	* debian/changelog: Version 1.0.2-2.
Index: support/nfs/rpcmisc.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/support/nfs/rpcmisc.c,v
retrieving revision 1.13
diff -u -r1.13 rpcmisc.c
--- support/nfs/rpcmisc.c	16 Sep 2002 02:27:45 -0000	1.13
+++ support/nfs/rpcmisc.c	19 Feb 2003 04:23:28 -0000
@@ -66,7 +66,7 @@
 	if ((_rpcfdtype == 0) || (_rpcfdtype == SOCK_DGRAM)) {
 		static SVCXPRT *last_transp = NULL;
  
-		if (_rpcfdtype == 0) {
+		if (_rpcpmstart == 0) {
 			if (last_transp
 			    && (!defport || defport == last_transp->xp_port)) {
 				transp = last_transp;
@@ -96,7 +96,7 @@
 	if ((_rpcfdtype == 0) || (_rpcfdtype == SOCK_STREAM)) {
 		static SVCXPRT *last_transp = NULL;
 
-		if (_rpcfdtype == 0) {
+		if (_rpcpmstart == 0) {
 			if (last_transp
 			    && (!defport || defport == last_transp->xp_port)) {
 				transp = last_transp;
Index: utils/mountd/mountd.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/mountd/mountd.c,v
retrieving revision 1.13
diff -u -r1.13 mountd.c
--- utils/mountd/mountd.c	8 Apr 2002 21:43:25 -0000	1.13
+++ utils/mountd/mountd.c	19 Feb 2003 04:23:28 -0000
@@ -399,7 +399,7 @@
 
 	/* Parse the command line options and arguments. */
 	opterr = 0;
-	while ((c = getopt_long(argc, argv, "o:Fd:f:p:P:hN:V:v", longopts, NULL)) != EOF)
+	while ((c = getopt_long(argc, argv, "on:Fd:f:p:P:hN:V:v", longopts, NULL)) != EOF)
 		switch (c) {
 		case 'o':
 			descriptors = atoi(optarg);


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
