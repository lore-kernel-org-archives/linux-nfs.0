From: Andrew Theurer <habanero@us.ibm.com>
Subject: RPC error on NFS over TCP
Date: Mon, 25 Mar 2002 18:05:03 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200203260016.SAA38018@popmail.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Received: from mg02.austin.ibm.com ([192.35.232.12])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16pedv-0000tM-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 16:16:51 -0800
Received: from austin.ibm.com (netmail2.austin.ibm.com [9.3.7.139])
	by mg02.austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id SAA34498
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 18:26:29 -0600
Received: from popmail.austin.ibm.com (popmail.austin.ibm.com [9.53.247.178])
	by austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id SAA29616
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 18:16:48 -0600
Received: from there (crashandburn.austin.ibm.com [9.53.216.41]) by popmail.austin.ibm.com (AIX4.3/8.9.3/8.7-client1.01) with SMTP id SAA38018 for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 18:16:48 -0600
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

Has anyone seen this client error before?
RPC: TCP connect error 104!

I get it sometimes when I try to mount an NFS fs from my clients to linux 
server.  This also happens on an NFS read test I have.  This does not happen 
on UDP.  All the clients eventually get what they want, but usually after a 
couple minute delay.  

The linux server is kernel 2.4.18 (with Neil's patches) and sometimes 2.5.7.  
The clients (48 of them) are mostly just RH-2.4.2-2 and one is 2.5.7 (happens 
on both kernels).  There are no dropped packets reported on ifconfig.  There 
are RPC retransmits on the clients.  Any ideas?

-Andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
