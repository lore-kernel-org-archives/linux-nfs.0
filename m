From: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
Subject: network socket buffers & file descriptor questions
Date: Fri, 19 Mar 2004 17:14:13 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <405B2A65.2080703@framestore-cfc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4NaW-000154-5z
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 09:15:16 -0800
Received: from gw.fs-cfc.co.uk ([193.203.83.22])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1B4NaM-0007gs-K3
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 09:15:06 -0800
Received: from localhost (localhost [127.0.0.1])
	by mail.admin.local (Postfix) with ESMTP id 67E53768FC5
	for <nfs@lists.sourceforge.net>; Fri, 19 Mar 2004 17:14:16 +0000 (GMT)
Received: from framestore-cfc.com (sys33.prod.local [172.18.10.33])
	by mail.admin.local (Postfix) with ESMTP id 6443471590D
	for <nfs@lists.sourceforge.net>; Fri, 19 Mar 2004 17:14:13 +0000 (GMT)
To: nfs@lists.sourceforge.net
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

Hi,

I wanted to clarify a couple of things that I've failed to understand 
fully after reading the FAQ, books, reading list archives and doing web 
searches.

Socket input buffers- some documentation I've read suggests that these 
are tuned dymanically for TCP but need to be manually tuned for UDP in
/proc/sys/net/core/rmem_default and rmem_max

Elsewhere I've read that "for kernels later than about 2.4.20-pre4, this 
setting is not needed and is ignored.  The nfsd code does 'the right 
thing'. The setting is only needed for earlier kernels."

Is this true for both UDP and TCP or only for TCP?


Second, what is the default amount of file descriptors available to 
rpc.mountd?

The man page that comes with nfs-utils 1.06 says "The default is to 
leave the limit unchanged." Older manpages seem to suggest that the 
limit was once 256. Is the number drawn from the default shell limit?


Thanks,

-- 
Johan van den Dorpe


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
