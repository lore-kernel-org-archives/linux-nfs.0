From: Christoph Biardzki <Christoph.Biardzki@lrz-muenchen.de>
Subject: nfsd hangs on 2.4.20 + 2.4.20_NFS_ALL patch + sched.c patch
Date: Mon, 12 May 2003 11:26:46 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EBF68D6.8050506@lrz-muenchen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailrelay1.lrz-muenchen.de ([129.187.254.101])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19F9bQ-0000nD-00
	for <nfs@lists.sourceforge.net>; Mon, 12 May 2003 02:28:12 -0700
Received: from [129.187.15.183] by mailout.lrz-muenchen.de with ESMTP for nfs@lists.sourceforge.net; Mon, 12 May 2003 11:26:47 +0200
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


Hello,


we are running an NFS server with 2.4.20 with the NFS_ALL patchset from 
Trond's site and the sched.c-patch from the list. There are ~150 clients 
all running 2.4.20. Occasionally nfsd on the server will hang and become 
unavailable to the clients (eg. the showmount command on ther server 
hangs). The only resolution is to reboot the server.

As the problem does not occur very often we did not have the opportunity 
to examine it closely but still I would like to know whether there are 
known problems with this configuration and how we can provide useful 
debug information to pinpoint the problem?


Regards,

   - Christoph


-- 
Leibniz Computing Center
Munich, Germany




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
