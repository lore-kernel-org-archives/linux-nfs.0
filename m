From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Eliminating the BKL from the NFS and RPC clients
Date: Fri, 19 Jan 2007 00:36:20 -0500
Message-ID: <1169184980.6158.19.camel@lade.trondhjem.org>
References: <45B00585.10001@oracle.com> <20070119012349.GA25491@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7mQl-0003hw-MW
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 21:36:52 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/86uRwrp0+7FOyYjbpQ1+0Xn8NP6MBDpM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7mQl-0002dz-0U
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 21:36:53 -0800
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20070119012349.GA25491@infradead.org>
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

On Fri, 2007-01-19 at 01:23 +0000, Christoph Hellwig wrote:
> 
> 056-nfs-smp-change_attribute.diff: 
> 	are the barriers really enough?  Don't you need at least a lock on 
> 	the writer side?

The change attribute should always be updated under the inode->lock
anyway. I'm not really sure we need these.


> 057-noattr_flag.diff:
> 	I don't really like this approach.  Can we make touch_atime
> 	and file_update_time go ghrough ->setattr instead?  Having all
> 	attribute updates going through setattr would fix up quite a
> 	lot of mess we have, also in other filesystems like xfs.
> 	In either case this really needs to go through -fsdevel

No. Attributes may change at any moment on the server. That is _very_
different to the case where the user or the client changes the
attributes via setattr. For one thing, we don't have to notify the
server. Secondly, we do want to be able to update those attributes from
asynchronous contexts (for instance when a WRITE request returns with
updated).
The client should in any case _never_ be overriding the server
attributes. The only exception to that rule is if we have cached writes
which change the file size. We do try to detect that...

> 059-nfs-serialize-change_attr.diff:
> 	Please don't spread all these CONFIG_NFS_V4 around, they don't really
> 	seem to help much.

ACK.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
