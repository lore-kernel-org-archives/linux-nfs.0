From: Maurice Volaski <mvolaski@aecom.yu.edu>
Subject: TCP mounting requires UDP access to portmap and NFS changes
 server's hostname
Date: Sat, 20 Jul 2002 14:41:29 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <a0511160eb95f5bf7b4b0@[129.98.90.227]>
References: <E17Vd5U-000143-00@usw-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii" ; format="flowed"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailgw.aecom.yu.edu ([129.98.1.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17VzAf-0007VP-00
	for <nfs@lists.sourceforge.net>; Sat, 20 Jul 2002 11:41:38 -0700
Received: from mailvx.aecom.yu.edu (mailvx.aecom.yu.edu [129.98.1.17])
	by mailgw.aecom.yu.edu (8.11.6/8.11.6) with SMTP id g6KIfZS12113
	for <nfs@lists.sourceforge.net>; Sat, 20 Jul 2002 14:41:35 -0400
Received: from post.aecom.yu.edu ([129.98.1.4])
 by mailvx.aecom.yu.edu (NAVGW 2.5.2.9) with SMTP id M2002072014413516736
 for <nfs@lists.sourceforge.net>; Sat, 20 Jul 2002 14:41:35 -0400
Received: from [129.98.90.227] (usseinstein.aecom.yu.edu [129.98.90.227])
	by post.aecom.yu.edu (8.9.3/8.9.3) with ESMTP id OAA22948
	for <nfs@lists.sourceforge.net>; Sat, 20 Jul 2002 14:41:34 -0400 (EDT)
In-Reply-To: <E17Vd5U-000143-00@usw-sf-list2.sourceforge.net>
To: nfs@lists.sourceforge.net
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

I am working with two clients (A and B) mounting a single directory 
via nfs from server C.

Client A is RedHat 7.3 using stock RedHat 2.4.18 kernel.
Client B is RedHat 7.2 using stock RedHat 2.4.7 kernel.
Server C is RedHat 7.1 using 2.4.18 kernel with NFS all patches.

Mounting is via tcp. The server uses iptables. A script extracts port 
information from rpcinfo -p to determine which nfs ports to permit 
into the server from the clients.

Issue #1: Even though I am mounting via tcp, apparently, I must 
permit udp access to the portmap daemon on the server via iptables, 
otherwise mount on the clients hang. Why is that?

Issue #2: At some point, I noticed that the server C's hostname has 
spontaneously changed to that of the client B! All options to the 
hostname command at server C's shell misidentify it as client B. What 
could possibly cause such weird behavior? The command prompt itself 
is affected of course. The uname command is also affected. The host 
command, which access external DNS servers, is not affected and I can 
seem to access the server via other network services (e.g, netatalk) 
on the server under its correct name. ( I don't know for sure that 
mounting nfs shares was somehow responsible for this, but it and 
iptables were the only things I had modified to get this working).
-- 

Maurice Volaski, mvolaski@aecom.yu.edu
Computing Support, Rose F. Kennedy Center
Albert Einstein College of Medicine of Yeshiva University


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
