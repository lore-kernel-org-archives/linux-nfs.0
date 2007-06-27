From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Question: When NFS client check dir's permission,
	it	does not check the cache data
Date: Tue, 26 Jun 2007 23:09:14 -0400
Message-ID: <1182913754.12836.61.camel@heimdal.trondhjem.org>
References: <467F8247.9060607@cn.fujitsu.com>
	<1182802099.6163.33.camel@heimdal.trondhjem.org>
	<4681BC44.6000605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3NuD-0008Ow-8V
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 20:09:23 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/w7poXZ7MV1Qtl0TA/PQougD6OBPzcit8=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3NuG-0000jn-5Q
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 20:09:24 -0700
In-Reply-To: <4681BC44.6000605@cn.fujitsu.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-06-27 at 09:24 +0800, Wei Yongjun wrote:

> I think code "status = nfs_access_get_cached(inode, cred, &cache);" can do
> this. And it works.
> Other question: why only optimize all write operations, read operations
> are not optimized? If read options is optimized, it can do the same things,
> do not use access to check permissions, and server will check permissions
> when we perform the read op.

Huh? What read operations are we failing to optimise and how?

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
