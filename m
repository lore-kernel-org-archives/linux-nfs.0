From: Rudi Starcevic <tech@wildcash.com>
Subject: NFS Clients Increase
Date: Fri, 01 Apr 2005 02:26:41 +1000
Message-ID: <424C24C1.40808@wildcash.com>
Reply-To: tech@wildcash.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DH2VJ-0001vE-5e
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 08:26:45 -0800
Received: from mail6.tpgi.com.au ([203.12.160.113] helo=mail.tpgi.com.au)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DH2VI-0002Ch-Hi
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 08:26:45 -0800
Received: from [192.168.1.1] (220-245-99-226-qld-pppoe.tpgi.com.au [220.245.99.226])
	(authenticated bits=0)
	by mail.tpgi.com.au (8.12.10/8.12.10) with ESMTP id j2VGQfgs032103
	for <nfs@lists.sourceforge.net>; Fri, 1 Apr 2005 02:26:41 +1000
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

I am using FreeBSD as and NFS server and Debian Linux as two clients.

These clients are www servers and mount 1TB from the NFS server.

I'm trying to tune for higher performance.

I can find info and have increased the nfsd daemons to 16.
This is a high as I can get it to go.
Can I go higher?

On the Linux client I have no been able to find how I can increase the max
number of connecting client daemons.

Can anyone please advise on how to increase the limit for client 
daemons, biod, with Linux?

Many thanks.
Kind regards,
Rudi


-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
