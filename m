From: Mike Waychison <mike@waychison.com>
Subject: Re: [PATCH 1/2] VFS: New /proc file /proc/self/mountstats
Date: Wed, 23 Mar 2005 17:42:31 +0000 (UTC)
Message-ID: <loom.20050323T183257-779@post.gmane.org>
References: <20050317162613.756101BB98@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DEAej-0008GD-T8
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 10:32:37 -0800
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DEAei-00035M-6f
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 10:32:37 -0800
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1DEATb-0003FD-3z
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 19:21:07 +0100
Received: from ip22-176.tor.istop.com ([66.11.176.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Wed, 23 Mar 2005 19:21:07 +0100
Received: from mike by ip22-176.tor.istop.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Wed, 23 Mar 2005 19:21:07 +0100
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hi Chuck,

Chuck Lever <cel <at> citi.umich.edu> writes:

> 
> Create a new file under /proc/self, called mountstats, where mounted file
>  systems can export information (configuration options, performance counters,
>  and so on).  Use a mechanism similar to /proc/mounts and s_ops->show_options.
> 

> diff -X /home/cel/src/linux/dont-diff -Naurp 00-stock/fs/namespace.c
01-mountstats/fs/namespace.c

...

> +struct seq_operations mountstats_op = {
> +	.start	= ms_start,
> +	.next	= ms_next,
> +	.stop	= ms_stop,

You can use m_start, m_next and m_stop here instead of copying and pasting the
routines.  Otherwise looks fine.

Mike Waychison








-------------------------------------------------------
This SF.net email is sponsored by Microsoft Mobile & Embedded DevCon 2005
Attend MEDC 2005 May 9-12 in Vegas. Learn more about the latest Windows
Embedded(r) & Windows Mobile(tm) platforms, applications & content.  Register
by 3/29 & save $300 http://ads.osdn.com/?ad_id=6883&alloc_id=15149&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
