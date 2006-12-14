From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: asynchronous locks for cluster exports
Date: Thu, 14 Dec 2006 17:51:27 -0500
Message-ID: <20061214225127.GA5147@fieldses.org>
References: <11653832602203-git-send-email-bfields@fieldses.org>
	<20061207165108.GA21009@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuzQP-0008IN-1v
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 14:51:37 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GuzQQ-0004MJ-91
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 14:51:38 -0800
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061207165108.GA21009@infradead.org>
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

On Thu, Dec 07, 2006 at 04:51:08PM +0000, Christoph Hellwig wrote:
> On Wed, Dec 06, 2006 at 12:34:10AM -0500, J. Bruce Fields wrote:
> > We'd like an asynchronous posix locking interface so that we can provide NFS
> > 	- We added a new ->lock() export operation, figuring this was a feature
> > 	  that only lockd and nfsd care about for now, and that we'd rather not
> > 	  muck about with common locking code.  But the export operation is
> > 	  pretty much identical to the file ->lock() operation; would it make
> > 	  more sense to use that?
> 
> This definitly needs to be merged back into the ->lock file operation

So the interesting question is whether we can merge the semantics in a
reasonable way.  The export operation implemented by the current version
of these patches returns more or less immediately with success, -EAGAIN,
or -EINPROGRESS; in the latter case the filesystem later calls fl_notify
to communicate the results.  The existing file lock operation normally
blocks until the lock is actually granted.

The one file lock operation could do both, and just switch between the
two cases depending on whether fl_notify is defined.  Would the
semantics be clear enough?

I find the existing use of ->lock() a little odd as it is; stuff like this,
from fcntl_getlk():

	if (filp->f_op && filp->f_op->lock) {
		error = filp->f_op->lock(filp, F_GETLK, &file_lock);
		if (file_lock.fl_ops && file_lock.fl_ops->fl_release_private)
			file_lock.fl_ops->fl_release_private(&file_lock);
		if (error < 0)
			goto out;
		else
			fl = (file_lock.fl_type == F_UNLCK ? NULL : &file_lock);
	} else {
		fl = (posix_test_lock(filp, &file_lock, &cfl) ? &cfl : NULL);
	}

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
