From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH] Make UDF exportable
Date: Wed, 6 Feb 2008 22:37:51 -0500
Message-ID: <20080207033751.GA26792__48615.3490645394$1202355530$gmane$org@infradead.org>
References: <1201726404.2976.8.camel@localhost.localdomain>
	<20080205102955.GA28347@infradead.org>
	<1202233464.12188.43.camel@localhost.localdomain>
	<20080206180850.GD3475@duck.suse.cz>
	<1202331482.2727.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>
To: Rasmus Rohde <rohde-3mLe3WyXyAE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:47781 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753406AbYBGDiN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 22:38:13 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JMxaT-00014E-P8
	for linux-nfs@vger.kernel.org; Thu, 07 Feb 2008 14:38:09 +1100
In-Reply-To: <1202331482.2727.8.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 06, 2008 at 09:58:02PM +0100, Rasmus Rohde wrote:
> Probably not. I just tested that I could read files and navigate the
> directory structure. However looking into UDF I think you are right - it
> will fail.
> I have extended udf_find_entry() to do an explicit check based on
> fileCharacteristics as you propose.
> How do I actually test this case?

Testing this is pretty hard.  You export a filesystem, then cd somewhere
deep into a directory hiearchy in there.  Then unexport the filesystem
and unmount on the server.  mount it back on the server, export it again
and do something with a file from the directory you've cd into before
the unmount.  Make sure you have a printk in your get_parent method
to make sure you're really hitting it.

Btw, I think it would be nicer to opencode the .. lookup in get_parent
instead of changing udf_find_entry.  The lookup for .. is not needed
by anything else, and get_parent only looks for it so it's a natural
place to opencode it there.


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

