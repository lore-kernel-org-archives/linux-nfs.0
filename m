From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs_readpage
Date: Mon, 25 Jun 2007 15:42:40 -0400
Message-ID: <1182800560.6163.20.camel@heimdal.trondhjem.org>
References: <loom.20070625T172031-300@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Rajat <sharma.rajat@hcl.in>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I2uSX-00039Z-MP
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 12:42:49 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18ooGJc/leGPPjpys5m+oX/1Q3eDRunk4U=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I2uSa-0006eU-Ql
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 12:42:53 -0700
In-Reply-To: <loom.20070625T172031-300@post.gmane.org>
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

On Mon, 2007-06-25 at 15:58 +0000, Rajat wrote:
> Hi,
> 
> I was vading through NFS read calls, and found a call to nfs_wb_page is made 
> to flush any pending writes, in nfs_readpage function. However all pending 
> writeback requests in nfs radix tree are set as PG_uptodate.

Wrong. If you write a partial page, then that will not be marked as
PG_uptodate.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
