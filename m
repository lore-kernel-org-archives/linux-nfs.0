From: Olof Johansson <olof@austin.ibm.com>
Subject: [PATCH] SVC sockets don't disable Nagle
Date: Tue, 29 Apr 2003 17:03:19 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EAEF6A7.1000806@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e35.co.us.ibm.com ([32.97.110.133])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AdCH-0008UY-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 15:03:34 -0700
To: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net
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

I noticed that the Nagle algorithm was disabled just recently on the 
client side, while it still seems to be enabled on the server side. The 
previous patch came from Chuck Lever.

Below patch disables it on the server side as well. For latency reasons, 
this should be the desired behaviour NFS at both client and server.

Diff is against 2.4.21-rc1.

---------------------------

--- linux-2.4.21-rc1/net/sunrpc/svcsock.c.orig
+++ linux-2.4.21-rc1/net/sunrpc/svcsock.c
@@ -932,6 +932,7 @@ static int
  svc_tcp_init(struct svc_sock *svsk)
  {
         struct sock     *sk = svsk->sk_sk;
+       struct tcp_opt  *tp = &(sk->tp_pinfo.af_tcp);

         svsk->sk_recvfrom = svc_tcp_recvfrom;
         svsk->sk_sendto = svc_tcp_sendto;
@@ -948,6 +949,8 @@ svc_tcp_init(struct svc_sock *svsk)
                 svsk->sk_reclen = 0;
                 svsk->sk_tcplen = 0;

+               tp->nonagle = 1;        /* disable Nagle's algorithm */
+
                 /* initialise setting must have enough space to
                  * receive and respond to one request.
                  * svc_tcp_recvfrom will re-adjust if necessary


---------------------------


Thanks,

Olof

-- 
Olof Johansson                                        Office: 4E002/905
pSeries Linux Development                             IBM Systems Group
Email: olof@austin.ibm.com                          Phone: 512-838-9858
All opinions are my own and not those of IBM.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
