From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/14] NFS/RPC client patches for 2.6.21
Date: Thu, 18 Jan 2007 18:23:56 -0500
Message-ID: <20070118232356.23310.6705.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7ghi-0002ic-EU
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:29:58 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7ghj-0004Bf-Rb
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:30:00 -0800
To: trond.myklybust@fys.uio.no
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

Hi Trond-

I'd like you to consider these for 2.6.21.  These include the new kernel
rpcbind client that supports versions 3 and 4 of the rpcbind protocol,
patches to fix tk_pid printk formatting, several patches that fix up RPC
buffer allocation, and a patch that makes rpc_show_tasks output more
readable by converting absolute function addresses to names.

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
