From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - RPC/TCP 4 of 4 - Handle short read when reading RPC/TCP packet length
Date: Tue, 13 Aug 2002 13:00:15 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15704.30271.141066.1984@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: minoura@valinux.co.jp (Minoura Makoto), Chuck Lever <cel@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eRvi-0008S9-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 20:01:10 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <minoura@valinux.co.jp>)
	(for <cel@citi.umich.edu>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Tue, 13 Aug 2002 13:00:17 +1000
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



The code already copes with the possibility of having
read some of the 4byte length but not all, but can never
get into that situation.  We just need to add a 'return' 
for the case where read got some data but not enough.
Either 0 or -EAGAIN could be returned, they both have the
same effect.


 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    3 +++
 1 files changed, 3 insertions(+)

--- ./net/sunrpc/svcsock.c	2002/08/13 01:57:46	1.4
+++ ./net/sunrpc/svcsock.c	2002/08/13 02:00:15	1.5
@@ -811,6 +811,9 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 			goto error;
 		svsk->sk_tcplen += len;
 
+		if (len < want)
+			return 0;
+
 		svsk->sk_reclen = ntohl(svsk->sk_reclen);
 		if (!(svsk->sk_reclen & 0x80000000)) {
 			/* FIXME: technically, a record can be fragmented,


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
