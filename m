From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - RPC/TCP 2 of 4 - Allow  SO_REUSEADDR for NFS sockets
Date: Tue, 13 Aug 2002 12:57:41 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15704.30117.665447.109832@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: minoura@valinux.co.jp (Minoura Makoto), Chuck Lever <cel@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eRu6-0008LJ-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 19:59:30 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <minoura@valinux.co.jp>)
	(for <cel@citi.umich.edu>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Tue, 13 Aug 2002 12:57:43 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: nfs@lists.sourceforge.net
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


Otherwise if you cannot stop and restart nfsd while a client holds a
connection.  Why this isn't the default I cannot imagine...

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    1 +
 1 files changed, 1 insertion(+)

--- ./net/sunrpc/svcsock.c	2002/08/12 06:01:42	1.2
+++ ./net/sunrpc/svcsock.c	2002/08/13 01:54:39	1.3
@@ -1208,6 +1208,7 @@ svc_create_socket(struct svc_serv *serv,
 		return error;
 
 	if (sin != NULL) {
+		sock->sk->reuse = 1; /* allow address reuse */
 		error = sock->ops->bind(sock, (struct sockaddr *) sin,
 						sizeof(*sin));
 		if (error < 0)


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
