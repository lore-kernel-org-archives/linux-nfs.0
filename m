From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH] Make UDF exportable
Date: Thu, 7 Feb 2008 00:45:15 -0500
Message-ID: <20080207054515.GA14585__43857.1084211164$1202363175$gmane$org@infradead.org>
References: <1201726404.2976.8.camel@localhost.localdomain>
	<20080205102955.GA28347@infradead.org>
	<1202233464.12188.43.camel@localhost.localdomain>
	<20080206180850.GD3475@duck.suse.cz>
	<1202331482.2727.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>,
	nfs@lists.sourceforge.net
To: Rasmus Rohde <rohde-3mLe3WyXyAE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43032 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751649AbYBGFph (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 00:45:37 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JMzZn-0001Un-EF
	for linux-nfs@vger.kernel.org; Thu, 07 Feb 2008 16:45:35 +1100
In-Reply-To: <1202331482.2727.8.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 06, 2008 at 09:58:02PM +0100, Rasmus Rohde wrote:
> > > +	dotdot.d_name.name = "..";
> > > +	dotdot.d_name.len = 2;
> > > +
> > > +	lock_kernel();
> > > +	if (!udf_find_entry(child->d_inode, &dotdot, &fibh, &cfi))
> > > +		goto out_unlock;
> >   Have you ever tried this? I think this could never work. UDF doesn't have
> > entry named .. in a directory. You have to search for an entry that has
> > in fileCharacteristics set bit FID_FILE_CHAR_PARENT. Maybe you could
> > hack-around udf_find_entry() to recognize .. dentry and do the search
> > accordingly.
> Probably not. I just tested that I could read files and navigate the
> directory structure. However looking into UDF I think you are right - it
> will fail.
> I have extended udf_find_entry() to do an explicit check based on
> fileCharacteristics as you propose.
> How do I actually test this case?
> 
> >   Otherwise the patch looks fine. But please rediff the patch against
> > Andrew's development tree (or -mm) because there are some cleanups there...
> > Thanks.
> Certainly there are. New patch against 2.6.24-mm1:

There's still a few trivial warnings from scripts/checkpatch.pl that
should be fixed up:

ERROR: trailing whitespace
#88: FILE: fs/udf/namei.c:1323:
+^I$

ERROR: trailing whitespace
#92: FILE: fs/udf/namei.c:1327:
+^I^I$

ERROR: trailing whitespace
#185: FILE: fs/udf/namei.c:1420:
+^I^Ifid->udf.parent_partref = location.partitionReferenceNum;^I$

WARNING: externs should be avoided in .c files
#212: FILE: fs/udf/super.c:79:
+extern struct export_operations udf_export_ops;

total: 3 errors, 1 warnings, 218 lines checked


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

