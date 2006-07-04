From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils 1.0.9-rc1 - hopefully -final in a week
Date: Tue, 4 Jul 2006 10:40:49 +1000
Message-ID: <17577.47377.412223.132567@cse.unsw.edu.au>
References: <17576.25386.427824.894874@cse.unsw.edu.au>
	<1151912016.18333.4.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxYyP-0008TT-Gw
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 17:41:07 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FxYyM-0007lg-PX
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 17:41:05 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Monday July 3
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

On Monday July 3, gnb@melbourne.sgi.com wrote:
> On Mon, 2006-07-03 at 10:22, Neil Brown wrote:
> > If anyone has patches that are ready and that I haven't included, now
> > might be a good time to send them to me.
> 
> I believe I've managed to wrestle git to the ground, can you try
> 
> git pull git://oss.sgi.com:8090/gnb/nfs-utils
> 
> It's a bunch of mostly harmless warning fixes.  I can now
> build nfs-utils on sles10 with no warnings except from the
> generated *xdr.c files.  You may not agree with the way
> I've used socklen_t conditionally, any feedback appreciated.

Thanks for doing these, and for giving me an excuse to try out more of
git.
All these changes look fine.

For the generates *xdr.c files, what would you think of this change?
It seems to do the right thing.  Each variable declaration is followed
by a (void) usage of it.  Slightly gross, but auto-generated code
often is ;-)

NeilBrown


--- /home/git/nfs-utils/tools/rpcgen/rpc_cout.c	2006-07-04 10:13:49.000000000 +1000
+++ tools/rpcgen/rpc_cout.c	2006-07-04 10:36:43.000000000 +1000
@@ -165,7 +165,7 @@
 	if (Inline == 0)
 		return;
 	/* May cause lint to complain. but  ... */
-	f_print(fout, "\t register int32_t *buf;\n\n");
+	f_print(fout, "\t register int32_t *buf; (void)buf;\n\t{\n\n");
 }
 
 static void
@@ -177,7 +177,7 @@
 static void
 print_trailer(void)
 {
-	f_print(fout, "\treturn (TRUE);\n");
+	f_print(fout, "\t}\n\treturn (TRUE);\n");
 	f_print(fout, "}\n");
 }
 
@@ -399,7 +399,7 @@
 
 		for (dl = def->def.st.decls; dl != NULL; dl = dl->next)
 			if (dl->decl.rel == REL_VECTOR) {
-				f_print(fout, "\t int i;\n");
+				f_print(fout, "\t int i;(void)i;\n");
 				break;
 			}
 		size = 0;

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
