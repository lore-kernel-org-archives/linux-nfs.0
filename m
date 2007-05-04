From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/18] export operations rewrite
Date: Fri, 4 May 2007 16:49:50 +1000
Message-ID: <17978.55182.198497.902215@notabene.brown>
References: <20070317010946.GA24947@infradead.org>
	<17932.34141.590792.120454@notabene.brown>
	<20070501103905.GA30906@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjrcV-0003Qv-5J
	for nfs@lists.sourceforge.net; Thu, 03 May 2007 23:50:23 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjrcX-0000sW-Jm
	for nfs@lists.sourceforge.net; Thu, 03 May 2007 23:50:25 -0700
In-Reply-To: message from Christoph Hellwig on Tuesday May 1
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

On Tuesday May 1, hch@infradead.org wrote:
> On Fri, Mar 30, 2007 at 01:34:53PM +1000, Neil Brown wrote:
> > On Saturday March 17, hch@infradead.org wrote:
> > 
> > less that 2 weeks later....
> 
> more than one month later.... :)
> 

Thanks for your explanations.

>  - the calling conversion on the decode side where we first call
>    ->decode_fh to split the filehandle into two blobs only to
>    recurse back into exportfs and then recurse back into the filesystem
>    seems rather odd.  By having two methods to get the dentry and
>    parent directly from the on the wire file handle this big callstack
>    collapses to a very simple one.

This is the bit I was particularly missing.  I see now how this aspect
was awkward before, and how your changes make the flow clearer.

Getting rid of s_export_op->find_exported_dentry is something I'm very
happy about.  There was actually bug lurking there that I never got
around to fixing.  The code:
-	/* Ok, we can export it */;
-	if (!inode->i_sb->s_export_op->find_exported_dentry)
-		inode->i_sb->s_export_op->find_exported_dentry =
-			find_exported_dentry;

assumes that the address of find_exported_dentry will never change.
But if you unload nfsd.ko, then re-load it. it could be different, yet a
filesystem could still have to old value in it's s_export_op.  That
would be bad.
I'm glad it is gone.

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
