From: "Michael R. Hudson" <michael_hudson@hp.com>
Subject: rpc.statd problem
Date: Thu, 15 May 2003 10:42:21 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EC3C36D.5040304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from atlrel9.hp.com ([156.153.255.214])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GLoI-0004g3-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 09:42:26 -0700
Received: from fczirkel.fc.hp.com (fczirkel.fc.hp.com [15.2.243.76])
	by atlrel9.hp.com (Postfix) with ESMTP id B5B571C01B64
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 12:42:22 -0400 (EDT)
Received: from hp.com (localhost.localdomain [127.0.0.1])
	by fczirkel.fc.hp.com (Postfix) with ESMTP id 4E36134164
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 12:42:22 -0400 (EDT)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



We're seeing the following problem with rpc.statd:

rpc.statd[13093]: Version 1.0.1 Starting
rpc.statd[13094]: my_svc_run() - select: Bad file descriptor

Two questions:
When and how can the above problem happen?
What does it mean?

We've got nfsutils-1.0.1 and kernel 2.4.17.

Thanks
-- 
michael.hudson@hp.com|"Climb the mountains and get their good tidings;
HP Loveland	     | Nature's peace will flow into you
970-898-3259	     |    as sunshine into flowers;
		| the winds will blow their freshness into you,
		| and the storms, their energy -- and cares
		| will drop off like autumn leaves." - John Muir



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
