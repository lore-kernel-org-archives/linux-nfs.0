From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Make sure unlock is really an unlock
	when	cancelling a lock
Date: Wed, 13 Jun 2007 12:35:11 -0400
Message-ID: <1181752511.6151.5.camel@heimdal.trondhjem.org>
References: <1181581269.8988.42.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HyVoY-0001wo-9v
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 09:35:22 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1928uTxgHivUGQQm7hcv35dOpUl5rOAwoc=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HyVoT-0007oK-JP
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 09:35:20 -0700
In-Reply-To: <1181581269.8988.42.camel@dyn9047022153>
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

On Mon, 2007-06-11 at 10:01 -0700, Frank Filz wrote:
> I ran into a curious issue when a lock is being canceled. The
> cancellation results in a lock request to the vfs layer instead of an
> unlock request. This is particularly insidious when the process that

Any idea why the cancellation turns into a lock request? I really don't
want to apply a patch that just appears to paper over the problem.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
