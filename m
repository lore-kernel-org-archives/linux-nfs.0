From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: nfs-utils 1.0.9-rc1 - hopefully -final in a week
Date: Tue, 04 Jul 2006 14:17:02 +1000
Message-ID: <1151986622.18333.189.camel@hole.melbourne.sgi.com>
References: <17576.25386.427824.894874@cse.unsw.edu.au>
	<1151912016.18333.4.camel@hole.melbourne.sgi.com>
	<17577.47377.412223.132567@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxcMH-0000ow-Gk
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 21:17:57 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FxcMH-0002fW-CE
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 21:17:57 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17577.47377.412223.132567@cse.unsw.edu.au>
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

On Tue, 2006-07-04 at 10:40, Neil Brown wrote:
> On Monday July 3, gnb@melbourne.sgi.com wrote:
> Thanks for doing these, and for giving me an excuse to try out more of
> git.

No worries, it gave me an excuse too ;-)

> For the generates *xdr.c files, what would you think of this change?
> It seems to do the right thing.  Each variable declaration is followed
> by a (void) usage of it.  Slightly gross, but auto-generated code
> often is ;-)

I think the following patch is cleaner.  It eliminates the
warnings about `buf' being unused by generating the declaration
on first demand.  As a result most XDR routines don't have
a `buf' declaration at all; those that do inlining have two,
one each in the encode and decode branch.  Comments?

I'll see if I can do something equivalent for that pesky `i' too.

diff-tree 18ffd1f098436ebfb99291815dfd3463a41fcb3f (from 4e9ed06f8f8a0cd9f34a6830c0ff14344a528042)
Author: Greg Banks <gnb@melbourne.sgi.com>
Date:   Tue Jul 4 14:07:11 2006 +1000

    Eliminate warnings about unused variable `buf' in generated
    XDR code by emitting a declaration for `buf' on demand.

diff --git a/tools/rpcgen/rpc_cout.c b/tools/rpcgen/rpc_cout.c
index cae8717..26dc466 100644
--- a/tools/rpcgen/rpc_cout.c
+++ b/tools/rpcgen/rpc_cout.c
@@ -164,8 +164,6 @@ print_header(definition *def)
 
 	if (Inline == 0)
 		return;
-	/* May cause lint to complain. but  ... */
-	f_print(fout, "\t register int32_t *buf;\n\n");
 }
 
 static void
@@ -390,6 +388,7 @@ emit_struct(definition *def)
 	char           *sizestr, *plus;
 	char            ptemp[256];
 	int             can_inline;
+	const char	*buf_declaration;
 
 
 	if (Inline == 0) {
@@ -444,6 +443,7 @@ emit_struct(definition *def)
 			i = 0;
 			size = 0;
 			sizestr = NULL;
+			buf_declaration = "int32_t *";
 			for (dl = def->def.st.decls; dl != NULL; dl = dl->next) {	/* xxx */
 
 				/* now walk down the list and check for basic types */
@@ -497,16 +497,17 @@ emit_struct(definition *def)
 
 							/* were already looking at a xdr_inlineable structure */
 							if (sizestr == NULL)
-								f_print(fout, "\t buf = XDR_INLINE(xdrs,%d * BYTES_PER_XDR_UNIT);",
-									size);
+								f_print(fout, "\t %sbuf = XDR_INLINE(xdrs,%d * BYTES_PER_XDR_UNIT);",
+									buf_declaration, size);
 							else if (size == 0)
 								f_print(fout,
-									"\t buf = XDR_INLINE(xdrs,%s * BYTES_PER_XDR_UNIT);",
-									sizestr);
+									"\t %sbuf = XDR_INLINE(xdrs,%s * BYTES_PER_XDR_UNIT);",
+									buf_declaration, sizestr);
 							else
 								f_print(fout,
-									"\t buf = XDR_INLINE(xdrs,(%d + %s)* BYTES_PER_XDR_UNIT);",
-									size, sizestr);
+									"\t %sbuf = XDR_INLINE(xdrs,(%d + %s)* BYTES_PER_XDR_UNIT);",
+									buf_declaration, size, sizestr);
+							buf_declaration = "";
 
 							f_print(fout, "\n\t   if (buf == NULL) {\n");
 
@@ -546,16 +547,17 @@ emit_struct(definition *def)
 
 					/* were already looking at a xdr_inlineable structure */
 					if (sizestr == NULL)
-						f_print(fout, "\t\tbuf = XDR_INLINE(xdrs,%d * BYTES_PER_XDR_UNIT);",
-							size);
+						f_print(fout, "\t\t%sbuf = XDR_INLINE(xdrs,%d * BYTES_PER_XDR_UNIT);",
+							buf_declaration, size);
 					else if (size == 0)
 						f_print(fout,
-							"\t\tbuf = XDR_INLINE(xdrs,%s * BYTES_PER_XDR_UNIT);",
-							sizestr);
+							"\t\t%sbuf = XDR_INLINE(xdrs,%s * BYTES_PER_XDR_UNIT);",
+							buf_declaration, sizestr);
 					else
 						f_print(fout,
-							"\t\tbuf = XDR_INLINE(xdrs,(%d + %s)* BYTES_PER_XDR_UNIT);",
-							size, sizestr);
+							"\t\t%sbuf = XDR_INLINE(xdrs,(%d + %s)* BYTES_PER_XDR_UNIT);",
+							buf_declaration, size, sizestr);
+					buf_declaration = "";
 
 					f_print(fout, "\n\t\tif (buf == NULL) {\n");
 

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
