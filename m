From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Unlocked pages flushed
Date: Mon, 02 Jul 2007 08:34:08 -0400
Message-ID: <1183379648.6479.7.camel@heimdal.trondhjem.org>
References: <loom.20070702T122224-68@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Rajat <sharma.rajat@hcl.in>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5L6f-0001Py-GG
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 05:34:47 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18xi10K8aKgWJxlkEOG6vBb56JRw6B8mhI=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5L6g-0004jy-Lc
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 05:34:21 -0700
In-Reply-To: <loom.20070702T122224-68@post.gmane.org>
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

On Mon, 2007-07-02 at 10:51 +0000, Rajat wrote:
> Hi List,
> 
> While flushing the data through nfs_file_flush, I observed that pages are 
> being flushed in unlocked state. nfs_file_flush call graph reaches to 
> nfs_flush_one where the comment above this definition states "The page must 
> have been locked by the caller." However I have checked with PageLocked() call 
> that the pages which enter into nfs_flush_one are not locked. 
> 
> What I could make out of it is: this is done porbably to avoid deadlock with 
> other functions like prepare_write, commit_write, writepage, readpage where 
> page is grabbed first then lock_kernel (HEAVILY used in NFS) is called. 
> Whereas nfs_file_flush calls lock_kernel, then enters into nfs_wb_all. So, to 
> avoid deadlock, logical place for lock_page loop would have been in 
> nfs_file_flush before lock_kernel (still not sure about this, will it help?). 
> 
> Here we are flushing pages without honouring page_lock OR am I going wrong 
> somewhere???
> 
> Rajat

When you hit contention on a mutex or page lock, that puts the process
to sleep: at that point the BKL is automatically released, and so no
deadlock occurs.

IOW: it is impossible to get the BKL to ABBA deadlock with any form of
"sleeping lock".

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
