From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsd write throughput
Date: Tue, 3 Aug 2004 12:23:51 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16654.63287.965253.5762@cse.unsw.edu.au>
References: <20040802162448.GB21365@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Broy8-0006dO-TC
	for nfs@lists.sourceforge.net; Mon, 02 Aug 2004 19:24:00 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Broy8-0003tj-9D
	for nfs@lists.sourceforge.net; Mon, 02 Aug 2004 19:24:00 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: message from Olaf Kirch on Monday August 2
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Monday August 2, okir@suse.de wrote:
> Hi,
> 
> I've been looking at the write throughput with NFSv3, and played around
> a little. Here's a patch that seems to increase iozone's write throughput
> from 6MB/s to close to 10MB/s on my test machine.
> 
> (The improvement in rewrite throughput is less pronounced). I'm still
> doing some testing on this, but I would still appreciate some feedback,
> especially from people seeing throughput problems.

Interesting idea, and probably worth pursuing, but it does look rather
"hackish".

The comment sounds very filesystem-specific.  Which filesystem(s) are
you testing this with? ext3?

It would be nice if this sort of functionality could go in the
filesystem.  ext3 already has a tunable for the commit_interval
("commit=").  It seems like what you are wanting is a similar tunable
that is measured in blocks rather than seconds.  Would that be right?
or have I missed something important.

NeilBrown

> 
> Olaf
> -- 
> Olaf Kirch     |  The Hardware Gods hate me.
> okir@suse.de   |
> ---------------+ 
> Index: linux-2.6.5/fs/nfsd/vfs.c
> ===================================================================
> --- linux-2.6.5.orig/fs/nfsd/vfs.c	2004-08-02 14:48:02.000000000 +0200
> +++ linux-2.6.5/fs/nfsd/vfs.c	2004-08-02 17:54:28.000000000 +0200
> @@ -45,6 +45,7 @@
>  #include <linux/quotaops.h>
>  #include <linux/dnotify.h>
>  #include <linux/xattr_acl.h>
> +#include <linux/backing-dev.h>
>  
>  #include <asm/uaccess.h>
>  
> @@ -810,6 +811,22 @@
>  		}
>  		last_ino = inode->i_ino;
>  		last_dev = inode->i_sb->s_dev;
> +	} else if (err >= 0 && !stable) {
> +		/* If we've been writing several pages, schedule them
> +		 * for the disk immediately. The client may be streaming
> +		 * and we don't want to hang on a huge journal sync when the
> +		 * commit comes in
> +		 */
> +		struct address_space	*mapping;
> +
> +		/* This assumes a minimum page size of 1K, and will issue
> +		 * a filemap_flushfast call every 64 pages written by the
> +		 * client. */
> +		if ((cnt & 1023) == 0
> +		 && ((offset / cnt) & 63) == 0
> +		 && (mapping = inode->i_mapping) != NULL
> +		 && !bdi_write_congested(mapping->backing_dev_info))
> +			filemap_flushfast(mapping);
>  	}
>  
>  	dprintk("nfsd: write complete err=%d\n", err);


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
