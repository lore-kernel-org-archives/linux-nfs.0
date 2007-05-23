From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 9/15] knfsd: add RDMA debug class to rpc_debug bitfield
Date: Thu, 24 May 2007 01:14:13 +1000
Message-ID: <20070523151412.GO14076@sgi.com>
References: <20070521031940.GF7482@sgi.com>
	<C2767CB3.30B42%tom@opengridcomputing.com>
	<20070521041617.GG7482@sgi.com>
	<18001.8854.771127.95716@notabene.brown>
	<4651ACDA.7050207@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqsXW-0000qw-PR
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 08:14:14 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX18MrNm7C3OYqezmM8mKCTx95QBXqt7QJ1E=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqsXZ-0006Wd-Ct
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 08:14:17 -0700
In-Reply-To: <4651ACDA.7050207@oracle.com>
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

On Mon, May 21, 2007 at 10:29:46AM -0400, Chuck Lever wrote:
> Neil Brown wrote:
> >On Monday May 21, gnb@sgi.com wrote:
> >>In any case I'm happy to do whatever is necessary in the transport
> >>patchset,  but I'd appreciate Neil's guidance on which approach he'd
> >>prefer before I go in with the scalpel.  Neil?
> >
> >I cannot immediately see the value in having different debug bits for
> >the socket transport code and the RDMA transport code.  The key
> >question is "When would you want to see the debugging from one, but
> >not from the other", and I cannot see when that would be.  Almost
> >certainly if you are testing one transport, you will not be using the
> >other, so it will not contribute any noise.
> 
> That's how I did it in the client transport switch.  One bit enables 
> debug messages for all transports.
> 
> >So I suspect we should simply
> >#define RPCDBG_FACILITY	RPCDBG_SVCSOCK
> 
> That's expedient, but I suggest you rename the flag to something less 
> specific to sockets.

Aah, I see now.  That's very easy.  How's this?



Rename RPCDBG_SVCSOCK to RPCDBG_SVCXPRT to reflect its
new more generic nature.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/debug.h |    2 +-
 net/sunrpc/svcsock.c         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Index: linux/include/linux/sunrpc/debug.h
===================================================================
--- linux.orig/include/linux/sunrpc/debug.h	2007-04-26 13:08:32.000000000 +1000
+++ linux/include/linux/sunrpc/debug.h	2007-05-24 01:09:11.427405573 +1000
@@ -20,7 +20,7 @@
 #define RPCDBG_PMAP		0x0020
 #define RPCDBG_SCHED		0x0040
 #define RPCDBG_TRANS		0x0080
-#define RPCDBG_SVCSOCK		0x0100
+#define RPCDBG_SVCXPRT		0x0100
 #define RPCDBG_SVCDSP		0x0200
 #define RPCDBG_MISC		0x0400
 #define RPCDBG_CACHE		0x0800
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-23 22:39:53.000000000 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-24 01:09:15.574878967 +1000
@@ -73,7 +73,7 @@
  *
  */
 
-#define RPCDBG_FACILITY	RPCDBG_SVCSOCK
+#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
