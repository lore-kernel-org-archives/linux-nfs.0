From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS performance issue - P3 vs P4
Date: 11 Oct 2002 23:01:40 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs1y6witaj.fsf@charged.uio.no>
References: <Pine.LNX.3.95a.1021011121800.12919A-100000@kiwi.caspur.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1806uo-0004hq-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 14:01:46 -0700
To: Andrei Maslennikov <andrei@caspur.it>
In-Reply-To: <Pine.LNX.3.95a.1021011121800.12919A-100000@kiwi.caspur.it>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

>>>>> " " == Andrei Maslennikov <andrei@caspur.it> writes:

     > with all the recent patches. On clients, we use RH kernel
     > 2.4.18-10smp.

Has a known UDP bug that can cause it to flood servers. Netapp over
Gigabit has previously been seen to be vulnerable. Please either use a
TCP connection to the Netapp, or try the appended patch.

Cheers,
  Trond

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.555.13.1 -> 1.555.13.2
#	net/ipv4/ip_output.c	1.10    -> 1.11   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/08/03	davem@nuts.ninka.net	1.555.13.2
# IPv4: Fix MSG_DONTWAIT behavior on output fragmentation.
# --------------------------------------------
#
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	Fri Oct 11 22:59:13 2002
+++ b/net/ipv4/ip_output.c	Fri Oct 11 22:59:13 2002
@@ -520,8 +520,18 @@
 		/*
 		 *	Get the memory we require with some space left for alignment.
 		 */
-
-		skb = sock_alloc_send_skb(sk, fraglen+hh_len+15, flags&MSG_DONTWAIT, &err);
+		if (!(flags & MSG_DONTWAIT) || nfrags == 0) {
+			skb = sock_alloc_send_skb(sk, fraglen + hh_len + 15,
+						  (flags & MSG_DONTWAIT), &err);
+		} else {
+			/* On a non-blocking write, we check for send buffer
+			 * usage on the first fragment only.
+			 */
+			skb = sock_wmalloc(sk, fraglen + hh_len + 15, 1,
+					   sk->allocation);
+			if (!skb)
+				err = -ENOBUFS;
+		}
 		if (skb == NULL)
 			goto error;
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
