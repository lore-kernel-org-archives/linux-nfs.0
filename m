From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Eliminating the BKL from the NFS and RPC clients
Date: Fri, 19 Jan 2007 01:23:49 +0000
Message-ID: <20070119012349.GA25491@infradead.org>
References: <45B00585.10001@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7iTy-0002hC-Ih
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 17:23:54 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7iTy-0001XD-VM
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 17:23:56 -0800
To: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <45B00585.10001@oracle.com>
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



056-nfs-smp-change_attribute.diff: 
	are the barriers really enough?  Don't you need at least a lock on 
	the writer side?
		        

057-noattr_flag.diff:
	I don't really like this approach.  Can we make touch_atime
	and file_update_time go ghrough ->setattr instead?  Having all
	attribute updates going through setattr would fix up quite a
	lot of mess we have, also in other filesystems like xfs.
	In either case this really needs to go through -fsdevel

059-nfs-serialize-change_attr.diff:
	Please don't spread all these CONFIG_NFS_V4 around, they don't really
	seem to help much.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
