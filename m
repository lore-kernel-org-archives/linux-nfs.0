From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH - try #2] sunrpc: fix typo in svc_udp_recvfrom
Date: Wed, 28 Mar 2007 12:16:00 +1000
Message-ID: <17929.53216.475068.190958@notabene.brown>
References: <200703271651.13181.olaf.kirch@oracle.com>
	<1175008207.6153.12.camel@heimdal.trondhjem.org>
	<200703271739.43675.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWNhr-000080-Hl
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 19:16:12 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWNhs-0006R1-AC
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 19:16:13 -0700
In-Reply-To: message from Olaf Kirch on Tuesday March 27
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

On Tuesday March 27, olaf.kirch@oracle.com wrote:
> On Tuesday 27 March 2007 17:10, Trond Myklebust wrote:
> > Could you please rather move those assignments out of the while()? Good
> > coding style dictates that the above should be avoided. One of the
> > benefits is precisely to avoid the above ambiguities.
> 
> Okay, here we go:
> ----------------------
> Fix a typo in svc_udp_recvfrom

Thanks...

This is already in -mm : net-sunrpc-svcsockc-fix-a-check.patch
Hopefully it will get to -linus soon.
Apparently coverty found it.

While I appreciate that having assignments inside conditionals can
hurt readability, I don't find the new version particularly
readable... The logic seems to be obscured.  Maybe it is just obscure
logic?

What about this (on top of current -mm).

NeilBrown


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-03-28 12:06:59.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2007-03-28 12:12:50.000000000 +1000
@@ -779,15 +779,20 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	}
 
 	clear_bit(SK_DATA, &svsk->sk_flags);
-	while ((err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
-				     0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
-	       (skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
-		if (err == -EAGAIN) {
-			svc_sock_received(svsk);
-			return err;
+	skb = NULL;
+	err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
+			     0, 0, MSG_PEEK | MSG_DONTWAIT);
+	if (err >= 0)
+		skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err);
+
+	if (skb == NULL) {
+		if (err != -EAGAIN) {
+			/* possibly an icmp error */
+			dprintk("svc: recvfrom returned error %d\n", -err);
+			set_bit(SK_DATA, &svsk->sk_flags);
 		}
-		/* possibly an icmp error */
-		dprintk("svc: recvfrom returned error %d\n", -err);
+		svc_sock_received(svsk);
+		return -EAGAIN;
 	}
 	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
 	if (skb->tstamp.off_sec == 0) {

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
