From: Juan Gomez <juang@us.ibm.com>
Subject: Clustered NAS Heads and mountd issues
Date: Mon, 14 Oct 2002 13:51:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF423378B1.6C9ABFCC-ON87256C52.0071E6CF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e32.co.us.ibm.com ([32.97.110.130])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 181CCk-0001xm-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 13:52:46 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.194.23])
	by e32.co.us.ibm.com (8.12.2/8.12.2) with ESMTP id g9EKpFpw025370
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 16:51:15 -0400
Received: from d03nm694.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.193.82])
	by westrelay02.boulder.ibm.com (8.12.3/NCO/VER6.4) with ESMTP id g9EKpEcK213332
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 14:51:14 -0600
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


I think there has been some previous chatter on this via this list so let
me try to bring it back and see if we could agree on what to include in the
distribution:

I wish NFS mountd daemons could issue a notification every time they update
the local rmtab (i.e. receive mount/umount etc) so that mountd dameons in
 different hosts could share a single rmtab and remain in sync.

Anyone has an idea of an interface that will be general enough to be used
by any type of NAS clustering software?

Could we register RPC callbacks with mountd so it would call remote
daemons? or is there a better suggestion? is there any patch already in the
queue to
 do something along these lines?


Juan



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
