From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - SUNRPC 1 of 3 - The new "sk_flags" word in struct svc_sock must be long....
Date: Tue, 20 Aug 2002 14:24:56 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15713.50328.541517.124690@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17h0Zr-0001mU-00
	for <nfs@lists.sourceforge.net>; Mon, 19 Aug 2002 21:25:11 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 20 Aug 2002 14:24:59 +1000
To: Marcelo Tosatti <marcelo@conectiva.com.br>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


As Dave Miller reminded me, 'flags' fields must be unsigned long.


 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svcsock.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- ./include/linux/sunrpc/svcsock.h	2002/08/20 03:00:47	1.1
+++ ./include/linux/sunrpc/svcsock.h	2002/08/20 03:01:25	1.2
@@ -22,7 +22,7 @@ struct svc_sock {
 
 	struct svc_serv *	sk_server;	/* service for this socket */
 	unsigned char		sk_inuse;	/* use count */
-	unsigned int		sk_flags;
+	unsigned long		sk_flags;
 #define	SK_BUSY		0			/* enqueued/receiving */
 #define	SK_CONN		1			/* conn pending */
 #define	SK_CLOSE	2			/* dead or dying */


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
